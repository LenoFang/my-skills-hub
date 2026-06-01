# MQ 与业务事件映射（BIZ-MQ-001 ~ 003）

> 主 SKILL.md 的子文档。只记录仓库中确认存在的 TurboMQ、MQ Handler 和 Spring 业务事件入口。

## BIZ-MQ-001 TurboMQ 基础入口

| 类型 | 代码位置 | 说明 |
|---|---|---|
| Tag 常量 | `base-common/src/main/java/com/tcoa/scm/common/constant/Constant.java` | `Constant.TurboMqTags` 定义 MQ tag |
| Handler 接口 | `base-common/src/main/java/com/tcoa/scm/common/mq/IMqMessageHandler.java` | MQ 消费处理器接口 |
| Handler 注解 | `base-common/src/main/java/com/tcoa/scm/common/mq/annotation/MqHandler.java` | 标记 tag 和说明 |
| 分发器 | `base-common/src/main/java/com/tcoa/scm/common/mq/MqMessageDispatcher.java` | 收集 `IMqMessageHandler` 并按 tag 分发 |
| MQ 服务接口 | `base-service/src/main/java/com/tcoa/scm/service/mq/ITurboMqService.java` | 生产、延迟生产、消费入口 |
| MQ 服务实现 | `base-service/src/main/java/com/tcoa/scm/service/mq/impl/TurboMqServiceImpl.java` | 调用 `TurboMQProducer`，消费时委派 `MqMessageDispatcher` |
| 生产工具 | `base-service/src/main/java/com/tcoa/scm/service/mq/TurboMQProducer.java` | TurboMQ 生产封装 |
| 消费工具 | `base-service/src/main/java/com/tcoa/scm/service/mq/TurboMQConsumer.java` | TurboMQ 消费封装 |

---

## BIZ-MQ-002 已确认 MQ Handler

| Handler | Tag 常量 | 说明 |
|---|---|---|
| `LedgerDelayRepushMqHandler` | `LEDGER_DELAY_REPUSH` | 总账推送延迟重推 |
| `AssetTransChangeMqHandler` | `ASSET_TRANS_CHANGE_TAG` | 资产事务变更消息处理 |
| `PaymentCallbackMqHandler` | `EXTERNAL_PAYMENT_APPLY_TAG_CALLBACK` | 外部付款回调 |
| `ContractSyncMqHandler` | `EXTERNAL_FINANCE_TAG_CONTRACT` | 外部财务合同同步 |
| `AlertTriggerMqHandler` | `ALERT_TRIGGER_TAG` | 预警监控触发执行 |

**已确认生产方入口**：

| 场景 | 代码位置 | Tag |
|---|---|---|
| 资产事务变更 | `MaterialAssetTransService` | `ASSET_TRANS_CHANGE_TAG` |
| 总账规则延迟重推 | `DelayRepushAction` | `LEDGER_DELAY_REPUSH` |
| 总账延迟重推 Handler 内再次投递 | `LedgerDelayRepushMqHandler` | `LEDGER_DELAY_REPUSH` |
| 预警监控定时触发 | `AlertScheduler` | `ALERT_TRIGGER_TAG` |
| 预警配置触发 | `AlertConfigServiceImpl` | `ALERT_TRIGGER_TAG` |
| 电商对账付款申请 | `EmallReconciliationServiceImpl` | `EXTERNAL_PAYMENT_APPLY_TAG` |

---

## BIZ-MQ-003 Spring 业务事件

| 事件 | Manage | Listener |
|---|---|---|
| `PushGeneralLedgerBusinessEvent` | `PushGeneralLedgerBusinessEventManage` | `PushGeneralLedgerBusinessListener` |
| `PushEbsAssetBusinessEvent` | `PushEbsAssetBusinessEventManage` | `PushEbsAssetBusinessListener` |
| `VirtualPurchaseBusinessEvent` | `VirtualPurchaseBusinessEventManage` | `VirtualPurchaseBusinessListener` |

公共基类：`BaseBusinessEvent`、`BaseEventManage`、`BaseBusinessListener`。修改事件发布和监听时优先查看这些基类。

---

## 变更摘要

| 日期 | 业务编号 | 描述 |
|------|---------|------|
| 2026-05-28 | BIZ-MQ-001 ~ 003 | 新增 TurboMQ、MQ Handler 和 Spring 业务事件映射 |
