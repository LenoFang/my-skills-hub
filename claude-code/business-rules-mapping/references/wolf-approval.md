# Wolf 审批实现映射（BIZ-WOLF-001 ~ 003）

> 主 SKILL.md 的子文档。只记录仓库中确认存在的 Wolf 回调入口、注册机制和处理器实现。

## BIZ-WOLF-001 回调入口与分发

| 类型 | 代码位置 | 说明 |
|---|---|---|
| 回调 Controller | `project-pc/src/main/java/com/tcoa/scm/pc/controller/wolf/WolfCallbackController.java` | Wolf 回调 HTTP 入口 |
| Handler 注册注解 | `base-common/src/main/java/com/tcoa/scm/common/annotation/WolfHandlerType.java` | 标记处理器对应的 Wolf 单据类型 |
| 单据类型常量 | `base-common/src/main/java/com/tcoa/scm/common/constant/WolfKindConst.java` | WolfKind 常量定义 |
| Handler 容器 | `base-common/src/main/java/com/tcoa/scm/common/wolf/WolfHandlerContext.java` | 按 formKind 获取处理器实例 |
| Handler 扫描 | `base-common/src/main/java/com/tcoa/scm/common/wolf/WolfHandlerProcessor.java` | 收集带 `@WolfHandlerType` 的处理器 |
| Handler 接口 | `base-common/src/main/java/com/tcoa/scm/common/wolf/IWolfHandler.java` | 定义提交、回调、撤回等方法 |
| 基类 | `base-service/src/main/java/com/tcoa/scm/service/wolf/BaseWolfHandlerService.java` | `callback()` 内按回调动作分派到业务方法 |
| 回调辅助 | `base-service/src/main/java/com/tcoa/scm/service/wolf/WolfCallbackHelper.java` | Wolf 回调辅助处理 |

`BaseWolfHandlerService.callback()` 已确认分派到 `rejectForm()`、`completeForm()`、`agreeForm()`、`recallForm()`、`returnForm()` 等方法。具体状态含义以该基类和各业务实现为准。

---

## BIZ-WOLF-002 已注册业务处理器

| 处理器 | 已确认 WolfKind 常量 |
|---|---|
| `PurchaseApplyWolfServiceImpl` | `WPURCHASEAPPLY` / `GPURCHASEAPPLY` |
| `PurchaseApplyTestWolfServiceImpl` | `WWPURCHASEAPPLYTEST` / `GWPURCHASEAPPLYTEST` |
| `PurchaseOrderApplyWolfServiceImpl` | `WEBSPURCHASE` / `GEBSPURCHASE` |
| `PurchaseOrderLocalWolfServiceImpl` | `W_PURCHASE_ORDER_Add` |
| `PurchaseOrderChangeWolfServiceImpl` | `W_PURCHASE_ORDER_CHANGE` |
| `PurchaseReturnWolfServiceImpl` | `W_PURCHASE_RETURN` |
| `MaterialApplyWolfServiceImpl` | `WMaterialApply` / `GMaterialApply` |
| `MaterialReceiveWolfServiceImpl` | `W_MATERIAL_RECEIVE` |
| `MaterialReturnWolfServiceImpl` | `W_MATERIAL_RETURN` |
| `MaterialStockAllotWolfServiceImpl` | `W_MATERIAL_STOCK_ALLOT` |
| `MaterialAssetAllotWolfServiceImpl` | `W_MATERIAL_ASSET_ALLOT` |
| `MaterialPriceApplyWolfServiceImpl` | `W_MATERIAL_PRICE` |
| `InvDisposalApplyWolfServiceImpl` | `WINVDISPOSALAPPLY` / `GINVDISPOSALAPPLY` |
| `AssetInitWolfServiceImpl` | `W_ASSET_INIT` |
| `AssetChangeApplyWolfServiceImpl` | `W_ASSET_CHANGE` |
| `AssetClosedLoopWolfServiceImpl` | `AssetClosedLoopOrder_WL` / `AssetClosedLoopOrder_GL` |
| `SalesOrderWolfServiceImpl` | `W_SALES_ORDER` |
| `SalesOrderChangeWolfServiceImpl` | `W_SALES_ORDER_CHANGE` |
| `PosInventoryFlowWolfServiceImpl` | `W_POS_INVENTORY_FLOW` |
| `PosInventoryFlowDeliveryWolfServiceImpl` | `W_POS_INVENTORY_DELIVERY_FLOW` |
| `PosProductPriceChangeWolfServiceImpl` | `W_POS_PRODUCT_PRICE_CHANGE` |
| `LeaseBackWolfServiceImpl` | `WLEASEBACK` / `GLEASEBACK` |
| `LeaseBackRetireWolfServiceImpl` | `WLEASEBACKRETIRE` / `GLEASEBACKRETIRE` |
| `RentalOutboundWolfServiceImpl` | `W_RENTAL_OUTBOUND` |
| `CardsApplyWolfServiceImpl` | `WCARDSAPPLY` / `GCARDSAPPLY` |
| `PrintApplyWolfServiceImpl` | `WPRINTAPPLY` / `GPRINTAPPLY` |
| `RackApplyWolfServiceImpl` | `WRACKAPPLY` / `GRACKAPPLY` |
| `ServerApplyWolfServiceImpl` | `WSERVERAPPLY` / `GSERVERAPPLY` |
| `EmallEnterpriseWolfServiceImpl` | `W_EMALL_COMPANY` |
| `EmallEnterpriseDepositWolfServiceImpl` | `W_EMALL_ENTERPRISE_DEPOSIT` |
| `EmallEnterpriseCreditWolfServiceImpl` | `W_EMALL_ENTERPRISE_CREDIT_LIMIT` |
| `EmallEnterpriseCreditRepaymentWolfServiceImpl` | `W_EMALL_ENTERPRISE_CREDIT_REPAYMENT` |
| `EmallEmployeeRoleWolfServiceImpl` | `W_EMALL_EMPLOYEE_ROLE_FLOW` |
| `WolfTestService` | `Wwuzitest` / `Gwuzitest` ⚠️ 测试用 Handler（无 `Impl` 后缀），真实注册到容器，请勿用于生产单据类型 |

