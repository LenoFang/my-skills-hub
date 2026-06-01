# TCOA Skills 命令插件映射表（初版）

## 目标
明确 skill 与插件命令之间的关系：
- 什么场景调用哪个命令
- 上一步返回什么，下一步怎么接
- 哪些结果写入状态文件
- 哪些结果同步进标准文档

> 说明：本映射表先定义“流程契约”，不假设所有宿主都支持自动发起这些命令。若宿主不支持自动命令调用，则由 skill 在对应步骤提示用户手动执行。

---

## 1. 总体原则

1. **skill 决定流程**，插件命令负责生成内容。
1.1 **不要混淆 skill 与插件命令**：
   - `tcoa-router`、`tcoa-auto-execute`、`tcoa-review` 是 skill
   - `/superpowers:brainstorming`、`/superpowers:writing-plans` 是插件命令
2. **插件输出必须落盘** 到：
   - `generated/*.md`
   - 标准文档（如 `proposal.md`、`tasks.md`）
   - `execution-state.json`
3. **动态参数优先写状态**，不依赖用户记忆。
4. **manual 模式下，任何下一步命令都应先展示再确认。**

---

## 2. OpenSpec

### `/opsx:explore`
#### 适用场景
- 需求模糊
- 需要先澄清范围和目标

#### 产物
- `generated/openspec-output.md`
- `proposal.md`
- 必要时 `spec.md`

#### 状态推进
写入 `execution-state.json`：
```json
{
  "toolState": {
    "openspec": {
      "lastCommand": "/opsx:explore",
      "status": "success",
      "lastOutputFile": "openspec-output.md"
    }
  },
  "lastStep": "openspec:explore",
  "nextStep": "openspec:propose"
}
```

### `/opsx:propose`
#### 适用场景
- 已基本明确需求
- 需要输出较结构化方案

#### 产物
- `generated/openspec-output.md`
- `proposal.md`
- `spec.md`

#### 状态推进
```json
{
  "lastStep": "openspec:propose",
  "nextStep": "superpowers:writing-plans 或 gsd-plan-phase"
}
```

---

## 3. Superpowers

> 正确顺序：先 `brainstorming` 做头脑风暴，再 `writing-plans` 基于风暴结果沉淀执行计划。

### `/superpowers:brainstorming`
#### 适用场景
- 需要发散方案
- 需要快速列风险点、方向备选项

#### 产物
- `generated/superpowers-output.md`
- `design.md`（可选）

#### 状态推进
```json
{
  "toolState": {
    "superpowers": {
      "lastCommand": "/superpowers:brainstorming",
      "status": "success",
      "lastOutputFile": "superpowers-output.md"
    }
  },
  "lastStep": "superpowers:brainstorming",
  "nextStep": "superpowers:writing-plans 或 gsd-plan-phase"
}
```

### `/superpowers:writing-plans`
#### 适用场景
- 已完成需求澄清
- 需要形成实施计划

#### 产物
- `generated/superpowers-output.md`
- `proposal.md`
- `design.md`

#### 状态推进
```json
{
  "lastStep": "superpowers:writing-plans",
  "nextStep": "gsd-plan-phase"
}
```

### `/superpowers:requesting-code-review`
#### 适用场景
- 代码完成后
- 需要审查、补风险和改进点

#### 产物
- `generated/superpowers-output.md`
- 评审记录（可先并入 `design.md` 或新增 review 文档）

#### 状态推进
```json
{
  "lastStep": "superpowers:requesting-code-review",
  "nextStep": "completed"
}
```

---

## 4. GSD

### `/gsd-plan-phase <topic>`
#### 适用场景
- 需要把需求拆成多个 phase
- 进入真正执行前的计划拆分阶段

#### 产物
- `generated/gsd-output.md`
- `tasks.md`
- `execution-state.json` 中的 `planId` / `phases`

#### 状态推进
```json
{
  "currentFlow": "gsd",
  "lastStep": "gsd-plan-phase",
  "nextStep": "gsd-execute-phase",
  "planId": "plan-001",
  "phases": [
    { "id": 1, "title": "分析", "status": "pending" },
    { "id": 2, "title": "实现", "status": "pending" }
  ]
}
```

### `/gsd-execute-phase <phaseId>`
#### 适用场景
- 执行某一个具体 phase

#### 产物
- `generated/gsd-output.md`
- `tasks.md`
- 必要时同步 `proposal.md` / `design.md`

#### 状态推进
```json
{
  "lastStep": "gsd-execute-phase",
  "nextStep": "gsd-execute-phase 或 gsd-progress",
  "phases": [
    { "id": 1, "title": "分析", "status": "done" },
    { "id": 2, "title": "实现", "status": "pending" }
  ]
}
```

### `/gsd-progress`
#### 适用场景
- 汇总当前执行进度
- 准备进入完成/收尾阶段

#### 产物
- `generated/gsd-output.md`
- `tasks.md`
- `metadata.json`

#### 状态推进
```json
{
  "lastStep": "gsd-progress",
  "nextStep": "completed"
}
```

---

## 5. E2E

### `/e2e <scope>`
#### 适用场景
- 需要针对某块需求自动生成或补充测试

#### 产物
- `generated/e2e-output.md`
- 测试说明文档
- 必要时写入测试用例文件（后续再细化）

#### 状态推进
```json
{
  "toolState": {
    "e2e": {
      "lastCommand": "/e2e <scope>",
      "status": "success",
      "lastOutputFile": "e2e-output.md"
    }
  },
  "lastStep": "e2e",
  "nextStep": "completed 或 review"
}
```

---

## 6. 自动 / 半自动差异

### auto
- skill 自动决定是否进入下一条命令
- phase 编号从 `execution-state.json` 读取
- 非关键失败按降级规则继续

### manual
- skill 展示：
  - 当前命令
  - 当前状态
  - 预期产物
  - 下一步建议
- 用户确认后再执行

---

## 7. 当前建议的优先落地顺序

1. 先把 GSD 链路接通：
   - `gsd-plan-phase`
   - `gsd-execute-phase`
   - `gsd-progress`
2. 再补 OpenSpec：
   - `explore`
   - `propose`
3. 再补 Superpowers：
   - `brainstorming`
   - `writing-plans`
   - `requesting-code-review`
4. 最后补 E2E

---

## 8. 结论

这份映射表的价值不是替代插件文档，而是把：
- skill
- 插件命令
- 状态文件
- 标准文档

四者真正连成一个可执行流程。

