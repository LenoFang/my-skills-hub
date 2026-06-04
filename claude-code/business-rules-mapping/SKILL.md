---
name: business-rules-mapping
description: "Use when 用户问 'XX 功能在哪个文件'、'物料申请代码'、'采购申请流程'、'库存冻结代码'、'数据同步'、'资产维修流程'、'销售/POS'、'返租装机'、'通信设备'，或需要定位业务代码、理解业务流程、修改具体业务功能。SKILL.md 只做导航，详细映射在 references。"
---

# Business Rules - 业务功能映射（导航）

> 记录业务功能与代码的对应关系，便于快速定位实现位置。每次业务改动时同步更新对应的 references 文件。
> 本文件只维护总览和导航；具体业务规则、实体、方法、页面、API 均放在 `references/` 子文档中。

## 如何使用

1. 按模块进入对应 `references/` 子文档
2. 按业务编号（BIZ-XXX-NNN）找具体功能
3. 每个业务编号含：功能描述 / 核心实体 / 核心方法 / 前端页面 / API 接口（视情况）
4. 如果导航和代码不一致，以代码为准，并同步更新对应 reference

## 模块导航

| 模块 | 业务编号前缀 | 参考文件 | 关键内容 |
|---|---|---|---|
| 物料信息 | BIZ-MAT-001 ~ 010 | [references/material.md](references/material.md) | 物料类型 / 实物/费用/服务物料流程 / 物料更新动态审批 / 服务物料入口 / 角色权限 / 驳回退回 |
| 物资申请与流转 | BIZ-MO-001 ~ 004 | [references/material-operations.md](references/material-operations.md) | 物资申请 / 领用 / 退货 / 调拨 / 赠品入库 / 盘盈 / 处置 / 评价 |
| 采购申请 | BIZ-PA-001 ~ 003 | [references/purchase-apply.md](references/purchase-apply.md) | 自动同意下单 / 整单同意 / PO 单自动建单 |
| 采购执行 | BIZ-PO-001 ~ 006 | [references/purchase-execution.md](references/purchase-execution.md) | 采购订单 / 采购变更 / 采购退货 / 价格库 / 采购合同 / 采购看板 / EBS 采购汇总 |
| 物料价格 | BIZ-PRICE-001 ~ 003 | [references/material-price.md](references/material-price.md) | 物料价格库 / 价格申请 / 明细导入 / 供应商 / Wolf 审批 |
| Wolf 审批实现 | BIZ-WOLF-001 ~ 003 | [references/wolf-approval.md](references/wolf-approval.md) | Wolf 回调入口 / Handler 注册 / 已确认处理器清单 |
| 库存冻结 | BIZ-INV-001 | [references/inventory-freeze.md](references/inventory-freeze.md) | 并发控制 / 批次与非批次路径 / 分布式锁 / 调用方清单 |
| 库存池与盘点 | BIZ-STOCK-001 ~ 004 | [references/inventory-stock.md](references/inventory-stock.md) | 库存池 / 库存流水 / 调整 / 快照 / 成本结存 / 盘点 / RFID / 差异 |
| 盘点流程 | BIZ-IPROC-001 ~ 004 | [references/inventory-process.md](references/inventory-process.md) | 盘点项目 / 盘点计划 / RFID 盘点 / 静态资产处理 / 待办消息 |
| 子库存与仓储配置 | BIZ-SINV-001 ~ 003 | [references/sub-inventory.md](references/sub-inventory.md) | 子库存 / 库管员 / 仓储环境 / 库存组织 |
| 资产生命周期 | BIZ-ASSET-001 ~ 005 | [references/asset-lifecycle.md](references/asset-lifecycle.md) | 资产信息 / 初始化 / 资产变更 API / 变更历史 / 资产直接更新 / 维修 / 转移 / 交还 / 闭环处置 steps |
| 移动端入口 | BIZ-MOBILE-001 ~ 005 | [references/mobile-entry.md](references/mobile-entry.md) | 移动端基础 / 资产 / 采购 / 出库 / 装机 / 盘点 / 预警 |
| 数据同步 | BIZ-SYNC-001 ~ 003 | [references/sync.md](references/sync.md) | Handler 调用链 / EBS/总账/资产推送 / 线程模型 / 总账比对监控 / 总账修复页面 |
| 总账推送规则 | BIZ-LEDGER-001 ~ 003 | [references/ledger-rules.md](references/ledger-rules.md) | 总账页面入口 / 自动规则动作 / 延迟重推链路 |
| MQ 与业务事件 | BIZ-MQ-001 ~ 003 | [references/mq-events.md](references/mq-events.md) | TurboMQ / MQ Handler / Spring 业务事件 |
| 销售与 POS | BIZ-SALES-001 ~ 004 | [references/sales-pos.md](references/sales-pos.md) | 销售分类 / 商品 / BOM / 订单 / 发货 / 出库 / 退货 / POS 库存 |
| POS 独立入口 | BIZ-POS-001 ~ 006 | [references/pos-entry.md](references/pos-entry.md) | front-pos / POS 管理端 / POS API / 门店 / 商品价格 / 订单支付 / 交班 / 补货 / 推送补偿 |
| 电商商城 | BIZ-EMALL-001 ~ 006 | [references/emall.md](references/emall.md) | 商品 / 订单 / 售后 / 库存 / 物流 / 发票 / 对账 / 支付 / 企业 / 授信 / 保证金 |
| 看板与风险 | BIZ-KANBAN-001 ~ 004 | [references/kanban-risk.md](references/kanban-risk.md) | 采购看板 / 采购风险 / 采购效率 / 物料风险 / 看板数据服务 |
| 财务主数据与付款 | BIZ-FIN-001 ~ 005 | [references/finance-payment.md](references/finance-payment.md) | 财务主数据 / 财务回调 / ERP 回调 / 发票回调 / 付款 / 付款 MQ / 财务配置 |
| 返租装机、租赁出库与通信设备 | BIZ-LEASE-001 ~ 003 / BIZ-IDC-001 | [references/lease-idc.md](references/lease-idc.md) | 入职电脑装机 / 返租 / 退租 / 租赁出库 / 设备清单 / 通信设备 |
| 内部服务类申请 | BIZ-ISA-001 ~ 005 | [references/internal-service-apply.md](references/internal-service-apply.md) | 名片 / 印刷品 / 机柜 / 服务器 / 自提柜 |
| 系统治理 | BIZ-SYS-001 ~ 004 | [references/system-governance.md](references/system-governance.md) | 权限资源 / API 管理 / 预警监控 / 定时任务 |
| Admin 后台权限 | BIZ-ADMIN-001 ~ 006 | [references/admin-permission.md](references/admin-permission.md) | admin-backend / 资源树 / 角色用户 / 数据权限 / 页面权限 / 元素权限 / API 转发 |
| 组织、区域、用途与视图权限 | BIZ-ORG-001 ~ 004 | [references/org-region-permission.md](references/org-region-permission.md) | 库存组织 / 虚拟组织 / 片区 / 用途范围 / 页面视图权限 |
| 监控与预警 | BIZ-ALERT-001 ~ 004 | [references/alert-monitor.md](references/alert-monitor.md) | 预警配置 / 端点 / 事件 / 执行链路 / 安全库存 / 效期监控 |
| 运维任务与补偿入口 | BIZ-OPS-001 ~ 004 | [references/operations-jobs.md](references/operations-jobs.md) | 调度网关 / 资产事务补偿 / 员工同步 / 管理补偿 |
| Facade 跨模块接口边界 | BIZ-FACADE-001 ~ 005 | [references/facade-boundaries.md](references/facade-boundaries.md) | base-facade 接口 / DTO / 事件 / base-service 实现 |
| 平台支撑与通用能力 | BIZ-PLAT-001 ~ 006 | [references/platform-support.md](references/platform-support.md) | utils / 系统配置 / API 鉴权 / 流水号 / 表单号解析 / 开发工具 |
| 预算服务 | BIZ-BUDGET-001 | [references/budget.md](references/budget.md) | 预算占用 / 消耗 / 释放 / 科目映射 / 余额查询 / 定时释放（内部服务，无 Controller） |

