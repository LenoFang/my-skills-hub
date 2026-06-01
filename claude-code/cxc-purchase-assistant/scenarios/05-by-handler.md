---
id: 5
name: 采购员维度查询
applicable_roles: [采购员, 采购管理层]
---

# 场景 05 — 采购员维度查询

## 识别特征

```yaml
hard_rules:
  - pattern: 人名 + "/(经手|处理|负责|办理)/"
  - keywords: ["处理了多少单", "办了几个"]
```

## 实体契约

```yaml
required_entities: [handler_name]
optional_entities: [status, date_range, category]
defaults: { page: 1, page_size: 10, status: all }
ask_template: "你想查哪位采购员？请告诉我姓名"
inheritable_entities: [handler_name, date_range]
```

## 归一化

```yaml
normalize:
  handler_name:
    via: lookupUserByName
    on_ambiguous: ask_user
    on_not_found: exception "未找到该员工"
  date_range:
    via: local_parser
```

## 权限

```yaml
deny_response: "您暂无权限查看该采购员的订单"
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
      applierId: handler.user_id
      status: status
      startDate: date_range.start
      endDate: date_range.end
      categoryCode: category.code
```

## 返回模板

```yaml
render_template: list_table
```

## 推荐提问候选池

```yaml
recommendation_pool:
  - text: "{handler}处理的通过率多少"
    direction: 金额排序
    when: total_count >= 5
  - text: "{handler}未交付的订单"
    direction: 异常项
    when: status_distribution.pending_delivery >= 1
  - text: "比上个月多了还是少了"
    direction: 同环比
    when: date_range is not null
  - text: "按供应商分布看看"
    direction: 分布下钻
    when: supplier_count >= 2
```
