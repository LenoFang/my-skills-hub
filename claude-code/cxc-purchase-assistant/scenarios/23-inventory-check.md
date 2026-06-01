---
id: 23
name: 盘点查询
applicable_roles: [采购管理层]
---

# 场景 23 — 盘点查询

## 识别特征

```yaml
hard_rules:
  - pattern: "/(盘点|盘点计划|盘点结果|盘点差异|盘盈|盘亏)/"
  - keywords: ["有没有盘点计划", "盘点结果", "上次盘点差异", "盘点情况"]
```

## 实体契约

```yaml
required_entities: []
optional_entities: [date_range, inventory_type]
defaults: {}
ask_template: null
inheritable_entities: [date_range]
note: "默认返回最近的盘点计划和结果概览"
```

## 归一化

```yaml
normalize:
  date_range:
    via: local_parser
  inventory_type:
    via: local_parser
    mapping:
      "计划": plan
      "结果": result
      "差异": discrepancy
```

## 权限

```yaml
deny_response: "您暂无权限查看盘点数据"
```

## cli 候选

```yaml
cli_candidates:
  - name: getInventoryPlanList
    endpoint: /inventoryConfig/list
    kind: business
    when: 用户问盘点计划（默认）
    priority: 1
    params_mapping:
      startDate: date_range.start
      endDate: date_range.end
  - name: getInventoryPeriodList
    endpoint: /inventoryPeriod/list
    kind: business
    when: 用户问盘点周期/期间
    priority: 2
    params_mapping:
      startDate: date_range.start
      endDate: date_range.end
  - name: getInventoryDiscrepancy
    endpoint: /inventoryCustomDiscrepancy/list
    kind: business
    when: 用户问盘点差异/盘盈盘亏
    priority: 2
    params_mapping:
      startDate: date_range.start
      endDate: date_range.end
```

## 返回模板

```yaml
render_template: stats_summary
format_plan: |
  盘点计划：
  （表格：计划名称、盘点范围、计划时间、状态）
format_result: |
  盘点结果概览：
  - 盘点物料数：{totalItems}
  - 盘盈：{surplusCount} 项
  - 盘亏：{deficitCount} 项
  - 差异金额：{discrepancyAmount} 元
```

## 推荐提问候选池

```yaml
recommendation_pool:
  - text: "盘点差异明细"
    direction: 明细下钻
    when: discrepancy_count > 0
  - text: "盘亏最多的物料"
    direction: 金额排序
    when: deficit_count > 0
  - text: "上次盘点是什么时候"
    direction: 同环比
    when: always
  - text: "差异物料的库存"
    direction: 同主体延伸
    when: discrepancy_count > 0
```
