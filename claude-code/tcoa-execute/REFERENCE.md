# tcoa-execute REFERENCE

> 本文件是 `tcoa-execute/SKILL.md` 的详细补充参考，按需读取。

## GitNexus 影响预检详细

### 触发时机
在调用任何代码改动工具之前，对主目标符号执行：
```
gitnexus_impact({target: "<symbolName>", direction: "upstream", maxDepth: 2})
```

### 风险处理
| risk | 处理 |
|---|---|
| LOW | 直接继续，snapshot §3 追加 `<symbol>:<line> — 风险 LOW，可改` |
| MEDIUM | 继续但 snapshot §4 追加决策行 |
| HIGH / CRITICAL | 强制 AskUserQuestion 二次确认；拒绝 → phase=paused(auto) 或切回上一步(manual) |

### 跳过条件
- 目标符号未被 GitNexus 索引 → 跳过预检并 warning
- 工具不可用 → 写 degradations，不阻塞

## Graphify 模块视图（可选）

触发条件（满足任一）：
- 变更涉及 ≥2 个 code-backend 子模块
- 用户请求 /graphify
- 重构规划

不触发：单模块/单文件改动，trivial/small

## auto 模式详细流程

### small（仅 gsd）
1. registry→gsd.quick 一步完成
2. 写 phase=awaiting-review → tcoa-review

### medium（gsd + openspec）
1. registry→openspec.propose 生成 proposal.md/spec.md
2. registry→gsd.quick --validate 规划+实施+验证
3. 写 phase=awaiting-review → tcoa-review

### large（gsd + openspec + superpowers 可选）
1. 并行阶段（SubAgent）：
   - Agent(openspec.propose) — 产出 proposal.md + spec.md
   - Agent(superpowers) — 可选，失败自动跳过
2. 收集并行结果，失败记 degradation
3. 串行阶段：直接 Skill(gsd.quick --full)
4. 写 phase=awaiting-review → tcoa-review

### auto 切 manual
用户说"还是一步步来吧" → 写 phase=executing-manual，进入 manual 当前步骤

## manual 模式详细确认序列

### 步骤 1：工具链与产物预览
AskUserQuestion 展示 mode/tools/changeSize/预期产物，选项：继续/调整/跳过/取消

### 步骤 2：方案确认（仅 tools 含 openspec）
openspec.propose 生成草稿（不写盘），展示摘要，用户同意后写入

### 步骤 3：探索/评审确认（仅 tools 含 superpowers，可选）
用户可跳过。brainstorming+writing-plans 草稿，用户同意写 design.md

### 步骤 4：执行拆解确认
展示 gsd.quick 任务拆解摘要，用户同意写 tasks.md

### 步骤 5：实施代码改动
gsd.quick 按任务推进。medium 用 --validate，large 用 --full
GitNexus 预检（medium/large）：HIGH/CRITICAL 拒绝 → 切回步骤 4

### 步骤 6：进入 review
写 phase=awaiting-review → tcoa-review

### 步骤 7：归档确认（review-passed 后）
展示更新文件列表，用户同意更新 metadata/changelog

### manual 切 auto
用户说"剩下全自动" → 写 phase=executing-auto，已确认步骤不重做

## 工具可用性检查
```
if registry["tools"][toolName]["installed"] === false:
    跳过，写入 degradation: {"from": "<tool>", "to": "skipped", "reason": "not installed"}
```

## 智能调度策略
| changeSize | 调度方式 | 原因 |
|---|---|---|
| trivial | 直接 Skill() | 单工具无并行 |
| small | 直接 Skill() | 单工具直接调用 |
| medium | 直接 Skill() | 串行依赖 |
| large 并行 | SubAgent 并行 | 独立任务同时运行 |
| large 串行 | 直接 Skill() | 依赖并行产物 |

## 必须回填的产物
退出前（写 phase=awaiting-review 之前）确保：
- generated/ 保存产物
- tasks.md/proposal.md/spec.md/design.md 同步更新
- metadata.json 写入 changeSize、tools、降级记录
- changelog.md 追加执行摘要
- execution-state.json phase=awaiting-review，nextSuggestedSkill=tcoa-review
- context-snapshot.md §5 追加切换记录

## context-snapshot 写入要求
累积桶：§3（代码发现）、§4（降级/风险决策）、§5（skill 切换/步骤确认/模式切换）、§7（Doc Status）
退出前合并为单次 Edit。

## 可观测性
每次调用插件前后在 skillChain 中记录：
```json
{"skill": "openspec-propose", "at": "...", "result": "success", "artifacts": ["proposal.md"]}
```
changelog.md 追加一行日志。
