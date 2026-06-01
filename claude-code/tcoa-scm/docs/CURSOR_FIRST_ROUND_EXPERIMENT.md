# TCOA Skills：Cursor 首轮实测记录（执行稿）

## 目标
本轮只验证 Cursor 下最小可用闭环：

1. Cursor 是否能把 root-level `tcoa-*` 当作规则集参考
2. Cursor 是否能体现 `tcoa-router -> tcoa-context -> manual` 的分流语义
3. Cursor 是否能稳定给出“下一步建议命令”
4. 本地桥接脚本是否能正常落盘到 `requirements/` 与标准文档

> 本轮默认以 `manual` 为主，不强求自动调用插件命令。

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
1. root-level skills 是否被参考
2. manual 流程是否可用
3. 是否能给出下一条建议命令
4. 执行后是否能落盘

### 本轮暂不重点测
1. 插件命令全自动调用
2. phase 自动续跑
3. 多宿主差异对比

---

## 三、测试用例 1：规则识别

### 测试输入

```text
继续当前需求，按半自动模式推进，并使用 OpenSpec、Superpowers、GSD。
```

### 预期行为
- 有上下文判断语义
- 识别模式为 `manual`
- 识别工具链为 `openspec + superpowers + gsd`
- 倾向逐步确认，而不是直接执行到底

### 通过判定
- [ ] 有“先上下文、后执行”的表现
- [ ] 能识别 `manual`
- [ ] 能识别 3 个工具

### 失败回退
- 改为明确输入：“请按 `tcoa-router` 的思路处理当前需求”
- 若仍不稳定，则本轮按文档驱动方式执行

---

## 四、测试用例 2：下一步建议能力

### 测试输入

```text
请按当前 skill 流程推进需求，如果不能自动调用插件命令，就明确告诉我下一条该执行的命令和预期产物。
```

### 预期行为
- Cursor 不一定自动发命令，但应能给出：
  - 下一条建议命令
  - 为什么执行它
  - 预期产物是什么
  - 执行后要更新哪些文档

### 通过判定
- [ ] 能稳定给出下一条建议命令
- [ ] 能说明预期产物
- [ ] 能说明后续要更新的文件

### 失败回退
- 将 Cursor 作为“规则说明 + 手动命令执行”宿主使用

---

## 五、测试用例 3：落盘与状态承接

### 测试步骤
在完成一个最小需求流程后，执行：

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
- `requirements/<requirementId>/spec.md`（如适用）
- `requirements/<requirementId>/design.md`（如适用）

### 通过判定
- [ ] 至少有 `metadata.json`
- [ ] 至少有 `execution-state.json`
- [ ] 至少有 `generated/*.md`
- [ ] 标准文档有同步更新

### 失败回退
- 保留当前 `requirements` 目录
- 记录失败步骤
- 优先修复落盘链路，再重测 Cursor

---

## 六、本轮最终结论模板

```text
宿主环境：Cursor
是否识别 root-level skills：
是否能正确走 manual 流程：
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
- Cursor 第二轮联调
- 补更细的命令映射验证

### 如果结果一般
保守建议：
- Cursor 暂按 `manual` 使用
- 先依赖 skill 规则 + 手动命令执行 + scaffold 落盘

### 如果结果较差
建议：
- 暂停自动化验证
- 先确保 bridge、状态、文档结构都稳定

