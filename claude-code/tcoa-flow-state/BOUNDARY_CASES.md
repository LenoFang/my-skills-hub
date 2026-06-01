# TCOA 流程边界场景手册

> 本文档是 `tcoa-flow-state/SKILL.md` §六 的扩展。所有 tcoa-* skill 在遇到边界场景时必须按本手册处理，不得自行决策。

## 1. trivial 改动（快速路径）

### 1.1 判定信号
以下任一命中即为 trivial：
- 用户说：改个文案 / 改个 bug / 加个日志 / 改个变量名 / typo / 改注释
- 预估改动 ≤30 行 + 单文件 + 无新增依赖 + 无接口变化
- 用户明确说"快速改一下 / 简单改一下 / 别走流程"

### 1.2 处理流程
```
tcoa-router → tcoa-context (判定 changeSize=trivial)
            → AskUserQuestion: "这看起来是 trivial 改动，是否走快速路径（跳过需求初始化，直接改 + 轻量 review + 可选提交）？"
            → 用户确认 → 直接修改代码 → tcoa-review (quick 模式) → 可选 tcoa-git-flow
            → 用户拒绝 → 走标准 small 流程
```

### 1.3 状态机处理
- 不创建需求目录
- 不写 `.tcoa/current-context.json`
- 仅在用户同意提交时记录到全局 `.claude/scripts/tcoa-trivial-log.json`（可选）
- review 仍然要做（最小检查项），但 reviewStatus.required 可由用户确认置 false

### 1.4 PreToolUse hook 配合
- hook 检测到 changeSize=trivial 且 reviewStatus.required=false → 放行 git commit
- 仍禁止 --force / --no-verify

---

## 2. 续跑判定（已有 current-context.json）

### 2.1 关键词重叠算法
```
# 伪代码
userKeywords = extractKeywords(userInput)  # 去停用词，取词根
contextKeywords = extractKeywords(currentContext.name + currentContext.slug)
overlap = len(userKeywords ∩ contextKeywords)

if overlap >= 2 OR userInput contains "继续/接着/上次":
    intentMatch = "续跑"
elif overlap == 0 OR userInput contains "新需求/新建/另一个":
    intentMatch = "新需求"
else:
    intentMatch = "不确定"  # 必须 AskUserQuestion
```

### 2.2 边界处理
| 场景 | 处理 |
|---|---|
| 用户说"还是继续之前的" | 续跑，无需询问 |
| 用户描述完全无关业务模块 | AskUserQuestion 确认是否归档当前需求 |
| current-context.json 指向的目录已删除 | 自动清理 current-context.json，提示用户 |
| 当前 phase = `completed` 且用户提新需求 | 自动判定为新需求，无需询问 |
| 当前 phase = `paused` | 询问：恢复当前需求 / 归档后新建 / 暂不处理 |

---

## 3. review 失败回流

### 3.1 失败次数追踪
`execution-state.json` 必须维护 `reviewFailCount` 字段：
```json
{
  "reviewStatus": {
    "required": true,
    "completed": false,
    "result": "failed",
    "reviewFailCount": 1,
    "findings": [...]
  }
}
```

### 3.2 流转规则
| reviewFailCount | 处理 |
|---|---|
| 1 | 自动回到 `executing-auto` 或 `executing-manual`（根据原 mode） |
| 2 | 自动回到执行 phase，但**强制切换为 manual 模式** |
| ≥ 3 | phase 保持 `review-failed`，AskUserQuestion 强制人工介入 |

### 3.3 修复后再 review
- 修复完成后 phase 必须重新走 `awaiting-review → reviewing`
- 不允许直接从 `executing-*` 跳到 `review-passed`

---

## 4. 模式切换

### 4.1 auto → manual
触发：执行中用户说"还是一步步来吧 / 我要看每一步"

处理：
1. 当前操作完成（不中途打断）
2. 写 phase = `executing-manual`
3. skillChain 追加 `{skill: "mode-switch", from: "auto", to: "manual"}`
4. changelog.md 记录
5. 后续步骤进入 manual-guide 的对应确认点

