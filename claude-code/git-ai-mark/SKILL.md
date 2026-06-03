---
name: git-ai-mark
description: 手动将指定文件/行范围标记为 AI 生成的代码归属（操作 git-ai notes）
trigger: /ai-mark
---

# /ai-mark

手动将指定代码标记为 AI 生成，写入 git-ai 归属数据（git notes/ai）。

## Usage

```
/ai-mark <file> [startLine-endLine] [--commit <sha>] [--model <model>] [--tool <tool>]
/ai-mark --commit <sha>                    # 标记该 commit 所有新增行
/ai-mark --commit <sha> --file <path>      # 标记该 commit 中指定文件的所有新增行
```

### 参数说明

| 参数 | 必填 | 说明 |
|------|------|------|
| `<file>` | ❌ | 相对于仓库根的文件路径（省略则标记 commit 中所有文件） |
| `[startLine-endLine]` | ❌ | 行号范围，省略则自动从 diff hunk 提取 |
| `--commit <sha>` | ❌ | 目标 commit，默认 HEAD |
| `--model <model>` | ❌ | 模型名称，默认 `claude-opus-4-8` |
| `--tool <tool>` | ❌ | 工具名称，默认 `claude` |

### 示例

```
/ai-mark --commit 0930bc64                    # 整个 commit 标记为 AI
/ai-mark --commit abc1234 --file src/Xxx.java # 只标记该文件
/ai-mark src/Xxx.java 100-150                 # HEAD 中指定行范围
/ai-mark src/main.java 1-50 --model gpt-4o --tool cursor
```

## 执行流程

### Step 1: 解析参数

从用户输入中提取：
- `FILE_PATH` — 文件路径（可选，省略则处理 commit 中所有文件）
- `LINE_RANGES` — 行号范围列表（可选）
- `COMMIT_SHA` — 目标 commit（默认 HEAD）
- `MODEL` — 模型名（默认 claude-opus-4-8）
- `TOOL` — 工具名（默认 claude）

### Step 2: 获取 diff 中的真实文件路径和行号

**关键**：文件路径必须与 `git show` 输出的 diff 路径完全一致。

```powershell
# 获取 commit 中变更的文件列表（真实路径）
git show <commit> --format="" --name-only

# 获取每个文件的 hunk headers（提取新增行范围）
git show <commit> --format="" --unified=0 -- <file> | Select-String "^@@"
```

从 hunk header `@@ -old,count +new,count @@` 中提取 `+new,count`：
- `start = new`
- `end = new + count - 1`

如果用户指定了行号范围，则只使用用户指定的范围（但仍需验证文件路径）。

### Step 3: 读取现有 notes

```powershell
git notes --ref=ai show <commit> 2>$null
```

- 如果已有 notes → 解析，追加新条目
- 如果没有 notes → 创建全新结构

### Step 4: 构建归属数据

生成 ID：
```
SESSION_ID = "s_" + random_hex(14)       # 一个 session 对应一次标记操作
TOOL_ID    = "t_" + random_hex(14)       # 每个 hunk 一个独立 tool_id
```

**Notes 格式**（schema 3.0.0，已验证可被 git-ai stats 识别）：

```
<file_path_from_diff>
  <session_id>::<tool_id_1> <start1>-<end1>
  <session_id>::<tool_id_2> <start2>-<end2>
  ...
<another_file_path>
  <session_id>::<tool_id_3> <start3>-<end3>
---
{
  "schema_version": "authorship/3.0.0",
  "git_ai_version": "1.5.2",
  "base_commit_sha": "<full_commit_sha>",
  "prompts": {},
  "sessions": {
    "<session_id>": {
      "agent_id": {
        "tool": "<tool>",
        "id": "<random_uuid>",
        "model": "<model>"
      },
      "human_author": "<git user.name> <<git user.email>>"
    }
  }
}
```

### Step 5: 写入 git notes

**必须用临时文件 + `-F` 参数**（`-m` 不支持多行内容）：

```powershell
$tmpFile = [System.IO.Path]::GetTempFileName()
# 必须 UTF-8 无 BOM，否则 git-ai 无法解析
[System.IO.File]::WriteAllText($tmpFile, $noteBody, [System.Text.UTF8Encoding]::new($false))
git notes --ref=ai add -f -F $tmpFile <commit>
[System.IO.File]::Delete($tmpFile)
```

### Step 6: 验证

```powershell
& "D:/MyConfiguration/fl13011/.git-ai/bin/git-ai.exe" stats <commit> --json
```

确认 `ai_additions` 数量符合预期。成功标准：
- `ai_additions` > 0
- `unknown_additions` = 0（如果标记了所有新增行）

向用户报告：标记了多少行、哪些文件、归属到哪个模型。

## 合并已有 notes 的规则

如果目标 commit 已有 ai notes：
1. 先用 `git notes --ref=ai show <commit>` 读取现有内容
2. 解析为两部分：`---` 之前是文件行映射，之后是 JSON
3. **文件行映射区**：追加新条目（同一文件下追加新行，新文件另起一行）
4. **JSON sessions**：追加新 session，保留已有 session 不动
5. 重新组装完整内容后写入

## 撤销操作

```powershell
# 删除某个 commit 的所有 AI 归属
git notes --ref=ai remove <commit>

# 推送到远端
git push origin refs/notes/ai
```

## 已验证的关键约束

| 约束 | 说明 |
|------|------|
| 文件路径 | 必须与 `git show --name-only` 输出完全一致 |
| 行号 | 必须是 diff `+` 侧的行号（文件中的绝对行号） |
| 编码 | UTF-8 无 BOM（PowerShell 默认 Out-File 会加 BOM，不可用） |
| 写入方式 | 必须用 `-F <file>` 不能用 `-m`（多行内容会被拆分为多参数） |
| tool_id | 每个 hunk/行范围一个独立 ID |
| session_id | 同一次标记操作共享一个 session |
