---
name: tcoa-router
description: "TCOA 需求流程统一入口（强制首选）。Use when user invokes /tcoa, says '开始新需求', '续跑', '继续做', '帮我做', or starts/resumes a TCOA requirement workflow. 负责加载状态机、识别上下文、多需求路由、分流到下游 skill。含会话控制（pause/resume/abort）。"
---

# tcoa-router

> **本 skill 是 TCOA 流程的强制入口**。禁止直接跳到下游 skill。

## 触发关键词（任一命中即进入）
显式 `/tcoa`；需求型 `新需求/继续/帮我做`；模式型 `全自动/半自动`；工具型 `OpenSpec/GSD`；操作型 `改bug/重构/新功能`；调试型 `调试/报错/异常`

## 强制前置
1. 读取 `.claude/skills/tcoa-flow-state/SKILL.md` 加载状态机
2. 读取 `.tcoa/current-context.json`
   - schemaVersion=3：读取 `active` 数组（**无 focused 字段，由 session lock 决定**）
   - 旧版本（含 focused 字段）：自动迁移，删 focused 字段，schemaVersion 改为 3
3. **解析 sessionFocused**：调用 tcoa-context 的会话级 focused 锁定协议
4. 根据 sessionFocused 读取 `execution-state.json` 获取 phase
5. 若 active 为空，按 `phase = uninitialized` 处理

## 路由决策树

```
step 1: 多需求路由（schemaVersion=3 + session lock）
  ├─ active 为空 → phase=uninitialized
  ├─ 用户显式指定（/tcoa <name> | "继续 X"）→ 锁定到 X，写 lock
  ├─ 本目录有未过期 lock + active 包含其 ID → 询问"续用该 lock？"
  ├─ active 只有 1 个 → 自动锁定，写 lock
  ├─ active 多个 + "新需求" → intentMatch=新需求
  ├─ active 多个 + "继续"未指明 → AskUserQuestion 选择 → 写 lock
  └─ active 多个 + 意图不明 → AskUserQuestion + "新建"选项 → 写 lock

step 2: 调用 tcoa-context → mode, tools, changeSize, intentMatch, sessionFocused

step 3: 按 intentMatch + phase 分流
  ├─ 调试意图（调试/报错/异常/bug/修复）→ bugfix 轻量路径：跳过 init，直接 tcoa-execute(trivial)
  ├─ uninitialized / completed+新需求 → tcoa-context(init)
  ├─ 续跑 + initialized → tcoa-execute
  ├─ 续跑 + branching → tcoa-git-flow（继续建分支）
  ├─ 续跑 + executing-auto/manual → tcoa-execute（继续执行）
  ├─ 续跑 + awaiting-review → tcoa-review
  ├─ 续跑 + reviewing → tcoa-review（继续 review）
  ├─ 续跑 + review-failed → tcoa-execute（返工）
  ├─ 续跑 + review-passed → tcoa-git-flow
  ├─ 续跑 + e2e-testing → tcoa-review（继续 e2e）
  ├─ 续跑 + awaiting-git → tcoa-git-flow
  ├─ 续跑 + git-flowing → tcoa-git-flow（继续 git 操作）
  ├─ 续跑 + paused → 走会话控制 resume
  └─ 不确定 → AskUserQuestion

step 4: changeSize 分级
  trivial → 快速路径 | small → 简化 init + GSD
  medium → 完整 init + 工具链 | large → 完整 + OpenSpec + GSD

step 5: 模式 → tcoa-execute(auto|manual)

step 6: 写 execution-state + 维护 active[] + 维护 session lock
```

## 会话控制（pause / resume / abort）

| 关键词 | 前置 phase | 动作 |
|---|---|---|
| 暂停/pause | 非终态 | previousPhase=当前, phase=paused |
| 继续/resume | 必须=paused | phase=previousPhase, 清空 previousPhase |
| 放弃/abort | 任意 | AskUserQuestion 确认 → archived, 从 active 移除 + **删除 lock** |

## 控制台输出（极简，每次进入必须输出）

```
当前需求：<requirementId> | <需求标题>
当前阶段：<phase>
下一步：<next-skill 对应的操作说明，一句话>
```

仅在检测到以下情况时追加提示（否则静默）：
- 平行 change 存在（activeCount > 1 且未锁定）
- 检测到 `openspec/changes/` 与 `requirements/` 双写风险

## 独立路径

| 关键词 | 路由 |
|---|---|
| `health` / `健康` / `检查状态` | 健康检查：按 tcoa-flow-state §七 漂移检测注册表逐项扫描，输出报告 |
| `graphify` / `图谱` / `架构图` | 调用 tcoa-graphify |

## Token 约束（按需加载）

- tcoa-router 只读路由表（本文件），不预加载下游 skill
- 下游 skill 在路由决策后按需加载
- 参考类文档（`business-rules-mapping`、`LESSONS.md`）只 grep，不整读
- 每次进入首轮参考文档总行数 ≤ 150 行

## 输出契约
```
[skill: tcoa-router]
[phase-before: <phase>] → [phase-after: <phase>]
[sessionFocused: <requirementId>] [activeCount: <N>]
[mode: auto|manual] [changeSize: ...] [tools: gsd,...]
[next-skill: <下游 skill>]
[intentMatch: 续跑|新需求|不确定]
```

## 必须 AskUserQuestion 的场景
1. intentMatch=不确定
2. 多个 active 需求未指明操作哪个
3. abort 前强制二次确认
4. resume 前确认恢复目标
5. **检测到本目录未过期 lock + 用户未显式指定，确认是否续用**

## 不做的事
- 不直接创建目录、不直接执行工具链
- 不跳过 tcoa-context 的上下文加载
- 不在 phase 不允许时强行进入下游 skill
- 不在 intentMatch 不明时擅自决策
- **不写 `current-context.json` 的 focused 字段（已废弃，仅靠 session lock）**

## 详细参考 → 见 REFERENCE.md
