# 物料价格模块（BIZ-PRICE-001 ~ 003）

> 主 SKILL.md 的子文档。记录物料价格库、价格申请、供应商与审批入口。

## BIZ-PRICE-001 物料价格库

| 类型 | 代码位置 |
|---|---|
| Controller | `MaterialPriceController`，根路径 `/materialPrice` |
| Service | `IMaterialPriceService` / `MaterialPriceServiceImpl` |
| Facade | `MaterialPriceQueryFacadeImpl` |

已确认 API：`/list`、`/export`、`/getDetail`、`/findMaterialPriceInfoListByIds`。

---

## BIZ-PRICE-002 物料价格申请

| 类型 | 代码位置 |
|---|---|
| Controller | `MaterialPriceApplyController`，根路径 `/materialPriceApply` |
| Service | `IMaterialPriceApplyService` / `MaterialPriceApplyServiceImpl` |
| 前端路径 | `front-pc/src/pages/materialsmanage` 中价格相关页面，`front-pc/src/pages/servicefeemanage` 中采购合同/订单相关页面 |
| Wolf 处理器 | `MaterialPriceApplyWolfServiceImpl` |

已确认 API：`/init`、`/searchContractList`、`/list`、`/export`、`/findSubList`、`/findHistoryPriceListByApplySubId`、`/findHistoryPriceList`、`/getDetail`、`/saveMaterialPriceApplyInfo`、`/recallApply`、`/materialPriceAnalysis`。

---

## BIZ-PRICE-003 明细与供应商

| 业务 | Controller | Service |
|---|---|---|
| 价格申请明细 | `MaterialPriceApplySubController`，根路径 `/materialPriceApplySub` | `IMaterialPriceApplySubService` / `MaterialPriceApplySubServiceImpl` |
| 价格申请供应商 | `MaterialPriceApplySupplierController`，根路径 `/materialPriceApplySupplier` | `IMaterialPriceApplySupplierService` / `MaterialPriceApplySupplierServiceImpl` |

已确认 API：`/init/export`、`/init/import/{type}`、`downLoadErrorExcel`、`/list`、`/export`、`/getDetail`。

---

## 变更摘要

| 日期 | 业务编号 | 描述 |
|------|---------|------|
| 2026-05-28 | BIZ-PRICE-001 ~ 003 | 新增物料价格库、价格申请、明细、供应商和 Wolf 审批映射 |
