# 采购执行模块（BIZ-PO-001 ~ 006）

> 主 SKILL.md 的子文档。只记录已在仓库中确认存在的前端目录、Controller 和 Service。

## BIZ-PO-001 采购订单与采购变更

| 业务 | 前端路径 | Controller | Service |
|---|---|---|---|
| 采购订单 | `front-pc/src/pages/purchase`、`front-pc/src/pages/servicefeemanage/purchaseorder` | `PurchaseOrderController` | `PurchaseOrderServiceImpl`、`PurchaseOrderSubServiceImpl`、`PurchaseOrderPaymentServiceImpl` |
| 采购变更 | `front-pc/src/pages/purchase` | `PurchaseChangeController` | `PurchaseChangeServiceImpl`、`PurchaseChangeSubServiceImpl` |

---

## BIZ-PO-002 采购退货

| 业务 | 前端路径 | Controller | Service |
|---|---|---|---|
| 采购退货 | `front-pc/src/pages/purchase/return` | `PurchaseReturnController` | `PurchaseReturnServiceImpl`、`PurchaseReturnReportServiceImpl` |

---

## BIZ-PO-003 价格库和价格申请

| 业务 | 前端路径 | Controller | Service |
|---|---|---|---|
| 价格库/价格申请 | `front-pc/src/pages/purchase/priceApply` | `MaterialPriceController`、`MaterialPriceApplyController`、`MaterialPriceApplySubController`、`MaterialPriceApplySupplierController` | `MaterialPriceServiceImpl`、`MaterialPriceApplyServiceImpl`、`MaterialPriceApplySubServiceImpl`、`MaterialPriceApplySupplierServiceImpl` |

---

## BIZ-PO-004 采购合同

| 业务 | 前端路径 | Controller | Service |
|---|---|---|---|
| 采购合同 | `front-pc/src/pages/servicefeemanage/purchaseContract` | `PurchaseContractController` | `PurchaseContractServiceImpl` |
| 合同关联 | `front-pc/src/pages/servicefeemanage/purchaseContract` | `PurchaseContractAssociationController` | `PurchaseContractAssociationServiceImpl` |
| 采购订单合同 | `front-pc/src/pages/servicefeemanage/purchaseContract` | `PurchaseOrderContractController` | `PurchaseOrderContractServiceImpl` |

---

## BIZ-PO-005 采购看板与分析

| 业务 | 前端路径 | Controller | Service |
|---|---|---|---|
| 采购看板 | `front-pc/src/pages/purchaseBoard`、`front-pc/src/pages/purchase/dashboard` | `PurchaseBusinessController`、`PurchaseDashboardController` | `PurchaseBusinessServiceImpl`、`PurchaseDashboardServiceImpl` |

---

## BIZ-PO-006 EBS 采购汇总

| 业务 | Controller | Service |
|---|---|---|
| EBS 采购汇总 | `EbsPurchaseSummaryController`，根路径 `/ebspurchasesummary` | `IEbsPurchaseSummaryService` / `EbsPurchaseSummaryServiceImpl`、`IEbsPurchaseSummarySubService` / `EbsPurchaseSummarySubServiceImpl` |

**已确认 API**：`/list`、`/AutoSync`、`/unsettledcount`、`/getEpsInfoDetail`、`/exportList`。

---

## 变更摘要

| 日期 | 业务编号 | 描述 |
|------|---------|------|
| 2026-05-28 | BIZ-PO-001 ~ 005 | 新增采购订单、采购变更、采购退货、价格库、采购合同、采购看板代码映射 |
| 2026-05-28 | BIZ-PO-006 | 补充 EBS 采购汇总 Controller、Service 和 API 入口 |
