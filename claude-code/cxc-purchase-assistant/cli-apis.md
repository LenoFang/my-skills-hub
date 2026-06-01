# cli 接口字典

> 本文件在 SKILL.md Step 7 加载。是 Plan 阶段 prompt 第 5 段 `available_cli_apis` 的数据源。
> 端点路径与 `cli/schema/modules.config.json` 保持一致。

## cli 覆盖状态

| 接口 | cli 命令 | 状态 |
|---|---|---|
| PR 列表 | `scm list purchase-applies` / `scm list purchase-applies-mlist` | ✅ 已覆盖 |
| PR 详情 | `scm get purchase-apply --id <formId>` | ✅ 已覆盖 |
| PR 进度 | `scm list purchase-apply-progress --form-id <formId>` | ✅ 已覆盖 |
| PO 列表 | `scm list purchase-orders` | ✅ 已覆盖 |
| PO 详情 | `scm get purchase-order --id <poId>` | ✅ 已覆盖 |
| PO 行数据 | `scm get purchase-order --id <poId> --lines` | ✅ 已覆盖 |
| 员工查找 | `scm list lookup-users --keyword <name>` | ✅ 已覆盖 |
| 品类查找 | `scm list lookup-categories` | ✅ 已覆盖 |
| 供应商查找 | `scm list lookup-suppliers --keyword <name>` | ✅ 已覆盖 |
| 供应商采购汇总 | `scm get supplier-purchase-info --supplier-code <code>` | ✅ 已覆盖 |
| 采购数据分析 | `scm get purchase-business-stats --type data` | ✅ 已覆盖 |
| 采购时效分析 | `scm get purchase-business-stats --type timeliness` | ✅ 已覆盖 |
| 采购异常分析 | `scm get purchase-business-stats --type abnormal` | ✅ 已覆盖 |

> **所有接口已覆盖**（2026-05-30 更新）

---

## business_apis

```yaml
- name: queryPrDetail
  kind: detail
  endpoint: /purchaseApply/detail
  method: GET
  desc: 按单号查 PR 详情（含审批进度、关联 PO）
  params:
    formId: { type: string, required: true }
  returns: PurchaseApplyDetailVO
  used_by_scenarios: [1]

- name: queryPrProgress
  kind: progress
  endpoint: /purchaseApply/progressList
  method: GET
  desc: PR 审批进度列表
  params:
    formId: { type: string, required: true }
  returns: List<ProgressVO>
  used_by_scenarios: [1]

- name: queryPrList
  kind: business
  endpoint: /purchaseApply/list
  method: GET
  desc: PR 列表（个人/经办侧，支持条件过滤）
  params:
    applicantId: { type: string, required: false }
    status: { type: string, required: false }
    keyword: { type: string, required: false }
    startDate: { type: string, required: false }
    endDate: { type: string, required: false }
    pageNum: { type: int, default: 1 }
    pageSize: { type: int, default: 10 }
  returns: PagedList<PrSummaryVO>
  used_by_scenarios: [2, 4, 9, 10]

- name: queryPrMlist
  kind: business
  endpoint: /mPurchaseApply/mlist
  method: GET
  desc: PR 管理端列表（采购员/管理层可见更广范围）
  params: # 同 queryPrList
  returns: PagedList<PrSummaryVO>
  used_by_scenarios: [2, 4, 9]

- name: queryPoDetail
  kind: detail
  endpoint: /purchase/order/detail
  method: GET
  desc: PO 详情
  params:
    orderId: { type: string, required: true }
  returns: PurchaseOrderDetailVO
  used_by_scenarios: [1]

- name: queryPoList
  kind: business
  endpoint: /purchase/order/mlist
  method: GET
  desc: PO 管理端列表
  params:
    handlerId: { type: string, required: false }
    supplierId: { type: string, required: false }
    status: { type: string, required: false }
    keyword: { type: string, required: false }
    startDate: { type: string, required: false }
    endDate: { type: string, required: false }
    pageNum: { type: int, default: 1 }
    pageSize: { type: int, default: 10 }
  returns: PagedList<PoSummaryVO>
  used_by_scenarios: [3, 5, 6, 9, 10]

- name: querySupplierPurchaseInfo
  kind: business
  endpoint: /purchase/order/supplier/getSupplierPurchaseInfo
  method: GET
  desc: 供应商采购汇总
  params:
    supplierId: { type: string, required: true }
  returns: SupplierPurchaseInfoVO
  used_by_scenarios: [6]

- name: queryProcurementStats
  kind: business
  endpoint: /purchaseBusiness/getPurchaseDataAnalysisInfo
  method: GET
  desc: 采购数据分析（金额/订单量汇总）
  params:
    startDate: { type: string, required: true }
    endDate: { type: string, required: true }
  returns: PurchaseDataAnalysisVO
  used_by_scenarios: [8]

- name: queryProcurementTimeliness
  kind: business
  endpoint: /purchaseBusiness/getPurchaseTimelinessAnalysisInfo
  method: GET
  desc: 采购时效分析
  params:
    startDate: { type: string, required: true }
    endDate: { type: string, required: true }
  returns: PurchaseTimelinessVO
  used_by_scenarios: [8]

- name: queryProcurementAbnormal
  kind: business
  endpoint: /purchaseBusiness/getPurchaseAbnormalAnalysisInfo
  method: GET
  desc: 采购异常分析
  params:
    startDate: { type: string, required: true }
    endDate: { type: string, required: true }
  returns: PurchaseAbnormalVO
  used_by_scenarios: [8]

- name: queryMonthlyComparison
  kind: business
  endpoint: /purchase-dashboard/monthly-comparison
  method: POST
  desc: 月度对比（同环比）
  params:
    startDate: { type: string, required: true }
    endDate: { type: string, required: true }
  returns: MonthlyComparisonVO
  used_by_scenarios: [8, 14]
```

