# TCOA：Skill / 插件命令 / CLI 命令 对照表

## 目的
这份文档用于明确区分三类不同对象：

1. **Skill**：流程规则与会话编排入口
2. **插件命令**：由宿主环境提供的插件能力命令
3. **CLI 命令**：`tcoa-scaffold` 暴露的本地显式可执行命令

> 这三者不是同一个层面的东西。把插件名当成 skill、把 skill 当成 CLI 命令，都会导致调用错误。

---

## 一、快速判断规则

### 如果你看到的是：
- `tcoa-router`
- `tcoa-review`
- `tcoa-git-flow`

它们属于：**Skill**

### 如果你看到的是：
- `/superpowers:brainstorming`
- `/opsx:propose`
- `/gsd-plan-phase <topic>`

它们属于：**插件命令**

### 如果你看到的是：
- `tcoa-scaffold init-requirement`
- `tcoa-scaffold git-create-branch`
- `tcoa-scaffold git-commit`

它们属于：**CLI 命令**

---

## 二、对照表

| 名称 / 标识 | 类别 | 调用形式 | 实际承载位置 | 主要职责 | 典型示例 |
|---|---|---|---|---|---|
| `tcoa-router` | Skill | 自然语言触发 / 宿主若支持可显式引用 | `.claude/skills/tcoa-router/` | 需求流程统一入口与分流 | 新需求、继续需求、auto/manual 判断 |
| `tcoa-context` | Skill | 自然语言触发 / 内部阶段 | `.claude/skills/tcoa-context/` | 识别当前需求上下文 | 锁定 `requirementId`、`mode`、`tools` |
| `tcoa-requirement-init` | Skill | 自然语言触发 / 内部阶段 | `.claude/skills/tcoa-requirement-init/` | 初始化需求目录与上下文 | 新建需求目录、询问是否建分支 |
| `tcoa-auto-execute` | Skill | 自然语言触发 / 宿主若支持可显式引用 | `.claude/skills/tcoa-auto-execute/` | 自动推进 OpenSpec / Superpowers / GSD | 全自动执行 |
| `tcoa-manual-guide` | Skill | 自然语言触发 / 宿主若支持可显式引用 | `.claude/skills/tcoa-manual-guide/` | 半自动逐步确认执行 | 一步步推进 |
| `tcoa-review` | Skill | 自然语言触发 / 流程固定阶段 | `.claude/skills/tcoa-review/` | 统一 code review | 快速 review / 标准 review |
| `tcoa-git-flow` | Skill | 自然语言触发 / review 后阶段 | `.claude/skills/tcoa-git-flow/` | Git 分支、提交、推送、合并流程 | 建分支 / 提交 / 合并 |
| `/opsx:explore` | 插件命令 | 宿主插件命令 | 宿主环境中的 OpenSpec | 模糊需求澄清 | 先探索需求边界 |
| `/opsx:propose` | 插件命令 | 宿主插件命令 | 宿主环境中的 OpenSpec | 输出结构化方案 | 明确方案与规格 |
| `/superpowers:brainstorming` | 插件命令 | 宿主插件命令 | 宿主环境中的 Superpowers | **先做头脑风暴** | 发散方案、风险点、备选方向 |
| `/superpowers:writing-plans` | 插件命令 | 宿主插件命令 | 宿主环境中的 Superpowers | **基于头脑风暴结果写计划** | 生成实施计划 |
| `/superpowers:requesting-code-review` | 插件命令 | 宿主插件命令 | 宿主环境中的 Superpowers | 对代码做 review | 审查风险与改进点 |
| `/gsd-plan-phase <topic>` | 插件命令 | 宿主插件命令 | 宿主环境中的 GSD | 把需求拆成 phase | 计划拆解 |
| `/gsd-execute-phase <phaseId>` | 插件命令 | 宿主插件命令 | 宿主环境中的 GSD | 执行某个 phase | 分阶段推进 |
| `/gsd-progress` | 插件命令 | 宿主插件命令 | 宿主环境中的 GSD | 汇总进度 | 收尾前检查 |
| `/e2e <scope>` | 插件命令 | 宿主插件命令 | 宿主环境中的 E2E | 测试生成与验证 | 生成测试或执行验证 |
| `tcoa-scaffold init-requirement` | CLI 命令 | 本地命令 | `tcoa-scaffold` | 真正创建需求目录与模板 | 显式初始化需求 |
| `tcoa-scaffold context` | CLI 命令 | 本地命令 | `tcoa-scaffold` | 查看当前需求上下文 | 列需求 / latest / 指定需求 |
| `tcoa-scaffold status` | CLI 命令 | 本地命令 | `tcoa-scaffold` | 查看当前需求摘要 | 查看当前需求状态 |
| `tcoa-scaffold state` | CLI 命令 | 本地命令 | `tcoa-scaffold` | 查看 `execution-state.json` | 看流程状态 |
| `tcoa-scaffold execute` | CLI 命令 | 本地命令 | `tcoa-scaffold` | 落盘与文档回填 | 把工具结果写回标准文档 |
| `tcoa-scaffold git-current-branch` | CLI 命令 | 本地命令 | `tcoa-scaffold` | 读取当前 Git 分支 | 查看当前分支 |
| `tcoa-scaffold git-create-branch` | CLI 命令 | 本地命令 | `tcoa-scaffold` | 创建并切换分支 | `feature/<slug>` |
| `tcoa-scaffold git-commit-message` | CLI 命令 | 本地命令 | `tcoa-scaffold` | 生成 Conventional Commit 候选信息 | `feat: 增加登录功能` |
| `tcoa-scaffold git-commit` | CLI 命令 | 本地命令 | `tcoa-scaffold` | 显式提交当前改动 | `git add -A && git commit` |
| `tcoa-scaffold git-push` | CLI 命令 | 本地命令 | `tcoa-scaffold` | 预览或执行推送 | 默认预览 |
| `tcoa-scaffold git-merge` | CLI 命令 | 本地命令 | `tcoa-scaffold` | 预览或执行合并 | 默认预览 |