## 附录：常用配置枚举

| 枚举值 | 说明 | 处理器 |
|--------|------|--------|
| `PURCHASE_APPLY_AUTO_AGREE_CONFIG` | 采购申请自动同意配置 | `PurchaseApplyAutoAgreeConfigHandler` |
| `PURCHASEAPPLY_SERIAL_NUMBER` | 采购申请流水号 | - |

## 主动更新时机（流程集成）

以下场景应主动更新对应 reference，不等 review 提示：

| 触发时机 | 命中条件 | 需更新的 reference |
|---------|---------|------------------|
| tcoa-review 产物自检 ⚠️ 命中后 | 新增/删除 Controller 方法 | 对应模块的 `references/<module>.md` BIZ 编号 |
| tcoa-review 产物自检 ⚠️ 命中后 | 新增/删除 `@WolfHandler` | `references/wolf-approval.md` |
| tcoa-review 产物自检 ⚠️ 命中后 | 新增/删除 MQ Handler | `references/mq-events.md` |
| tcoa-review 产物自检 ⚠️ 命中后 | 新增库存冻结调用方 | `references/inventory-freeze.md` |
| tcoa-review 产物自检 ⚠️ 命中后 | 新增定时任务 | `references/operations-jobs.md` |
| tcoa-git-flow 归档前 | 本次需求涉及业务逻辑新增/删除 | 同上，归档前作最后确认 |

**更新原则**：
- 新增功能 → 追加 BIZ 编号条目
- 删除功能 → 标注 `[已废弃]` 而非直接删除
- 修改方法签名/职责 → 更新对应 BIZ 编号的"核心方法"列

## 更新记录

旧版 Wolf 简表保留在 [references/workflow.md](references/workflow.md)，新增或修改 Wolf 映射时优先维护 [references/wolf-approval.md](references/wolf-approval.md)。

