# 子库存与仓储配置（BIZ-SINV-001 ~ 003）

> 主 SKILL.md 的子文档。记录子库存、库管员、仓储环境和库存组织入口。

## BIZ-SINV-001 子库存

| 类型 | 代码位置 |
|---|---|
| 前端页面 | `front-pc/src/pages/Home/configs/materialSubInventoryManager.vue` |
| Controller | `MaterialSubInventoryController`，根路径 `/materialSI` |
| Service | `IMaterialSubInventoryService` / `MaterialSubInventoryServiceImpl` |
| 管理员 Service | `IMaterialSubInventoryManagerService` / `MaterialSubInventoryManagerServiceImpl` |

已确认 API：`/list`、`/getDetail`、`/saveSubInventory`、`/disabled`、`/enable`、`/save`、`/del`。

---

## BIZ-SINV-002 库管员与仓储环境

| API | 说明 |
|---|---|
| `/initManager` | 初始化库管员 |
| `/saveWarehouseEnv` | 保存仓储环境 |
| `/initWarehouseEnv` | 初始化仓储环境 |

---

## BIZ-SINV-003 相关配置与库存组织

| 类型 | 代码位置 |
|---|---|
| 子库存属性配置 | `SubInventoryAttributeConfigHandler` |
| 库存组织 | `CompanyOrganizationController`、`ICompanyOrganizationService` |
| 库存公司服务 | `InventoryCompanyService` / `InventoryCompanyServiceImpl` |

---

## 变更摘要

| 日期 | 业务编号 | 描述 |
|------|---------|------|
| 2026-05-28 | BIZ-SINV-001 ~ 003 | 新增子库存、库管员、仓储环境和库存组织相关映射 |