---

## 三、最容易混淆的几个点

### 1. `superpowers` 不是 skill 名
错误理解：
- `superpowers` 是一个 skill

正确理解：
- `superpowers` 是插件能力集合
- 真正的插件命令是：
  - `/superpowers:brainstorming`
  - `/superpowers:writing-plans`
  - `/superpowers:requesting-code-review`

### 2. `tcoa-router` 不是插件命令
错误理解：
- `tcoa-router` 可以像 `/superpowers:brainstorming` 一样执行插件命令

正确理解：
- `tcoa-router` 是流程入口 skill
- 它负责决定后续该进入哪个 skill / 插件命令 / CLI 命令

### 3. `tcoa-scaffold` 不是 skill
错误理解：
- `tcoa-scaffold` 是一个 Claude skill

正确理解：
- `tcoa-scaffold` 是本地 CLI / 执行底座
- 它负责目录、状态、文档、Git 等显式可执行动作

---

## 四、Superpowers 正确顺序

正确顺序是：

1. `/superpowers:brainstorming`
2. `/superpowers:writing-plans`
3. `/superpowers:requesting-code-review`（如需要）

不要写反成：
- 先 `writing-plans`
- 再 `brainstorming`

因为：
- `brainstorming` 负责头脑风暴
- `writing-plans` 负责基于风暴结果形成计划

---

## 五、推荐的实际使用方式

### 想让代理自己分流
优先说自然语言：
- “继续当前需求，按半自动模式推进”
- “新建一个需求并开始推进”
- “review 后帮我生成提交信息并问我是否提交”

### 想手工显式执行本地动作
优先用 CLI：
- `tcoa-scaffold init-requirement`
- `tcoa-scaffold git-create-branch`
- `tcoa-scaffold git-commit-message`
- `tcoa-scaffold git-commit`

### 想调用宿主插件命令
优先确认宿主支持后再用：
- `/opsx:propose`
- `/superpowers:brainstorming`
- `/gsd-plan-phase <topic>`

---

## 六、结论

如果后续再出现：
- `Unknown skill: superpowers`
- `Unknown skill: tcoa-router`
- `Superpowers` 顺序写反
- 不清楚该用 skill、插件还是 CLI

优先先回看这份对照表，再判断是哪一层调用出了问题。