详见各 references 文件末尾的"变更摘要"。主文件仅维护索引。

---

## 全量审查总结 (2026-05-28)

> 本轮由 /tcoa-grill 触发，对 gpt5.5 主体生成的 30 份 reference 做准确性+完整性+结构核对。
> 详细审查记录见各 reference 末尾的"## 审查记录 (2026-05-28)"小节。

### 准确性：远超预期

| 深度审查（3 份） | 快扫（27 份） |
|---|---|
| `inventory-freeze.md`、`wolf-approval.md`、`material-operations.md` | 其余 27 份 |
| **0 处 ❌ 错误** | 全部判 🟢 绿色，抽样命中率 >99% |
| 仅有 ⚠️ 表达不精确 + 缺漏 | 仅有少量 enum 在 base-domain 而非 base-service（初次 grep 路径过窄导致误判） |

**gpt5.5 错误模式（避免，未来人工补写时注意）**：
1. 重名类只抓一个（如 PC 版本，漏移动端）
2. 不区分接口方法 vs 类内私有方法（freezeMaterials 复数 vs freezeMaterial 单数）
3. 不交叉引用相关 reference
4. 不区分双向 vs 单向注册（Wolf 的 WL+GL 双值压成单值）
5. 测试性 / 边角实现遗漏（如 `WolfTestService`）

### 完整性：发现 2 处真缺失

| 包 | 现状 | 建议 |
|---|---|---|
| `service/budget/` | `BudgetServiceImpl` + `BuddgetServiceTempImpl`（注意 typo "Buddget"）+ `IBudgetService`，**未在任何 reference 中出现** | 新增 `references/budget.md`（BIZ-BUDGET-001） |
| `service/steps/assetclosedloop/` | 10+ `*BusinessService`（资产闭环子流程：SellOut/SellCross/PersonLoss/PersonDamage/InventoryLoss/NoneIncomeDisposal 等） | 并入 `asset-lifecycle.md` 作为 BIZ-ASSET-005 章节 |
| `service/communicationdevice/` | 14+ `Idc*ServiceImpl`（通信设备生命周期：申请/办理/转移/退租/注销/恢复/离职/承运商/设备/费用） | **已被 `lease-idc.md` 覆盖**，确认无缺漏 |
| `service/demo/` | 演示代码 | 可忽略，不需 reference |

### 结构性建议（适用于持续优化）

1. **建立"穷举型清单"标杆**：`wolf-approval.md` 的"实现类 + 注解常量对账表"模式准确率最高，建议把它作为模板复制到 `mq-events.md`、`operations-jobs.md`、`alert-monitor.md` 等同类清单型 reference
2. **每个 BIZ 编号补一行"相关 reference"**：当前 reference 之间几乎无交叉引用，但实际业务高度耦合（如 material-operations 链接 wolf-approval + inventory-freeze）。建议每个二级标题下加 `> 相关：[[wolf-approval#BIZ-WOLF-002]]、[[inventory-freeze#BIZ-INV-001]]`
3. **前端"页面"列改为"目录"**：vue 文件多为 `list/add/detail/mlist` 多入口，目录指向比文件指向更准确
4. **重名类标注模块归属**：如 `MaterialApplyController` 在 project-pc 和 project-mobile 各一份，应在表中加包路径或并列
5. **避免与独立 skill 内容重复**：`inventory-freeze.md` 与 `inventory-freeze-safety` skill 有重叠嫌疑，建议本文档只保留"调用方索引表"，模板代码全交给后者

### 下一步建议（按优先级）

> 本轮（2026-05-28）已完成 ✅ 1 / 2 / 4，3 按渐进式部分落地。

1. ✅ 已完成：新增 `references/budget.md`（BIZ-BUDGET-001）
2. ✅ 已完成：`asset-lifecycle.md` 增 BIZ-ASSET-005 资产闭环 steps
3. 🔄 渐进式：5 条结构性建议**仅在本轮新增/改动文件上应用**（新内容含"相关 reference"交叉引用、重名类标包路径、闭环用 wolf-approval 标杆清单格式）；存量 27 份 🟢 文件未动，留待各模块下次实际改动时顺手升级
4. ✅ 已完成：3 份深度审查的"❌ 缺漏"已落正文（inventory-freeze 补 2 调用方 + 解冻方法；wolf-approval 补 `WolfTestService`；material-operations 补移动端重名 Controller）

### 遗留 / 待人工决策

- `BuddgetServiceTempImpl` 类名 typo（双 d）属既有历史代码，本轮仅在 `budget.md` 标注、**未改代码**，需单独开任务修复
- 3 份审查记录小节（`## 审查记录 (2026-05-28)`）中"❌ 缺漏"已落正文，保留作审查留痕；如需清爽可在确认后归档
- `workflow.md` 内容偏薄（仅 2 类），各业务域 `*WolfServiceImpl` 实际散落在 wolf-approval.md，属设计意图，非缺陷

