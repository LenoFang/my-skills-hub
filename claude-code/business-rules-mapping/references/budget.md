# 预算服务模块（BIZ-BUDGET-001）

> 主 SKILL.md 的子文档。只记录已在仓库中确认存在的类、方法和调用方。
> 本模块为**内部服务**，无独立 Controller，被采购申请 / 物资申请 / 数据同步等流程调用。

## BIZ-BUDGET-001 预算占用 / 消耗 / 释放

**功能描述**：管理员工成本中心预算的占用、消耗、释放，按物料用途映射 EBS 科目，校验科目是否启用预算。采购申请、物资申请提交时占用预算，同步回写时消耗，驳回 / 撤回时释放。

**核心实现**：

| 类型 | 代码位置 | 说明 |
|---|---|---|
| Service 接口 | `base-service/.../service/budget/IBudgetService.java` | 预算服务接口 |
| Service 实现 | `base-service/.../service/budget/impl/BudgetServiceImpl.java` | 预算服务主实现 |
| 临时实现 | `base-service/.../service/budget/impl/BuddgetServiceTempImpl.java` | ⚠️ 注意类名拼写为 `Buddget`（双 d，疑似历史 typo），是临时 / 兜底实现 |
| 定时任务 | `project-pc/.../pc/tasks/BudgetReleaseTask.java` | 预算释放定时任务 |

**核心方法（`IBudgetService`）**：

| 分类 | 方法 | 说明 |
|---|---|---|
| 预算占用 | `occupyUpdate(guid, requestInfo)` / `occupyUpdate(guid, requestInfoList)` | 提交申请时占用，`guid` 防重复提交 |
| 预算消耗 | `consumeUpdate(guid, requestInfo)` / `consumeUpdate(guid, requestInfoList)` | 实际消耗 |
| 预算释放 | `releaseUpdate(guid, requestInfo)` / `releaseUpdate(guid, requestInfoList)` | 驳回 / 撤回时释放 |
| 余额查询 | `getAmountList(empCode, userFor)` / `getAmountListByColNo(empCode, colNo)` / `getAmountList(period, empCode, userFor)` | 查询当前 / 指定期间预算余额 |
| 科目映射 | `getColNo(userFor)` / `getAccountUserForMappingInfo(userFor)` / `checkColNo(colNo)` | 按物料用途映射 EBS 科目并校验是否启用预算 |
| 基础信息 | `getBaseRequestInfo(empCode, userFor)` / `getCostCenterCode(empCode)` | 按员工 + 用途填充成本中心等基础信息 |
| 税率 | `calcTax(amount)` | 计算税率（常量 `TAX = 0.13`） |

**关键常量（`IBudgetService`）**：
- `TAX = 0.13` 税率
- `ACCOUNT_1601 = "1601"` 固定资产预算科目
- `ACCOUNT_1701 = "1701"` 非实物采购预算科目

**视图对象（`base-domain/.../viewobject/budget/`）**：
`BudgetRequestInfo`、`BudgetReturnInfo`、`BudgetResponseInfo`、`BudgetBaseRequestInfo`、`BudgetAmountInfo`、`BudgetAmountRequest`

**已确认调用方**：

| 调用方 | 场景 |
|---|---|
| `PurchaseApplyServiceImpl` / `PurchaseApplySubServiceImpl` | 采购申请预算占用 |
| `MaterialApplySubServiceImpl` | 物资申请预算占用 |
| `MaterialAssetDataService` / `MaterialAssetInitRecordServiceImpl` | 资产相关预算处理 |
| `ErpServiceImpl` | ERP 交互 |
| `EbsPurchaseSummarySubServiceImpl` | EBS 采购汇总 |
| `ScmApiController` | API 入口透出 |
| 多个 `*PostDataHandlerService`（sync 包） | 同步回写时消耗 / 释放预算（MaterialApply / MaterialReceive / MaterialReturn / MaterialGiftStorage / MaterialInventoryProfit / MaterialStockAllot / Sales / PoImport 等） |

> 相关 reference：[purchase-apply.md](purchase-apply.md)、[material-operations.md](material-operations.md)、[sync.md](sync.md)

---

## 变更摘要

| 日期 | 业务编号 | 描述 |
|------|---------|------|
| 2026-05-28 | BIZ-BUDGET-001 | 新增预算服务模块映射（全量审查发现 service/budget 包未被任何 reference 覆盖） |
