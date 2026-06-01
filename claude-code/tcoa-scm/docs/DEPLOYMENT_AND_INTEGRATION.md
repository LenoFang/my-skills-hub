# TCOA Skills 部署与命令协作说明

## 1. 这些 skill 放在哪里最稳

### 推荐优先级
1. **项目族根目录**：`D:\Projects\TCOA.SCM\.claude\skills\tcoa-scm`
2. **当前项目内**：`D:\Projects\TCOA.SCM\code-backend\.claude\skills`
3. **全局目录**：`%USERPROFILE%\.claude\skills`

### 当前建议
基于你当前的开发习惯，**最推荐放在项目族根目录**：

`D:\Projects\TCOA.SCM\.claude\skills\tcoa-scm`

原因：
- 你习惯在 `D:\Projects\TCOA.SCM` 目录层级进行开发
- 该目录下已经有其他项目 skill，适合统一管理
- 当前这套 TCOA.SCM skill 明显是项目族级能力，不只是 `code-backend` 单仓库能力

### 放在 `D:\Projects\TCOA.SCM\code-backend\.claude` 会怎样
仍然可用，而且对单仓库最封闭。

适合场景：
- 只想先在 `code-backend` 内验证
- 宿主环境不支持父目录 `.claude` 继承

缺点：
- 不符合你当前的使用习惯
- 后续如果多个子项目共用，还需要再搬一次

### 放到全局 `%USERPROFILE%\.claude` 会怎样
当前仍然**不建议直接全局化**。

原因：
- 这套 skill 仍然带有明显的 TCOA.SCM 项目约束
- 默认 requirement 目录、脚手架路径、上下文语义都不是全局通用的
- 放全局后，其他仓库也可能被错误触发

### 结论
- **按你当前要求，优先放父级 `D:\Projects\TCOA.SCM\.claude\skills\tcoa-scm`**
- **保留项目内版本作为过渡或回退方案**
- **在没有做项目变量化之前，不建议直接放全局**

---

## 2. skill 和 `tcoa-scaffold` 的关系

### skill 是什么
skill 是：
- 意图识别规则
- 流程编排规则
- auto/manual 模式分流规则
- OpenSpec / Superpowers / GSD 的调用顺序规则
- 文档沉淀规则

### `tcoa-scaffold` 是什么
`tcoa-scaffold` 是本地底座，负责：
- 初始化需求目录
- 维护 `metadata.json`
- 维护 `changelog.md`
- 保存当前上下文
- 执行本地落盘
- 标准文档回填

### 关键区别
- **skill 负责“怎么做”**
- **scaffold 负责“落到哪里、怎么存”**

---

## 3. `tcoa-scaffold` 需要安装吗

### skill 文件本身
**不需要安装。**
只要宿主代理环境会加载这些 skill 文档即可。

### `tcoa-scaffold`
**需要可执行，但不一定要全局安装。**

当前脚手架是一个 Node CLI，要求：
- 本机有 Node.js
- 仓库里存在 `tcoa-scaffold`

### 当前最推荐方式：父级桥接脚本
已提供桥接脚本：

`D:\Projects\TCOA.SCM\.claude\scripts\tcoa-scaffold.ps1`

它会：
- 自动找到 `D:\Projects\TCOA.SCM\tcoa-scaffold\src\cli.js`
- 自动补齐 `--project-root "D:\Projects\TCOA.SCM"`
- 把 skill 文案中的本地命令入口统一起来

使用方式：

```powershell
powershell -ExecutionPolicy Bypass -File "D:\Projects\TCOA.SCM\.claude\scripts\tcoa-scaffold.ps1" status
powershell -ExecutionPolicy Bypass -File "D:\Projects\TCOA.SCM\.claude\scripts\tcoa-scaffold.ps1" context --latest
powershell -ExecutionPolicy Bypass -File "D:\Projects\TCOA.SCM\.claude\scripts\tcoa-scaffold.ps1" execute
```

### 后续增强方式：做成全局命令
如果你希望 skill 中的命令更短，后续可以再把 `tcoa-scaffold` 做成真正的全局命令。

---

## 4. skill 会不会自动执行 `/superpowers:*`、`/opsx:*`、`/gsd-*` 这些命令

### 先说结论
**不一定自动。**
是否能自动，取决于宿主代理环境是否支持“skill 在会话里主动调用这些插件命令”。

