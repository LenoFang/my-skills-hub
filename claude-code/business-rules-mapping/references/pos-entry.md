# POS 独立入口（BIZ-POS-001 ~ 006）

> 主 SKILL.md 的子文档。只记录已在仓库中确认存在的 `front-pos` 页面、`project-mobile` POS Controller、POS Service、Entity/VO/Enum。

## BIZ-POS-001 POS 前端应用入口

| 业务 | 前端路径 | 路由文件 | 后端入口 |
|---|---|---|---|
| POS 登录和首页 | `front-pos/src/pages/login`、`front-pos/src/pages/home` | `front-pos/src/router/index.js` | `PosAdminUserController`、`PosApiUserController`、`PosHomeController` |
| 门店管理 | `front-pos/src/pages/shopManagement` | `front-pos/src/router/index.js` | `PosShopAdminController`、`PosShopApiController` |
| 商品列表 | `front-pos/src/pages/goodsList` | `front-pos/src/router/index.js` | `PosProductController`、`PosProductApiController` |
| 价格管理和调价 | `front-pos/src/pages/priceManagement`、`front-pos/src/pages/priceAdjustment` | `front-pos/src/router/index.js` | `PosProductController`、`PosProductPriceChangeController` |
| 订单和交班 | `front-pos/src/pages/orderList`、`front-pos/src/pages/shiftHandoverManagement` | `front-pos/src/router/index.js` | `PosOrderController`、`PosOrderApiController`、`PosHandoverAdminController`、`PosHandoverApiController` |
| 推送和补货 | `front-pos/src/pages/pushManagement`、`front-pos/src/pages/autoReplenishment` | `front-pos/src/router/index.js` | `PosPushController`、`PosReplenishmentConfigController` |
| 数据分析和用户 | `front-pos/src/pages/dataList`、`front-pos/src/pages/userManagement` | `front-pos/src/router/index.js` | `PosProductController`、`PosAdminUserController` |

---

## BIZ-POS-002 POS 管理端 Controller

| 业务 | Controller | API 前缀 / 关键接口 | Service |
|---|---|---|---|
| 管理端登录、资源、用户 | `PosAdminUserController` | `/pos/admin/user/login`、`/listResource`、`/listRole`、`/saveUser`、`/resetPassword`、`/pageUser`、`/changePassword`、`/userInfo` | `PosUserServiceImpl` |
| 管理端公共数据 | `CommonAdminController` | `/pos/admin/common/user-list`、`/authUserList`、`/operationsManual`、`/configCenter/{key}`、`/getAppLog`、`/refundCompensation` | `PosUserServiceImpl`、`PosRefundServiceImpl` |
| 门店管理 | `PosShopAdminController` | `/pos/admin/shop/listPage`、`/detail`、`/save`、`/del`、`/editShopStatus`、`/shop-list`、`/shop-all-list` | `PosShopServiceImpl` |
| 商品、价格、库存周转 | `PosProductController` | `/pos/admin/product/list`、`/getProductDetailById`、`/findPricePageList`、`/synchronizeSalesProduct`、`/effectiveProcessingOfProductPrices`、`/findInventoryTurnoverPage` | `PosProductServiceImpl` |
| 调价申请 | `PosProductPriceChangeController` | `/pos/admin/productPriceChange/list`、`/getDetail`、`/submitPriceChangeForm`、`/withdrawPriceChangeForm/{id}`、`/init/import/{accountingAttribution}` | `PosProductPriceChangeServiceImpl`、`PosProductPriceChangeDetailServiceImpl` |
| 订单查询 | `PosOrderController` | `/pos/admin/order/findOrderList`、`/getOrderDetail`、`/export` | `PosOrderServiceImpl` |
| 交班审核和导出 | `PosHandoverAdminController` | `/pos/admin/handover/listPage`、`/un-check-count`、`/checkHandover`、`/detail`、`/handover-export`、`/handover-sale-export`、`/handover-payment-export` | `PosHandoverServiceImpl`、`PosHandoverSaleServiceImpl`、`PosHandoverPaymentServiceImpl` |
| 补货配置 | `PosReplenishmentConfigController` | `/pos/admin/replenishment/config/list`、`/detail`、`/save`、`/del`、`/export`、`/template/export`、`/import` | `PosReplenishmentConfigServiceImpl` |
| 推送管理和补偿 | `PosPushController` | `/pos/admin/push/list`、`/changeRequestData`、`/push`、`/rePush`、`/complete`、`/detail`、`/logs` | `PosPushServiceImpl`、`PosPushLogServiceImpl` |

