---
id: 17
name: 库存查询
applicable_roles: [需求人, 采购员, 采购管理层]
---

# 场景 17 — 库存查询

## 识别特征

```yaml
hard_rules:
  - pattern: "/(库存|存量|有没有货|还有多少|现货|可用量)/"
  - keywords: ["库存够不够", "还有多少库存", "这个物料有现货吗", "库存查一下"]
```

## 实体契约

```yaml
required_entities: []
optional_entities: [material_code, material_name, sub_inventory]
defaults: { page: 1, page_size: 10 }
ask_template: "你想查哪个物料的库存？请提供物料名称或编码"
inheritable_entities: [material_code, material_name]
note: "无必填实体时返回库存总览；有物料名/编码时查具体物料"
```

## 归一化

```yaml
normalize:
  material_code:
    via: local_parser
    pattern: "^[A-Z]\\d+.*"
  material_name:
    via: local_parser
  sub_inventory:
    via: local_parser
```

## 权限

```yaml
deny_response: "您暂无权限查看库存数据"
```

## cli 候选

```yaml
cli_candidates:
  - name: getInventoryList
    endpoint: /inventoryDataPool/list
    kind: business
    when: 用户查个人视角库存
    priority: 2
    params_mapping:
      materialCode: material_code
      materialName: material_name
      subInventoryCode: sub_inventory
  - name: getInventoryMlist
    endpoint: /inventoryDataPool/mlist
    kind: business
    when: 用户权限为 dept/all scope
    priority: 1
    params_mapping:
      materialCode: material_code
      materialName: material_name
      subInventoryCode: sub_inventory
  - name: getAvailableQuantity
    endpoint: /inventoryDataPool/getMaterialAvailableInventoryQuantity
    kind: business
    when: 用户问具体物料的可用量
    priority: 1
    params_mapping:
      materialCode: material_code
```

## 返回模板

```yaml
render_template: list_table
format_single: |
  物料 {materialName}（{materialCode}）：
  可用库存：{availableQuantity} {unit}
  所在仓库：{subInventoryName}
format_list: |
  库存列表（共 {total} 条）：
  （表格：物料编码、物料名称、可用量、单位、子库存）
```

## 推荐提问候选池

```yaml
recommendation_pool:
  - text: "这个物料的安全库存是多少"
    direction: 明细下钻
    when: has_material_code
  - text: "库存不够的物料有哪些"
    direction: 异常项
    when: always
  - text: "这个物料的采购申请"
    direction: 同主体延伸
    when: has_material_code
  - text: "历史价格查一下"
    direction: 同主体延伸
    when: has_material_code
```
