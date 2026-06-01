# 库存冻结模块（BIZ-INV-001）

> 主 SKILL.md 的子文档。库存冻结并发控制与调用方清单。  
> 更详细的代码模板见 `inventory-freeze-safety` skill。

## BIZ-INV-001 库存冻结并发控制

**功能描述**：出库/领用/发货等操作需要冻结库存，确保并发场景下不超卖

**核心流程**：
1. 读取可用库存（实际库存 - 已冻结数量）
2. 校验是否满足需求数量
3. 写入冻结记录
4. 以上步骤必须在同一个分布式锁内原子完成

**批次路径（核心方法）**：
- `InventoryDataPoolServiceImpl.getInventoryBatchMap()` - 按批次分配库存并加锁
- 锁 Key：`InventoryBatchMap_<materialCode>_<stockCode>_<organizationCode>_<companyCode>`
- 锁在事务提交后释放（`TransactionSynchronizationAdapter.afterCompletion`）

**非批次路径**：
- 各调用方自行加锁保护"检查库存 + 写冻结"操作
- 锁 Key：`InventoryFreeze_<materialCode>_<stockCode>_<organizationCode>_<companyCode>`

**涉及的冻结调用方**：

| 调用方类 | 方法 | 业务场景 | 冻结类型 |
|----------|------|----------|----------|
| `SalesOutboundOrderProductServiceImpl` | `freezeInventoryQuantity` | 销售出库 | `SALES_OUTBOUND_ORDER` |
| `SalesOrderDeliveryServiceImpl` | `freezeInventoryQuantity` | 销售发货 | `SALES_ORDER_DELIVERY` |
| `PosOutApiServiceImpl` | `freezeMaterial` | POS 出库 | 门店出库 |
| `PosInventoryFlowServiceImpl` | `freezeMaterial` | POS 库存流水 | 门店流水 |
| `MaterialReceiveServiceImpl` | `freezeService.freezeMaterials()` | 物资领用 | `MATERIAL_RECEIVE` |
| `MaterialApplySubServiceImpl` | `freezeService.freezeMaterials()` | 物资申请 | `MATERIAL_APPLY` |
| `MaterialInventoryDisposalServiceImpl` | `freezeService.freezeMaterials()` | 资产处置 | 处置冻结 |
| `MaterialStockAllotServiceImpl` | `freezeService.freezeMaterials()` | 物资调拨 | 调拨冻结 |

> 说明：销售 / Material 系调用方直接调接口方法 `freezeService.freezeMaterials(...)`（复数）；POS 系（`PosOutApiServiceImpl:612`、`PosInventoryFlowServiceImpl:1194`）各有类内**私有编排方法** `freezeMaterial(...)`（单数），内部仍调 `freezeService.freezeMaterials()`（见 PosOutApi:639/689）。两者不要混淆。

**解冻配套方法**：
- `IMaterialAssetFreezeService.unFreezeMaterials(relationData)` - 按业务关系数据解冻（POS 撤回 / 单据取消等场景调用，见 `PosInventoryFlowServiceImpl`）

**依赖服务**：
- `IMaterialAssetFreezeService.freezeMaterials()` - 写入冻结记录
- `IMaterialAssetFreezeService.getBatchFreezeCountByMaterial()` - 按批次查询冻结数量
- `InventoryDataPoolService.getInventoryBatchMap()` - 批次分配
- `InventoryDataPoolService.checkInventoryQuantity()` - 校验库存
- `RedisDistributeLock` - 分布式锁

**只读查询方法（不涉及锁，不受并发控制影响）**：
- `getInventoryQuantity()` - 查询库存数量
- `getMaterialAvailableInventoryQuantity()` - 查询可用库存
- `checkInventoryQuantity()` - 校验库存是否充足
- `fillPoolDetailInfo()` - 填充库存池详情（显示用）

---

## 变更摘要

| 日期 | 业务编号 | 描述 |
|------|---------|------|
| 2026-02-09 | BIZ-INV-001 | 新增库存冻结并发控制文档，修复出库超卖问题 |
| 2026-02-24 | BIZ-INV-001 | 修复同一单据多行相同物料冻结时分布式锁重入失败问题，引入 InventoryFreezeContext 合并模式 |