---

## BIZ-POS-003 POS API Controller

| 业务 | Controller | API 前缀 / 关键接口 | Service |
|---|---|---|---|
| API 登录、验证码、切换门店 | `PosApiUserController` | `/pos/api/user/login`、`/loginOut`、`/generateVerifyCode`、`/userInfo`、`/setLoginShop` | `PosUserServiceImpl` |
| API Token | `TokenController` | `/pos/api/token/get` | `PosUserServiceImpl` |
| 公共数据和应用版本 | `CommonApiController` | `/pos/api/common/user-list`、`/add-log`、`/app-version` | `PosUserServiceImpl` |
| 门店列表 | `PosShopApiController` | `/pos/api/shop/shop-list`、`/shop-all-list` | `PosShopServiceImpl` |
| 商品、库存数量 | `PosProductApiController` | `/pos/api/product/findProductCategoryList`、`/findProductPriceInfoList`、`/inventory/product/quantity`、`/inventory/shop/quantity`、`/inventory/shop/availableQuantity` | `PosProductServiceImpl` |
| 收银下单和支付状态 | `PosProductSettlementApiController` | `/pos/api/product/settlement/submitOrder`、`/getOrderPaymentStatus`、`/getOrderPaymentResult`、`/listingProduct` | `PosProductServiceImpl`、`PosOrderServiceImpl`、`PosPayServiceImpl` |
| 订单查询、退款、取消 | `PosOrderApiController` | `/pos/api/order/findOrderList`、`/getOrderDetail`、`/refund`、`/cancel`、`/getApprovalQrCodeUrl` | `PosOrderServiceImpl`、`PosRefundServiceImpl` |
| 支付和退款回调 | `CommonPayController` | `/pos/api/commonPay/callback`、`/refundCallback` | `PosPayServiceImpl`、`PosRefundServiceImpl` |
| 库存流转 | `PosFlowApiController` | `/pos/api/flow/ask-list`、`/allot/ask-list`、`/allot/receive-list`、`/detail`、`/copy`、`/recall`、`/ask/submit`、`/allot/submit`、`/receive/submit`、`/receive/reject`、`/period-list` | `PosInventoryFlowServiceImpl`、`PosInventoryFlowSubServiceImpl`、`PosInventoryFlowMaterialServiceImpl`、`PosInventoryFlowBatchServiceImpl` |
| 盘点提交 | `PosInventoryPlanController` | `/pos/api/inventory/submit` | `PosInventoryPlanServiceImpl` |
| API 交班 | `PosHandoverApiController` | `/pos/api/handover/findHandoverInfoList`、`/findHandoverPaymentInfoList`、`/save`、`/listPage`、`/detail` | `PosHandoverServiceImpl`、`PosHandoverSaleServiceImpl`、`PosHandoverPaymentServiceImpl` |
| POS 任务补偿 | `PosJopApiController` | `/pos/api/job/autoRetryPushData`、`/monitorFailedPushData` | `PosPushServiceImpl` |

---

## BIZ-POS-004 POS Service 边界

