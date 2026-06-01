# 盘点流程模块（BIZ-IPROC-001 ~ 004）

> 主 SKILL.md 的子文档。记录资产盘点项目、盘点计划、RFID 盘点、静态资产处理和待办入口。

## BIZ-IPROC-001 盘点项目

| 类型 | 代码位置 |
|---|---|
| Controller | `InventoryProjectController`，根路径 `/InventoryProjectController` |
| Service | `InventoryProjectService` / `InventoryProjectServiceImpl` |
| 前端路径 | `front-pc/src/pages/handle/process/index.vue`、`front-pc/src/pages/inventoryPool/transactionProcessing` |

已确认 API：`/getInventoryConfirmation`、`/inventoryProgressDashboard`、`/resumeSendingMessages`、`/inventoryCompensation`、`/list`、`/getProjectDetail`、`/listAddress`、`/listTreeInfo`、`/listTreeCategoryInfo`、`/init`、`/submit`、`/projectNameCount`、`/deleteProjectResult`、`/delete`、`/saveInvPlan`、`/closeProject`、`/automaticInventorySubmit`、`/exportSupplementaryDataAll`、`/synchronizeNetworkDevice`、`/inventoryMessageTasks`、`/deleteZabbix`、`/saveZabbix`。

---

## BIZ-IPROC-002 盘点计划与 RFID 盘点

| 业务 | Controller | Service |
|---|---|---|
| 盘点计划 | `InvPlanController`，根路径 `/InvPlanController` | `InvPlanService` / `InvPlanServiceImpl` |
| RFID 盘点计划 | `InvRfPlanController`，根路径 `/InvRfPlanController` | `InvRfPlanService` / `InvRfPlanServiceImpl` |
| 盘点确认用户 | `InvConfirmUserController` | `InvConfirmUserService` / `InvConfirmUserServiceImpl` |
| 库存确认用户 | - | `IInventoryConfirmUserService` / `InventoryConfirmUserServiceImpl` |
| 盘点用户记录 | - | `IInventoryUserRecordService` / `InventoryUserRecordServiceImpl` |

---

## BIZ-IPROC-003 静态资产处理

| 类型 | 代码位置 |
|---|---|
| Controller | `MaterialStaticAssetsProcessController`，根路径 `/MaterialStaticAssetsProcessController` |
| Service | `MaterialStaticAssetsProcessService` / `MaterialStaticAssetsProcessServiceImpl` |

已确认 API：`/init`、`/badgeCount`、`/deleteStaticAssets`、`/delete`、`/deleteUntreated`、`/synchronizeAddress`、`/synchronizeStaticAssets`、`/list`、`/getStaticById`、`/submit`、`/export`。

---

## BIZ-IPROC-004 盘点待办与消息发送

| 类型 | 代码位置 |
|---|---|
| 事务待办 Controller | `TransactionToDoListController`，根路径 `/tranTodo` |
| 闭环待办 Controller | `ClosedLoopToDoListController` |
| 系统待办 Controller | `ToDoListController` |
| 批量发送 | `BatchSender`、`ThrottledMessageSender` |
| 发送进度 | `SendingProgress`、`SendResult`、`ThrottleConfig` |

---

## 变更摘要

| 日期 | 业务编号 | 描述 |
|------|---------|------|
| 2026-05-28 | BIZ-IPROC-001 ~ 004 | 新增盘点项目、盘点计划、RFID盘点、静态资产处理、盘点待办与消息发送映射 |
