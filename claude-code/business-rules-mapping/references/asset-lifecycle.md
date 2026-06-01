# 资产生命周期模块（BIZ-ASSET-001 ~ 004）

> 主 SKILL.md 的子文档。只记录已在仓库中确认存在的前端目录、Controller 和 Service。

## BIZ-ASSET-001 资产信息、初始化、变更

| 业务 | 前端路径 | Controller |
|---|---|---|
| 资产信息 | `front-pc/src/pages/handle/assetinfo` | `AssetInfoController`、`MaterialAssetDataController`、`MaterialAssetTranslationController` |
| 资产初始化 | `front-pc/src/pages/assetcycle/init` | `MaterialAssetInitController` |
| 资产信息变更 | `front-pc/src/pages/assetcycle/change` | `MaterialAssetChangeApplyController` |

**已确认同步处理器**：`MaterialAssetsInitPostDataHandlerService`

### 资产变更实现明细

| 类型 | 代码位置 |
|---|---|
| Controller | `project-pc/src/main/java/com/tcoa/scm/pc/controller/materialtransfer/MaterialAssetChangeApplyController.java` |
| Service 接口 | `base-service/src/main/java/com/tcoa/scm/service/material/IMaterialAssetChangeApplyService.java` |
| Service 实现 | `base-service/src/main/java/com/tcoa/scm/service/material/impl/MaterialAssetChangeApplyServiceImpl.java` |
| 历史接口 | `base-service/src/main/java/com/tcoa/scm/service/material/IMaterialAssetChangeHistoryService.java` |
| 历史实现 | `base-service/src/main/java/com/tcoa/scm/service/material/impl/MaterialAssetChangeHistoryServiceImpl.java` |
| Wolf 处理器 | `base-service/src/main/java/com/tcoa/scm/service/wolf/impl/AssetChangeApplyWolfServiceImpl.java` |
| 申请实体 | `base-domain/src/main/java/com/tcoa/scm/domain/dataobject/master/MaterialAssetChangeApplyEntity.java` |
| 明细实体 | `base-domain/src/main/java/com/tcoa/scm/domain/dataobject/master/MaterialAssetChangeDetailEntity.java` |
| 历史实体 | `base-domain/src/main/java/com/tcoa/scm/domain/dataobject/master/MaterialAssetChangeHistoryEntity.java` |

**已确认 API**（Controller 根路径 `/asset-change`）：

| API | Controller 方法 |
|---|---|
| `POST /init` | `initAssetChangeApply()` |
| `POST /submit` | `submitAssetChangeApply()` |
| `POST /page-list` | `getAssetChangeApplyPageList()` |
| `GET /detail-list` | `getAssetChangeApplyDetailList()` |
| `GET /detail` | `getAssetChangeApplyDetail()` |
| `POST /cancel` | `cancelAssetChangeApply()` |
| `POST /import` | `importAssetChangeApply()` |
| `POST /export` | `exportAssetChangeApply()` |
| `GET /exportTemplate` | `exportResultTemplate()` |
| `GET /downLoadErrorExcel` | `downLoadErrorExcel()` |
| `POST /execute` | `executeAssetChange()` |
| `GET /pending-count` | `getPendingApprovalCount()` |
| `POST /history/page-list` | `getChangeHistoryPageList()` |
| `GET /history/by-apply/{changeApplyId}` | `getChangeHistoryByApplyId()` |
| `GET /history/by-asset/{assetCode}` | `getChangeHistoryByAssetCode()` |
| `GET /history/details/by-asset/{assetCode}` | `getChangeDetailHistoryByAssetCode()` |
| `GET /asset/get` | `getAssetChangeDetailInfoByCode()` |
| `GET /address/get` | `getAddressInfoByDetailAddress()` |
| `GET /progress/{id}` | `getProgress()` |

**已确认 Service 方法**：`initAssetChangeApply()`、`submitAssetChangeApply()`、`getAssetChangeApplyPageList()`、`getAssetChangeApplyDetail()`、`getAssetChangeApplyDetailList()`、`cancelAssetChangeApply()`、`importAssetChangeApply()`、`getAssetChangeDetailInfoByCode()`、`getAddressInfoByDetailAddress()`、`unFreezeAsset()`、`exportAssetChangeApply()`、`executeAssetChange()`、`getPendingApprovalCount()`、`getAssetChangeApplyDetailByInstanceId()`、`getProcessProgress()`。

**变更历史方法**：`recordChangeHistory()`、`getChangeHistoryPageList()`、`getChangeHistoryByApplyId()`、`getChangeHistoryByAssetCode()`。

---

## BIZ-ASSET-002 资产操作与交接

| 业务 | 前端路径 | Controller | Service |
|---|---|---|---|
| 资产列表/申请/详情 | `front-pc/src/pages/assetcycle/*.vue` | `TransAssetController` | `TransAssetServiceImpl` |
| 资产转移 | `front-pc/src/pages/assetcycle/operation/transAsset.vue` | `TransAssetController` | `TransAssetServiceImpl` |
| 资产交还/交接 | `front-pc/src/pages/assetcycle/operation/return.vue`、`handover.vue` | `TransAssetHandoverController`、`TransAssetHandoverHandleController` | `TransAssetHandoverServiceImpl` |
| 离职资产 | `front-pc/src/pages/assetcycle/operation/resignAsset.vue`、`resignExpand.vue` | `TransAssetResignController` | `TransAssetResignServiceImpl` |