| 业务 | Service 接口 / 实现 | 说明 |
|---|---|---|
| 用户和门店 | `PosUserService` / `PosUserServiceImpl`、`PosShopService` / `PosShopServiceImpl` | POS 用户、角色资源、门店资料 |
| 商品和价格 | `IPosProductService` / `PosProductServiceImpl`、`IPosProductPriceChangeService` / `PosProductPriceChangeServiceImpl`、`IPosProductPriceChangeDetailService` / `PosProductPriceChangeDetailServiceImpl` | POS 商品、价格、调价申请、调价明细 |
| 订单、支付、退款 | `IPosOrderService` / `PosOrderServiceImpl`、`IPosOrderProductService` / `PosOrderProductServiceImpl`、`IPosPayService` / `PosPayServiceImpl`、`IPosRefundService` / `PosRefundServiceImpl`、`IPosRefundProductService` / `PosRefundProductServiceImpl`、`IPosRefundOrderService` / `PosRefundOrderServiceImpl` | POS 订单、订单商品、支付、退款、退款订单 |
| 库存流转和盘点 | `PosInventoryFlowService` / `PosInventoryFlowServiceImpl`、`PosInventoryFlowSubService` / `PosInventoryFlowSubServiceImpl`、`PosInventoryFlowMaterialService` / `PosInventoryFlowMaterialServiceImpl`、`PosInventoryFlowBatchService` / `PosInventoryFlowBatchServiceImpl`、`PosInventoryPlanService` / `PosInventoryPlanServiceImpl` | POS 申领、调拨、收货、周期流转、盘点提交 |
| 交班 | `PosHandoverService` / `PosHandoverServiceImpl`、`PosHandoverSaleService` / `PosHandoverSaleServiceImpl`、`PosHandoverPaymentService` / `PosHandoverPaymentServiceImpl` | 交班主表、销售明细、支付明细 |
| 推送和补货 | `PosPushService` / `PosPushServiceImpl`、`PosPushLogService` / `PosPushLogServiceImpl`、`PosReplenishmentConfigService` / `PosReplenishmentConfigServiceImpl`、`PosOutApiService` / `PosOutApiServiceImpl` | POS 外部推送、推送日志、补货配置、对外 API |

---

## BIZ-POS-005 POS 数据对象和枚举

| 类型 | 路径 | 内容 |
|---|---|---|
| Entity | `base-domain/src/main/java/com/tcoa/scm/domain/dataobject/master/pos` | `PosUserEntity`、`PosShopEntity`、`PosProductEntity`、`PosProductPriceChangeEntity`、`PosOrderEntity`、`PosPayEntity`、`PosRefundEntity`、`PosInventoryFlowEntity`、`PosHandoverEntity`、`PosPushEntity`、`PosReplenishmentConfigEntity` |
| VO / DTO / Request | `base-domain/src/main/java/com/tcoa/scm/domain/viewobject/pos` | POS 查询、保存、导出、接口请求、收银结算、库存流转、交班、退款、推送相关对象 |
| Enum | `base-domain/src/main/java/com/tcoa/scm/domain/enums/pos` | `PosOrderTypeEnum`、`PosOrderStatusEnum`、`PosOrderActionEnum`、`PosPaymentStatusEnum`、`PosRefundStatusEnum`、`PosPushStatusEnum`、`PosPushSourceEnum`、`PosInventoryFlowTypeEnum`、`PosInventoryFlowStatusEnum`、`PosRoleEnum`、`EffectiveStatusEnum`、`PosAccountingAttributionEnum` |

---

## BIZ-POS-006 与销售/POS 库存文档的边界

| 文档 | 覆盖范围 |
|---|---|
| `references/sales-pos.md` | PC 端销售基础资料、销售订单、销售出库、销售退货、PC 侧 POS 库存入口 |
| `references/pos-entry.md` | `front-pos` 独立应用、`project-mobile` 下 `/pos/admin/**` 和 `/pos/api/**`、POS Service、POS Entity/VO/Enum |

## 变更摘要

| 日期 | 业务编号 | 描述 |
|------|---------|------|
| 2026-05-28 | BIZ-POS-001 ~ 006 | 新增 POS 独立前端、管理端 API、移动 API、Service、数据对象和边界说明 |