### 4.2 manual → auto
触发：执行中用户说"剩下的全自动 / 不用每步问了"

处理：
1. 已确认的步骤不重做
2. 写 phase = `executing-auto`
3. skillChain 追加切换记录
4. 后续步骤进入 auto-execute 路径

---

## 5. Git 操作失败

### 5.1 push 失败
| 失败类型 | 处理 |
|---|---|
| 网络错误 / 超时 | phase 保持 `git-flowing`，提示用户重试 |
| 权限拒绝 | phase 保持 `git-flowing`，提示用户检查 SSH/token |
| 非 fast-forward | AskUserQuestion：pull rebase / pull merge / 取消 |
| pre-push hook 拒绝 | 显示 hook 错误，phase 退回 `awaiting-git`，禁止 --no-verify |

### 5.2 merge 冲突
1. phase 退回 `awaiting-git`
2. 列出冲突文件清单
3. AskUserQuestion：用户人工解决 / 取消合并 / abort
4. **绝不**使用 `-X theirs/ours` 或 `git reset --hard` 自动解决
5. 用户人工解决后，再次 AskUserQuestion 是否继续合并

### 5.3 commit hook 失败
1. 显示完整 hook 输出
2. phase 保持 `awaiting-git`
3. 修复后**创建新 commit**，禁止 --amend
4. 禁止 --no-verify 绕过

---

## 6. 多需求并行

### 6.1 当前不支持
TCOA 流程默认假设同一会话内只跟踪一个需求。`.tcoa/current-context.json` 是单值。

### 6.2 用户同时处理多需求时
- 提示用户：建议在不同 worktree 或不同会话中处理
- 或显式调用 `/tcoa pause` 暂停当前 → 切换到另一个需求 → 后续 `/tcoa resume`

---

## 7. 状态文件损坏 / 不一致

### 7.1 检测时机
- `tcoa-context` 加载时
- SessionStart hook 加载时

### 7.2 不一致场景
| 场景 | 处理 |
|---|---|
| current-context.json 存在，但 requirementPath 不存在 | 提示用户清理或重建 |
| execution-state.json phase 字段非法 | 中断流程，AskUserQuestion 让用户选择重置或修复 |
| skillChain 出现循环 | 警告但不阻塞，记录到 changelog |
| reviewStatus 与 phase 矛盾（如 phase=review-passed 但 result=failed） | 中断，要求用户人工核对 |

### 7.3 重置流程
用户选择重置时：
1. AskUserQuestion 二次确认
2. 备份原文件到 `<requirementPath>/.backup-<timestamp>/`
3. 清空 `.tcoa/current-context.json`
4. 不删除需求目录本身

---

## 8. 用户中断 / 暂停

### 8.1 显式暂停
用户说"先停一下 / 暂停 / 等会儿再做" → `/tcoa pause` 或自动写 phase = `paused`

### 8.2 隐式中断（用户切换话题）
- skill 不主动写 phase = `paused`
- 但下一次进入 `tcoa-context` 时若发现已过 24 小时未更新，主动询问是否恢复

### 8.3 恢复
`/tcoa resume` → 读取 `previousPhase` → AskUserQuestion 确认恢复点

---

## 9. 工具链外部失败

### 9.1 OpenSpec 不可用
- 降级为仅 GSD
- 写入 degradations
- changeSize=large 时**强制 AskUserQuestion**：是否接受降级

### 9.2 Superpowers 不可用
- 直接跳过
- 写入 degradations

### 9.3 GSD 失败
- 阻塞，phase → `paused`
- AskUserQuestion：重试 / 切换工具 / 中断需求

---

## 10. 适用范围说明

本手册不覆盖以下场景（属于 CLAUDE.md 或其他规则）：
- Java/前端编码规范
- 数据库迁移流程
- GitNexus 索引刷新
- CI/CD 配置

这些由各自的 skill 或规则文档处理。tcoa-* skill 只负责需求生命周期与状态机。
