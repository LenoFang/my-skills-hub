---
id: 8
name: 周期业务量统计
applicable_roles: [采购员, 采购管理层]
---

# 场景 08 — 周期业务量统计

## 识别特征

```yaml
hard_rules:
  - pattern: "/(本月|上月|本周|上周|本季度|今年|Q[1-4])/ + /(量|花了|多少|统计|金额|汇总)/"
  - keywords: ["本月采购量", "上个月花了多少", "这个季度统计"]
```

## 实体契约

```yaml
required_entities: [date_range]
optional_entities: [category]
defaults: {}
ask_template: "你想查哪个时间段的？本月 / 上月 / 本季度？"
inheritable_entities: [date_range]
```

## 归一化

```yaml
normalize:
  date_range:
    via: local_parser
  category:
    via: lookupCategoryByName
    on_not_found: exception "未找到该品类"
```

## 权限

```yaml
deny_response: "您暂无权限查看采购统计数据"
```

## cli 候选

```yaml
cli_candidates:
  - name: queryProcurementStats
    endpoint: /purchaseBusiness/getPurchaseDataAnalysisInfo
    kind: business
    when: 用户问金额/订单量汇总
    priority: 1
    params_mapping:
      startDate: date_range.start
      endDate: date_range.end
  - name: queryProcurementTimeliness
    endpoint: /purchaseBusiness/getPurchaseTimelinessAnalysisInfo
    kind: business
    when: 用户问时效/处理周期
    priority: 2
    params_mapping:
      startDate: date_range.start
      endDate: date_range.end
  - name: queryProcurementAbnormal
    endpoint: /purchaseBusiness/getPurchaseAbnormalAnalysisInfo
    kind: business
    when: 用户问异常/超时/超标
    priority: 2
    params_mapping:
      startDate: date_range.start
      endDate: date_range.end
  - name: queryMonthlyComparison
    endpoint: /purchase-dashboard/monthly-comparison
    kind: business
    when: 用户问同环比/对比/比上个月（含关键词：对比/比/环比/同比/上个月比/增长/下降）
    priority: 1
    params_mapping:
      startDate: date_range.start
      endDate: date_range.end
    note: "返回月度对比数据，含同比环比增长率"
```

## 返回模板

```yaml
render_template: stats_summary
```

## 推荐提问候选池

```yaml
recommendation_pool:
  - text: "比上个月多了还是少了"
    direction: 同环比
    when: always
  - text: "按品类分布看看"
    direction: 分布下钻
    when: category_count >= 2
  - text: "按部门分布看看"
    direction: 分布下钻
    when: dept_count >= 2
  - text: "异常采购有哪些"
    direction: 异常项
    when: abnormal_count >= 1
```
