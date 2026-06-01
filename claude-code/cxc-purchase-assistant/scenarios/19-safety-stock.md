---
id: 19
name: 安全库存预警
applicable_roles: [采购员, 采购管理层]
---

# 场景 19 — 安全库存预警

## 识别特征

```yaml
hard_rules:
  - pattern: "/(安全库存|低于库存|补货|缺货|库存不足|库存预警)/"
  - keywords: ["哪些物料需要补货", "安全库存预警", "库存不够的", "缺货预警"]
```

## 实体契约

```yaml
required_entities: []
optional_entities: [material_name, category]
defaults: {}
ask_template: null
inheritable_entities: []
note: "默认返回所有低于安全库存的物料列表"
```

## 归一化

```yaml
normalize:
  material_name:
    via: local_parser
  category:
    via: lookupCategoryByName
    on_not_found: exception "未找到该品类"
```

## 权限

```yaml
deny_response: "您暂无权限查看安全库存监控数据"
```

## cli 候选

```yaml
cli_candidates:
  - name: getSafetyStockCount
    endpoint: /safetyStockMonitor/count
    kind: business
    when: 用户问总数/概览
    priority: 1
    params_mapping: {}
    note: "返回低于安全库存的物料总数"
  - name: getSafetyStockList
    endpoint: /safetyStockMonitor/list
    kind: business
    when: 用户要看明细列表
    priority: 2
    params_mapping:
      materialName: material_name
  - name: getSafetyStockDetail
    endpoint: /safetyStockMonitor/detail
    kind: business
    when: 用户问具体物料的安全库存详情
    priority: 2
    params_mapping:
      materialName: material_name
```

## 返回模板

```yaml
render_template: stats_summary
format_count: |
  安全库存预警：当前有 {count} 种物料低于安全库存线 ⚠️
format_list: |
  低于安全库存的物料（共 {total} 种）：
  （表格：物料编码、物料名称、当前库存、安全库存、缺口量）
```

## 推荐提问候选池

```yaml
recommendation_pool:
  - text: "缺口最大的是哪个"
    direction: 金额排序
    when: count > 1
  - text: "这个物料的采购申请"
    direction: 同主体延伸
    when: has_material
  - text: "历史价格查一下"
    direction: 同主体延伸
    when: has_material
  - text: "按品类看看哪类缺货最多"
    direction: 分布下钻
    when: count >= 5
```
