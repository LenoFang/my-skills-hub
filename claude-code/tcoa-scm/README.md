# TCOA 通用 Agent Skills

这组文件是给 AI 编程代理环境使用的通用 skill 层，适用于 Claude Code、Cursor、Copilot、Codex 等支持类似技能/规则编排的场景。当前仓库使用 `.claude/skills/` 作为承载目录，但 skill 本身的设计目标是通用的，而不是绑定单一工具。

目标不是替代 `tcoa-scaffold`，而是把：

- 需求上下文识别
- 需求初始化
- 全自动执行
- 半自动引导
- 统一 review
- Git 提交/推送/合并

这些“会话内编排能力”固化成可复用的技能说明。

## 当前推荐放置位置

当前这套 TCOA.SCM skill，推荐放在：

`D:\Projects\TCOA.SCM\.claude\skills\tcoa-scm`

这样更符合你在 `D:\Projects\TCOA.SCM` 目录层级进行开发的习惯，也更方便和同目录下其他项目 skill 共存。

## 关于“是否加载”与“是否能命令引用”

这两个问题需要分开看：

1. **skill 是否被宿主加载**
2. **skill 是否会被宿主暴露成 `/xxx` 形式的命令**

当前这套 TCOA skill 设计为：
- 以 root-level `tcoa-*` 目录作为宿主识别入口
- 以自然语言意图触发为主
- 不假设宿主一定会把 skill 暴露成 slash 命令

因此：
- “不能用命令名直接引用” **不等于** “没有加载 skill”
- 如果宿主本身不提供 skill 到命令的映射，用户仍需要通过自然语言意图触发 skill

常见原因通常有三类：
- 宿主只加载当前工作目录的 `.claude`，而你把 skill 放在父级目录
- 宿主支持 skill 规则，但不支持把 skill 暴露成命令入口
- skill 文案不够直白，导致自然语言意图不容易命中

更详细的部署/触发/命令协作模型，见：

- [`DEPLOYMENT_AND_INTEGRATION.md`](./docs/DEPLOYMENT_AND_INTEGRATION.md)
- [`HOST_ADAPTER_MATRIX.md`](./docs/HOST_ADAPTER_MATRIX.md)
- [`EXECUTION_STATE_MACHINE.md`](./docs/EXECUTION_STATE_MACHINE.md)
- [`COMMAND_PLUGIN_MAPPING.md`](./docs/COMMAND_PLUGIN_MAPPING.md)
- [`SKILL_PLUGIN_CLI_REFERENCE.md`](./docs/SKILL_PLUGIN_CLI_REFERENCE.md)

## 宿主联调执行稿

首轮联调建议按以下文档逐个宿主执行：

- [`CLAUDE_CODE_FIRST_ROUND_EXPERIMENT.md`](./docs/CLAUDE_CODE_FIRST_ROUND_EXPERIMENT.md)
- [`CURSOR_FIRST_ROUND_EXPERIMENT.md`](./docs/CURSOR_FIRST_ROUND_EXPERIMENT.md)
- [`COPILOT_FIRST_ROUND_EXPERIMENT.md`](./docs/COPILOT_FIRST_ROUND_EXPERIMENT.md)
- [`CODEX_FIRST_ROUND_EXPERIMENT.md`](./docs/CODEX_FIRST_ROUND_EXPERIMENT.md)

联调过程建议配合：

- [`HOST_RUNTIME_CHECKLIST.md`](./docs/HOST_RUNTIME_CHECKLIST.md)
- [`HOST_EXPERIMENT_RECORD_TEMPLATE.md`](./docs/HOST_EXPERIMENT_RECORD_TEMPLATE.md)

## 与 `tcoa-scaffold` 的分工

### Skill 层负责
- 在会话里识别用户意图
- 判断当前是全自动还是半自动模式
- 决定使用 `OpenSpec`、`Superpowers`、`GSD` 的顺序
- 决定哪些步骤必须确认，哪些步骤自动继续
- 将插件输出整理成标准文档内容

### `tcoa-scaffold` 负责
- 初始化需求目录和标准文档
- 维护项目级配置与当前需求上下文
- 负责本地文件落盘、日志、元数据
- 在需要时做命令适配、文档回填和状态持久化

### 父级桥接脚本负责
- 把 skill 中的本地命令调用统一转发到 `tcoa-scaffold`
- 默认补齐 `--project-root "D:\Projects\TCOA.SCM"`
- 降低 skill 文案直接依赖具体工作目录的风险

## 当前建议的使用方式

1. 需求会话先进入 `tcoa-router` 做意图识别与分流。
2. `tcoa-router` 先调用 `tcoa-context` 判断当前上下文。
3. 若没有需求目录，则由 `tcoa-context` 执行新需求初始化子流程。
4. 用户要求”全自动”时，进入 `tcoa-execute`（mode=auto）。
5. 用户要求”半自动 / 一步步确认”时，进入 `tcoa-execute`（mode=manual）。
6. 在需求准备结束前，统一进入 `tcoa-review`。
7. 若用户确认需要建分支、提交、推送或合并，则进入 `tcoa-git-flow`。
8. 所有产物都应沉淀到项目同级 `requirements/` 目录，并保持 `metadata.json` / `changelog.md` / 标准 Markdown 文档一致。

## 仍未完全自动化的部分

这些 skill 文件已经把流程规范固定下来，但“代理环境如何加载这些 skill、如何自动触发”的最终效果，仍然取决于具体宿主环境的技能加载方式与触发规则。

也就是说：

- **Skill 规则与流程说明：已补上第一版**
- **本地目录、配置、落盘底座：已具备**
- **不同代理环境中的最终触发与插件调用体验：还需要结合你实际安装环境继续打磨**

## 当前实现状态

### 已完成
- `tcoa-router`（统一入口 + 会话控制 pause/resume/abort）
- `tcoa-context`（上下文识别 + 新需求初始化子流程）
- `tcoa-execute`（auto + manual 统一执行）
- `tcoa-review`
- `tcoa-git-flow`
- `tcoa-flow-state`（状态机共享规范）
- `tcoa-scaffold` 作为本地支撑底座

### 仍建议继续补强
- 不同代理环境中的 skill 实际触发词与加载方式校验
- 半自动模式的确认模板细化
- 插件输出到标准文档的章节级映射细化
- 多轮续跑时的阶段状态推进规则
