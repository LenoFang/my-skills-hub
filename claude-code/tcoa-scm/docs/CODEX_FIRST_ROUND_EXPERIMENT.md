# TCOA Skills：Codex 首轮实测记录（执行稿）

## 目标
本轮只验证 Codex 下最小可用闭环：

1. Codex 是否会参考 root-level `tcoa-*` 规则
2. Codex 是否能体现 `tcoa-router -> tcoa-context -> manual` 的流程语义
3. Codex 是否能承接上一条结果并给出下一步建议
4. 本地桥接脚本是否能正常落盘到 `requirements/` 与状态文件

> 本轮默认按 `manual` 设计，不强求自动调用插件命令。

---

## 一、前置条件

### 目录前提
确认以下目录存在：
- `.claude/skills/tcoa-router`
- `.claude/skills/tcoa-context`
- `.claude/skills/tcoa-requirement-init`
- `.claude/skills/tcoa-auto-execute`
- `.claude/skills/tcoa-manual-guide`
- `.claude/skills/tcoa-scm/bin/tcoa-scaffold.ps1`

### 本地底座前提
先验证桥接脚本：

```powershell
powershell -ExecutionPolicy Bypass -File ".\.claude\skills\tcoa-scm\bin\tcoa-scaffold.ps1" status
powershell -ExecutionPolicy Bypass -File ".\.claude\skills\tcoa-scm\bin\tcoa-scaffold.ps1" state
```

### 通过标准
- `status` 正常输出当前需求信息
- `state` 正常输出 `execution-state.json`

---

## 二、测试范围

### 本轮重点测 4 件事
1. root-level skills 是否被引用
2. 是否体现 manual 语义
3. 是否能承接上一条结果继续推进
4. 是否能通过桥接脚本落盘

### 本轮暂不重点测
1. 插件命令自动触发
2. 复杂 phase 状态机
3. 多宿主交叉对比

---

## 三、测试用例 1：规则引用能力

### 测试输入

```text
继续当前需求，按半自动模式推进，并使用 OpenSpec、Superpowers、GSD。
```

### 预期行为
- 至少体现：
  - 先看当前上下文
  - 再看模式和工具链
  - 再给下一步建议
- 倾向 manual，而不是直接假设全自动

### 通过判定
- [ ] 有上下文判断语义
- [ ] 能识别 `manual`
- [ ] 能识别工具链

### 失败回退
- 明确要求：“请按 `tcoa-router` 和 `tcoa-manual-guide` 的思路处理。”
- 若仍不稳定，则按 `tcoa-scm` 文档集合手工推进

---

## 四、测试用例 2：结果承接能力

### 测试输入

```text
如果你不能自动调插件命令，请在我执行完上一条命令后，继续承接结果并告诉我下一步。
```

### 预期行为
- 能承接上一条命令输出
- 能根据结果继续给出下一步建议
- 能说明下一步会更新哪些文档

### 通过判定
- [ ] 能承接上一条结果继续推进
- [ ] 能给出下一步建议
- [ ] 能说明要更新的文档

### 失败回退
- 退到“规则说明 + 手工命令执行”模式

---

## 五、测试用例 3：桥接与状态检查

### 测试步骤
执行：

```powershell
powershell -ExecutionPolicy Bypass -File ".\.claude\skills\tcoa-scm\bin\tcoa-scaffold.ps1" status
powershell -ExecutionPolicy Bypass -File ".\.claude\skills\tcoa-scm\bin\tcoa-scaffold.ps1" state
```

### 检查文件
- `requirements/<requirementId>/generated/*.md`
- `requirements/<requirementId>/metadata.json`
- `requirements/<requirementId>/execution-state.json`
- `requirements/<requirementId>/proposal.md`
- `requirements/<requirementId>/tasks.md`

### 通过判定
- [ ] 至少有 `metadata.json`
- [ ] 至少有 `execution-state.json`
- [ ] 至少有 `generated/*.md`

### 失败回退
- 保留当前测试目录
- 先修桥接脚本或状态落盘链路

---

## 六、本轮最终结论模板

```text
宿主环境：Codex
是否识别 root-level skills：
是否体现 manual 流程语义：
是否能承接上一条结果继续推进：
桥接脚本是否正常落盘：
当前推荐模式：manual / auto
当前最大问题：
下轮是否继续联调：是 / 否
```

---

## 七、本轮建议

### 如果结果较好
继续进入：
- Codex 第二轮联调
- 进一步验证命令映射与结果承接

### 如果结果一般
保守建议：
- Codex 按 `manual` 使用
- 依赖 skill 规则 + 手工命令 + scaffold 落盘

### 如果结果较差
建议：
- 暂时只把 Codex 作为规则说明型宿主
- 不要求它进入自动化链路

