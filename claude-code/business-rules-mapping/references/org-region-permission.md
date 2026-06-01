# 组织、区域、用途与视图权限（BIZ-ORG-001 ~ 004）

> 主 SKILL.md 的子文档。记录库存组织、虚拟组织、片区、用途范围、页面视图权限入口。

## BIZ-ORG-001 库存组织与虚拟组织

| 业务 | Controller | Service |
|---|---|---|
| 库存组织 | `CompanyOrganizationController`，根路径 `/companyOrganization` | `ICompanyOrganizationService` / `CompanyOrganizationServiceImpl` |
| 库存组织配置 | `CompanyOrganizationConfigController`，根路径 `/companyOrganizationConfig` | `ICompanyOrganizationConfigService` / `CompanyOrganizationConfigServiceImpl` |
| 虚拟组织 | `CompanyVirtualOrganizationController`，根路径 `/companyVirtualOrganization` | `ICompanyVirtualOrganizationService` / `CompanyVirtualOrganizationServiceImpl` |
| 组织层级 | - | `ICompanyOrganizationLevelService` / `CompanyOrganizationLevelServiceImpl` |
| 公司关系 | - | `ICompanyRelationService` / `CompanyRelationServiceImpl`、`CompanyRelationSpecialUtil` |

前端路径：`front-pc/src/pages/configuration/company`。

---

## BIZ-ORG-002 片区配置与地址匹配

| 类型 | 代码位置 |
|---|---|
| Controller | `RegionConfigController`，根路径 `/region-config` |
| Service | `IRegionConfigService` / `RegionConfigServiceImpl` |
| 区域解析 | `IRegionResolveService` / `RegionResolveServiceImpl`、`RegionFieldHelper` |
| 区域同步 | `IRegionSyncService` / `RegionSyncServiceImpl`、`RegionDataPullService` |
| 数据清理 | `IRegionDataCleanService` / `RegionDataCleanServiceImpl`、`RegionDataCleanController` |
| API 同步 | `RegionSyncApiController` |

前端路径：`front-pc/src/pages/configuration/address/regionConfig.vue`。

已确认 API：`/list`、`/detail`、`/save`、`/delete`、`/material-admins/save`、`/leaders/save`、`/member/delete`、`/scope/save`、`/scope/delete`、`/scope/members/save`、`/scope/member/delete`、`/match-by-address`、`/match-by-location`、`/user-region-ids`、`/user-city-ids`、`/user-primary-region`、`/export`、`/region-options`、`/country-options`、`/province-options`、`/city-options`。

---

## BIZ-ORG-003 用途范围与公司用途映射

| 类型 | 代码位置 |
|---|---|
| 前端页面 | `front-pc/src/pages/use/useRangeConfig.vue`、`front-pc/src/pages/use/companyUseRange.vue` |
| Controller | `UseRangeController`，根路径 `/useRange` |
| Service | `IUseRangeConfigService` / `UseRangeConfigServiceImpl` |
| 公司用途映射 | `ICompanyUseRangeConfigService` / `CompanyUseRangeConfigServiceImpl` |
| Facade | `UseRangeConfigFacadeImpl` |

已确认 API：`/init`、`/list`、`/listAll`、`/configUpdate`、`/configDelete`、`/listGoldCompany`、`/getGoldCompanyMapping`、`/goldCompanyMapping`、`/getGoldCompanyUseRange`、`/getAllUseRangeSelectItem`、`/getAllCompanyNoOverCompany`、`/getUseRangeByAttr`。

---

## BIZ-ORG-004 页面视图权限与缓存

| 业务 | Controller | Service |
|---|---|---|
| 页面视图配置 | `PageViewConfigController`，根路径 `/page-view-config` | `IPageViewConfigService` / `PageViewConfigServiceImpl` |
| 视图权限缓存 | `ViewPermissionCacheController`，根路径 `/view-permission-cache` | `IViewPermissionCacheService` / `ViewPermissionCacheServiceImpl` |
| 视图权限数据 | - | `IViewPermissionDataService` / `ViewPermissionDataServiceImpl` |

工具入口：`ViewDataPermissionContext`、`ViewPermissionChecker`。

---

## 变更摘要

| 日期 | 业务编号 | 描述 |
|------|---------|------|
| 2026-05-28 | BIZ-ORG-001 ~ 004 | 新增组织、片区、用途范围、页面视图权限映射 |
