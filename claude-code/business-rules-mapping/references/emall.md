# 电商商城模块（BIZ-EMALL-001 ~ 006）

> 主 SKILL.md 的子文档。只记录已确认存在的前端目录、Controller、Service、API 集成与审批处理器入口。

## BIZ-EMALL-001 前端与 API 分层

| 类型 | 路径 |
|---|---|
| 电商前端根目录 | `front-emall/src` |
| 管理页面 | `front-emall/src/pages/mallManagement` |
| VOP 页面 | `front-emall/src/pages/vop` |
| 前端 API | `front-emall/src/utils/api` |
| 后端管理 Controller | `project-pc/src/main/java/com/tcoa/scm/pc/controller/emall` |
| 后端开放 API Controller | `project-pc/src/main/java/com/tcoa/scm/pc/controller/api/Emall*ApiController.java` |
| 后端 Service | `base-service/src/main/java/com/tcoa/scm/service/emall` |

---

## BIZ-EMALL-002 商品、分类、规则、标签、活动、优惠券

| 业务 | 前端目录 | Controller | Service |
|---|---|---|---|
| 商品 | `mallManagement/goodsManagement`、`vop/goodsManagement` | `EmallGoodsController`、`EmallGoodApiController` | `EmallGoodsService`、`EmallGoodsDetailService`、`EmallGoodsMaterialService` |
| 商品规则 | `mallManagement/goodsRules` | `EmallGoodsRulesController`、`EmallGoodsRulesRelationController` | `EmallGoodsRulesService`、`EmallGoodsRulesRelationService` |
| 分类 | `mallManagement/classificationManagement`、`vop/classify` | `EmallCategoryPlatformController` | `EmallCategoryPlatformService`、`EmallGoodsCategoryService`、`SyncEmallCategoryService` |
| 标签 | `mallManagement/tagManagement` | `EmallTagsController` | `EmallTagsService`、`EmallGoodsTagsService` |
| 活动 | `mallManagement/activityManager` | `EmallActivityController`、`EmallActivityTemplateController` | `EmallActivityService`、`EmallActivityTemplateService`、`EmallActivityProductService` |
| 优惠券 | `mallManagement/couponManager` | `EmallCouponBatchController`、`EmallCouponBatchClaimScopeController`、`EmallCouponBatchUseScopeController` | `IEmallCouponBatchService`、`IEmallCouponBatchClaimScopeService`、`IEmallCouponBatchUseScopeService` |

---

## BIZ-EMALL-003 订单、售后、库存、物流、发票、对账、支付

| 业务 | 前端目录 | Controller | Service |
|---|---|---|---|
| 订单 | `mallManagement/orderManagement` | `EmallOrderController`、`EmallOrderApiController` | `EmallOrderService`、`EmallOrderAssetService`、`EmallOrderSupplierService`、`EmallOrderValuationService` |
| 售后 | `mallManagement/afterSalesManagement` | `EmallReturnExchangeController`、`EmallCustomerServiceController` | `EmallReturnExchangeService`、`EmallCustomerServiceService` |
| 库存 | `mallManagement/inventoryQuantity`、`mallManagement/inventoryFlowManagement` | `EmallInventoryController`、`EmallInventorySubController`、`EmallInventoryFlowController` | `EmallInventoryService`、`EmallInventorySubService`、`EmallInventoryFlowService`、`EmallInventoryAssetService` |
| 物流 | `front-emall/src/components/logistics` | `EmallLogisticsController`、`EmallLogisticsApiController` | `EmallLogisticsService` |
| 发票 | `mallManagement/invoice` | `EmallInvoiceController`、`EmallOrderInvoiceController`、`EmallOrderInvoiceApplyController` | `EmallInvoiceService`、`EmallOrderInvoiceService`、`EmallOrderInvoiceApplyService`、`EmallOrderInvoiceApplyItemService` |
| 对账 | `mallManagement/accounting` | `EmallReconciliationController`、`EmallReconciliationApiController` | `EmallReconciliationService`、`EmallReconciliationOrderService`、`EmallReconciliationAuditService` |
| 支付 | - | `EmallPaymentController` | `EmallPaymentService`、`EmallPaymentSubService` |

---

## BIZ-EMALL-004 企业、授信、保证金、用户

| 业务 | 前端目录 | Controller | Service | Wolf 处理器 |
|---|---|---|---|---|
| 企业 | `mallManagement/enterprise` | `EmallEnterpriseController` | `EmallEnterpriseService`、`EmallEnterpriseApprovalService` | `EmallEnterpriseWolfServiceImpl` |
| 授信 | `mallManagement/credit` | `EmallEnterpriseCreditController` | `IEmallEnterpriseCreditService`、`IEmallEnterpriseCreditFlowService` | `EmallEnterpriseCreditWolfServiceImpl`、`EmallEnterpriseCreditRepaymentWolfServiceImpl` |
| 保证金 | `mallManagement/deposit` | `EmallEnterpriseDepositController` | `IEmallEnterpriseDepositService`、`IEmallEnterpriseDepositFlowService` | `EmallEnterpriseDepositWolfServiceImpl` |
| 用户 | `mallManagement/account`、`mallManagement/account-logout` | `EmallMemberController`、`EmallUserCancelRecordController`、`EmallUserApiController` | `EmallUserService`、`EmallEmployeeService`、`EmallUserCancelRecordService` | `EmallEmployeeRoleWolfServiceImpl` |

---

## BIZ-EMALL-005 外部 API 与工具

| 类型 | 代码位置 |
|---|---|
| 认证 API | `EmallAuthApiController` |
| 商城聚合 API | `EmallApiController` |
| 虚拟采购 API | `EmallVirtualPurchaseApiController` |
| 任务 API | `EmallJobApiController` |
| 区域 | `EmallRegionController`、`EmallRegionService` |
| 充值 | `EmallRechargeController`、`EmallRechargeService` |
| 购物车 | `EmallShoppingCartController`、`EmallShoppingCartService` |
| 弹窗通知 | `EmallPopUpNotificationController`、`EmallPopUpNotificationService` |
| 访问日志 | `EmallAccessLogController`、`EmallAccessLogService` |
| EPS API 工具 | `service/emall/epsapi/EpsApiUtil.java` |
| 发票 API 工具 | `service/emall/invoice/InvoiceApi.java` |
| 优惠券 API 工具 | `service/emall/coupon/CouponApi.java` |

---

## BIZ-EMALL-006 MQ 与业务事件入口

| 类型 | 代码位置 |
|---|---|
| 付款申请生产方 | `EmallReconciliationServiceImpl` 使用 `EXTERNAL_PAYMENT_APPLY_TAG` |
| 付款回调消费方 | `PaymentCallbackMqHandler` 使用 `EXTERNAL_PAYMENT_APPLY_TAG_CALLBACK` |
| 虚拟采购事件 | `VirtualPurchaseBusinessEvent`、`VirtualPurchaseBusinessEventManage`、`VirtualPurchaseBusinessListener` |

---

## 变更摘要

| 日期 | 业务编号 | 描述 |
|------|---------|------|
| 2026-05-28 | BIZ-EMALL-001 ~ 006 | 新增电商商城前端、Controller、Service、审批、MQ/事件入口映射 |
