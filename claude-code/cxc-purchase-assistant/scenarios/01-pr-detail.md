---
id: 1
name: 查单进度（PR 精确查询）
applicable_roles: [需求人, 采购员, 采购管理层]
---

# 场景 01 — 查单进度

## 识别特征

```yaml
hard_rules:
  - pattern: "/(PR|pr|采购申请)\\s*\\d{5,}/"
    extract: pr_no
  - pattern: "/(PO|po|采购订单|订单号)\\s*\\d{5,}/"
    extract: po_no
  - keywords: ["到哪了", "进度", "什么状态", "审到哪"]
```

## 实体契约

```yaml
required_entities: [pr_no]          # 或 po_no（二选一）
optional_entities: []
defaults: {}
ask_template: "请提供完整的单号，例如 PR20260523001"
inheritable_entities: []            # 本场景结果不向下一轮继承
```

## 归一化

```yaml
normalize:
  pr_no:
    via: lookupPrByNo                # 调 cli 查 formId
    on_not_found: exception_E01      # 单号不存在
    output: { form_id, pr_no, status, applicant }
  po_no:
    via: lookupPoByNo                # 调 cli 查 orderId
    on_not_found: exception_E01
    output: { order_id, po_no, status, handler }
```

> **重要**：后端 `/purchaseApply/detail` 需要 `formId`（Long），不是业务单号 `pr_no`。
> 同理 `/purchase/order/detail` 需要 `id`（Long），不是 `po_no`。
> 必须先通过列表接口（带 keyword 过滤）或专用 lookup 接口把业务单号转成内部 ID。

## 权限

```yaml
# 推荐方式：场景只声明候选端点，step 6 自动从映射表反查权限
# 下方显式写出仅作为文档参考，实际运行时以 endpointToPermissions 为准
deny_response: "您暂无权限查看此单据"
```

## cli 候选

```yaml
cli_candidates:
  # PR 查询 — 两步：先 lookup 单号→formId，再查详情
  - name: lookupPrByNo
    endpoint: /purchaseApply/list
    kind: lookup
    when: 已抽取到 pr_no 但尚未获得 form_id
    priority: 0
    params_mapping:
      keyword: pr_no                 # 用单号作为关键词搜索
      pageSize: 1
    post_process: "从返回列表中匹配 pr_no，提取 formId"

  - name: queryPrDetail
    endpoint: /purchaseApply/detail
    kind: detail
    when: 已获得 form_id
    priority: 1
    params_mapping:
      formId: form_id                # Long 类型，从 lookup 结果获取

  - name: queryPrProgress
    endpoint: /purchaseApply/progressList
    kind: progress
    when: 用户问"进度"/"到哪了"/"审到哪" 且已获得 form_id
    priority: 2
    params_mapping:
      formId: form_id

  # PO 查询 — 两步：先 lookup 单号→orderId，再查详情
  - name: lookupPoByNo
    endpoint: /purchase/order/mlist
    kind: lookup
    when: 已抽取到 po_no 但尚未获得 order_id
    priority: 0
    params_mapping:
      keyword: po_no
      pageSize: 1
    post_process: "从返回列表中匹配 po_no，提取 id"

  - name: queryPoDetail
    endpoint: /purchase/order/detail
    kind: detail
    when: 已获得 order_id
    priority: 1
    params_mapping:
      id: order_id                   # Long 类型，从 lookup 结果获取

  # 兜底：模糊搜索（单号格式不完整时）
  - name: fuzzySearchPr
    endpoint: /purchaseApply/list
    kind: business
    when: 单号格式不完整或用户用了"那个"等指代
    priority: 3
    params_mapping:
      keyword: raw_input_fragment
```

## 返回模板

```yaml
render_template: detail_card_pr    # 或 detail_card_po，由 Plan 阶段根据 pr/po 选定
```

## 推荐提问候选池

```yaml
recommendation_pool:
  - text: "这个单子是谁在处理"
    direction: 明细下钻
    when: status in [审批中, 待采购]
  - text: "驳回原因是什么"
    direction: 异常项
    when: status == 已驳回
  - text: "关联订单查一下"
    direction: 明细下钻
    when: has_linked_po == true
  - text: "{applicant}最近还有什么单子"
    direction: 同主体延伸
    when: always
```
