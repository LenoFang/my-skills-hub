# 看板与风险模块（BIZ-KANBAN-001 ~ 004）

> 主 SKILL.md 的子文档。记录采购看板、风险看板、物料风险和看板数据服务入口。

## BIZ-KANBAN-001 前端与 Controller

| 业务 | 前端路径 | Controller |
|---|---|---|
| 采购看板 | `front-pc/src/pages/purchaseBoard` | `KanbanController` |
| 采购风险 | `front-pc/src/pages/risk` | `ProcurementRiskController`、`ProcurementRiskSyncController` |
| 采购效率 | `front-pc/src/pages/purchaseBoard` | `ProcurementEfficiencyController`、`ProcurementEfficiencySyncController` |
| 物料风险 | `front-pc/src/pages/risk` | `MaterialRiskController` |

---

## BIZ-KANBAN-002 Service 入口

| Service | 说明 |
|---|---|
| `IProcurementRiskService` / `ProcurementRiskServiceImpl` | 采购风险服务 |
| `IProcurementEfficiencyService` / `ProcurementEfficiencyServiceImpl` | 采购效率服务 |
| `IProcurementContractOperationService` / `ProcurementContractOperationServiceImpl` | 采购合同操作服务 |
| `IMaterialRiskService` / `MaterialRiskServiceImpl` | 物料风险服务 |
| `IBoardStatisticsDataService` / `BoardStatisticsDataServiceImpl` | 看板统计数据服务 |

---

## BIZ-KANBAN-003 看板数据服务

| Service | 说明 |
|---|---|
| `IBoardAssetsDataService` / `BoardAssetsDataServiceImpl` | 资产数据看板 |
| `IBoardSafetyStockDataService` / `BoardSafetyStockDataServiceImpl` | 安全库存数据看板 |
| `IBoardRetainedInventoryDataService` / `BoardRetainedInventoryDataServiceImpl` | 滞留库存数据看板 |
| `IBoardExpirationDataService` / `BoardExpirationDataServiceImpl` | 效期数据看板 |

---

## BIZ-KANBAN-004 系统配置

| 配置处理器 | 说明 |
|---|---|
| `KanbanSceneConfigHandler` | 看板场景配置 |
| `KanbanRiskTimeRangeConfigHandler` | 看板风险时间范围配置 |
| `KanbanRiskCopyWritingConfigHandler` | 看板风险文案配置 |

---

## 变更摘要

| 日期 | 业务编号 | 描述 |
|------|---------|------|
| 2026-05-28 | BIZ-KANBAN-001 ~ 004 | 新增看板、采购风险、采购效率、物料风险和看板数据服务映射 |
