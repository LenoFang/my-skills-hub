# 系统治理模块（BIZ-SYS-001 ~ 004）

> 主 SKILL.md 的子文档。只记录已在仓库中确认存在的前端目录、Controller 和 Service。

## BIZ-SYS-001 API 管理

| 业务 | 前端路径 | Controller | Service |
|---|---|---|---|
| API 接口管理 | `front-pc/src/pages/system/apiManage/endpointList.vue` | `ApiEndpointManageController` | `ApiEndpointServiceImpl` |
| API 接口组管理 | `front-pc/src/pages/system/apiManage/endpointGroupList.vue` | `ApiEndpointGroupManageController` | `ApiEndpointGroupServiceImpl` |
| API 调用方管理 | `front-pc/src/pages/system/apiManage/clientList.vue`、`clientDetail.vue` | `ApiClientManageController`、`ApiCredentialManageController`、`ApiClientEndpointAuthManageController` | `ApiClientServiceImpl`、`ApiClientCredentialServiceImpl`、`ApiClientEndpointAuthServiceImpl` |
| API 调用日志 | `front-pc/src/pages/system/apiManage/callLogList.vue` | `ApiCallLogManageController` | `ApiCallLogServiceImpl` |

**已确认但未补充 Service 的页面入口**：
| 业务 | 前端路径 | Controller |
|---|---|---|
| API 调用分析 | `front-pc/src/pages/system/apiManage/statsAnalysis.vue` | `ApiStatsManageController` |

---

## BIZ-SYS-002 预警监控

| 业务 | 前端路径 | Controller | Service |
|---|---|---|---|
| 预警规则配置 | `front-pc/src/pages/alertmonitor/config.vue` | `AlertConfigController` | `AlertConfigServiceImpl` |
| 预警事件 | `front-pc/src/pages/alertmonitor/event.vue`、`eventDetail.vue` | `AlertEventController` | `AlertEventServiceImpl` |
| 数据源端点 | `front-pc/src/pages/alertmonitor/endpoint.vue` | `AlertEndpointController` | `AlertEndpointServiceImpl` |

---

## BIZ-SYS-003 权限资源

| 业务 | 前端路径 | Controller/Service |
|---|---|---|
| 系统资源 | `front-pc/src/pages/authorize/resourceList.vue` | `SystemResourceService` |
| 系统角色 | `front-pc/src/pages/authorize/roleList.vue` | `SystemRoleService`、`SystemRoleUserService` |
| 资源角色配置 | `front-pc/src/pages/authorize/resourceRole.vue` | `SystemRoleResourceService` |
| 用户权限管理 | `front-pc/src/pages/authorize/userList.vue` | `SystemRoleUserService`、`SystemRoleDataService` |
| 页面权限/元素权限 | `front-pc/src/pages/system/pagePermConfig`、`front-pc/src/pages/system/pageElementConfig` | `PagePermissionServiceImpl`、`PageElementServiceImpl` |

---

## BIZ-SYS-004 定时任务

| 业务 | 前端路径 | Controller |
|---|---|---|
| 定时任务列表/日志 | `front-pc/src/pages/system/scheduleTask` | `ScheduleGatewayController` |

---

## 变更摘要

| 日期 | 业务编号 | 描述 |
|------|---------|------|
| 2026-05-28 | BIZ-SYS-001 ~ 004 | 新增 API 管理、预警监控、权限资源、定时任务代码映射 |