---

## BIZ-WOLF-003 修改定位入口

| 修改点 | 优先查看 |
|---|---|
| 回调动作分派、重复回调保护 | `BaseWolfHandlerService`、`WolfCallbackHelper` |
| 某业务审批通过/驳回/撤回后的状态更新 | 对应 `*WolfServiceImpl` 的 `agreeForm()`、`completeForm()`、`rejectForm()`、`recallForm()` |
| 新增审批单据类型 | `WolfKindConst`（加常量）、`@WolfHandlerType`（标注新 Handler）、实现 `IWolfHandler` 并继承 `BaseWolfHandlerService`（拿到默认动作分派）、由 `WolfHandlerProcessor` 自动扫描注册到 `WolfHandlerContext` |

---

## 变更摘要

| 日期 | 业务编号 | 描述 |
|------|---------|------|
| 2026-05-28 | BIZ-WOLF-001 ~ 003 | 补充 Wolf 回调入口、注册机制和已确认处理器清单 |

---

## 审查记录 (2026-05-28)

> 抽样验证 gpt5.5 主体生成内容；以代码为准，未直接改正文，请逐条确认是否落正文。

### ✅ 已核实（与代码一致 —— 这份准确率最高）
- 处理器清单 32 行全部命中真实类（grep `class .*WolfServiceImpl` 共 33 个 + `WolfTestService` 1 个）
- 全部 32 行的 WolfKind 常量名与 `@WolfHandlerType(wolfKind_WL=..., wolfKind_GL=...)` 注解值一一对应，包括边角案例：
  - `Wwuzitest`、`AssetClosedLoopOrder_WL` 这种非全大写命名也正确
  - `W_PURCHASE_ORDER_Add` 这种混合大小写也正确
- 回调入口体系（`WolfCallbackController`、`WolfHandlerProcessor`、`WolfHandlerContext`、`@WolfHandlerType`、`IWolfHandler`、`BaseWolfHandlerService`、`WolfCallbackHelper`、`WolfKindConst`）8 个文件全部存在
- `BaseWolfHandlerService.callback()` 分派到 `agreeForm/completeForm/rejectForm/recallForm/returnForm` 描述与基类实际一致

### ❌ 缺漏（建议补到清单）
- **`WolfTestService`**（`base-service/src/main/java/com/tcoa/scm/service/wolf/impl/WolfTestService.java`）—— 注解 `@WolfHandlerType(wolfKind_WL = WolfKindConst.Wwuzitest, wolfKind_GL = WolfKindConst.Gwuzitest)`，是真实注册到容器的 Handler。建议作为"⚠️ 测试用，请勿用于生产单据类型"独立列出，避免后续误删
- 类命名规律不一致：所有业务实现都叫 `*WolfServiceImpl`，唯独这一个叫 `WolfTestService`（无 Impl 后缀），值得在文档中标注以免被误以为是基类/工具类

### ⚠️ 表达不精确（建议改写但不算错）
- "已确认 WolfKind 常量"列对**单向（只有 WL）vs 双向（WL + GL 都注册）**未做区分。例如：
  - 单向：`MaterialReceiveWolfServiceImpl` 只有 `wolfKind_WL = W_MATERIAL_RECEIVE`
  - 双向：`PurchaseReturnWolfServiceImpl` `wolfKind_WL = W_PURCHASE_RETURN, wolfKind_GL = W_PURCHASE_RETURN`
  - 当前 skill 表里 `PurchaseReturnWolfServiceImpl` 写成 `W_PURCHASE_RETURN`（单值），看不出是否注册了 GL。建议统一改成"WL: xxx / GL: xxx"双列或加标注
- BIZ-WOLF-003 "新增审批单据类型"行只列了 `WolfKindConst`、`@WolfHandlerType`、`IWolfHandler`，遗漏了 `WolfHandlerProcessor`（实际扫描注册的是它）和 `BaseWolfHandlerService`（实际继承基类才能拿到默认分派）。建议补上以免新人接入时漏步骤

### 📌 结论
本 reference 在 30 个 reference 里**质量最高**，gpt5.5 在这种"穷举型清单"上表现稳定。建议把 wolf-approval.md 的"清单 + 注解对账"模式作为其他 reference 的标杆模板（例如 mq-events、operations-jobs 等）

