# 运维任务与补偿入口（BIZ-OPS-001 ~ 004）

> 主 SKILL.md 的子文档。记录调度网关、Job Controller、运维补偿和员工同步入口。

## BIZ-OPS-001 调度任务网关

| 类型 | 代码位置 |
|---|---|
| 前端页面 | `front-pc/src/pages/system/scheduleTask` |
| Controller | `ScheduleGatewayController`，根路径 `/schedule` |
| Service | `IScheduleTaskService` / `ScheduleTaskServiceImpl` |
| 注册器 | `ScheduleTaskRegistrar` |

**已确认 API**：`/execute`、`/tasks`、`/task/{taskCode}`、`/logs`、`/refresh`、`/toggle`、`/clean-logs`、`/ping`、`/generate-request`。

---

## BIZ-OPS-002 资产与事务补偿 Job

| 类型 | 代码位置 |
|---|---|
| Controller | `TransAssetJobController`，根路径 `/trans/job` |
| 已确认 API | `/searchTransAsset`、`/handleLeasebackExpire`、`/checkAssetsHandoverOrReturn`、`/checkLeaseBack`、`/callbackNotFinishedTranslation`、`/callbackNotFinishedTranslationById`、`/getLeaseEmpList` |

---

## BIZ-OPS-003 员工同步 Job

| 类型 | 代码位置 |
|---|---|
| Controller | `EmployeeJobController`，根路径 `/employee/job` |
| 已确认 API | `syncEmployee`、`initEmployee`、`createLeaveEmployeeOrdinaryInfo` |
| API Controller | `CompanyOrganizationJobController`、`EmallJobApiController`、`JobApiController` |

---

## BIZ-OPS-004 管理补偿入口

| 类型 | 代码位置 |
|---|---|
| Controller | `AdminProcessController`，根路径 `/adminProcess` |
| 已确认 API | `/inventory/serial/order/retry` |
| 采购申请 Job | `PurchaseCallJob` |

---

## 变更摘要

| 日期 | 业务编号 | 描述 |
|------|---------|------|
| 2026-05-28 | BIZ-OPS-001 ~ 004 | 新增调度网关、资产事务补偿、员工同步和管理补偿入口 |
