---
id: 14
name: 采购仪表盘
applicable_roles: [需求人, 采购员, 采购管理层]
---

# 场景 14 — 采购仪表盘

## 识别特征

```yaml
hard_rules:
  - pattern: "/(花了多少|总金额|采购额|采购量|采购数据|采购概况|整体情况)/"
  - keywords: ["这个月花了多少", "采购总额", "下了多少单", "采购概况"]
```

## 实体契约

```yaml
required_entities: []
optional_entities: [date_range, dashboard_dimension]
defaults: { date_range: "本月" }
ask_template: null
inheritable_entities: [date_range]
```

## 归一化

```yaml
normalize:
  date_range:
    via: local_parser
  dashboard_dimension:
    via: local_parser
    mapping:
      "品类": category-proportion
      "供应商": supplier-top
      "BG": bg-proportion
      "月度对比": monthly-comparison
      "物料": material-top
      "采购方式": method-proportion
```

## 权限

```yaml
deny_response: "您暂无权限查看采购仪表盘"
```

## cli 候选

```yaml
cli_candidates:
  - name: getAmountStats
    endpoint: /purchase-dashboard/amount-statistics
    kind: business
    when: 用户问金额/总览（默认）
    priority: 1
    params_mapping:
      startDate: date_range.start
      endDate: date_range.end
    parallel_endpoints:
      - /purchase-dashboard/amount-statistics
      - /purchase-dashboard/apply-count-statistics
      - /purchase-dashboard/order-count-statistics
  - name: getCategoryProportion
    endpoint: /purchase-dashboard/category-proportion
    kind: business
    when: 用户问品类占比/分布
    priority: 2
    params_mapping:
      startDate: date_range.start
      endDate: date_range.end
  - name: getSupplierTop
    endpoint: /purchase-dashboard/supplier-top
    kind: business
    when: 用户问供应商排名/TOP
    priority: 2
    params_mapping:
      startDate: date_range.start
      endDate: date_range.end
  - name: getMonthlyComparison
    endpoint: /purchase-dashboard/monthly-comparison
    kind: business
    when: 用户问月度对比/环比/同比
    priority: 2
    params_mapping:
      startDate: date_range.start
      endDate: date_range.end
```

## 返回模板

```yaml
render_template: stats_summary
format: |
  采购数据概览（{date_range_display}）：
  - 总金额：{totalAmount} 元
  - 采购订单：{orderCount} 笔
  - 采购申请：{applyCount} 笔
```

## 推荐提问候选池

```yaml
recommendation_pool:
  - text: "按品类看看分布"
    direction: 分布下钻
    when: always
  - text: "供应商 TOP5"
    direction: 金额排序
    when: always
  - text: "和上个月比怎么样"
    direction: 同环比
    when: always
  - text: "哪个 BG 花最多"
    direction: 分布下钻
    when: always
```
