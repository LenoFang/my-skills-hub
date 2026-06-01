# 销售与 POS 模块（BIZ-SALES-001 ~ 004）

> 主 SKILL.md 的子文档。只记录已在仓库中确认存在的前端目录、Controller 和 Service。

## BIZ-SALES-001 销售基础资料

| 业务 | 前端路径 | Controller | Service |
|---|---|---|---|
| 销售分类 | `front-pc/src/pages/salesManagement/classificationManagement` | `SalesCategoryController` | `SalesCategoryServiceImpl`、`SalesCategoryManagerServiceImpl` |
| 商品/产品 | `front-pc/src/pages/salesManagement/goodsManagement` | `SalesProductController` | `SalesProductServiceImpl`、`SalesProductSpecServiceImpl` |
| 销售 BOM | `front-pc/src/pages/salesManagement/bomManagement` | `SalesBomController` | `SalesBomServiceImpl`、`SalesBomMaterialServiceImpl`、`SalesBomVersionServiceImpl` |

---

## BIZ-SALES-002 销售订单、发货、出库

| 业务 | 前端路径 | Controller | Service |
|---|---|---|---|
| 销售订单 | `front-pc/src/pages/salesManagement/orderManagement` | `SalesOrderController` | `SalesOrderServiceImpl`、`SalesOrderProductServiceImpl`、`SalesOrderChangeServiceImpl`、`SalesOrderChangeProductServiceImpl` |
| 销售发货 | `front-pc/src/pages/salesManagement/orderManagementOutbound` | `SalesOrderDeliveryController` | `SalesOrderDeliveryServiceImpl`、`SalesOrderDeliveryAssetServiceImpl`、`SalesOrderDeliveryBatchServiceImpl` |
| 销售出库 | `front-pc/src/pages/salesManagement/orderOutbound` | `SalesOutboundOrderController` | `SalesOutboundOrderServiceImpl`、`SalesOutboundOrderProductServiceImpl`、`SalesOutboundOrderAssetServiceImpl`、`SalesOutboundOrderBatchServiceImpl` |

---

## BIZ-SALES-003 销售退货和利润报表

| 业务 | 前端路径 | Controller | Service |
|---|---|---|---|
| 销售退货 | `front-pc/src/pages/salesManagement/return` | `SalesReturnController` | `SalesReturnServiceImpl`、`SalesReturnProductServiceImpl`、`SalesReturnAssetServiceImpl` |
| 利润报表 | `front-pc/src/pages/salesManagement/profit` | `SalesProfitReportController` | `SalesProfitReportServiceImpl` |

---

## BIZ-SALES-004 POS 库存

| 业务 | 前端路径 | Controller |
|---|---|---|
| POS 库存 | `front-pc/src/pages/salesManagement/posInventory` | `PosApiController`、`PosReplenishmentConfigApiController` |

---

## 变更摘要

| 日期 | 业务编号 | 描述 |
|------|---------|------|
| 2026-05-28 | BIZ-SALES-001 ~ 004 | 新增销售基础资料、订单、发货、出库、退货、利润报表、POS 库存代码映射 |
