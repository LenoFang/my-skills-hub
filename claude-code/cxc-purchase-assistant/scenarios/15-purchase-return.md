---
id: 15
name: 退货查询
applicable_roles: [需求人, 采购员, 采购管理层]
---

# 场景 15 — 退货查询

## 识别特征

```yaml
hard_rules:
  - pattern: "/(退货|退回|退货单|退货进度|退了)/"
  - keywords: ["退货单到哪了", "退货情况", "有哪些退货", "退货进度"]
  - pattern_precise: "退货单号?\\s*\\w+"
```

## 实体契约

```yaml
required_entities: []
optional_entities: [return_no, status, date_range, supplier_name]
defaults: { page: 1, page_size: 10 }
ask_template: null
inheritable_entities: [return_no, date_range]
note: "无必填实体；有退货单号走精确查询，无单号走列表"
```

## 归一化

```yaml
normalize:
  return_no:
    via: lookupReturnByNo
    steps:
      - 用 /purchase-return/page-list + keyword=return_no 查到内部 ID
      - 取第一条结果的 returnId
    on_invalid: exception "退货单号格式不正确"
    on_not_found: exception "未找到该退货单"
  date_range:
    via: local_parser
  supplier_name:
    via: lookupSupplierByName
    on_not_found: exception "未找到该供应商"
```

## 权限

```yaml
deny_response: "您暂无权限查看退货单据"
```

## cli 候选

```yaml
cli_candidates:
  - name: getReturnDetail
    endpoint: /purchase-return/detail
    kind: business
    when: 用户提供了退货单号
    priority: 1
    params_mapping:
      returnId: return_no.id
  - name: getReturnProgress
    endpoint: /purchase-return/progress/list
    kind: business
    when: 用户问退货进度且有单号
    priority: 1
    params_mapping:
      returnId: return_no.id
  - name: getReturnList
    endpoint: /purchase-return/page-list
    kind: business
    when: 用户问退货列表（无精确单号）
    priority: 2
    params_mapping:
      status: status
      startDate: date_range.start
      endDate: date_range.end
      supplierName: supplier_name
```

## 返回模板

```yaml
render_template_detail: detail_card_return
render_template_list: list_table
format_detail: |
  退货单 {returnNo}：
  状态：{status}
  供应商：{supplierName}
  退货金额：{amount} 元
  发起时间：{createTime}
format_list: |
  共 {total} 条退货记录
  （表格：单号、状态、供应商、金额、时间）
```

## 推荐提问候选池

```yaml
recommendation_pool:
  - text: "这个退货单的进度"
    direction: 明细下钻
    when: has_return_no AND mode == list
  - text: "退货原因是什么"
    direction: 明细下钻
    when: mode == detail
  - text: "这个供应商还有其他退货吗"
    direction: 同主体延伸
    when: has_supplier
  - text: "本月退货总金额"
    direction: 金额排序
    when: always
```
