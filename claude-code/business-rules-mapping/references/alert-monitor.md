# 监控与预警模块（BIZ-ALERT-001 ~ 004）

> 主 SKILL.md 的子文档。记录预警监控、安全库存监控、效期监控和消息通道入口。

## BIZ-ALERT-001 预警配置、端点、事件

| 业务 | 前端路径 | Controller | Service |
|---|---|---|---|
| 预警配置 | `front-pc/src/pages/alertmonitor/config.vue` | `AlertConfigController`，根路径 `/alert/monitor/config` | `IAlertConfigService` / `AlertConfigServiceImpl` |
| 预警端点 | `front-pc/src/pages/alertmonitor/endpoint.vue` | `AlertEndpointController`，根路径 `/alert/monitor/endpoint` | `IAlertEndpointService` / `AlertEndpointServiceImpl` |
| 预警事件 | `front-pc/src/pages/alertmonitor/event.vue`、`eventDetail.vue` | `AlertEventController` | `IAlertEventService` / `AlertEventServiceImpl` |

---

## BIZ-ALERT-002 预警执行链路入口

| 类型 | 代码位置 |
|---|---|
| 定时触发 | `AlertScheduler` |
| MQ Handler | `AlertTriggerMqHandler`，Tag：`ALERT_TRIGGER_TAG` |
| 执行器 | `AlertExecutor` / `AlertExecutorImpl` |
| 端点扫描 | `AlertSourceScanner` |
| 配置校验 | `AlertConfigValidator` |
| 规则引擎 | `SpelRuleEngine` |
| 模板渲染 | `AlertTemplateRenderer` |
| SQL 校验 | `AlertSqlValidator` |
| 日志格式化 | `AlertLogFormatter` |

---

## BIZ-ALERT-003 数据源、接收人、通道

| 类别 | 代码位置 |
|---|---|
| 数据源注册 | `AlertDataSourceRegistry` |
| SQL 数据源 | `SqlAlertDataSource` |
| 外部 API 数据源 | `ExternalApiAlertDataSource` |
| Controller 数据源 | `ControllerAlertDataSource` |
| 接收人分发 | `ReceiverDispatcher` |
| 接收人解析 | `ReceiverResolver`、`UserReceiverResolver`、`ResolvedReceiver` |
| 通道注册 | `AlertChannelRegistry`、`AlertChannelSupport` |
| 系统消息通道 | `SystemMessageChannel` |
| 企业微信应用消息通道 | `WeixinAppMessageChannel` |
| 企业微信机器人通道 | `WeixinRobotChannel` |

---

## BIZ-ALERT-004 库存监控

| 业务 | 前端路径 | Controller | Service |
|---|---|---|---|
| 安全库存配置 | `front-pc/src/pages/configuration/safeStock` | `SafetyStockMonitorSettingController`，根路径 `monitor/setting/safetystock` | `SafetyStockMonitorSettingService`、`SafetyStockMonitorSubService` |
| 安全库存监控 | - | `SafetyStockMonitorController` | `SafetyStockMonitorService` |
| 效期监控配置 | - | `NearExpireDefineConfigController` | `NearExpireDefineConfigService` |
| 效期监控 | `front-pc/src/pages/inventoryPool/expirationMonitoring/index.vue` | `ExpirationMonitorController` | `ExpirationMonitorService` |

---

## 变更摘要

| 日期 | 业务编号 | 描述 |
|------|---------|------|
| 2026-05-28 | BIZ-ALERT-001 ~ 004 | 新增预警监控、执行链路、数据源/通道、安全库存和效期监控映射 |
