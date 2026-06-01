---
name: inventory-freeze-safety
description: "Use when 涉及库存冻结、出库、领用、发货代码，或用户提到 '冻结'、'freeze'、'分布式锁'、'批量冻结'、'InventoryFreezeContext'、'批次 / 非批次'、'锁合并'、'并发安全'。包含分布式锁模板和批次路径。"
---
# 库存冻结并发安全规范

## R-BE-039 库存冻结并发安全规范（重要）
涉及库存冻结/出库的代码必须遵循"读写原子性"原则，防止并发超卖。

**核心原则**："读取可用库存"和"写入冻结记录"必须在同一个分布式锁的保护下，且锁延迟到事务提交后释放。

### 批次物料（通过 `getInventoryBatchMap`）
- `InventoryDataPoolServiceImpl.getInventoryBatchMap()` 内部已有 Redis 分布式锁，锁在事务提交后释放
- 调用方无需额外加锁，但必须在同一个 `@Transactional` 事务中调用 `getInventoryBatchMap` 和 `freezeService.freezeMaterials`
- 锁 Key：`InventoryBatchMap_<materialCode>_<stockCode>_<organizationCode>_<companyCode>`

### 非批次物料
- 必须在调用方手动加锁，包裹"检查库存 + 冻结库存"操作
- 锁 Key：`InventoryFreeze_<materialCode>_<stockCode>_<organizationCode>_<companyCode>`
- 锁延迟释放模式：使用 `TransactionSynchronizationAdapter.afterCompletion` 在事务提交/回滚后释放

### 标准代码模板
```java
// 非批次物料冻结标准模板
String lockKey = String.format("InventoryFreeze_%s_%s_%s_%s", materialCode,
        stockCode, organizationCode, companyCode);
String lockVal = RedisDistributeLock.DEFAULT_LOCK_KEY;
if (!redisDistributeLock.tryLock(lockKey, lockVal, RedisDistributeLock.DEFAULT_ONE_MINUTES, 10, 300)) {
    throw new WarningException("系统繁忙，请稍后重试");
}
try {
    // 1. 检查可用库存
    BigDecimal available = getMaterialAvailableInventoryQuantity(...);
    if (available.compareTo(quantity) < 0) {
        throw new WarningException("库存数量不足");
    }
    // 2. 冻结库存
    freezeService.freezeMaterials(targetData, relationData, quantity);
} catch (Exception e) {
    redisDistributeLock.tryUnLock(lockKey, lockVal);
    throw e;
}
// 3. 延迟释放锁至事务提交后
if (TransactionSynchronizationManager.isSynchronizationActive()) {
    TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronizationAdapter() {
        @Override
        public void afterCompletion(int status) {
            redisDistributeLock.tryUnLock(lockKey, lockVal);
        }
    });
} else {
    redisDistributeLock.tryUnLock(lockKey, lockVal);
}
```

### 禁止的错误模式
```java
// 错误：读和写不在同一个锁保护下
BigDecimal available = getAvailableQuantity(...); // 读
// 此时另一个请求也读到了相同的可用库存！
freezeService.freezeMaterials(...); // 写 → 并发超卖

// 错误：锁在 finally 中立即释放
try {
    batchMap = getInventoryBatchMap(...);
} finally {
    redisDistributeLock.tryUnLock(lockKey, lockVal); // 释放太早！
}
freezeService.freezeMaterials(...); // 锁已释放，其他请求可以读到旧数据
```

### 已加锁保护的调用方（修改时需保持锁完整性）
| 类 | 方法 | 路径 |
|---|---|---|
| `InventoryDataPoolServiceImpl` | `getInventoryBatchMap` | 批次路径（内部锁） |
| `SalesOutboundOrderProductServiceImpl` | `freezeInventoryQuantity` | 非批次路径 |
| `SalesOrderDeliveryServiceImpl` | `freezeInventoryQuantity` | 非批次路径 |
| `PosOutApiServiceImpl` | `freezeMaterial` | 非批次路径 |
| `PosInventoryFlowServiceImpl` | `freezeMaterial` | 非批次路径 |

### 同一单据内多行相同物料的锁合并（InventoryFreezeContext 模式）
`RedisDistributeLock` 不支持重入，同一事务内对相同锁 Key 的第二次 `tryLock` 会失败。
当同一单据存在多行相同（物料+子库存+库存组织+公司）时，必须使用 `InventoryFreezeContext` 合并处理：

```java
// 1. 循环前预计算每个唯一维度的总需求量
InventoryFreezeContext ctx = new InventoryFreezeContext();
for (item : itemList) {
    String key = buildFreezeKey(materialCode, stockCode, orgCode, companyCode);
    ctx.totalQuantityByKey.merge(key, quantity, BigDecimal::add);
}
// 2. 循环中传入 ctx，首次遇到某 key 时获取锁并校验总量，后续复用
for (item : itemList) {
    freezeInventoryQuantity(item, ..., ctx);
}
```

**已使用 InventoryFreezeContext 的调用方**：
| 类 | 方法 |
|---|---|
| `SalesOutboundOrderProductServiceImpl` | `verifyInventoryQuantity` → `freezeInventoryQuantity` |
| `SalesOrderDeliveryServiceImpl` | `processInventoryQuantity` → `freezeInventoryQuantity` |
| `PosInventoryFlowServiceImpl` | `shipmentsOrder` / `addOrder` → `freezeMaterial` |
| `PosOutApiServiceImpl` | `addOrder` → `freezeMaterial` |

### 注意事项
1. `getInventoryBatchMap` 仅用于冻结场景，所有 6 个调用方都后接 `freezeMaterials`，不用于只读/显示
2. 只读查询库存数量的方法（`getInventoryQuantity`、`getMaterialAvailableInventoryQuantity`、`checkInventoryQuantity`）不涉及锁，不受影响
3. 新增库存冻结逻辑时，务必按上述模板加锁
4. 锁 Key 中四个维度（物料+子库存+库存组织+公司）缺一不可
5. 同一单据循环冻结多行时，必须使用 `InventoryFreezeContext` 模式避免锁重入失败
