# 平台支撑与通用能力映射（BIZ-PLAT-001 ~ 006）

> 主 SKILL.md 的子文档。记录 utils、系统配置、API 鉴权、流水号等通用能力入口。具体工具 API 细节优先参考 `backend-utility-apis` skill。

## BIZ-PLAT-001 常用工具类入口

| 类别 | 代码位置 | 说明 |
|---|---|---|
| 通用工具 | `base-common/src/main/java/com/tcoa/scm/common/utils/CommonUtil.java` | 通用辅助方法 |
| 日期工具 | `base-common/src/main/java/com/tcoa/scm/common/utils/DateUtil.java` | 日期时间处理 |
| Redis 工具 | `base-common/src/main/java/com/tcoa/scm/common/utils/RedisUtil.java` | Redis 操作封装 |
| 分布式锁 | `base-common/src/main/java/com/tcoa/scm/common/utils/RedisDistributeLock.java` | Redis 分布式锁封装 |
| JSON 工具 | `base-common/src/main/java/com/tcoa/scm/common/utils/JsonUtil.java` | JSON 辅助处理 |
| Excel 工具 | `base-common/src/main/java/com/tcoa/scm/common/utils/ExcelUtil.java`、`ExcelUtils.java` | Excel 导入导出辅助 |
| HTTP 工具 | `base-common/src/main/java/com/tcoa/scm/common/utils/HttpUtil.java`、`OkHttpTool.java` | HTTP 调用辅助 |
| EBS 工具 | `base-common/src/main/java/com/tcoa/scm/common/utils/EBSUtil.java`、`EbsSwitchUtil.java` | EBS 相关辅助 |
| Wolf 工具 | `base-common/src/main/java/com/tcoa/scm/common/utils/WolfUtil.java` | Wolf 调用辅助 |
| POS API | `base-common/src/main/java/com/tcoa/scm/common/utils/PosApiUtil.java` | POS 相关 API 调用辅助 |
| SRM API | `base-common/src/main/java/com/tcoa/scm/common/utils/SrmApiUtil.java` | SRM 相关 API 调用辅助 |
| 电商 API | `base-common/src/main/java/com/tcoa/scm/common/utils/EmallApiUtil.java` | 电商相关 API 调用辅助 |
| 待办 | `base-common/src/main/java/com/tcoa/scm/common/utils/ToDoUtil.java` | 待办相关辅助 |
| 权限 | `base-common/src/main/java/com/tcoa/scm/common/utils/PermissionUtil.java`、`ViewPermissionChecker.java` | 权限相关辅助 |
| 实体更新 | `base-common/src/main/java/com/tcoa/scm/common/utils/EntityUpdateUtil.java`、`UpdateUtil.java`、`EntityComparatorUtil.java` | 实体字段更新/比较辅助 |
| 物料/资产 | `base-common/src/main/java/com/tcoa/scm/common/utils/MaterialAssetUtil.java`、`AssetVersionUtil.java` | 物料资产辅助 |

---

## BIZ-PLAT-002 系统配置

| 类型 | 代码位置 | 说明 |
|---|---|---|
| 配置枚举 | `base-domain/src/main/java/com/tcoa/scm/domain/enums/system/SystemConfigEnum.java` | 系统配置 key 枚举 |
| 配置展示注解 | `base-domain/src/main/java/com/tcoa/scm/domain/annotation/SystemConfigDisplay.java` | 配置展示元数据 |
| 配置实体 | `base-domain/src/main/java/com/tcoa/scm/domain/dataobject/master/system/SystemConfigEntity.java` | 系统配置表实体 |
| 配置 Handler 接口 | `base-common/src/main/java/com/tcoa/scm/common/system/config/ISystemConfigHandler.java` | 配置处理器接口 |
| 配置 Handler 上下文 | `base-common/src/main/java/com/tcoa/scm/common/system/config/SystemConfigContext.java` | 获取配置处理器 |
| 配置 Handler 扫描 | `base-common/src/main/java/com/tcoa/scm/common/system/config/SystemConfigHandlerProcessor.java` | 注册配置处理器 |
| 配置 Handler 基类 | `base-service/src/main/java/com/tcoa/scm/service/system/config/BaseSystemConfigHandler.java` | 业务配置处理器基类 |
| 配置服务 | `SystemConfigServiceImpl` | 系统配置业务服务 |
| 配置 Controller | `project-pc/src/main/java/com/tcoa/scm/pc/controller/SystemConfigController.java` | PC 端系统配置入口 |

