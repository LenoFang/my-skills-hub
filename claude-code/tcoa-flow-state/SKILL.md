---
name: tcoa-flow-state
description: "[内部 skill，被 tcoa-* 全系列引用，不应独立触发] TCOA 流程状态机共享规范。所有 tcoa-* skill 必须遵循此处定义的状态枚举、流转规则与门禁条件。"
---

# tcoa-flow-state

> **所有 tcoa-* skill 的唯一权威状态规范**。执行任何动作前必须校验 phase 合法性。
>
> **多会话隔离**：focused（当前焦点需求）由会话级 session lock 维护，不再写入 `.tcoa/current-context.json`。详见 `tcoa-context/SKILL.md` 的"会话级 focused 锁定协议"。

## 一、状态枚举（phase）

| phase | 含义 |
|---|---|
| `uninitialized` | 无需求上下文 |
| `initialized` | 需求目录已建，未开始执行 |
| `branching` | 正在创建/确认 Git 分支 |
| `executing-auto` | 全自动执行中 |
| `executing-manual` | 半自动执行中 |
| `awaiting-review` | 等待 review |
| `reviewing` | review 进行中 |
| `review-failed` | review 不通过，需返工 |
| `review-passed` | review 通过 |
| `awaiting-git` | 等待 git 操作确认 |
| `git-flowing` | git 操作中 |
| `e2e-testing` | e2e 测试中（可选） |
| `completed` | 需求收尾（终态） |
| `paused` | 用户暂停 |

## 二、合法流转

```
uninitialized       → initialized
initialized         → branching | executing-auto | executing-manual | completed(abort)
branching           → executing-auto | executing-manual | initialized | completed(abort)
executing-auto      → awaiting-review | paused | completed(abort)
executing-manual    → awaiting-review | paused | completed(abort)
awaiting-review     → reviewing | completed(abort)
reviewing           → review-failed | review-passed | completed(abort)
review-failed       → executing-auto | executing-manual | completed(abort)
review-passed       → awaiting-git | e2e-testing | completed
e2e-testing         → awaiting-git | review-failed | completed
awaiting-git        → git-flowing | completed
git-flowing         → completed | review-passed | awaiting-git
paused              → 任何之前的 phase | completed(abort)
```

**禁止流转**（检测到必须中断并报错，abort 除外）：
- `executing-* → completed`（绕过 review，abort 除外）
- `executing-* → git-flowing`（绕过 review）
- `awaiting-review → completed`（abort 除外）
- `uninitialized → executing-*`

## 三、门禁规则

| Skill | 允许进入的 phase |
|---|---|
| tcoa-router | 无门禁，但必须先调用 tcoa-context |
| tcoa-context | 任何（负责读取和校验 phase） |
| tcoa-context(init) | `uninitialized`, `completed`, `initialized`(用户确认覆盖) |
| tcoa-execute | `initialized`, `branching`, `review-failed`, `executing-auto`(续跑), `executing-manual`(续跑) |
| tcoa-review | `awaiting-review`, `executing-auto`, `executing-manual`, `reviewing`(续跑), `e2e-testing`(续跑) |
| tcoa-git-flow | `initialized`(建分支), `branching`, `review-passed`, `awaiting-git`, `git-flowing`(续跑) |

## 四、execution-state.json 关键字段

```json
{
  "schemaVersion": 2,
  "requirementId": "...",
  "phase": "awaiting-review",
  "previousPhase": "executing-auto",
  "mode": "auto",
  "tools": ["gsd"],
  "changeSize": "medium",
  "skillChain": [{"skill": "...", "at": "..."}],
  "reviewStatus": {"required": true, "completed": false, "result": null, "findings": []},
  "gitStatus": {"branchCreated": false, "branchName": null, "committed": false, "pushed": false, "merged": false},
  "nextSuggestedSkill": "tcoa-review",
  "degradations": [],
  "updatedAt": "..."
}
```

## 五、输出契约（所有 tcoa-* skill 必须遵守）

```
[skill: <skill-name>]
[phase-before: <旧 phase>] → [phase-after: <新 phase>]
[skillChain: tcoa-router → tcoa-context → ...]
[mode: auto|manual] [changeSize: trivial|small|medium|large] [tools: gsd,...]
[sessionFocused: <requirementId>]
[next-skill: <建议下一个 skill>]
```

## 六、changeSize 分级

| 级别 | 判定标准 | 推荐流程 |
|---|---|---|
| `trivial` | ≤30 行，单文件 | 跳过 init，直接改 + 轻量 review |
| `small` | ≤200 行，≤3 文件 | 简化 init + GSD + 标准 review |
| `medium` | ≤500 行，多文件 | 完整 init + GSD/OpenSpec + 标准 review |
| `large` | >500 行，跨模块 | 完整 init + OpenSpec + GSD + 严格 review |

## 七、漂移检测注册表（供 `/tcoa health` 使用）

每种漂移类型有独立检测器 + 幂等修复建议，cap=1 重试上限。

| 类型 | 检测方式 | 修复建议 | 重试上限 |
|---|---|---|---|
| `phase-drift` | execution-state.json 的 phase 值不在枚举内 | 提示用户选择最近合法 phase | 1 |
| `double-write` | requirements/ 和 openspec/changes/ 存在同名活跃 change | 提示降级 openspec 为参考 | 0 |
| `artifact-missing` | changeSize 对应必要工件不存在 | 列出缺失项，提示补全或降档 | 0 |
| `orphan-requirement` | 目录存在但 execution-state 无 phase | 提示归档或补全 phase | 0 |
| `stale-review-passed` | phase=review-passed 超过 7 天未推进 | 提示进入 git-flow | 0 |
| `stale-lesson` | LESSONS.md 条目 hits=0 且 lastHitAt 超过 90 天 | 提示清理 | 0 |

## 八、变更目录权威声明

- **`requirements/<change-id>/`** 是唯一官方变更容器，所有工件以此为权威
- **`openspec/changes/`** 是外部工具产物，仅供参考，不与 `requirements/` 平权
- 同一需求若两处均有文件，以 `requirements/` 为准

## 详细参考

边界场景（续跑判定、review 失败回流、模式切换、git 失败处理）、持久化格式（context-snapshot.md、metadata.json 结构）、hook 协作等详细内容见 **REFERENCE.md**。
