---
name: tcoa-execute
description: "[内部 skill，由 tcoa-router 链式调用，不应独立触发] TCOA 执行 skill。按 mode (auto|manual) 分支处理，主流程结束必须转入 tcoa-review。"
---

# tcoa-execute

## 门禁
- phase ∈ {`initialized`, `branching`, `review-failed`, `executing-auto`(续跑), `executing-manual`(续跑)}
- 进入时写 phase = `executing-auto`（auto）或 `executing-manual`（manual），追加 skillChain

## 触发条件
- 由 tcoa-router 在 phase 合法时调用
- 用户显式说"全自动/直接做完" → mode=auto
- 用户显式说"半自动/一步步" → mode=manual

## 核心原则
- review 不可绕过：结束必须写 phase = `awaiting-review`
- 降级必须留痕：写入 degradations + changelog
- 失败立即停止：gsd 失败 → phase = `paused`
- 工具命令从 `.tcoa/command-registry.json` 读取，不硬编码

## 步骤宣告（用户可读）

每个关键阶段开始时输出用户可读宣告（与输出契约并存）：

| 阶段 | 宣告格式 |
|------|----------|
| 影响预检 | `▶ 正在进行 GitNexus 影响预检` |
| 读取回执 | `▶ 正在读取业务代码` |
| 编码实现 | `▶ 正在进行编码实现` |
| 转入审查 | `▶ 编码完成，转入代码审查` |

**要求**：宣告必须在对应阶段开始时输出，不得省略或合并。

## GitNexus 影响预检（trivial/small 轻量，medium/large 完整）
改动前对主目标符号执行 `gitnexus_impact`：
- trivial/small → 仅检查 d=1 直接依赖（`maxDepth: 1`），LOW/MEDIUM 直接继续，HIGH/CRITICAL 提示用户
- medium/large → 完整检查（`maxDepth: 2`），HIGH/CRITICAL → AskUserQuestion 确认
- 目标符号未被索引 → 跳过并 warning，不阻塞

## 编码前轻量回执（仅 medium/large）

影响预检通过后、编码前，输出一行回执确认已读取关键代码：

```
[读取回执] Entity: <名称> ✓ | Service: <名称> ✓ | Rules: R-FORCE-001/002 ✓
```

**来源优先级**：
1. `.tcoa/grill-result.json` 的 coreEntities/coreServices
2. `proposal.md` §代码上下文
3. 无上述来源时，从 business-rules-mapping grep 关键词
4. grep 也无法定位时，输出 `[读取回执] 无法定位核心符号，跳过` 并继续

**门禁**：medium/large 未输出回执不得开始编码。trivial/small 可跳过。

## Graphify 模块视图提示（跨模块时）
从 `.tcoa/project-config.json` 的 `projectModules` 读取模块列表。
检测到涉及 ≥2 个模块时，在执行前提示：
```
检测到跨模块变更（涉及：<模块列表>）。是否需要 Graphify 模块视图辅助分析？
```
用户确认后调用 tcoa-graphify，否则跳过继续执行。

## decisions.md 追加规则

**manual 模式**：每步 AskUserQuestion 确认后，自动追加一条决策记录到 `requirements/<id>/decisions.md`：
```
## <步骤名>
- **时间**: <今日>
- **选择**: <用户确认的内容>
- **理由**: <用户说明或 AI 推断>
```

**auto 模式**：遇到 AskUserQuestion（GitNexus HIGH/CRITICAL、changeSize 超出预估）时同样追加。

## 执行流程（按 mode + changeSize 路由）

### auto 模式
| changeSize | 流程 |
|---|---|
| trivial | 轻量路径：impact(d=1) → 直接改动 → awaiting-review |
| small | registry→gsd.quick → awaiting-review |
| medium | registry→openspec.propose → registry→gsd.quick --validate → awaiting-review |
| large | 并行 SubAgent(openspec+superpowers) → 直接 Skill(gsd.quick --full) → awaiting-review |

### manual 模式
7 步确认序列：工具预览 → 方案确认 → 探索确认 → 任务拆解 → 实施改动 → 进入 review → 归档确认
每步用 AskUserQuestion，未确认不写文件。

