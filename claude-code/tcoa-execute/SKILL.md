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
- 工具命令从 `.tcoa/project-config.json` 读取，不硬编码

## GitNexus 影响预检（仅 medium/large）
改动前对主目标符号执行 `gitnexus_impact`：
- LOW → 继续
- MEDIUM → 继续，snapshot §4 记录
- HIGH/CRITICAL → AskUserQuestion 确认

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
| trivial | 不应进入本 skill |
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
registry = 读取 .tcoa/project-config.json
cmd = registry["tools"]["gsd"]["commands"]["quick"]
Skill(skill=cmd["skill"], args=cmd["flags"][changeSize])
```

## 降级矩阵
| 工具 | 失败处理 |
|---|---|
| gsd | 阻塞，phase → paused |
| openspec | 降级到仅 gsd |
| superpowers | 允许跳过 |

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
