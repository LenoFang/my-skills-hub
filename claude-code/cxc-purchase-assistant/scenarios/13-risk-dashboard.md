---
id: 13
name: 采购风险看板
applicable_roles: [采购员, 采购管理层]
---

# 场景 13 — 采购风险看板

## 识别特征

```yaml
hard_rules:
  - pattern: "/(风险|黑名单|冻结|异常供应商|合同风险|订单风险)/"
  - keywords: ["有风险的供应商", "供应商风险", "哪些供应商有问题", "风险预警"]
```

## 实体契约

```yaml
required_entities: []
optional_entities: [risk_type]
defaults: {}
ask_template: null
inheritable_entities: [risk_type]
note: "无必填实体，默认返回三维度风险汇总"
```

## 归一化

```yaml
normalize:
  risk_type:
    via: local_parser
    mapping:
      "供应商": supplier
      "合同": contract
      "订单": order
```

## 权限

```yaml
deny_response: "您暂无权限查看采购风险数据"
```

## cli 候选

```yaml
cli_candidates:
  - name: getSupplierRiskOverview
    endpoint: /kanban/procurement-risk/totalSupplierCount
    kind: business
    when: 用户问总览或供应商风险
    priority: 1
    params_mapping: {}
    parallel_endpoints:
      - /kanban/procurement-risk/totalSupplierCount
      - /kanban/procurement-risk/formalSupplierCount
      - /kanban/procurement-risk/frozenSupplierCount
      - /kanban/procurement-risk/blackSupplierCount
      - /kanban/procurement-risk/potentialSupplierCount
  - name: getSupplierRiskList
    endpoint: /kanban/procurement-risk/supplierRisk
    kind: business
    when: 用户要看供应商风险明细列表
    priority: 2
    params_mapping: {}
  - name: getContractRiskList
    endpoint: /kanban/procurement-risk/contractRisk
    kind: business
    when: 用户问合同风险
    priority: 2
    params_mapping: {}
  - name: getOrderRiskList
    endpoint: /kanban/procurement-risk/orderRisk
    kind: business
    when: 用户问订单风险
    priority: 2
    params_mapping: {}
```

## 返回模板

```yaml
render_template: stats_summary
format: |
  采购风险概览：
  供应商：共 {total} 家，正式 {formal}、冻结 {frozen} ⚠️、黑名单 {black} 🚫、潜在 {potential}
  合同风险：{contractRisk} 条
  订单风险：{orderRisk} 条
```

## 推荐提问候选池

```yaml
recommendation_pool:
  - text: "冻结的供应商有哪些"
    direction: 明细下钻
    when: frozen > 0
  - text: "黑名单供应商明细"
    direction: 明细下钻
    when: black > 0
  - text: "合同风险明细"
    direction: 明细下钻
    when: contractRisk > 0
  - text: "订单风险明细"
    direction: 明细下钻
    when: orderRisk > 0
```
