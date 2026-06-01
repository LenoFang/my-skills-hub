---
name: tcoa-review
description: "[内部 skill，由 tcoa-router 链式调用，不应独立触发] TCOA 统一代码审查 skill。仅在 phase ∈ {awaiting-review, executing-auto, executing-manual} 时进入。review 结论决定后续流转。"
---

# tcoa-review

## 门禁
- phase ∈ {`awaiting-review`, `executing-auto`, `executing-manual`, `reviewing`(续跑), `e2e-testing`(续跑)}
- 进入时写 phase = `reviewing`，追加 skillChain

## 触发条件
- tcoa-execute 主流程结束后自动转入
- 用户显式说"做 code review / 快速检查"
- trivial 快速路径完成代码改动后也必须走本 skill

## 核心流程

### 0. 工件完整性 lint（review 前置）
按当前 changeSize 检查 `requirements/<id>/` 下必要工件是否存在：

| changeSize | 必须存在 |
|---|---|
| trivial | `tasks.md` |
| small | `proposal.md` `design.md` `tasks.md` |
| medium | small 档 + `context.md` |
| large | medium 档 + `test.md` `uat.md` |

缺失工件 → 列出缺失项，AskUserQuestion 是否补全后继续，或跳过直接 review。

### 1. build 门禁（仅 medium/large）
从 `.tcoa/project-config.json` 的 `buildGates` 读取命令：
- `buildGates.backend` → 后端改动时执行
- `buildGates.frontend` → 前端改动时执行
- 失败 → phase = `review-failed`，转回执行 phase 修复
- trivial/small 跳过

### 2. 测试门禁（仅 medium/large，非阻塞）
- 从 registry 的 `review.buildGates.test` 读取命令
- 失败 → AskUserQuestion 询问是否继续 review
- trivial/small 跳过

### 3. review 子代理（从 registry 读取类型）
- 从 `registry["tools"]["review"]["subagents"]` 读取 subagent_type
- trivial/small → 仅 code-reviewer
- medium → code-reviewer + security-reviewer（涉及认证/输入/DB 时）
- large → code-reviewer + security-reviewer + java-reviewer，全部并行

### 4. 结论处理
- 无 CRITICAL/HIGH → phase = `review-passed`
- 有 CRITICAL/HIGH → phase = `review-failed`，reviewFailCount++
- reviewFailCount ≥ 3 → 强制 AskUserQuestion 人工介入
- 仅 MEDIUM/LOW → AskUserQuestion 是否放行

### 5. review-passed 后
- 可选 e2e 测试（medium/large 推荐）
- AskUserQuestion 是否进入 git 流程
- 同意 → phase = `awaiting-git` → tcoa-git-flow
- 全部拒绝 → phase = `completed`

## 输出契约
```
[skill: tcoa-review]
[phase-before: awaiting-review|executing-*] → [phase-after: review-passed|review-failed|awaiting-git]
[review-mode: quick|standard|strict] [changeSize: ...]
[buildCheck: pass|fail|skipped|n/a]
[findings: CRITICAL:0 HIGH:0 MEDIUM:N LOW:N]
[reviewFailCount: N]
[next-skill: tcoa-git-flow|tcoa-execute|none]
```

## 必须 AskUserQuestion 的场景
1. MEDIUM/LOW 问题是否放行
2. reviewFailCount ≥ 3 人工介入
3. review-passed 后是否进入 git 流程
4. 测试失败是否继续 review

## 不做的事
- 不跳过 review 直接 completed
- 不在 CRITICAL/HIGH 存在时写 review-passed
- 不修改业务代码（review 只产出结论）

## 详细参考 → 见 REFERENCE.md
