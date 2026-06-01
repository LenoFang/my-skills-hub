---
id: 7
name: 品类维度查询
applicable_roles: [采购员, 采购管理层]
---

# 场景 07 — 品类维度查询

## 识别特征

```yaml
hard_rules:
  - pattern: 品类名 + "/(采购|订单|申请)/"
  - keywords: ["IT设备类", "办公用品的", "服务器采购"]
```

## 实体契约

```yaml
required_entities: [category]
optional_entities: [status, date_range, applicant_name]
defaults: { page: 1, page_size: 10, status: all }
ask_template: "你想查哪个品类？如 IT设备、办公用品"
inheritable_entities: [category, date_range]
```

## 归一化

```yaml
normalize:
  category:
    via: lookupCategoryByName
    on_not_found: exception "未找到该品类，可输入'帮助'查看支持的品类"
  date_range:
    via: local_parser
```

## 权限

```yaml
deny_response: "您暂无权限查看该品类的采购数据"
```

## cli 候选

```yaml
cli_candidates:
  - name: queryPrList
    endpoint: /purchaseApply/list
    kind: business
    when: 用户问的是申请/PR 且权限为 personal scope
    priority: 2
    params_mapping:
      categoryCode: category.code
      status: status
      startDate: date_range.start
      endDate: date_range.end
  - name: queryPrMlist
    endpoint: /mPurchaseApply/mlist
    kind: business
    when: 用户问的是申请/PR 且权限为 dept/all scope
    priority: 1
    params_mapping:
      categoryCode: category.code
      applicantId: applicant.user_id
      status: status
      startDate: date_range.start
      endDate: date_range.end
  - name: queryPoList
    endpoint: /purchase/order/mlist
    kind: business
    when: 用户问的是订单/PO
    priority: 1
    params_mapping:
      categoryCode: category.code
      status: status
      startDate: date_range.start
      endDate: date_range.end
```

## 返回模板

```yaml
render_template: list_table
```

## 推荐提问候选池

```yaml
recommendation_pool:
  - text: "{category}花了多少钱"
    direction: 金额排序
    when: always
  - text: "{category}待审批的有几个"
    direction: 异常项
    when: status_distribution.pending >= 1
  - text: "按供应商分布看看"
    direction: 分布下钻
    when: supplier_count >= 2
  - text: "比上个月多了还是少了"
    direction: 同环比
    when: date_range is not null
```
