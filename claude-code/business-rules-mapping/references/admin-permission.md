# Admin 后台权限（BIZ-ADMIN-001 ~ 006）

> 主 SKILL.md 的子文档。只记录已在仓库中确认存在的 `admin-backend` 权限 Controller、`front-admin` 权限路由和组件。

## BIZ-ADMIN-001 Admin 权限前端入口

| 业务 | 前端路由 | 前端组件 | 后端 Controller |
|---|---|---|---|
| SCM 资源树 | `/auth/resource` | `front-admin/src/components/Authorize/Resource/ResourceList.vue` | `SystemResourceController` |
| Admin 资源树 | `/admin/resource` | `front-admin/src/components/Authorize/Resource/AdminResourceList.vue` | `SystemResourceController` |
| 电商资源树 | `/auth/emall/resource` | `front-admin/src/components/Authorize/Resource/EmallResourceList.vue` | `SystemResourceController` |
| SCM 资源角色配置 | `/auth/resourceRole` | `front-admin/src/components/Authorize/Resource/ResourceRoleList.vue` | `SystemRoleController` |
| 电商资源角色配置 | `/auth/emall/resourceRole` | `front-admin/src/components/Authorize/Resource/EmallResourceRoleList.vue` | `SystemRoleController` |
| 角色管理 | `/auth/role` | `front-admin/src/components/Authorize/Role/RoleList.vue`、`RoleModify.vue`、`RoleUser.vue`、`RoleResource.vue`、`Permission.vue` | `SystemRoleController`、`SysRoleDataPermissionController` |
| 用户权限 | `/auth/userList` | `front-admin/src/components/Authorize/UserList/index.vue` | `SystemRoleController` |

---

## BIZ-ADMIN-002 资源树管理

| 业务 | Controller | API | Service |
|---|---|---|---|
| 资源初始化 | `SystemResourceController` | `GET /auth/resource/init` | `ISystemResourceService` |
| 全量资源树 | `SystemResourceController` | `GET /auth/resource/all/tree` | `ISystemResourceService` |
| SCM 资源树 | `SystemResourceController` | `GET /auth/resource/tree` | `ISystemResourceService` |
| 电商资源树 | `SystemResourceController` | `GET /auth/resource/emall/tree` | `ISystemResourceService` |
| Admin 资源树 | `SystemResourceController` | `GET /auth/resource/admin/tree` | `ISystemResourceService` |
| 新增、详情、保存、清理 | `SystemResourceController` | `GET /auth/resource/new`、`GET /auth/resource/detail`、`POST /auth/resource/save`、`POST /auth/resource/clear` | `ISystemResourceService` |

---

## BIZ-ADMIN-003 角色、用户、资源关系

| 业务 | Controller | API | Service |
|---|---|---|---|
| 角色列表和初始化 | `SystemRoleController` | `GET /auth/role/list`、`GET /auth/role/init` | `SystemRoleService` |
| 角色新增、详情、保存、复制、清理 | `SystemRoleController` | `GET /auth/role/new`、`GET /auth/role/detail`、`POST /auth/role/save`、`POST /auth/role/copy`、`POST /auth/role/clear` | `SystemRoleService` |
| 角色用户关系 | `SystemRoleController` | `GET /auth/role/user/list`、`GET /auth/role/user/relationList`、`POST /auth/role/user/add`、`POST /auth/role/user/remove`、`POST /auth/role/user/removeByUser` | `SystemRoleUserService` |
| 角色资源关系 | `SystemRoleController` | `GET /auth/role/resource/list`、`POST /auth/role/resource/add`、`POST /auth/role/resource/remove` | `SystemRoleResourceService` |
| 采购角色查询 | `SystemRoleController` | `GET /auth/role/purchase`、`GET /auth/role/monopolize/purchase/users` | `SystemRoleService` |

---

## BIZ-ADMIN-004 数据权限、页面权限、元素权限

| 业务 | Controller | API | Service |
|---|---|---|---|
| 角色数据权限 | `SysRoleDataPermissionController` | `POST /dataPermission/page`、`GET /dataPermission/list`、`POST /dataPermission/add`、`POST /dataPermission/deleteDataPermission`、`POST /dataPermission/addAll` | `ISysRoleDataPermissionService` |
| 页面权限同步、检查、查询、更新 | `PagePermissionController` | `POST /pagePermission/sync`、`GET /pagePermission/check`、`GET /pagePermission/list`、`PUT /pagePermission/update`、`PUT /pagePermission/batchUpdate` | `PagePermissionServiceImpl` |
| 页面元素上报和授权查询 | `PageElementController` | `POST /pageElement/report`、`GET /pageElement/permissions`、`GET /pageElement/list`、`PUT /pageElement/update`、`PUT /pageElement/batchUpdate`、`GET /pageElement/pages`、`POST /pageElement/syncToResources` | `PageElementServiceImpl` |

---

## BIZ-ADMIN-005 API 转发和路由刷新

| 业务 | Controller | API | Service |
|---|---|---|---|
| API 转发配置 | `ApiRedirectController` | `GET /apiRedirect/list`、`GET /apiRedirect/detail`、`POST /apiRedirect/save`、`POST /apiRedirect/delete`、`POST /apiRedirect/refreshCache` | `ApiRedirectServiceImpl` |
| 路由映射刷新 | `SystemAdminController` | `GET /routeMap/refresh` | `ISystemResourceService` |

---

## BIZ-ADMIN-006 与系统治理文档的边界

| 文档 | 覆盖范围 |
|---|---|
| `references/system-governance.md` | PC 端系统治理总览：API 管理、预警监控、权限资源概要、定时任务入口 |
| `references/admin-permission.md` | `admin-backend` 权限 Controller、`front-admin` 权限路由与组件、资源/角色/数据权限/页面权限/元素权限/API 转发 |

## 变更摘要

| 日期 | 业务编号 | 描述 |
|------|---------|------|
| 2026-05-28 | BIZ-ADMIN-001 ~ 006 | 新增 Admin 后台权限资源、角色用户、数据权限、页面元素权限、API 转发和路由刷新映射 |