### 有两种模式

#### 模式 A：宿主支持 agent 主动调用插件命令
这种情况下，skill 可以把这些命令当成流程的一部分：
- 先 `opsx:propose`
- 再 `superpowers:brainstorming`
- 再 `superpowers:writing-plans`
- 再 `gsd-plan-phase`
- 再根据返回结果继续

这是你想要的“真正自动化”方向。

#### 模式 B：宿主不支持自动调用，只支持用户手动输入命令
这种情况下，skill 只能：
- 告诉你下一步该运行哪个命令
- 解释为什么运行它
- 在命令执行后继续读取结果并往下推进

这是“半自动 / 人机协作”方向。

### 当前状态
**我们现在的 skill 文档已经定义了流程，但还没有把“宿主是否允许自动调用这些命令”最终验证死。**

所以当前最稳的理解是：
- skill 已经能定义“应该调用什么”
- 但“是代理自动发起，还是你手动输命令”仍取决于宿主能力

### 额外说明：`superpowers` 不是一个 skill 名称
- `superpowers` 在这套流程里表示**插件 / 工具能力**。
- 如果宿主报 `Unknown skill: superpowers`，更可能是把插件名误当成了 skill 名去调用。
- 正确区分应是：
  - skill：`tcoa-router`、`tcoa-auto-execute`、`tcoa-review` 等
  - 插件命令：`/superpowers:brainstorming`、`/superpowers:writing-plans`、`/superpowers:requesting-code-review`

---

## 5. 像 `gsd-execute-phase 1` 这种动态参数怎么办

这是 skill 设计里最重要的一类问题。

### 不推荐的方式
不建议把流程设计成：
- 用户自己记住 phase 编号
- 用户自己手工把编号输到下一条命令里

这样会很脆弱。

### 推荐方式
应该把“上一步返回的动态参数”沉淀成状态，再由下一个步骤读取。状态来源可以是：
- `metadata.json`
- `generated/*.md`
- `current-context.json`
- 单独的 `execution-state.json`

### 推荐设计
例如：
1. `gsd-plan-phase xxx` 返回 phase 列表
2. 将 phase 信息写入需求目录，例如：
   - `generated/gsd-output.md`
   - 或 `metadata.json.executionState.gsd.phases`
   - 或单独 `execution-state.json`
3. 后续 `gsd-execute-phase` 不再依赖用户肉眼找编号，而是：
   - 由 agent 根据状态自动选择 phase 1 / phase 2
   - 或在半自动模式下给用户一个明确列表供选择

### 结论
**动态参数应该由“状态文件 + skill 流程”来承接，而不是靠用户手输串联。**

这一块目前还没有完整落地，是接下来最值得补的能力之一。

---

## 6. 当前最推荐的协作模型

### 全自动模式
1. `tcoa-router` 识别用户意图
2. `tcoa-context` 锁定当前需求
3. 若无需求目录，`tcoa-requirement-init` 创建目录
4. 自动调用：
   - `OpenSpec`
   - `Superpowers`
   - `GSD`
5. 将返回结果写入标准文档与状态文件
6. 如存在动态参数，优先写入状态文件并自动续跑

### 半自动模式
1. `tcoa-router` 识别到 manual
2. `tcoa-context` 锁定需求
3. 每一步先展示：
   - 将调用哪个命令
   - 预期产物是什么
   - 是否有动态参数需要确认
4. 用户确认后再执行下一步

---

## 7. 当前还没完全实现的部分

1. 多宿主环境对 skill 的自动加载规则验证
2. 插件命令能否由 agent 自动发起的能力验证
3. 动态参数状态机（尤其是 phase 编号续跑）
4. `manual-guide` 的确认模板细化
5. 将 `tcoa-scaffold` 做成真正稳定的全局命令

---

## 8. 下一步建议

最建议的下一步不是继续扩写普通 README，而是补两类东西：

1. **宿主适配说明**
   - 哪些环境支持自动触发
   - 哪些环境只能半自动
   - `.claude` 项目级 / 父级 / 全局的使用建议

2. **动态参数与状态机设计**
   - 如何保存 `phase` 编号
   - 如何在 skill 中续跑
   - 如何让 `manual` 和 `auto` 共用同一套状态

