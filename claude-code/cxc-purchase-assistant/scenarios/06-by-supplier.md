---
id: 6
name: 供应商维度查询
applicable_roles: [采购员, 采购管理层]
---

# 场景 06 — 供应商维度查询

## 识别特征

```yaml
hard_rules:
  - pattern: 供应商名 + "/(订单|PO|供货|交付)/"
  - keywords: ["XX供应商的订单", "XX公司的采购"]
```

## 实体契约

```yaml
required_entities: [supplier_name]
optional_entities: [status, date_range]
defaults: { page: 1, page_size: 10, status: all }
ask_template: "你想查哪个供应商？请告诉我供应商名称"
inheritable_entities: [supplier_name, date_range]
```

## 归一化

```yaml
normalize:
  supplier_name:
    via: lookupSupplierByName
    on_ambiguous: ask_user
    on_not_found: exception "未找到该供应商"
  date_range:
    via: local_parser
```

## 权限

```yaml
deny_response: "您暂无权限查看供应商订单"
```

## cli 候选

```yaml
cli_candidates:
  - name: querySupplierPurchaseInfo
    endpoint: /purchase/order/supplier/getSupplierPurchaseInfo
    kind: business
    when: 用户要看汇总信息
    priority: 1
    params_mapping:
      supplierId: supplier.id
  - name: queryPoList
    endpoint: /purchase/order/mlist
    kind: business
    when: 用户要看明细列表
    priority: 2
    params_mapping:
      supplierId: supplier.id
      status: status
      startDate: date_range.start
      endDate: date_range.end
```

## 返回模板

```yaml
render_template: list_table         # 明细时用 list_table；汇总时用 stats_summary
```

## 推荐提问候选池

```yaml
recommendation_pool:
  - text: "{supplier}还有未交付的吗"
    direction: 异常项
    when: status_distribution.pending_delivery >= 1
  - text: "{supplier}总金额多少"
    direction: 金额排序
    when: always
  - text: "按品类看看"
    direction: 分布下钻
    when: category_count >= 2
  - text: "比上个月多了还是少了"
    direction: 同环比
    when: date_range is not null
```
