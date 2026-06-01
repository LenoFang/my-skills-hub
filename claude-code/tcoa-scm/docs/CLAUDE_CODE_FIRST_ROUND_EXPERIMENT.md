# TCOA Skills：Claude Code 首轮实测记录（执行稿）

## 目标
本轮只验证最关键的最小闭环，不追求一步到位：

1. Claude Code 是否能识别父级 `.claude/skills/` 下 root-level `tcoa-*` skill
2. Claude Code 是否能体现 `tcoa-router -> tcoa-context -> auto/manual` 的分流语义
3. Claude Code 是否能配合插件命令推进需求
4. 本地桥接脚本是否能正常落盘到：
   - `requirements/`
   - `metadata.json`
   - `execution-state.json`
   - 标准 Markdown 文档
5. 是否在流程结束前进入 `tcoa-review`
6. 失败时是否能稳定回退到 `manual`

> 本轮不强求验证：phase 自动续跑、复杂多轮状态机、全插件全自动协同。

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
先手动验证桥接脚本：

```powershell
powershell -ExecutionPolicy Bypass -File ".\.claude\skills\tcoa-scm\bin\tcoa-scaffold.ps1" status
powershell -ExecutionPolicy Bypass -File ".\.claude\skills\tcoa-scm\bin\tcoa-scaffold.ps1" state
```

### 通过标准
- `status` 正常输出当前需求信息
- `state` 正常输出 `execution-state.json`

### 失败回退
- 如果这一步失败，先不要进入 Claude Code 联调
- 先修桥接脚本或 `tcoa-scaffold`

---

## 二、测试范围

### 本轮重点测 4 件事
1. **skill 识别**
2. **auto/manual 分流**
3. **插件命令协作能力**
4. **落盘与状态承接**

### 本轮暂不重点测
1. `gsd-plan-phase -> gsd-execute-phase` 的自动续跑
2. 多宿主差异对比
3. 插件复杂错误恢复

---

## 三、测试用例 1：root-level skills 识别

### 测试输入
在 Claude Code 中输入：

```text
继续当前需求，按半自动模式推进，并使用 OpenSpec、Superpowers、GSD
```

### 预期行为
应至少体现以下语义：
- 先判断是否已有当前需求
- 识别模式为 `manual`
- 识别工具链为 `openspec + superpowers + gsd`
- 准备进入逐步确认流程

### 通过判定
满足以下 3 项即可判定通过：
- [ ] 有“先上下文、后执行”的表现
- [ ] 能识别 `manual`
- [ ] 能识别 3 个工具

### 失败判定
若出现以下任一情况，视为失败：
- 完全无 skill 流程语义
- 无法体现上下文判断
- 无法识别模式与工具链

### 失败回退
- 改为明确输入：
  - “请按 `tcoa-router` 的思路处理当前需求”
- 若仍不稳定，则本轮先按 `manual` + 文档驱动方式继续

---

## 四、测试用例 2：auto/manual 分流

### 测试输入 A（auto）

```text
直接做完，不用每步确认。用 OpenSpec + GSD 处理当前需求，并把结果落到 requirements 文档里。
```

### 预期行为 A
- 识别为 `auto`
- 识别 `openspec + gsd`
- 倾向直接推进流程

### 测试输入 B（manual）

```text
一步步来，每一步先给我确认。用 OpenSpec、Superpowers、GSD 做当前需求。
```

### 预期行为 B
- 识别为 `manual`
- 先展示当前步骤、预期产物、下一步动作
- 不应直接跳过确认点

### 通过判定
- [ ] A 能表现为 `auto`
- [ ] B 能表现为 `manual`
- [ ] B 中存在“先确认再继续”的行为

### 失败回退
- 如果 Claude Code 不能稳定分流，则统一按 `manual` 执行
- 用 `HOST_RUNTIME_CHECKLIST.md` 记录“当前宿主 manual 优先”

---

## 五、测试用例 3：插件命令协作能力

## 测试输入

```text
请按当前 skill 流程推进需求，如果不能自动调用插件命令，就明确告诉我下一条该执行的命令。
```

### 观察项
需要观察 Claude Code 对插件命令的处理是：

#### 模式 A：可自动调用
- 自动推进 `OpenSpec` / `Superpowers` / `GSD`
- 自动承接上一步输出

#### 模式 B：不可自动调用，但能正确提示
- 明确告诉用户下一条建议命令
- 说明预期产物
- 等用户执行后再继续

### 通过判定
满足以下任一即可视为本轮通过：
- [ ] 能自动调用插件命令
- [ ] 不能自动调用，但能稳定提示下一步命令并解释原因

### 失败判定
- 无法自动调用
- 也无法稳定给出下一步建议

### 失败回退
- 直接进入 `manual`
- 用户手动执行插件命令
- skill 负责解释、整理、回填与记录

---

## 六、测试用例 4：落盘与状态承接

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
- [ ] 结束前存在 review 行为或 review 结论

### 失败回退
- 保留当前 `requirements` 目录，不要立即删除
- 记录失败步骤
- 下轮优先修复落盘链路，再重测宿主

---

## 七、本轮最终结论模板

```text
宿主环境：Claude Code
是否识别 root-level skills：
是否能正确分流 auto/manual：
是否支持自动调用插件命令：
如果不支持，是否能正确提示下一步命令：
桥接脚本是否正常落盘：
当前推荐模式：auto / manual
review 是否已完成：
当前最大问题：
下轮是否继续联调：是 / 否
```

---

## 八、本轮建议

### 如果结果较好
继续进入：
- Claude Code 第二轮联调
- 补更细的命令映射验证

### 如果结果一般
保守建议：
- Claude Code 暂按 `manual` 使用
- 先依赖 skill 规则 + 手动命令执行 + scaffold 落盘

### 如果结果较差
建议：
- 暂停自动化验证
- 先确保桥接、文档、状态、目录结构完全稳定
- 后续再回头验证宿主能力

