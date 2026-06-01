---
id: 12
name: 采购效率/超期预警
applicable_roles: [需求人, 采购员, 采购管理层]
---

# 场景 12 — 采购效率/超期预警

## 识别特征

```yaml
hard_rules:
  - pattern: "/(超期|超时|逾期|overdue|效率|时效)/"
  - keywords: ["有哪些超期的", "采购效率", "哪些单子超时了", "逾期未处理"]
```

## 实体契约

```yaml
required_entities: []
optional_entities: [overdue_type, date_range]
defaults: {}
ask_template: null
inheritable_entities: [overdue_type]
note: "无必填实体，默认返回全部超期类型汇总"
```

## 归一化

```yaml
normalize:
  overdue_type:
    via: local_parser
    mapping:
      "PR转PO": prToPoOverdue
      "采购转单": purchaseToPrOverdue
      "采购转PR": purchaseToPrOverdue
      "物资处理": materialProcessOverdue
      "入库": materialInboundOverdue
      "出库": materialOutboundOverdue
      "合同到期": contractExpired
  date_range:
    via: local_parser
```

## 权限

```yaml
deny_response: "您暂无权限查看采购效率数据"
```

## cli 候选

```yaml
cli_candidates:
  - name: getAllOverdue
    endpoint: /kanban/procurement-efficiency/purchaseToPrOverdue
    kind: business
    when: 用户问总览或未指定类型
    priority: 1
    params_mapping: {}
    note: "需并行调多个超期端点汇总"
    parallel_endpoints:
      - /kanban/procurement-efficiency/purchaseToPrOverdue
      - /kanban/procurement-efficiency/materialProcessOverdue
      - /kanban/procurement-efficiency/prToPoOverdue
      - /kanban/procurement-efficiency/materialInboundOverdue
      - /kanban/procurement-efficiency/contractExpired
  - name: getSpecificOverdue
    endpoint: /kanban/procurement-efficiency/{overdue_type}
    kind: business
    when: 用户指定了具体超期类型
    priority: 2
    params_mapping:
      type: overdue_type
```

## 返回模板

```yaml
render_template: stats_summary
format: |
  超期预警汇总：
  - PR转PO超期：{purchaseToPrOverdue} 条 ⚠️
  - 物资处理超期：{materialProcessOverdue} 条
  - 入库超期：{materialInboundOverdue} 条
  - 合同到期：{contractExpired} 条
  （按数量从多到少排列，仅展示 >0 的类型）
```

## 推荐提问候选池

```yaml
recommendation_pool:
  - text: "PR转PO超期的明细"
    direction: 明细下钻
    when: purchaseToPrOverdue > 0
  - text: "哪些合同快到期了"
    direction: 明细下钻
    when: contractExpired > 0
  - text: "入库超期的单子"
    direction: 明细下钻
    when: materialInboundOverdue > 0
  - text: "和上个月比怎么样"
    direction: 同环比
    when: always
```
