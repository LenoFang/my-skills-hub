# 数据同步模块（BIZ-SYNC-001 ~ 003）

> 主 SKILL.md 的子文档。数据同步调用链路与总账比对监控。

## BIZ-SYNC-001 数据同步调用链路

**功能描述**：各业务操作完成后触发数据同步，包括 EBS 推送、资产事务、库存流水、总账推送

**调用链路总览**：
```
业务操作（领用/退货/调拨/入库/出库/盘点等）
    │
    ▼
sync.impl.XxxPostDataHandlerService（30+个业务Handler）
    │  所有Handler均为 @Scope("prototype")
    │
    ├─① createTransData() → fillSyncTransData() → 保存资产事务数据
    │     └─ transService.saveTranslationInfo()
    │
    ├─② fillRequestParams() → addAssetEbsInfo() → 构建EBS推送参数
    │     └─ 资产新增(ASSET_ADDITION)/资产转移(ASSET_TRANSFER)/资产报废(ASSET_RETIRE)
    │
    ├─③ postEBSRequest() → 推送EBS接口
    │     └─ pushSubRequest() 遍历 assetEbsInfoList 逐条推送
    │
    └─④ doCallback() → 业务回调（含创建库存流水）
          │
          └─ inventorySerialOrderService.addSerialOrder()
                │
                ├─ 保存流水单 + 子项
                ├─ 更新库存池数据 (refreshPoolData)
                └─ pushGeneralLedgerData() → 推送总账
                          │
                          └─ Spring Event → PushGeneralLedgerBusinessListener
                                │
                                └─ syncPushService.pushInfo() → 总账推送EBS
```

**基类体系**：
| 基类 | 说明 |
|------|------|
| `BaseDataHandlerService` | 数据处理器基类 |
| `BaseDataPostHandlerService` | 推送处理器基类（含推送/异步推送/回调） |
| `BaseEBSPostHandlerService` | EBS推送处理器基类（含资产子推送逻辑） |
| `BaseEBSSubPostHandlerService` | EBS子推送处理器基类 |

**业务 Handler 映射表**：
| Handler | SyncSourceEnum | 业务场景 |
|---------|---------------|----------|
| `MaterialApplyPostDataHandlerService` | MATERIAL_APPLY | 物资申请 |
| `MaterialReceivePostDataHandlerService` | MATERIAL_RECEIVE | 物资领用 |
| `MaterialReturnPostDataHandlerService` | MATERIAL_RETURN | 物资退货 |
| `MaterialStockAllotPostDataHandlerService` | STOCK_ALLOT | 库存调拨 |
| `MaterialAssetAllotPostDataHandlerService` | ASSET_ALLOT | 资产调拨 |
| `MaterialTransAllotPostDataHandlerService` | (跨公司调拨) | 物资跨公司调拨 |
| `MaterialGiftStoragePostDataHandlerService` | GIFT_STORAGE | 赠品入库 |
| `MaterialInventoryDisposalPostDataHandlerService` | INVENTORY_DISPOSAL | 库存处置 |
| `MaterialInventoryProfitPostDataHandlerService` | INVENTORY_PROFIT | 库存盘盈 |
| `MaterialClosedLoopPostDataHandlerService` | CLOSED_LOOP | 资产闭环 |
| `MaterialAssetsInitPostDataHandlerService` | MATERIAL_ASSETS_INIT | 资产初始化 |
| `ComputerInstalledPostDataHandlerService` | COMPUTER_INSTALLED | 装机回调 |
| `SalesReceivePostDataHandlerService` | SALES_RECEIVE | 销售领用 |
| `SalesReturnPostDataHandlerService` | SALES_RETURN | 销售退货 |
| `SalesOutboundOrderReceivePostDataHandlerService` | SALES_OUTBOUND_ORDER_RECEIVE | 销售出库领用 |
| `SalesOutboundOrderReturnPostDataHandlerService` | SALES_OUTBOUND_ORDER_RETURN | 销售出库退回 |
| `PosInventoryFlowPostDataHandlerService` | POS_INVENTORY_FLOW_ORDER | 门店出入库 |
| `PoRcvPostDataHandlerService` | PURCHASE_STOCK | 采购入库 |
| `PoRcvRtnPostDataHandlerService` | PURCHASE_RETURN | 采购退货 |
| `PoRecPostDataHandlerService` | (采购验收入库) | 采购验收 |
| `PoRecRtnPostDataHandlerService` | (采购验收退货) | 验收退货 |
| `PoRecForVirtualPostDataHandlerService` | (虚拟采购) | 虚拟采购验收 |
| `PoOrderCreatePostDataHandlerService` | PURCHASE_ORDER_CREATE | 采购订单创建 |
| `PoOrderCancelPostDataHandlerService` | (采购取消) | 采购订单取消 |
| `PoOrderUpdatePostDataHandlerService` | (采购更新) | 采购订单更新 |
| `PoImportPostDataHandlerService` | (采购导入) | 采购导入 |
| `PoApprovedSyncPostDataHandlerService` | (审批同步) | 采购审批同步 |
| `PoUnqualifyPostDataHandlerService` | (不合格处理) | 采购不合格 |
| `InventoryCustomDiscrepancyPostDataHandlerService` | INVENTORY_CUSTOM_DISCREPANCY | 盘点差异 |
| `MaterialInfoImportPostDataHandlerService` | (物料导入) | 物料信息导入 |
| `DefaultPostDataHandlerService` | (默认) | 默认处理器 |

