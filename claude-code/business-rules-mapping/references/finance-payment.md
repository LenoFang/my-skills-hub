# 财务主数据与付款集成（BIZ-FIN-001 ~ 005）

> 主 SKILL.md 的子文档。记录财务主数据、付款、回调、费控/财务接口入口。业务口径以具体 Service 和外部接口契约为准。

## BIZ-FIN-001 财务主数据

| 主数据 | Controller | Service |
|---|---|---|
| 财务公司 | `FinanceMdCompanyController` | `FinanceMdCompanyService` / `FinanceMdCompanyServiceImpl` |
| 成本中心 | `FinanceMdCostCenterController` | `FinanceMdCostCenterService` / `FinanceMdCostCenterServiceImpl` |
| 利润中心 | `FinanceMdProfitController` | `FinanceMdProfitService` / `FinanceMdProfitServiceImpl` |
| 科目 | `FinanceMdSubjectInfoController` | `FinanceMdSubjectInfoService` / `FinanceMdSubjectInfoServiceImpl` |
| 子目 | `FinanceMdSubsubjectController` | `FinanceMdSubsubjectService` / `FinanceMdSubsubjectServiceImpl` |
| 产品 | `FinanceMdProductController` | `FinanceMdProductService` / `FinanceMdProductServiceImpl` |
| 活动 | `FinanceMdActivityController` | `FinanceMdActivityService` / `FinanceMdActivityServiceImpl` |
| 商户 | - | `FinanceMdMerchantService` / `FinanceMdMerchantServiceImpl` |

公共服务：`FinanceMasterDataService`、`FinanceService` / `FinanceServiceImpl`。

---

## BIZ-FIN-002 财务接口与回调

| 类型 | 代码位置 |
|---|---|
| 财务 Controller | `project-pc/src/main/java/com/tcoa/scm/pc/controller/finance/FinanceController.java` |
| 财务 API Controller | `project-pc/src/main/java/com/tcoa/scm/pc/controller/finance/FinanceApiController.java` |
| 财务合同 API | `project-pc/src/main/java/com/tcoa/scm/pc/controller/api/FinanceContractApiController.java` |
| 财务回调接口 | `base-service/src/main/java/com/tcoa/scm/service/api/IFinanceCallBackService.java` |
| 财务回调实现 | `base-service/src/main/java/com/tcoa/scm/service/api/impl/FinanceCallBackServiceImpl.java` |
| ERP 回调 Controller | `project-pc/src/main/java/com/tcoa/scm/pc/controller/api/ErpCallbackApiController.java` |
| ERP 回调接口 | `IErpCallBackService` / `ErpServiceCallBackImpl` |

---

## BIZ-FIN-003 付款与 MQ

| 类型 | 代码位置 |
|---|---|
| 付款服务 | `base-service/src/main/java/com/tcoa/scm/service/pay/PayService.java` |
| 通用付款 API | `base-service/src/main/java/com/tcoa/scm/service/pay/CommonPayApi.java` |
| 采购订单付款 | `PurchaseOrderPaymentService` / `PurchaseOrderPaymentServiceImpl` |
| 电商付款服务 | `EmallPaymentService` / `EmallPaymentServiceImpl`、`EmallPaymentSubService` / `EmallPaymentSubServiceImpl` |
| 付款回调 MQ | `PaymentCallbackMqHandler`，Tag：`EXTERNAL_PAYMENT_APPLY_TAG_CALLBACK` |
| 电商付款申请生产方 | `EmallReconciliationServiceImpl`，Tag：`EXTERNAL_PAYMENT_APPLY_TAG` |

---

## BIZ-FIN-004 财务相关配置与报表

| 类型 | 代码位置 |
|---|---|
| 账簿映射配置 | `FinanceBookMappingConfigHandler` |
| 付款渠道配置 | `PaymentChannelConfigHandler` |
| 公司税务报表 | `CompanyTaxReportService` / `CompanyTaxReportServiceImpl`，前端 `front-pc/src/pages/report/companyTax/index.vue` |
| 总账规则与推送 | 详见 `references/ledger-rules.md` |

---

## BIZ-FIN-005 发票回调

| 类型 | 代码位置 |
|---|---|
| Controller | `project-pc/src/main/java/com/tcoa/scm/pc/controller/callback/InvoiceCallbackController.java` |
| 根路径 | `/callback/invoice` |
| 发票回调 API | `POST /callback` |
| 发票验价 API | `POST /checkPrice` |

---

## 变更摘要

| 日期 | 业务编号 | 描述 |
|------|---------|------|
| 2026-05-28 | BIZ-FIN-001 ~ 004 | 新增财务主数据、财务/ERP回调、付款服务、付款MQ和财务配置映射 |
| 2026-05-28 | BIZ-FIN-005 | 补充发票回调 Controller 和 API 入口 |
