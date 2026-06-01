# tcoa-router REFERENCE

> 本文件是 `tcoa-router/SKILL.md` 的详细补充参考，按需读取。

## 触发关键词完整列表

| 类型 | 关键词 |
|---|---|
| 显式 | `/tcoa`、`tcoa-router`、`tcoa 流程`、`走 tcoa` |
| 需求型 | `新需求`、`继续需求`、`接着做`、`帮我实现`、`帮我做`、`完成这个` |
| 模式型 | `全自动`、`半自动`、`一步步`、`不用确认`、`每步确认` |
| 工具型 | `OpenSpec`、`Superpowers`、`GSD` |
| 操作型 | `改 bug`、`修复`、`优化`、`重构`、`新功能`、`方案设计`、`生成任务` |
| 调试型 | `调试`、`排查`、`debug`、`报错`、`异常`、`不工作`、`出问题`、`查原因` |

## 多需求路由详细逻辑（step 1）

schemaVersion=2 时的完整分支：

```
active 为空 → 视为 phase=uninitialized，进入 step 2
active 只有 1 个 → 自动作为 focused，进入 step 2
active 有多个 + 用户明确指定了某需求（关键词/名称匹配）→ 切换 focused，进入 step 2
active 有多个 + 用户说"新需求" → 直接进入 step 2（intentMatch=新需求）
active 有多个 + 用户说"继续"但未指明哪个 → AskUserQuestion 展示列表让用户选择
active 有多个 + 用户意图不明 → AskUserQuestion 展示列表 + "新建需求"选项
```

### AskUserQuestion 展示格式
列出每个 active 需求：`[requirementId] <name> — phase: <phase>（<updatedAt>）`
加一个"新建需求"选项（仅当用户意图不明时）。

## changeSize 分级处理详细（step 4）

| changeSize | init 产物 | 工具链 | review 级别 |
|---|---|---|---|
| trivial | 跳过 init | 直接改 | 轻量 review |
| small | 仅 tasks.md | GSD | 标准 review |
| medium | 完整 init | 工具链 | 标准 review |
| large | 完整 init | OpenSpec + Superpowers + GSD | 严格 review |

## 工具识别规则详细

> 工具的 `installed` 状态和实际命令定义在 `.tcoa/command-registry.json` 中。
> 本 skill 仅做工具标签识别（tools 数组），实际命令解析由下游 `tcoa-execute` 从注册表读取。

- 明确提到 `OpenSpec` → tools 包含 `openspec`（注册表 installed=true 时可用）
- 明确提到 `Superpowers` → tools 包含 `superpowers`（注册表 installed=false 时下游自动降级）
- 明确提到 `GSD` → tools 包含 `gsd`
- 未指定 → 至少包含 `gsd`
- changeSize=large 且未指定 → 默认 `gsd + openspec`

## context-snapshot 写入详细

本 skill 是会话入口，每次进入都必须向 snapshot §2 追加一行用户输入摘要（≤80 字，含时间戳）。
仅当 phase ≠ uninitialized 且 requirementPath 存在时才写入；trivial 快速路径不写。

- 续跑场景：§2 追加新输入；§1「关键词/涉及模块」由 tcoa-context 增量合并，本 skill 不重复写
- 新需求场景：snapshot 由下游 `tcoa-context` 新需求初始化子流程创建，本 skill 仅在 §5 标记「拟新建」
- 跨 skill 切换前：§5 追加切换记录（router → 下游 skill）

写入失败不阻塞主流程。

## 会话控制详细（pause / resume / abort）

> 原 `tcoa-session-control` skill 已合并入 tcoa-router。

### 触发关键词
- **暂停**：`暂停`、`先停`、`先停一下`、`pause`、`等会儿`、`先放着`
- **恢复**：`继续`（仅当 phase=`paused` 时；否则走路由决策树续跑判定）、`resume`、`恢复需求`
- **放弃**：`放弃需求`、`abort`、`不做了`、`取消当前需求`

命中以上关键词时**不进入路由决策树**，直接执行对应子流程。

### pause（暂停）详细
**前置 phase**：任意非终态（`uninitialized` / `completed` / `paused` 除外）

动作：
1. 读取当前 phase，写入 `previousPhase`
2. 写 `phase = paused`
3. 追加 skillChain 记录
4. snapshot §5 追加一行：`[时间] <prev-phase> → paused | 进展：用户暂停`
5. changelog.md 追加暂停记录

**不做**：不修改业务产物、不切分支、不停止后台进程

### resume（恢复）详细
**前置 phase**：必须 = `paused`，否则报错

动作：
1. 读取 `previousPhase`
2. AskUserQuestion 二次确认：「恢复到 `<previousPhase>` 阶段，是否继续？」
3. 用户确认 → 写 `phase = previousPhase`，清空 `previousPhase`
4. 追加 skillChain 记录
5. snapshot §5 追加：`[时间] paused → <new-phase> | 进展：用户恢复`
6. 输出契约的 `next-skill` 根据恢复后的 phase 推荐

### abort（放弃）详细
**前置 phase**：任意（含 `paused`）

动作：
1. AskUserQuestion **强制二次确认**
2. 用户确认 → 写 `metadata.json.archived = true`，写 `archivedAt`
3. 写 `phase = completed`（标注 abortedAt）
4. 从 `.tcoa/current-context.json` 的 `active` 数组中移除该需求
5. 若 `active` 仍有其他需求 → `focused` 设为 active[0]；否则 `focused` 设为 null
6. snapshot §6 追加一行：`[时间] git-abort：用户放弃需求`
7. changelog.md 追加放弃记录

**不做**：不删除需求目录、不回滚已提交代码、不切分支

### 路由分流速查
| 用户输入 | 当前 phase | 处理路径 |
|---|---|---|
| 「暂停」 | 非终态 | pause 子流程 |
| 「继续」 | paused | resume 子流程 |
| 「继续」 | 非 paused | 路由决策树（续跑判定） |
| 「放弃」 | 任意 | abort 子流程 |
| 「调试/排查/报错/异常」 | 任意 | step 2 调试意图 → `/gsd-debug` |
| 「新需求」 | 任意 | 路由决策树 → `tcoa-context` 新需求初始化子流程 |

## 与 hook 协作
- `SessionStart` hook 已自动加载 `current-context.json`，本 skill 仍需主动二次校验
- `PreToolUse(Bash)` hook 会拦截不合规的 git 命令，本 skill 不应绕过

## 必须 AskUserQuestion 的完整场景
1. `current-context.json` 存在但用户描述与之关键词重叠 < 2 且未说"继续" → 是否新需求
2. phase ∈ {`review-failed`, `paused`} 时用户给出无关请求 → 是否放弃当前需求
3. changeSize 介于 small/medium 边界 → 是否需要完整 init
4. 用户未指定模式但 changeSize=large → 推荐 manual
5. 多个 active 需求未指明操作哪个
6. resume 前确认恢复目标 phase
7. abort 前强制二次确认
8. pause 时若 phase ∈ {`reviewing`, `git-flowing`} → 提示等待完成再暂停