**已确认与总账/EBS相关配置处理器**：`pushGeneralLedgerJournalConfigConfigHandler`、`pushAllotTransJournalConfigConfigHandler`、`LedgerIdlePushWindowConfigHandler`、`CanPushEbsConfigHandler`、`EbsSwitchConfigHandler`。

---

## BIZ-PLAT-003 API 鉴权

| 类型 | 代码位置 | 说明 |
|---|---|---|
| 鉴权上下文 | `base-common/src/main/java/com/tcoa/scm/common/api/ApiAuthContext.java` | API 鉴权上下文 |
| Token 校验接口 | `base-common/src/main/java/com/tcoa/scm/common/api/IApiTokenValidator.java` | Token 校验接口 |
| 第三方 Token Handler | `base-common/src/main/java/com/tcoa/scm/common/api/ThirdPartyApiTokenHandler.java` | 第三方 API Token 处理 |
| 鉴权类型枚举 | `base-domain/src/main/java/com/tcoa/scm/domain/enums/api/ApiAuthTypeEnum.java` | API 鉴权类型 |
| Token 服务 | `base-service/src/main/java/com/tcoa/scm/service/api/impl/ApiTokenServiceImpl.java` | API Token 服务实现 |
| 鉴权 Controller | `project-pc/src/main/java/com/tcoa/scm/pc/controller/api/ApiAuthController.java` | API 鉴权入口 |

---

## BIZ-PLAT-004 流水号

| 类型 | 代码位置 | 说明 |
|---|---|---|
| 流水号接口 | `base-service/src/main/java/com/tcoa/scm/service/system/serial/ISerialNumberService.java` | 流水号服务接口 |
| 流水号实现 | `base-service/src/main/java/com/tcoa/scm/service/system/serial/impl/SerialNumberServiceImpl.java` | 流水号服务实现 |
| 采购申请流水号配置 | `PrSerialNumberConfigHandler` | 采购申请流水号配置处理器 |
| 采购订单流水号配置 | `PurchaseOrderSerialNumberConfigHandler` | 采购订单流水号配置处理器 |
| 物料流水号配置 | `MaterialSerialNumberConfigHandler` | 物料流水号配置处理器 |
| 卡券流水号配置 | `CardSerialNumberConfigHandler` | 卡券流水号配置处理器 |

---

## BIZ-PLAT-005 表单号解析

| 类型 | 代码位置 | 说明 |
|---|---|---|
| 解析服务接口 | `base-service/src/main/java/com/tcoa/scm/service/formno/IFormNoResolveService.java` | 表单号解析服务接口 |
| 解析服务实现 | `FormNoResolveServiceImpl` | 表单号解析服务实现 |
| 策略接口 | `IFormNoResolveStrategy` | 表单号解析策略接口 |
| 策略上下文 | `FormNoResolveContext` | 收集策略并按表单号匹配 |

**已确认策略实现**：`PurchaseApplyResolveStrategy`、`PurchaseOrderResolveStrategy`、`PurchaseReturnResolveStrategy`、`MaterialApplyResolveStrategy`、`MaterialReceiveResolveStrategy`、`MaterialReturnResolveStrategy`、`MaterialStockAllotResolveStrategy`、`MaterialAssetAllotResolveStrategy`、`MaterialGiftStorageResolveStrategy`、`MaterialInventoryProfitResolveStrategy`、`MaterialInventoryDisposalResolveStrategy`、`MaterialAssetInitRecordResolveStrategy`、`AssetInfoResolveStrategy`、`AssetClosedLoopResolveStrategy`、`PosInventoryFlowResolveStrategy`。

---

## BIZ-PLAT-006 开发工具入口

| 工具 | 前端路径 | Controller | Service |
|---|---|---|---|
| 代码生成 | `front-pc/src/pages/system/codeGenerator/index.vue` | `CodeGeneratorController`，根路径 `/codegen` | `CodeGeneratorService` / `CodeGeneratorServiceImpl` |
| API 测试 | `front-pc/src/pages/system/apiTest/index.vue` | `ApiTestController`，根路径 `/apitest` | `ApiTestService` / `ApiTestServiceImpl` |

**已确认 API**：

| Controller | API |
|---|---|
| `CodeGeneratorController` | `/tables`、`/columns`、`/preview`、`/download` |
| `ApiTestController` | `/controllers`、`/controller/detail`、`/method/detail`、`/execute`、`/refresh` |

---

## 变更摘要

| 日期 | 业务编号 | 描述 |
|------|---------|------|
| 2026-05-28 | BIZ-PLAT-001 ~ 004 | 新增通用工具、系统配置、API 鉴权和流水号入口映射 |
| 2026-05-28 | BIZ-PLAT-005 ~ 006 | 补充表单号解析、代码生成和 API 测试入口 |
