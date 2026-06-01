# 库存池与盘点模块（BIZ-STOCK-001 ~ 004）

> 主 SKILL.md 的子文档。只记录已在仓库中确认存在的前端目录、Controller 和 Service。

## BIZ-STOCK-001 库存池、库存流水、库存调整

| 业务 | 前端路径 | Controller | Service |
|---|---|---|---|
| 库存池 | `front-pc/src/pages/inventoryPool/inventoryDataPool` | `InventoryDataPoolController` | `InventoryDataPoolServiceImpl` |
| 库存流水 | `front-pc/src/pages/inventoryPool/serialOrder` | `InventorySerialOrderController` | `InventorySerialOrderServiceImpl`、`InventorySerialSubServiceImpl` |
| 库存调整 | `front-pc/src/pages/inventoryPool/inventoryFormAdjust` | `InventoryFormAdjustController` | `InventoryFormAdjustServiceImpl` |

---

## BIZ-STOCK-002 库存快照、成本和结存

| 业务 | 前端路径 | Controller | Service |
|---|---|---|---|
| 库存快照 | `front-pc/src/pages/snapshot` | `MaterialInventorySnapshotController` | `MaterialInventorySnapshotServiceImpl`、`MaterialInventorySnapshotSubServiceImpl` |
| 库存成本/结存 | `front-pc/src/pages/inventoryPool/balance`、`front-pc/src/pages/materialsmanage/real/cost.vue` | `InventoryPeriodController` | `InventoryPeriodServiceImpl`、`InventoryCostServiceImpl` |

**库存快照已确认入口**：

| 类型 | 代码位置 |
|---|---|
| 页面 Controller | `MaterialInventorySnapshotController`，根路径 `/inventoryPool/snapshot` |
| API Controller | `MaterialInventorySnapshotApiController`，根路径 `/api/snapshot/` |
| 页面 API | `/init`、`/list`、`/detail`、`/delete`、`/save`、`/export`、`/import/{id}` |
| 同步 API | `POST /api/snapshot/sync`、`POST /api/snapshot/shop/sync` |

---

## BIZ-STOCK-003 盘点计划与确认

| 业务 | 前端路径 | Controller | Service |
|---|---|---|---|
| 盘点计划 | `front-pc/src/pages/assetcycle/inventory/planList.vue` | `InventoryPlanController` | `InventoryPlanServiceImpl` |
| 盘点确认 | `front-pc/src/pages/assetcycle/inventory/confirmList.vue` | `InventoryConfirmController` | `InventoryConfirmServiceHelper`、`InventoryConfirmServiceImpl`、`InventoryConfirmUserServiceImpl` |
| 库存盘点计划 | `front-pc/src/pages/assetcycle/stock` | `InventoryStockPlanController` | `InventoryStockPlanServiceImpl`、`InventoryStockPlanSubServiceImpl` |
| 库存盘点确认 | `front-pc/src/pages/assetcycle/stock` | `InventoryStockConfirmController` | `InventoryStockConfirmMaterialsServiceImpl` |

---

## BIZ-STOCK-004 盘点差异与 RFID

| 业务 | 前端路径 | Controller | Service |
|---|---|---|---|
| 盘点差异 | `front-pc/src/pages/inventoryPool/discrepancy` | `InventoryCustomDiscrepancyController` | `InventoryCustomDiscrepancyServiceImpl`、`InventoryCustomDiscrepancySubServiceImpl` |
| RFID 页面 | `front-pc/src/pages/rfid` | `RFIDPlanController`、`RFIDConfirmController` | `InventoryRfPlanServiceImpl`、`InventoryRfConfirmAssetsServiceImpl` |

---

## 变更摘要

| 日期 | 业务编号 | 描述 |
|------|---------|------|
| 2026-05-28 | BIZ-STOCK-001 ~ 004 | 新增库存池、库存流水、调整、快照、成本结存、盘点、差异、RFID 代码映射 |
| 2026-05-28 | BIZ-STOCK-002 | 补充库存快照页面 Controller、API Controller 和同步入口 |
