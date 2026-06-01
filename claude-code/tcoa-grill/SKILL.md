---
name: tcoa-grill
description: "Use when 用户给出模糊需求需要逐项澄清、用户说 'grill me'、'挑刺'、'帮我把需求挑透'、'逐项追问'、'拷问需求'，或在 tcoa-router 入口前需求边界不清晰。一次问一个，能查代码就先查代码。"
---

# tcoa-grill

逐项追问 TCOA 需求的每个分支，直到达成共识。沿决策树每个分支走，按依赖顺序逐个解决。每个问题给出推荐答案。

**一次只问一个问题。**

**能从代码库回答的问题，先去查代码，不要问用户。**

## 何时使用

- 用户给出模糊需求（"做个物料申请的小功能"、"优化下盘点"）
- 进入 tcoa-router 但意图不明，AskUserQuestion 单次回答仍不足
- 用户主动要求"挑刺"、"拷问需求"、"grill me"

## 何时不用

- 需求已明确（用户给了完整 PRD 或 raw-requirement.md）
- 极小改动（typo、单点 bug 修复）
- 已经在 tcoa-execute 阶段——此时应走 tcoa-router 的暂停 / 切流，不是 grill

## 工作方式

1. **先查项目领域 skill，再查代码**：能从项目内 domain knowledge skill 回答的问题（如 TCOA 项目的 `business-rules-mapping`、其他项目的 `<project>-domain-knowledge`）必须先查；其次 grep 代码；最后才问用户
2. **逐项追问**：每个问题独立、聚焦一个决策点
3. **附推荐答案**：每个问题给一个默认建议 + 简短理由，用户可直接接受
4. **沿依赖前进**：上一个问题的答案决定下一个问题的内容
5. **形成共识即止**：达到能写需求文档 / proposal 的程度即停止 grill，进入 tcoa-router

> **领域 skill 契约**：本 skill 不 hard-code 任何项目特定 skill 名。在 TCOA.SCM 用 `business-rules-mapping`；在其他项目，按惯例查找 `*-domain-knowledge`、`*-business-rules`、`*-feature-map` 等命名的 skill。如项目无领域 skill，直接进入 grep + AskUserQuestion 流程，不报错。

## 输出格式

```
[?] <聚焦的单一问题>

推荐答案：<默认建议>
理由：<一句话>

可选答案：
- A. <选项 A>
- B. <选项 B>
- C. 其他（请说明）
```

## 追问完成后自动输出

当追问达成共识、准备退出 grill 进入 tcoa-router 时，执行以下步骤：

### Step 1：提取关键词

从追问过程中提取：
- 业务关键词（如"物料申请"、"库存冻结"、"采购订单"）
- 技术关键词（如"批量导入"、"审批流"、"报表"）

### Step 2：查询 business-rules-mapping

1. grep `business-rules-mapping/SKILL.md` 的模块导航表
2. 若命中 BIZ 编号，读取对应 `references/*.md` 提取：
   - 核心实体（Entity）
   - 核心服务（Service）
   - 核心控制器（Controller）
   - 前端页面目录
3. 若未命中，调用 `gitnexus_query({query: "<关键词>"})` 搜索

### Step 3：输出 grill-result

追问结束时，在常规输出后追加：

```
---
[grill-result]
keywords: 物料申请, 批量导入
bizCode: BIZ-MO-001
bizName: 物资申请
referenceFile: references/material-operations.md
coreEntities: MaterialApplyEntity, MaterialApplyDetailEntity
coreServices: IMaterialApplyService, MaterialApplyServiceImpl
coreControllers: MaterialApplyController
frontendDir: project-pc-vue/src/views/material/apply/
---
```

若未命中任何模块，输出：

```
---
[grill-result]
keywords: xxx
bizCode: null
bizName: null
note: 未匹配到现有业务模块，可能是新模块
---
```

### Step 4：写入临时文件

将 grill-result 写入 `.tcoa/grill-result.json`，供 tcoa-context(init) 读取：

```json
{
  "keywords": ["物料申请", "批量导入"],
  "bizCode": "BIZ-MO-001",
  "bizName": "物资申请",
  "referenceFile": "references/material-operations.md",
  "coreEntities": ["MaterialApplyEntity", "MaterialApplyDetailEntity"],
  "coreServices": ["IMaterialApplyService", "MaterialApplyServiceImpl"],
  "coreControllers": ["MaterialApplyController"],
  "frontendDir": "project-pc-vue/src/views/material/apply/",
  "createdAt": "2026-05-30T10:00:00+08:00"
}
```

## 不做的事

- 不一次抛出 5 个问题让用户挑
- 不问代码库能回答的问题（先查再问）
- 不在用户已明确的边界上反复确认
- 不擅自把 grill 结果直接写进 raw-requirement.md（应由 tcoa-router 接手处理）
- **不做影响分析（留给 tcoa-execute 的 GitNexus 预检）**