---

## 审查记录 (2026-05-28)

> 抽样验证 gpt5.5 主体生成内容；以代码为准，未直接改正文，请逐条确认是否落正文。

### ✅ 已核实（与代码一致）
- 6 个调用方类全部存在于 `base-service`：`InventoryDataPoolServiceImpl`、`SalesOutboundOrderProductServiceImpl`、`SalesOrderDeliveryServiceImpl`、`PosOutApiServiceImpl`、`PosInventoryFlowServiceImpl`、`MaterialReceiveServiceImpl`、`MaterialApplySubServiceImpl`
- 方法签名正确：`InventoryDataPoolServiceImpl.getInventoryBatchMap()`（行 1630）、`fillPoolDetailInfo()`（行 1303，注意是 **private**）
- 锁 Key 格式与 `String.format` 字面量一致：`InventoryBatchMap_%s_%s_%s_%s`（InventoryDataPoolServiceImpl:1639）、`InventoryFreeze_%s_%s_%s_%s`（4 处调用方均一致）
- `TransactionSynchronizationAdapter.afterCompletion(int status)` 释放锁模式真实存在（InventoryDataPoolServiceImpl:378-391）
- `IMaterialAssetFreezeService` 接口与 `MaterialAssetFreezeService` 实现存在；`freezeMaterials`（**复数**）、`getBatchFreezeCountByMaterial` 签名正确
- `InventoryFreezeContext` 类真实存在（PosInventoryFlowServiceImpl:548 等处使用）

### ⚠️ 存疑 / 表达不精确（建议改写但不算错）
- **调用方表"方法"列**混淆了两类方法：
  - 销售/Material 系：调用 `freezeService.freezeMaterials(...)`（接口的复数方法）
  - POS 系：类内**私有方法** `freezeMaterial(...)`（单数，PosInventoryFlowServiceImpl:569）作为"冻结编排"，内部仍调 `freezeService.freezeMaterials()`
  - 当前表把两者都写成"freezeMaterial / freezeInventoryQuantity"扁平列在一起，读者难以分辨"接口调用 vs 私有编排方法"。建议加一列"方法类型"或拆两表
- `MaterialReceiveServiceImpl` 与 `MaterialApplySubServiceImpl` 行写的是"冻结逻辑"占位文字，应明确为"调用 `freezeService.freezeMaterials(targetData, relationData, inventoryBatchMap)`"（MaterialReceive:704、MaterialApplySub:1644 实证）
- "锁在事务提交后释放"表述准确，但配套机制是 `TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronizationAdapter(){...})`，而不是直接调 `TransactionSynchronizationAdapter.afterCompletion`。当前措辞容易让人误以为后者是入口。建议改为："通过 `TransactionSynchronizationManager.registerSynchronization` 注册回调，在事务 `afterCompletion` 阶段释放分布式锁"

### ❌ 缺漏（建议补到调用方表）
- `MaterialInventoryDisposalServiceImpl.freezeMaterials` 调用（行 309）—— **资产处置**场景的冻结，当前表完全未提
- `MaterialStockAllotServiceImpl.freezeMaterials` 调用（行 537）—— **物资调拨**场景的冻结，当前表完全未提
- 解冻入口 `freezeService.unFreezeMaterials(relationData)`（PosInventoryFlowServiceImpl:350、678 等多处）——本文档主题是冻结，但与冻结成对出现，建议加一节"解冻配套方法"否则定位时易遗漏

### 📌 建议结构性优化（结合 inventory-freeze-safety skill 一起看）
- 与独立 skill `inventory-freeze-safety` 的边界已经在文首声明（"详细模板见 inventory-freeze-safety"），但调用方表实际有重复嫌疑。建议本 reference 只保留"业务编号 + 调用方索引表"，把"批次/非批次模板代码"完全交给 `inventory-freeze-safety`，避免双份维护漂移

