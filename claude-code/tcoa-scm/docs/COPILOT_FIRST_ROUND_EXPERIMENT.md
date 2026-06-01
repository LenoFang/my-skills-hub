# TCOA Skills：Copilot 首轮实测记录（执行稿）

## 目标
本轮只验证 Copilot 下最小可用闭环：

1. Copilot 是否能把 root-level `tcoa-*` 当作规则说明参考
2. Copilot 是否能体现 `tcoa-router -> tcoa-context -> manual` 的思路
3. Copilot 是否能给出“下一步建议命令 + 预期产物”
4. 本地桥接脚本是否能正常落盘到 `requirements/` 与标准文档

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
1. root-level skills 是否被会话自然参考
2. 是否体现 manual 语义
3. 是否能明确提示下一步建议命令
4. 是否能依赖桥接脚本完成落盘

### 本轮暂不重点测
1. 插件命令自动调用
2. 多步状态机自动续跑
3. 多宿主交叉对比

---

## 三、测试用例 1：规则说明承载

### 测试输入

```text
继续当前需求，按半自动模式推进，并使用 OpenSpec、Superpowers、GSD。
```

### 预期行为
- Copilot 不一定显式“调用 skill”，但应至少体现：
  - 上下文判断
  - 模式判断
  - 工具判断
- 倾向以说明和建议形式推进，而不是盲目执行

### 通过判定
- [ ] 有上下文判断语义
- [ ] 能识别 `manual`
- [ ] 能识别工具链

### 失败回退
- 明确补一句：“请按 `tcoa-router` 和 `tcoa-manual-guide` 的思路处理当前需求。”
- 若仍不稳定，则按文档手工推进

---

## 四、测试用例 2：下一步建议能力

### 测试输入

```text
如果你不能自动调用插件命令，请明确告诉我下一条命令、预期产物，以及执行后该看哪个文档。
```

### 预期行为
应至少给出：
- 下一条建议命令
- 该命令为什么要执行
- 预期产物是什么
- 执行后查看哪个文件

### 通过判定
- [ ] 能稳定给出下一步建议命令
- [ ] 能说明预期产物
- [ ] 能说明执行后该检查哪个文档

### 失败回退
- 将 Copilot 作为纯“规则说明 + 手工命令执行”宿主使用

---

## 五、测试用例 3：桥接脚本落盘检查

### 测试步骤
在完成一个最小流程后，执行：

```powershell
powershell -ExecutionPolicy Bypass -File ".\.claude\skills\tcoa-scm\bin\tcoa-scaffold.ps1" status
powershell -ExecutionPolicy Bypass -File ".\.claude\skills\tcoa-scm\bin\tcoa-scaffold.ps1" state
```

### 检查文件
- `requirements/<requirementId>/generated/*.md`
- `requirements/<requirementId>/metadata.json`
- `requirements/<requirementId>/changelog.md`
- `requirements/<requirementId>/execution-state.json`
- `requirements/<requirementId>/proposal.md`
- `requirements/<requirementId>/tasks.md`

### 通过判定
- [ ] 至少有 `metadata.json`
- [ ] 至少有 `execution-state.json`
- [ ] 至少有 `generated/*.md`

### 失败回退
- 保留当前 `requirements` 目录，先不要删除
- 记录失败步骤，优先修复桥接或落盘链路

---

## 六、本轮最终结论模板

```text
宿主环境：Copilot
是否识别 root-level skills：
是否体现 manual 流程语义：
是否能稳定给出下一步建议命令：
桥接脚本是否正常落盘：
当前推荐模式：manual / auto
当前最大问题：
下轮是否继续联调：是 / 否
```

---

## 七、本轮建议

### 如果结果较好
继续进入：
- Copilot 第二轮联调
- 进一步验证命令映射和结果承接

### 如果结果一般
保守建议：
- Copilot 按 `manual` 使用
- 依赖 skill 规则 + 手动命令 + scaffold 落盘

### 如果结果较差
建议：
- 暂时只把 Copilot 作为阅读/解释型宿主
- 暂不要求它进入自动化链路