## lookup_apis

```yaml
- name: lookupUserByName
  kind: lookup
  endpoint: /common/queryEmployee
  method: GET
  desc: 员工查找（支持 keyword 模糊搜索姓名/工号）
  params:
    keyword: { type: string, required: true }   # 姓名或工号关键词
  returns: [{ userId, username, workId, departmentId, department, ... }]
  used_by_scenarios: [4, 5]
  on_ambiguous: 反问用户选择
  on_not_found: exception "未找到该员工"
  cli_module: lookup-users

- name: lookupCategoryByName
  kind: lookup
  endpoint: /purchaseBusiness/findMaterialCategoryInfo
  method: GET
  desc: 获取全量物料品类列表（无入参），skill 侧本地匹配品类名
  params: {}                       # 后端无入参，返回全量二级分类
  returns: [{ categoryCode, categoryName, parentCode, ... }]
  used_by_scenarios: [7]
  cli_module: lookup-categories
  note: |
    后端返回全量品类列表，skill 需要：
    1. 首次调用后缓存（建议会话级或更长）
    2. 用户输入品类名时，在缓存中模糊匹配
    3. 匹配到多个时反问用户确认
    4. 匹配到唯一时提取 categoryCode

- name: lookupSupplierByName
  kind: lookup
  endpoint: /purchase/order/supplier/list
  method: GET
  desc: 采购订单供应商列表（支持关键字搜索）
  params:
    keyword: { type: string, required: false }  # 供应商名称关键词
  returns: [{ supplierCode, supplierName, ... }]
  used_by_scenarios: [6]
  cli_module: lookup-suppliers
  on_ambiguous: 反问用户选择
  on_not_found: exception "未找到该供应商"
```

## permission_api

```yaml
- name: getCurrentUser
  kind: lookup
  endpoint: /scm/getUser
  method: GET
  desc: 获取当前登录用户信息 + 权限串列表（扁平结构）
  params: {}                       # 依赖 session cookie / token
  returns:                         # 扁平字段，非嵌套
    userId: Long
    username: String
    workId: String
    departmentId: Long
    department: String
    currentManageUnitName: String
    perms: [permission_code]
    urls: [url]
  cache: 会话级 600s
  used_by_scenarios: [all]
  note: "取值用 data.userId / data.perms，不是 data.userInfo.xxx"
```
