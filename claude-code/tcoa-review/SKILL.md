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
从 `.tcoa/command-registry.json` 的 `tools.review.buildGates` 读取命令：
- `buildGates.compile` → 后端 Java 文件改动时执行
- `buildGates.lint` → 前端文件改动时执行
- 失败 → phase = `review-failed`，转回执行 phase 修复
- trivial/small 跳过

### 2. 测试门禁（仅 medium/large，非阻塞）
- 从 registry 的 `review.buildGates.test` 读取命令
- 失败 → AskUserQuestion 询问是否继续 review
- trivial/small 跳过

### 3. review 子代理（从 registry 读取类型）
- `subagent_type = registry["tools"]["review"]["subagents"][key]["type"]`（取 `.type` 字段，非 key 名）
- trivial/small → 仅 `subagents.code`（code-reviewer）
- medium → `subagents.code` + `subagents.security`（涉及认证/输入/DB 时）；优先使用 `.claude/agents/backend-developer.md` / `frontend-developer.md` / `dba-expert.md`（按改动类型）
- large → `subagents.code` + `subagents.security` + `subagents.java`，全部并行；`subagents.java` 对应 `.claude/agents/backend-developer.md`

**子 agent 提示词**：优先使用 `.claude/agents/tcoa-code-reviewer.md`，无则内嵌提示词。

调用示例：
```
Agent({
  subagent_type: "code-reviewer",
  prompt: `请按 .claude/agents/tcoa-code-reviewer.md 执行代码审查。
    需求目录：{REQUIREMENT_DIR}
    变更范围：{DIFF_OR_SCOPE}
    changeSize：{CHANGE_SIZE}`
})
```

### 4. 结论处理
- 无 CRITICAL/HIGH → phase = `review-passed`
- 有 CRITICAL/HIGH → phase = `review-failed`，reviewFailCount++
- reviewFailCount ≥ 3 → 强制 AskUserQuestion 人工介入
- 仅 MEDIUM/LOW → AskUserQuestion 是否放行

### 4.5 产物自检表（review-passed 后必须输出）

review 结论为 passed 或 conditional-passed 时，必须输出以下自检表：

```markdown
## 产物自检

| 阶段 | 产物 | 状态 | 路径/说明 |
|------|------|------|-----------|
| grill | grill-result.json | ✓/- | bizCode 或"无"；trivial 档固定为 - |
| context | 需求描述 | ✓/✗ | raw-requirement.md / proposal.md / tasks.md 任一含需求 |
| context | changeSize 最小工件 | ✓/✗ | 见 §0 工件表 |
| execute | 代码变更 | ✓/✗ | N files, +X -Y |
| execute | GitNexus 预检 | ✓/-/✗ | risk 级别 (medium/large) |
| execute | 读取回执 | ✓/- | Entity+Service+Rules (medium/large) |
| review | build 门禁 | ✓/✗/- | 命令或"跳过" |
| review | 决定性检查 | ✓/✗ | N issues |
| review | 启发式检查 | ✓/⚠️ | N suggestions |

**结论**：N/N 必需 ✓，可进入 git-flow
```

**状态说明**：✓=通过，✗=失败，⚠️=有建议，-=不适用/跳过

**tasks.md 格式提示**（⚠️ 不阻塞）：扫描 tasks.md 中的任务条目，若超过半数缺少"**验证**"字段，追加一行：
```
| review | tasks.md 格式 | ⚠️ | 部分任务缺少验证标准，建议参考 requirements/_template/tasks.md |
```

**必需产物**（任一 ✗ 不得进入 git-flow）——与 §0 工件完整性 lint 的 changeSize 工件表对齐：
- 需求描述（raw-requirement.md / proposal.md 需求章节 / tasks.md 需求说明，三者有其一即可）
- 当前 changeSize 对应的最小工件（trivial=tasks.md；small 及以上=proposal.md/design.md/tasks.md）
- 代码变更
- 决定性检查通过

> 说明：raw-requirement.md 非所有档位强制产物（见 §0），trivial 档只产 tasks.md。
> 此处只要求"需求可追溯"，按档位取对应工件中的需求描述即可，避免与 context 工件表冲突造成死锁。

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

## 业务规则映射一致性检查（review-passed 前）

在产物自检表输出前，检查本次变更是否涉及以下类型，若命中则提示更新对应 reference：

| 命中条件 | 需更新的 reference |
|---------|------------------|
| 新增/删除 Controller 方法 | `business-rules-mapping/references/<module>.md` 对应 BIZ 编号 |
| 新增/删除 Wolf Handler（`@WolfHandler`） | `references/wolf-approval.md` |
| 新增/删除 MQ Handler | `references/mq-events.md` |
| 新增库存冻结调用方 | `references/inventory-freeze.md` |
| 新增定时任务（`@Scheduled`/Quartz） | `references/operations-jobs.md` |

**执行方式**：
1. 通过 `git diff` 扫描变更文件名，判断是否命中上述条件
2. 命中时在产物自检表末尾追加一行提示（不阻塞 review-passed）：
```
| review | business-rules-mapping | ⚠️ | 涉及 <类型>，建议更新 references/<file>.md |
```
3. 不强制要求在本次 review 中完成，但 HIGH 级别（新增 Wolf Handler/Controller）建议在 git-flow 前更新

## 不做的事
- 不跳过 review 直接 completed
- 不在 CRITICAL/HIGH 存在时写 review-passed
- 不修改业务代码（review 只产出结论）

## 详细参考 → 见 REFERENCE.md
