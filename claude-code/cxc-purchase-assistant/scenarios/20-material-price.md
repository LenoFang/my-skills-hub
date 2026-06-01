---
id: 20
name: 物料价格查询
applicable_roles: [采购员, 采购管理层]
---

# 场景 20 — 物料价格查询

## 识别特征

```yaml
hard_rules:
  - pattern: "/(价格|报价|历史价|单价|价格趋势|比价)/"
  - keywords: ["这个物料多少钱", "历史价格", "价格趋势", "上次买多少钱"]
  - negative: ["总金额", "花了多少"]
  note: "含'总金额/花了多少'走场景 14 仪表盘，纯'价格/单价'走本场景"
```

## 实体契约

```yaml
required_entities: [material_name]
optional_entities: [supplier_name, date_range]
defaults: {}
ask_template: "你想查哪个物料的价格？请提供物料名称或编码"
inheritable_entities: [material_name]
```

## 归一化

```yaml
normalize:
  material_name:
    via: local_parser
    note: "支持物料名称或编码，后端接口同时匹配"
  supplier_name:
    via: lookupSupplierByName
    on_not_found: exception "未找到该供应商"
  date_range:
    via: local_parser
```

## 权限

```yaml
deny_response: "您暂无权限查看物料价格信息"
```

## cli 候选

```yaml
cli_candidates:
  - name: getHistoryPriceList
    endpoint: /materialPriceApply/findHistoryPriceList
    kind: business
    when: 用户问历史价格（默认）
    priority: 1
    params_mapping:
      materialName: material_name
      supplierName: supplier_name
  - name: getMaterialPriceAnalysis
    endpoint: /materialPriceApply/materialPriceAnalysis
    kind: business
    when: 用户问价格趋势/分析
    priority: 2
    params_mapping:
      materialName: material_name
  - name: getMaterialPriceList
    endpoint: /materialPriceApply/list
    kind: business
    when: 用户查价格申请列表
    priority: 2
    params_mapping:
      materialName: material_name
      startDate: date_range.start
      endDate: date_range.end
```

## 返回模板

```yaml
render_template: list_table
format: |
  物料「{materialName}」价格记录：
  （表格：供应商、含税单价、不含税单价、采购时间、PO单号）
  最近一次：{latestPrice} 元（{latestSupplier}，{latestDate}）
```

## 推荐提问候选池

```yaml
recommendation_pool:
  - text: "哪个供应商最便宜"
    direction: 金额排序
    when: supplier_count >= 2
  - text: "这个物料的库存"
    direction: 同主体延伸
    when: always
  - text: "价格趋势分析"
    direction: 明细下钻
    when: history_count >= 3
  - text: "这个供应商的其他物料价格"
    direction: 同主体延伸
    when: has_supplier
```
