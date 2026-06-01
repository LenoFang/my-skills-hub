# 总账推送规则映射（BIZ-LEDGER-001 ~ 003）

> 主 SKILL.md 的子文档。记录总账推送、自动规则、审计、调整的代码入口。具体业务判定以对应 Service 和规则表配置为准。

## BIZ-LEDGER-001 总账推送与页面入口

| 业务 | 前端路径 | Controller | Service |
|---|---|---|---|
| 总账推送 | `front-pc/src/pages/inventoryPool/pushLedger` | `SyncGeneralLedgerPushController` | `SyncGeneralLedgerPushServiceImpl` |
| 总账比对 | `front-pc/src/pages/inventoryPool/pushLedgerComparison` | `LedgerComparisonController` | `LedgerComparisonServiceImpl` |
| 总账审计 | `front-pc/src/pages/inventoryPool/pushLedgerAudit` | `SyncLedgerAuditLogController` | `SyncLedgerAuditLogServiceImpl` |
| 总账自动规则 | `front-pc/src/pages/inventoryPool/pushLedgerRule` | `SyncLedgerAutoRuleController` | `SyncLedgerAutoRuleServiceImpl` |
| 总账看板 | `front-pc/src/pages/inventoryPool/pushLedgerDashboard` | `SyncLedgerDashboardController` | - |
| 总账调整 | `front-pc/src/pages/inventoryPool/generalLedgerAdjust` | `GeneralLedgerAdjustController` | `GeneralLedgerAdjustServiceImpl` |

**核心实体/VO**：`SyncGeneralLedgerPushEntity`、`SyncGeneralLedgerDetailEntity`、`SyncGeneralLedgerLogEntity`、`SyncGeneralLedgerSubEntity`、`SyncLedgerAutoRuleEntity`、`SyncLedgerAutoRuleLogEntity`、`GeneralLedgerAdjustEntity`、`GeneralLedgerAdjustDetailEntity`、`GeneralLedgerAdjustSubEntity`。

---

## BIZ-LEDGER-002 自动规则动作

| 动作实现 | 枚举/动作类型来源 | 已确认行为入口 |
|---|---|---|
| `AutoRepushAction` | `LedgerAutoRuleActionEnum.AUTO_REPUSH` | 调用总账重推 |
| `DelayRepushAction` | `LedgerAutoRuleActionEnum.DELAY_REPUSH` | 投递 `LEDGER_DELAY_REPUSH` 延迟消息 |
| `AutoCompleteAction` | `LedgerAutoRuleActionEnum.AUTO_COMPLETE` | 自动完结 |
| `NotifyOnlyAction` | `LedgerAutoRuleActionEnum.NOTIFY_ONLY` | 记录通知/待人工处理 |
| `AutoRefineCostAction` | `LedgerAutoRuleActionEnum.AUTO_REFINE_COST` | 成本中心补全入口 |
| `AutoRefineProfitAction` | `LedgerAutoRuleActionEnum.AUTO_REFINE_PROFIT` | 利润中心补全入口 |
| `AutoRefineCurrentAction` | `LedgerAutoRuleActionEnum.AUTO_REFINE_CURRENT` | 往来段补全入口；代码返回“暂不支持” |
| `AutoRefineThenPushAction` | `LedgerAutoRuleActionEnum.AUTO_REFINE_THEN_PUSH` | 补全后重推入口 |

规则动作接口：`LedgerAutoRuleAction`。执行结果对象：`RuleActionResult`。`SyncLedgerAutoRuleServiceImpl` 通过 Spring 注入 `List<LedgerAutoRuleAction>` 并按 `getActionType()` 组装 `actionMap`。

---

## BIZ-LEDGER-003 延迟重推链路

| 节点 | 代码位置 | 说明 |
|---|---|---|
| 动作发起 | `DelayRepushAction` | 根据规则参数投递延迟消息 |
| MQ Tag | `Constant.TurboMqTags.LEDGER_DELAY_REPUSH` | 总账延迟重推 tag |
| MQ Handler | `LedgerDelayRepushMqHandler` | 消费延迟重推消息 |
| MQ 服务 | `ITurboMqService` / `TurboMqServiceImpl` | 生产延迟消息 |

---

## 变更摘要

| 日期 | 业务编号 | 描述 |
|------|---------|------|
| 2026-05-28 | BIZ-LEDGER-001 ~ 003 | 新增总账页面、自动规则动作、延迟重推链路映射 |