---

## BIZ-ASSET-003 资产维修

| 业务 | 前端路径 | Controller | Service |
|---|---|---|---|
| 资产维修 | `front-pc/src/pages/assetrepair` | `AssetRepairController` | `AssetRepairServiceImpl` |

---

## BIZ-ASSET-004 资产直接更新与校准入口

| 场景 | Controller/API | Service/方法 |
|---|---|---|
| 资产基础更新 | `MaterialAssetDataController` `/assetData/updateExtendCodes`、`/assetData/update-remarks`、`/assetData/uploadRFCodes` | `MaterialAssetDataService.updateAssetDataExtendCodes()`、`updateUserRemarks()` |
| 资产核心更新方法 | - | `IMaterialAssetDataService.updateAssetData()`、`MaterialAssetDataService.updateAssetData()` |
| 资产成本更新 | - | `IMaterialAssetDataService.updateAssetCost()`、`MaterialAssetDataService.updateAssetCost()` |
| 电脑盘点资产更新 | `InventoryComputerPowerupController` `/computer/updateAssetCode`、`/computer/updateAssetBelong`、`/computer/updateAssetRemarks` | `InventoryComputerPowerupService.updateAssetsInfo()`、`updateAssetsBelong()`、`updateAssetRemarks()` |
| RFID 资产更新 | `RFIDApiController` `/api/rfid/confirm/assets/update` | Controller 内资产确认更新入口 |
| 总账资产校准更新 | `AssetCalibrateController` `/sync/calibrate/batchUpdatePush` | `IAssetCalibrateService.batchUpdatePushSub()`、`AssetCalibrateServiceImpl.batchUpdatePushSub()` |
| 电商订单资产更新 | `EmallOrderController` `/emall/order/updateAssert` | 电商订单 Controller 资产更新入口 |

**通用更新工具**：`EntityUpdateUtil`、`EntityComparatorUtil`、`AssetVersionUtil`、`MaterialAssetUtil`。

---

## BIZ-ASSET-005 资产闭环处置（steps）

**功能描述**：资产闭环单（AssetClosedLoop）按处置类型走不同的业务步骤编排。每种处置类型对应一个 `*BusinessService`，统一继承 `BaseAssetClosedLoopBusiness`（再继承通用步骤基类 `BaseBusinessStepService`）。审批走 Wolf `AssetClosedLoopWolfServiceImpl`。

**入口与基础设施**：

| 类型 | 代码位置 | 说明 |
|---|---|---|
| Controller (PC) | `project-pc/.../pc/controller/closedloop/ClosedLoopController.java` | 资产闭环 PC 入口 |
| Controller (移动端) | `project-mobile/.../mobile/controller/closedloop/ClosedLoopController.java` | 资产闭环移动端入口（与 PC 重名，注意包路径） |
| Wolf 处理器 | `base-service/.../service/wolf/impl/AssetClosedLoopWolfServiceImpl.java` | `extends BaseWolfHandlerService<AssetClosedLoopOrderInfo>`，WolfKind `AssetClosedLoopOrder_WL` / `AssetClosedLoopOrder_GL` |
| 步骤基类 | `base-service/.../service/steps/assetclosedloop/base/BaseAssetClosedLoopBusiness.java` | `extends BaseBusinessStepService<TInfo>`，闭环各处置类型公共逻辑 |
| 通用步骤基类 | `base-service/.../service/steps/BaseBusinessStepService.java` | 业务步骤编排通用基类 |
| 闭环模型基类 | `base-service/.../service/steps/assetclosedloop/base/BaseAssetClosedLoopModel.java` | 闭环数据模型基类 |

**处置类型实现（均 `extends BaseAssetClosedLoopBusiness<AssetClosedLoopOrderInfo>`）**：

| 处置类型 | BusinessService |
|---|---|
| 对外销售出库 | `SellOutBusinessService` |
| 跨公司销售 | `SellCrossBusinessService` |
| 对个人销售 | `SellPersonBusinessService` |
| 境外销售 | `SellAbroadBusinessService` |
| 销售资产处置 | `SellAssetDisposalService` |
| 个人丢失 | `PersonLossBusinessService` |
| 个人损坏 | `PersonDamageBusinessService` |
| 盘亏 | `InventoryLossBusinessService` |
| 无收入处置 | `NoneIncomeDisposalBusinessService` |

> 相关 reference：[wolf-approval.md](wolf-approval.md)（BIZ-WOLF-002 `AssetClosedLoopWolfServiceImpl`）、本文件 BIZ-ASSET-002 资产操作与交接

---

## 变更摘要

| 日期 | 业务编号 | 描述 |
|------|---------|------|
| 2026-05-28 | BIZ-ASSET-001 ~ 003 | 新增资产信息、初始化、变更、转移、交接、离职资产、维修代码映射 |
| 2026-05-28 | BIZ-ASSET-001 | 补充资产变更 Controller/API、Service、History、Wolf 处理器映射 |
| 2026-05-28 | BIZ-ASSET-004 | 补充资产直接更新、电脑盘点更新、RFID 更新、总账资产校准、电商订单资产更新入口 |
| 2026-05-28 | BIZ-ASSET-005 | 新增资产闭环处置 steps 映射（全量审查发现 service/steps/assetclosedloop 包未被覆盖） |
