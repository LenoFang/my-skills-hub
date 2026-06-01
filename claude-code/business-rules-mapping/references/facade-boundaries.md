# Facade 跨模块接口边界（BIZ-FACADE-001 ~ 005）

> 主 SKILL.md 的子文档。记录 `base-facade` 中对外接口与 `base-service` 中对应实现，用于定位跨模块调用边界。

## BIZ-FACADE-001 Facade 目录

| 类型 | 路径 |
|---|---|
| 接口模块 | `code-backend/base-facade/src/main/java/com/tcoa/scm/facade` |
| 实现目录 | `code-backend/base-service/src/main/java/com/tcoa/scm/service/facade/impl` |

---

## BIZ-FACADE-002 组织与配置 Facade

| Facade 接口 | DTO | 实现 |
|---|---|---|
| `ICompanyConfigFacade` | `CompanyConfigDTO` | `CompanyConfigFacadeImpl` |
| `IUseRangeConfigFacade` | `UseRangeConfigFacadeDTO` | `UseRangeConfigFacadeImpl` |

---

## BIZ-FACADE-003 物料与商品 Facade

| Facade 接口 | DTO/事件 | 实现 |
|---|---|---|
| `IMaterialBaseFacade` | `MaterialBaseFacadeDTO` | `MaterialBaseFacadeImpl` |
| `IMaterialCategoryFacade` | - | `MaterialCategoryFacadeImpl` |
| `IMaterialGoodsFacade` | - | `MaterialGoodsFacadeImpl` |
| `IEmallGoodsMaterialFacade` | `EmallGoodsMaterialDTO` | `EmallGoodsMaterialFacadeImpl` |
| `IMaterialEventPublisher` | `MaterialPriceUpdatedEvent` | `MaterialEventPublisherImpl` |

---

## BIZ-FACADE-004 库存与冻结 Facade

| Facade 接口 | DTO | 实现 |
|---|---|---|
| `IInventoryQueryFacade` | `InventorySubDTO`、`StockOnHandDTO` | `InventoryQueryFacadeImpl` |
| `IAssetFreezeQueryFacade` | - | `AssetFreezeQueryFacadeImpl` |

---

## BIZ-FACADE-005 申请与价格查询 Facade

| Facade 接口 | DTO | 实现 |
|---|---|---|
| `IMaterialApplyQueryFacade` | `MaterialApplyBaseFacadeDTO` | `MaterialApplyQueryFacadeImpl` |
| `IMaterialPriceQueryFacade` | - | `MaterialPriceQueryFacadeImpl` |

---

## 变更摘要

| 日期 | 业务编号 | 描述 |
|------|---------|------|
| 2026-05-28 | BIZ-FACADE-001 ~ 005 | 新增 base-facade 接口、DTO/事件和 base-service 实现映射 |
