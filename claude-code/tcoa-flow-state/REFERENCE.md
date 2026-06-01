# tcoa-flow-state REFERENCE

> 本文件是 `tcoa-flow-state/SKILL.md` 的详细补充参考，按需读取。

## Skill 可见性（跨会话续跑）

所有 `tcoa-*` skill 仅安装在项目级 `.claude/skills/`，不进入全局 `~/.claude/skills/`。跨窗口续跑时若其他会话提示找不到本 skill：
1. 确认工作目录是项目根（`D:\Projects\TCOA.SCM` 或对应仓库根）
2. 直接读取 `<projectRoot>/.claude/skills/tcoa-flow-state/SKILL.md` 获取本规范
3. 其他 tcoa-* skill 均位于 `<projectRoot>/.claude/skills/<skill-name>/SKILL.md`

## 状态枚举详细进入/退出条件

| phase | 进入条件 | 退出条件 |
|---|---|---|
| `uninitialized` | 首次会话 / 用户清空上下文 | 完成 tcoa-context 新需求初始化子流程 |
| `initialized` | tcoa-context 新需求初始化子流程完成 | 进入 auto/manual 执行 |
| `branching` | 用户确认建分支 | 分支已切换 |
| `executing-auto` | 进入 tcoa-execute（mode=auto） | 主流程产物完成 |
| `executing-manual` | 进入 tcoa-execute（mode=manual） | 用户确认全部步骤 |
| `awaiting-review` | 主流程完成，未 review | 进入 tcoa-review |
| `reviewing` | 进入 tcoa-review | review 输出结论 |
| `review-failed` | review 发现 CRITICAL/HIGH | 修复后回到对应执行 phase |
| `review-passed` | review 无阻塞问题 | 进入 git 流程或完成 |
| `awaiting-git` | review-passed 后 | 用户确认或拒绝 git 操作 |
| `git-flowing` | 进入 tcoa-git-flow | 提交/推送/合并完成 |
| `e2e-testing` | review-passed 且用户同意运行 /e2e | 测试通过/失败 |
| `completed` | 所有动作完成 | （终态） |
| `paused` | 用户明确表示中断 | 用户恢复 |

## 门禁规则详细

### tcoa-router
- 入口无门禁，但必须先调用 tcoa-context 加载状态

### tcoa-context
- 必须读取 `.tcoa/current-context.json`
- 若文件不存在 → phase = `uninitialized`
- 必须读取 `<requirementPath>/execution-state.json` 并校验 phase 字段合法性

### tcoa-context（新需求初始化子流程）
- 仅当 phase ∈ {`uninitialized`, `initialized`(用户确认覆盖), `completed`} 时允许执行子流程
- 子流程完成后必须写入 phase = `initialized`

### tcoa-execute
- 仅当 phase ∈ {`initialized`, `branching`, `review-failed`} 时允许进入
- 进入时必须写入 phase = `executing-auto`（mode=auto）或 `executing-manual`（mode=manual）
- 退出主流程时必须写入 phase = `awaiting-review`
- **不允许直接写 `completed`**

### tcoa-review
- 仅当 phase ∈ {`awaiting-review`, `executing-auto`, `executing-manual`} 时允许进入
- 进入时写 phase = `reviewing`
- 退出时根据结论写 `review-passed` 或 `review-failed`

### tcoa-git-flow
- 仅当 phase ∈ {`initialized`(建分支场景), `branching`, `review-passed`, `awaiting-git`} 时允许进入
- 严禁在 phase = `executing-*` 或 `awaiting-review` 时进入（除建分支子流程外）
- 提交/推送/合并必须 phase = `review-passed` 或 `awaiting-git`

## 关键字段说明

- **changeSize**: `trivial` / `small` / `medium` / `large`，用于决定走快速路径还是完整路径
- **skillChain**: 本轮已经过的 skill 时间序列，由每个 skill 自动追加
- **reviewStatus.required**: 仅 `trivial` 改动可设为 false（且必须用户明确同意），其他强制为 true
- **degradations**: 每次工具降级记录，含 `from`, `to`, `reason`, `at`

## 边界场景规则

### trivial 改动（如改 bug、改文案）
- 用户描述明显是小改动时，tcoa-context 必须主动询问是否使用快速路径
- 用户确认 → 跳过 init，直接进入实现
- 仍需轻量 review，但允许跳过 git 流程的合并步骤

### 续跑判定
- tcoa-context 必须比对：用户当前描述的功能/模块/文件 vs current-context.json 中的 name/slug
- 关键词重叠 ≥2 或显式说"继续" → 续跑
- 关键词完全无关或显式说"新需求" → 询问用户
- 无法判断 → 必须 AskUserQuestion

### review 失败回流
- tcoa-review 写 phase = `review-failed` 后，必须明确指定回到哪个执行 phase
- 二次 review 通过后才能进入 review-passed
- 第三次仍失败 → 强制转人工

### 模式切换（auto ↔ manual）
- "还是一步步来吧" → 写 phase = `executing-manual`，保留 skillChain
- "剩下的全自动" → 写 phase = `executing-auto`，已确认的步骤不重做

### completed 后 openspec 归档（可选）
- tools 含 openspec 且 phase=completed → 询问是否归档
- 用户同意 → 调用 /opsx:archive
- 归档不改变 phase

### git 操作失败
- push 失败 → phase 保持 `git-flowing`，提示用户处理
- merge 冲突 → phase 退回 `awaiting-git`
- 严禁 `--force` 或 `--no-verify`

## 与 hook 的协作

- **SessionStart**: 自动加载 `.tcoa/current-context.json` 提示当前需求
- **PreToolUse(Bash)**: 拦截 `git commit/push/merge`，校验 phase 必须为 `review-passed` 或 `awaiting-git`
- **PreToolUse(Bash)**: 拦截 `--no-verify`、`--force`
- **Stop**: 检查 phase 是否处于一致终态

## 持久化格式

> 完整结构见 `.claude/skills/tcoa-flow-state/tcoa-persistence-spec.md`

关键约定：
- **execution-state.json**：会话期状态（phase、skillChain、reviewStatus、gitStatus）
- **context-snapshot.md**：跨会话上下文知识（用户描述、关键词、代码发现、决策、skill 切换）
- **metadata.json**：需求级长期元数据（requirementId、name、changeSize、archived 等）
- **批量写入原则**：snapshot 采用「内存累积 + 退出 skill 时单次 Edit」
- **trivial 快速路径不创建** snapshot/metadata

## 不做的事
- 不直接修改本规范定义的 phase 含义
- 不在 skill 内部硬编码状态字符串以外的状态
- 不跳过 execution-state.json 的读写