**资产 EBS 子推送 Handler**（sub 包）：
| Handler | SyncSourceEnum | 说明 |
|---------|---------------|------|
| `AssetAdditionPostDataHandlerService` | ASSET_ADDITION | 资产新增 |
| `AssetTransferPostDataHandlerService` | ASSET_TRANSFER | 资产转移 |
| `AssetRetirePostDataHandlerService` | ASSET_RETIRE | 资产报废 |

**关键服务依赖**：
| 服务 | 说明 |
|------|------|
| `InventorySerialOrderService` | 库存流水单服务 |
| `InventoryDataPoolService` | 库存池数据服务 |
| `IMaterialAssetTransService` | 资产事务服务 |
| `SyncGeneralLedgerPushService` | 总账推送服务 |
| `ISyncDataPostService` | 推送配置管理服务 |
| `ISyncDataLogService` | 推送日志服务 |

**线程模型**：
- 同步推送：`push()` 在调用线程中执行
- 异步推送：`pushAsync()` 提交到 `ThreadPoolTaskExecutor`（核心10/最大20/队列1000）
- 事务后提交：通过 `TransactionSynchronizationAdapter.afterCommit()` 在事务提交后异步推送
- 总账推送：通过 Spring ApplicationEvent 同步触发

**补偿机制**：
- 推送失败的数据记录在 `sync_data_post` 表中，通过页面/API 可发起重推
- 库存流水创建异常会发送 DSF 告警通知管理员
- 总账推送异常会发送 DSF 告警通知管理员（2026-02-11 新增）
- 回调异常会发送 DSF 告警通知管理员（2026-02-11 新增）

---

## BIZ-SYNC-002 总账推送比对监控

**功能描述**：通过反向分析库存流水单与 inventory_trans_config 配置，判断哪些业务单据缺少总账推送或资产推送记录，支持字段比对和已处理标记

**关键数据关联**：
1. 总账推送：`sync_general_ledger_push.serial_id = inventory_serial_order.order_id`（非 syncId 关联）
2. `inventory_serial_order.sync_id` = `sys_sync_data_post.data_id`（推送列表主键），不是总账表
3. 资产推送：`sys_sync_data_post_sub.data_id` = `inventory_serial_order.sync_id`，直接通过 syncId 关联
4. 业务单号字段：`trans_type`、`trans_id`、`trans_code`、`trans_line_id`（非 relation 系列字段）
5. `sync_general_ledger_detail` 上仍使用 `relation` 系列字段

**比对逻辑**：
1. 从 `inventory_serial_order` 出发，匹配 `inventory_trans_config` 配置判断"应推"
2. 通过 `sglp.serial_id = iso.order_id` LEFT JOIN `sync_general_ledger_push` 判断总账"实推"
3. 通过 `sync_id`（= `sys_sync_data_post.data_id`）直接关联 `sys_sync_data_post_sub`（sub_post_source=30/31/32）判断资产"实推"
4. 比对字段：公司编码、成本中心、利润中心

