# 内部服务类申请（BIZ-ISA-001 ~ 005）

> 主 SKILL.md 的子文档。记录名片、印刷品、机柜、服务器、自提柜等内部服务类入口。

## BIZ-ISA-001 名片申请

| 类型 | 代码位置 |
|---|---|
| 前端页面 | `front-pc/src/pages/apply/cards` |
| Controller | `project-pc/src/main/java/com/tcoa/scm/pc/controller/cards/CardsApplyController.java`，根路径 `/cards` |
| Service | `ICardsApplyService`、`ICardsApplySubService`、`ICardsApplyConfigService` |
| Service 实现 | `CardsApplyService`、`CardsApplySubService`、`CardsApplyConfigService` |
| Wolf 处理器 | `CardsApplyWolfServiceImpl` |
| 流水号配置 | `CardSerialNumberConfigHandler` |

已确认 API：`/init`、`/save`、`/updateSub`、`/list`、`/mlist`、`/recall`、`/confirm`、`/detail`、`/getProgressList`、`/census`、`/push`、`/configList`、`/configUpdate`、`/getUserDetail`、`/exportExcel`、`/importExcel`、`/getPurchaseRole`、`/getSupplier`、`/AutoConfirm`、`/sendEmail`。

---

## BIZ-ISA-002 印刷品申请

| 类型 | 代码位置 |
|---|---|
| 前端页面 | `front-pc/src/pages/apply/printedMatter`、`front-pc/src/pages/printSummary` |
| Controller | `project-pc/src/main/java/com/tcoa/scm/pc/controller/print/PrintApplyController.java`，根路径 `/print` |
| Service | `IPrintApplyService`、`IPrintApplySubService`、`IPrintApplyConfigService` |
| Service 实现 | `PrintApplyServiceImpl`、`PrintApplySubServiceImpl`、`PrintApplyConfigServiceImpl` |
| Wolf 处理器 | `PrintApplyWolfServiceImpl` |

已确认 API：`/init`、`/submitInit`、`/save`、`/list`、`/mList`、`/recall`、`/confirm`、`/detail`、`/getProgressList`、`/census`、`/updateSub`、`/updatePrintData`、`/push`、`/exportExcel`、`/exportApplyExcel`、`/exportAdminApplyExcel`、`/getPurchaseRole`、`/AutoConfirm`、`/sendEmail`、`/configList`、`/configUpdate`、`/configDelete`、`/configListDelete`、`/getByCode`、`/getPrintConfigEnum`。

---

## BIZ-ISA-003 机柜申请

| 类型 | 代码位置 |
|---|---|
| 前端页面 | `front-pc/src/pages/apply/rack`、`front-pc/src/pages/handle/rack`、`front-pc/src/pages/rack` |
| Controller | `project-pc/src/main/java/com/tcoa/scm/pc/controller/rack/RackApplyController.java`，根路径 `/rack` |
| Service | `IRackApplyService`、`IRackApplySubService`、`IRackApplyConfigService`、`RackListingService` |
| Service 实现 | `RackApplyServiceImpl`、`RackApplySubServiceImpl`、`RackApplyConfigServiceImpl`、`RackListingServiceImpl` |
| Wolf 处理器 | `RackApplyWolfServiceImpl` |
| 配置处理器 | `RackContactConfigHandler` |

已确认 API：`/submitInit`、`/init`、`/getRackStatus`、`/checkRackNumber`、`/checkRackNumberOpenedApply`、`/getOpenSubInfoByRackNumber`、`/save`、`/saveSub`、`/list`、`/mList`、`/recall`、`/detail`、`/getProgressList`、`/updateSub`、`/openImportExcel`、`/endImportExcel`、`/exportExcel`、`/census`、`/exportCensusExcel`、`/configList`、`/configUpdate`、`/configDelete`、`/configListDelete`、`/getEmailContact`、`/updateEmailContact`、`/import`。

---

## BIZ-ISA-004 服务器申请

| 类型 | 代码位置 |
|---|---|
| 前端配置页面 | `front-pc/src/pages/Home/configs/serverInventoryConfig.vue` |
| Controller | `project-pc/src/main/java/com/tcoa/scm/pc/controller/server/ServerApplyController.java`，根路径 `/server` |
| Service | `IServerApplyConfigService` / `ServerApplyConfigServiceImpl` |
| Wolf 处理器 | `ServerApplyWolfServiceImpl` |

已确认 API：`/configList`、`/configUpdate`、`/configDelete`、`/configListDelete`、`/getByCode`。

---

## BIZ-ISA-005 自提柜

| 类型 | 代码位置 |
|---|---|
| 前端页面 | `front-pc/src/pages/selfliftingcabinet/index.vue` |
| Controller | `project-pc/src/main/java/com/tcoa/scm/pc/controller/selfliftingcabinet/SelfLiftingCabinetController.java`，根路径 `/selfLiftingCabinet` |
| Service | `ISelfLiftingCabinetService`、`IPickUpLogService`、`IAssetsStorageInfoService` |
| Service 实现 | `SelfLiftingCabinetServiceImpl`、`PickUpLogServiceImpl`、`AssetsStorageInfoServiceImpl` |

已确认 API：`/list`、`add`、删除接口、`getById`、`/exportList`。

---

## 变更摘要

| 日期 | 业务编号 | 描述 |
|------|---------|------|
| 2026-05-28 | BIZ-ISA-001 ~ 005 | 新增名片、印刷品、机柜、服务器、自提柜代码映射 |
