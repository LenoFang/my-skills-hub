# TCOA Skills 宿主联调检查清单

## 目标
用于在不同宿主环境中逐步判断：
- root-level skills 是否被识别
- 插件命令是否能被自动调用
- skill 与命令结果能否顺利衔接
- 当前宿主更适合 `auto` 还是 `manual`
- review 是否能作为所有模式的必经步骤被保留

建议配合记录模板一起使用：

- [`HOST_EXPERIMENT_RECORD_TEMPLATE.md`](./HOST_EXPERIMENT_RECORD_TEMPLATE.md)

对应宿主执行稿：

- [`CLAUDE_CODE_FIRST_ROUND_EXPERIMENT.md`](./CLAUDE_CODE_FIRST_ROUND_EXPERIMENT.md)
- [`CURSOR_FIRST_ROUND_EXPERIMENT.md`](./CURSOR_FIRST_ROUND_EXPERIMENT.md)
- [`COPILOT_FIRST_ROUND_EXPERIMENT.md`](./COPILOT_FIRST_ROUND_EXPERIMENT.md)
- [`CODEX_FIRST_ROUND_EXPERIMENT.md`](./CODEX_FIRST_ROUND_EXPERIMENT.md)

---

## 1. 通用前置检查

### 目录检查
确认以下目录存在：

- `.claude/skills/tcoa-router`
- `.claude/skills/tcoa-context`
- `.claude/skills/tcoa-requirement-init`
- `.claude/skills/tcoa-auto-execute`
- `.claude/skills/tcoa-manual-guide`
- `.claude/skills/tcoa-scm/bin/tcoa-scaffold.ps1`

### 底座检查
确认桥接脚本可执行：

```powershell
powershell -ExecutionPolicy Bypass -File ".\.claude\skills\tcoa-scm\bin\tcoa-scaffold.ps1" status
powershell -ExecutionPolicy Bypass -File ".\.claude\skills\tcoa-scm\bin\tcoa-scaffold.ps1" state
```

### 通过标准
- `status` 能输出当前需求摘要
- `state` 能输出 `execution-state.json`

### 失败回退
- 若桥接脚本失败，先修复本地 `tcoa-scaffold` 或桥接脚本，再做宿主联调

---

## 2. Claude Code 联调

### Step 1：验证 root-level skills 是否被识别
发起一个需求对话，例如：
- “用 OpenSpec + GSD 做一个支付改造需求”
- “继续之前的需求，按半自动模式执行”

观察是否体现：
- `tcoa-router` 的分流思路
- `tcoa-context` 的上下文判断思路

### Step 2：验证 auto / manual 分流
测试两类表达：
- “直接做完，不用确认”
- “一步步来，每步确认”

观察是否：
- 前者更偏 `auto`
- 后者更偏 `manual`

### Step 3：验证插件命令协作
检查 Claude Code 中：
- 是否允许 skill 自动推进插件命令
- 若不允许，是否至少能提示下一条应执行命令

### 通过标准
- 能识别 root-level `tcoa-*`
- 能体现 auto/manual 分流
- 能与桥接脚本协作落盘

### 失败回退
- 退到 `manual`
- skill 只负责提示下一条命令，由用户手动执行

---

## 3. Cursor 联调

### Step 1：验证 root-level skills 规则承载
发起一个新需求或续跑需求对话。
观察是否能体现：
- 模式识别
- 工具识别
- 新建/续跑判断

### Step 2：验证是否支持下一步建议
观察 skill 是否能明确给出：
- 下一条建议命令
- 预期产物
- 需要更新的文档

### Step 3：验证落盘
执行桥接脚本：

```powershell
powershell -ExecutionPolicy Bypass -File ".\.claude\skills\tcoa-scm\bin\tcoa-scaffold.ps1" execute
```

### 通过标准
- skill 至少能作为规则集使用
- 能给出下一步建议
- 桥接脚本可正常落盘

### 失败回退
- 将 Cursor 作为“规则说明 + 手动命令执行”的宿主使用

---

## 4. Copilot 联调

### Step 1：验证规则说明承载
观察 root-level `tcoa-*` 是否能在会话中被自然参考。

### Step 2：验证流程提示
看是否能出现：
- 上下文判断
- 模式判断
- 下一步建议

### Step 3：验证桥接脚本
确认桥接脚本仍能在当前工作目录执行：

```powershell
powershell -ExecutionPolicy Bypass -File ".\.claude\skills\tcoa-scm\bin\tcoa-scaffold.ps1" status
```

### 通过标准
- 能把 skill 当规则说明使用
- 能结合桥接脚本完成状态/文档落盘

### 失败回退
- 把 `tcoa-scm` 文档集合当手册使用

---

## 5. Codex 联调

### Step 1：验证是否读取 root-level skills
观察是否会自然参考：
- `tcoa-router`
- `tcoa-context`
- `tcoa-auto-execute`
- `tcoa-manual-guide`

### Step 2：验证结果承接
检查上一条命令执行后，是否能继续承接其结果推进下一步。

### Step 3：验证桥接与状态
确认：
- `status`
- `state`
- `execution-state.json`

都正常可用。

### 通过标准
- 能引用 skill 规则
- 能配合桥接脚本推进状态与文档

### 失败回退
- 先作为 manual 模式宿主使用

---

## 6. 自动调用命令能力统一检查

对每个宿主，都单独判断以下四类命令：
- `OpenSpec`
- `Superpowers`
- `GSD`
- `e2e`

### 如果支持自动调用
skill 可以：
- 自动推进命令链
- 自动承接结果
- 自动更新文档与状态

### 如果不支持自动调用
skill 应退化为：
- 明确告诉用户下一条命令
- 用户执行后继续承接结果

---

## 7. 文档与状态承接检查

每次联调后，都检查：
- `generated/*.md`
- `metadata.json`
- `changelog.md`
- `execution-state.json`
- `proposal.md`
- `tasks.md`
- `spec.md`
- `design.md`

同时检查：
- 是否存在 review 结论
- 是否在 review 完成前就直接结束流程

### 通过标准
- 至少状态与产物能稳定落盘
- 即使插件命令不能自动发起，也能继续承接结果

---

## 8. auto / manual 最终判定

### 判定为 auto 可用
同时满足大部分条件：
- 宿主能识别 root-level `tcoa-*`
- 宿主能自动调用插件命令
- 宿主能自动承接结果继续推进
- 桥接脚本稳定工作
- review 能作为默认必经步骤被保留

### 判定为 manual 优先
满足任一条件：
- 宿主不能自动调插件命令
- 宿主不能稳定承接结果
- 宿主只能把 skill 当规则说明文档

### 无论 auto / manual 都必须检查
- 是否存在 `tcoa-review` 阶段或等价 review 行为
- 即使只使用 `GSD` 的快速模式，也不能跳过 review

---

## 9. 联调结果记录模板

建议为每个宿主记录：

```text
宿主环境：
是否识别 root-level skills：
是否支持自动调用命令：
是否支持多步承接：
当前推荐模式：auto / manual
已验证命令：
失败回退方式：
存在问题：
```

---

## 10. 当前推荐联调顺序

1. 先联调 Claude Code
2. 再联调 Cursor
3. 再验证 Copilot / Codex

---

## 11. 结论

只要这份清单跑完，你就能知道：
- 这套 skill 在目标宿主里是不是“真的可用”
- 它适合走 `auto` 还是 `manual`
- 哪些插件命令能自动化，哪些只能人工协作