### 模式切换
- auto→manual：写 phase=executing-manual，保留 skillChain
- manual→auto：写 phase=executing-auto，已确认步骤不重做

## 工具引用方式（从 registry）
```
registry = 读取 .tcoa/command-registry.json
cmd = registry["tools"]["gsd"]["commands"]["quick"]
Skill(skill=cmd["skill"], args=cmd["flags"][changeSize])
```

## 降级矩阵
| 工具 | 失败处理 |
|---|---|
| gsd | 阻塞，phase → paused |
| openspec | 降级到仅 gsd |
| superpowers | 允许跳过 |

## 三次失败停止原则（调试红线）

修复同一问题时严格遵循失败次数门槛：

| 失败次数 | 动作 |
|---------|------|
| **第 1 次** | 重新分析根因（systematic-debugging：读错误 → 追溯数据流 → 找工作示例） |
| **第 2 次** | 换方案，寻找备选路径（不在原方案上打补丁） |
| **第 3 次** | **停止编码，phase → paused，向用户报告架构性问题** |

**触发"架构性问题"的模式**（满足任一即停止）：
1. 链式暴露：改 A → B 报错 → 改 B → C 报错（耦合蔓延）
2. 大规模重构：修复需改动 ≥3 个模块或 ≥5 个文件
3. 循环症状：修复后在不同模块产生新的相同症状

**报告格式**（写入 `requirements/<id>/decisions.md`）：
```markdown
## 三次失败停止 - <问题简述>
- **时间**: <YYYY-MM-DD>
- **尝试 1**: <方案> → 失败原因：<具体错误>
- **尝试 2**: <方案> → 失败原因：<具体错误>
- **尝试 3**: <方案> → 失败原因：<具体错误>
- **暴露模式**: <链式暴露/大规模重构/循环症状>
- **建议**: 停止症状修复，重新设计 <模块> 的 <边界/职责分离/数据流>
- **预估**: 重构工作量 <文件数/天数>，需与用户确认是否值得
```

**不适用场景**（不计入失败次数）：
- 环境问题（Node 版本、依赖缺失）
- 配置错误（typo、路径错误）
- 测试数据问题（mock 不匹配真实协议）

## 输出契约
```
[skill: tcoa-execute]
[phase-before: initialized|branching|review-failed] → [phase-after: awaiting-review|paused]
[mode: auto|manual] [changeSize: ...] [tools: ...]
[degradations: <count>] [next-skill: tcoa-review]
```

## 必须 AskUserQuestion 的场景
1. gsd 失败
2. GitNexus HIGH/CRITICAL 风险
3. changeSize 超出预估
4. manual 模式每步进入前

## 不做的事
- 不绕过 review 直接 completed
- 不在 phase 不合法时执行
- 不静默切换 mode

## Token Pressure Mode（压缩输出应急）

当会话上下文预算紧张（compact 临近、长链路多模块改动、已反复补上下文）时，切换到压缩输出：

**进入条件**（满足任一）：
- 模型检测到距离 compact 仅剩 < 30% 预算
- 用户显式说 "caveman"、"压缩输出"、"少点废话"、"token 吃紧"
- 长链路多 SubAgent 并行，主线程只做协调

**压缩规则**：
- 丢弃：冠词 / 填充词（"just", "really", "basically"）/ 客套话 / 过度解释
- 保留：技术术语（class / method / 错误信息原文）、代码块、contract 格式
- 用箭头表示因果：`X -> Y`
- 用缩写：DB / auth / req / res / fn / impl
- 一个词够就一个词

**退出条件**（满足任一恢复正常输出）：
- 上下文预算恢复 > 50%
- 用户说 "解释下" / "normal mode" / "stop caveman"
- 进入破坏性 / 不可逆操作确认（安全警告必须详尽）

**示例对比**：
> 普通："I'll check the context first, then run the GSD tool to implement the feature. Let me start by reading the configuration file."
>
> 压缩："Read config. Run gsd. Impl feature."

**不压缩的场景**（即使 token 吃紧也要写清楚）：
- 破坏性操作确认（删除 / 重置 / force push）
- 安全警告
- 多步依赖顺序
- 用户反复问同一点

## 详细参考 → 见 REFERENCE.md