**缓存机制**：
- 刷新按钮触发异步比对，结果通过 `IRedisUtil.saveSplitByZipped` 存入 Redis（key: `SCM:LEDGER_COMPARISON:{periodName}`）
- 查询从缓存读取，在内存中过滤+分页
- 状态 key: `SCM:LEDGER_COMPARISON_STATUS:{periodName}`，值: idle/running/done/error
- 缓存过期时间: 1 小时

**核心逻辑**：
| 方法 | 所在类 | 说明 |
|------|--------|------|
| `refreshComparison()` | `LedgerComparisonServiceImpl` | 异步刷新比对数据到 Redis 缓存 |
| `getComparisonPageList()` | `LedgerComparisonServiceImpl` | 从缓存分页查询比对结果 |
| `getSummary()` | `LedgerComparisonServiceImpl` | 从缓存汇总统计 |
| `getRefreshStatus()` | `LedgerComparisonServiceImpl` | 查询刷新进度状态 |
| `markHandled()` | `LedgerComparisonServiceImpl` | 标记已处理 |
| `matchConfig()` | `LedgerComparisonServiceImpl` | 匹配 inventory_trans_config 配置 |
| `shouldPushAsset()` | `LedgerComparisonServiceImpl` | 判断是否应推资产 |
| `buildAssetSubMap()` | `LedgerComparisonServiceImpl` | 通过 syncId 直接关联资产推送子记录 |

**API 接口**：
| 接口 | 说明 |
|------|------|
| `POST /sync/ledger/comparison/refresh` | 触发异步刷新比对数据 |
| `GET /sync/ledger/comparison/refreshStatus` | 查询刷新进度 |
| `GET /sync/ledger/comparison/list` | 分页查询比对结果（从缓存读取） |
| `GET /sync/ledger/comparison/init` | 初始化数据 |
| `GET /sync/ledger/comparison/summary` | 汇总统计（从缓存读取） |
| `POST /sync/ledger/comparison/markHandled` | 标记已处理 |
| `POST /sync/ledger/comparison/batchMarkHandled` | 批量标记 |

**已处理标记**：复用 `sys_sync_data_log` 表，logType=2(比对标记)，logKind=2(比对已处理)

**前端页面**：`front-pc/src/pages/inventoryPool/pushLedgerComparison/index.vue`  
**路由**：`/inventoryPool/pushLedgerComparison/index`

---

## BIZ-SYNC-003 总账与同步管理页面

**功能描述**：总账推送、同步记录、总账比对、总账审计、总账规则、总账调整等页面和后端入口。

| 业务 | 前端路径 | Controller |
|---|---|---|
| 同步记录 | `front-pc/src/pages/sync` | `SyncDataPostController`、`SyncDataPostApiController` |
| 总账推送 | `front-pc/src/pages/inventoryPool/pushLedger` | `SyncGeneralLedgerPushController` |
| 总账比对 | `front-pc/src/pages/inventoryPool/pushLedgerComparison` | `LedgerComparisonController` |
| 总账审计 | `front-pc/src/pages/inventoryPool/pushLedgerAudit` | `SyncLedgerAuditLogController` |
| 总账自动规则 | `front-pc/src/pages/inventoryPool/pushLedgerRule` | `SyncLedgerAutoRuleController` |
| 总账看板 | `front-pc/src/pages/inventoryPool/pushLedgerDashboard` | `SyncLedgerDashboardController` |
| 总账调整 | `front-pc/src/pages/inventoryPool/generalLedgerAdjust` | `GeneralLedgerAdjustController` |

---

## 变更摘要

| 日期 | 业务编号 | 描述 |
|------|---------|------|
| 2026-02-11 | BIZ-SYNC-001 | 新增数据同步调用链路文档，包含完整 Handler 映射表和线程模型 |
| 2026-02-28 | BIZ-SYNC-002 | 新增总账推送比对监控功能，支持反向分析缺失推送和字段差异比对 |
| 2026-02-28 | BIZ-SYNC-002 | 修复关联关系(serial_id)、业务字段(trans 系列)、syncId 直连资产推送、Redis 缓存+刷新机制 |
| 2026-05-28 | BIZ-SYNC-003 | 补充同步记录、总账推送、比对、审计、规则、看板、调整页面和 Controller 映射 |
