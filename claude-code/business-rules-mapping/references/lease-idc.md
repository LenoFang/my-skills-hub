# 返租装机、租赁出库与通信设备模块（BIZ-LEASE-001 ~ 003 / BIZ-IDC-001）

> 主 SKILL.md 的子文档。只记录已在仓库中确认存在的前端目录、Controller 和 Service。

## BIZ-LEASE-001 入职电脑装机

| 业务 | 前端路径 | Controller | Service |
|---|---|---|---|
| 入职电脑装机 | `front-pc/src/pages/cominstalled/companyList.vue`、`front-pc/src/pages/cominstalled/companyInstall` | `ComputerInstalledController` | `ComputerInstalledService` |
| 装机地址 | `front-pc/src/pages/cominstalled/installAddress.vue` | `LeaseAddressController` | `LeaseBackAddressService` |

---

## BIZ-LEASE-002 返租与退租

| 业务 | 前端路径 | Controller | Service |
|---|---|---|---|
| 入职电脑返租 | `front-pc/src/pages/cominstalled/leasebackList.vue`、`front-pc/src/pages/cominstalled/personLeaseback` | `LeaseBackController` | `LeaseBackService` |
| 返租申请/我的返租 | `front-pc/src/pages/leaseback/apply`、`front-pc/src/pages/leaseback/mine` | `LeaseBackController`、`LeaseBackEntryController` | `LeaseBackService`、`LeaseBackEntryService` |
| 退租 | `front-pc/src/pages/leaseback/back` | `LeaseBackRetireController` | `LeaseBackRetireService` |
| 返租汇总/配置 | `front-pc/src/pages/leaseback/summary`、`front-pc/src/pages/leaseback/config.vue` | `LeaseBackCollectController`、`LeaseBackConfigController` | `LeaseBackCollectService`、`LeaseBackConfigService` |

---

## BIZ-LEASE-003 租赁出库与设备清单

| 业务 | Controller | Service | Wolf 处理器 |
|---|---|---|---|
| 租赁出库 | `RentalOutboundController`，根路径 `rental/outbound` | `RentalOutboundService` / `RentalOutboundServiceImpl`、`RentalOutboundAssetService` / `RentalOutboundAssetServiceImpl` | `RentalOutboundWolfServiceImpl` |
| 租赁设备清单 | `RentalEquipmentListController`，根路径 `rental/equipmentList` | `RentalEquipmentListService` / `RentalEquipmentListServiceImpl` | - |

**已确认 API**：

| Controller | API |
|---|---|
| `RentalOutboundController` | `/init`、`/list`、`/mlist`、`/subList`、`/detail`、`/getAssetDetail`、`/save`、`/delete`、`/export`、`/adminExport`、`/import/{companyCode}` |
| `RentalEquipmentListController` | `/init`、`/list`、`/recoveryAsset`、`/export` |

**资产冻结实现**：`RentalOutboundAssetsFreezeServiceImpl`。

---

## BIZ-IDC-001 通信设备

| 业务 | 前端路径 | Controller | Service |
|---|---|---|---|
| 通信设备库存 | `front-pc/src/pages/apply/communication/inventory` | `IdcEquipmentController`、`IdcApplyController` | `IdcEquipmentServiceImpl`、`IdcApplyServiceImpl` |
| 通信设备费用 | `front-pc/src/pages/apply/communication/expense` | `IdcExpenseController` | `IdcExpenseServiceImpl` |
| 通信设备处理 | `front-pc/src/pages/apply/communication/deal` | `IdcApplyController`、`IdcApplyDetailController`、`IdcHandleDetailController` | `IdcApplyServiceImpl`、`IdcApplyDetailServiceImpl`、`IdcHandleDetailServiceImpl` |
| 通信设备交接/转移/注销/关闭 | `front-pc/src/pages/apply/communication/deal` | `IdcHandoverController`、`IdcTransferController`、`IdcLogoffController`、`IdcCloseController` | `IdcHandoverServiceImpl`、`IdcTransferServiceImpl`、`IdcLogoffServiceImpl`、`IdcCloseServiceImpl` |
| 运营商 | `front-pc/src/pages/apply/communication/carrier` | `IdcCarrierController` | `IdcCarrierServiceImpl` |
| 离职号码 | `front-pc/src/pages/leaveEmploymentNumber` | `IdcLeaveEmploymentController` | `IdcLeaveEmploymentServiceImpl` |

---

## 变更摘要

| 日期 | 业务编号 | 描述 |
|------|---------|------|
| 2026-05-28 | BIZ-LEASE-001 ~ 002 / BIZ-IDC-001 | 新增入职电脑装机、返租、退租、通信设备代码映射 |
| 2026-05-28 | BIZ-LEASE-003 | 补充租赁出库、租赁设备清单、Wolf 处理器和资产冻结入口 |
