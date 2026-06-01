---
id: 3
name: 我的订单
applicable_roles: [采购员, 采购管理层]
---

# 场景 03 — 我的订单

## 识别特征

```yaml
hard_rules:
  - pattern: "/^我的.*(订单|PO|采购订单)/"
  - pattern: "/(我|本人).*(经手|处理|创建).*订单/"
  - keywords: ["我的PO", "我处理的订单"]
```

## 实体契约

```yaml
required_entities: []
optional_entities: [status, date_range, supplier_name]
defaults: { page: 1, page_size: 10, status: all }
ask_template: null
inheritable_entities: [status, date_range, supplier_name]
```

## 归一化

```yaml
normalize:
  date_range:
    via: local_parser
  supplier_name:
    via: lookupSupplierByName
    on_ambiguous: ask_user
    on_not_found: exception "未找到该供应商"
```

## 权限

```yaml
deny_response: "采购订单查询仅对采购人员开放"
```

## cli 候选

```yaml
cli_candidates:
  - name: queryPoList
    endpoint: /purchase/order/mlist
    kind: business
    when: always
    priority: 1
    params_mapping:
      handlerId: session.user_id
      status: status
      startDate: date_range.start
      endDate: date_range.end
      supplierId: supplier.id
```

## 返回模板

```yaml
render_template: list_table
```

## 推荐提问候选池

```yaml
recommendation_pool:
  - text: "还有哪些没验收的"
    direction: 异常项
    when: status_distribution.pending_inspection >= 1
  - text: "未交付的订单"
    direction: 状态筛选
    when: status_distribution.pending_delivery >= 1
  - text: "本月处理了多少单"
    direction: 同环比
    when: always
  - text: "{top_supplier}的订单"
    direction: 分布下钻
    when: supplier_count >= 2
```
