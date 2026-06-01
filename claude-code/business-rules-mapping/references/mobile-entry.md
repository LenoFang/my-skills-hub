# 移动端入口映射（BIZ-MOBILE-001 ~ 005）

> 主 SKILL.md 的子文档。记录 `project-mobile` 与 `front-touch` 中已确认存在的移动端入口。

## BIZ-MOBILE-001 移动端基础入口

| 类型 | 路径 |
|---|---|
| 移动端后端 Controller 根目录 | `code-backend/project-mobile/src/main/java/com/tcoa/scm/mobile/controller` |
| 移动端前端页面根目录 | `front-touch/src/pages` |
| 登录/OAuth Controller | `AuthorizationCodeController`，根路径 `oauth/mobile` |
| 首页 Controller | `HomeController` |
| 通用查询/附件/上传 Controller | `CommonController`，根路径 `/common` |
| 地址 Controller | `SystemAddressController`、`LeaseAddressController` |

---

## BIZ-MOBILE-002 移动端资产入口

| 业务 | 前端路径 | Controller |
|---|---|---|
| 资产查询与扫码退库 | `front-touch/src/pages/rfid` | `AssetInfoController`，根路径 `/assetinfo` |
| 资产数据 | `front-touch/src/pages/rfid` | `assets/MaterialAssetDataController`，根路径 `/assetData` |
| 资产闭环 | `front-touch/src/pages/rfid/assetToSell.vue`、`assetSell*.vue` | `closedloop/ClosedLoopController`，根路径 `/closedloop` |
| 资产转移 | `front-touch/src/pages/rfid` | `transasset/TransAssetController` |
| 资产交接交还 | `front-touch/src/pages/rfid/assetHandOver.vue`、`assetHandBack.vue` | `TransAssetHandoverController`、`TransAssetHandoverHandleController` |
| 离职资产 | `front-touch/src/pages/rfid` | `TransAssetResignController`，根路径 `/transResign` |

---

## BIZ-MOBILE-003 移动端采购、出库与装机入口

| 业务 | 前端路径 | Controller |
|---|---|---|
| 采购申请移动处理 | `front-touch/src/pages/purchase` | `purchase/PurchaseApplyController` |
| 物资申请移动入口 | - | `MaterialApplyController` |
| 出库确认 | `front-touch/src/pages/outstock` | `InventoryController`、`InventoryConfirmController` |
| 装机扫码确认 | `front-touch/src/pages/Installation` | `ComputerInstallController`，根路径 `/computer/install` |

---

## BIZ-MOBILE-004 移动端盘点与预警入口

| 业务 | 前端路径 | Controller |
|---|---|---|
| 盘点 | `front-touch/src/pages/inventory` | `inventory/InventoryConfirmController`、`InventoryController` |
| 盘点管理 | `front-touch/src/pages/inventoryAdmin` | `inventory/InventoryConfirmController` |
| 移动端预警事件 | `front-touch/src/pages/alertmonitor/eventDetail.vue` | `alertmonitor/AlertEventMobileController`，根路径 `/mobile/alert/monitor/event` |

---

## BIZ-MOBILE-005 移动端 POS 入口

| 类型 | 路径 |
|---|---|
| 前端页面 | `front-touch/src/pages/pos` |
| 移动端 Controller | `ScmPosController` |

POS 独立管理端和 POS API 入口位于 `project-mobile/src/main/java/com/tcoa/scm/pos`，本文件只记录 `mobile/controller` 下的移动端入口。

---

## 变更摘要

| 日期 | 业务编号 | 描述 |
|------|---------|------|
| 2026-05-28 | BIZ-MOBILE-001 ~ 005 | 新增移动端基础、资产、采购/出库/装机、盘点、预警和移动 POS 入口映射 |
