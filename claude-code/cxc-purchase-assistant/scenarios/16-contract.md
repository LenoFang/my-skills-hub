---
id: 16
name: 合同查询
applicable_roles: [采购员, 采购管理层]
---

# 场景 16 — 合同查询

## 识别特征

```yaml
hard_rules:
  - pattern: "/(合同|contract|签约|续签|到期).*(?!风险)/"
  - keywords: ["合同什么时候到期", "这个供应商的合同", "快到期的合同", "合同列表"]
  - negative: ["合同风险"]
  note: "含'合同风险'走场景 13，纯'合同'走本场景"
```

## 实体契约

```yaml
required_entities: []
optional_entities: [supplier_name, contract_status, date_range]
defaults: { page: 1, page_size: 10 }
ask_template: null
inheritable_entities: [supplier_name, date_range]
note: "无必填实体；可按供应商、状态、到期时间筛选"
```

## 归一化

```yaml
normalize:
  supplier_name:
    via: lookupSupplierByName
    on_ambiguous: ask_user
    on_not_found: exception "未找到该供应商"
  contract_status:
    via: local_parser
    mapping:
      "生效中": 1
      "已到期": 2
      "快到期": expiring
      "未生效": 0
  date_range:
    via: local_parser
```

## 权限

```yaml
deny_response: "您暂无权限查看合同信息"
```

## cli 候选

```yaml
cli_candidates:
  - name: getContractList
    endpoint: /purchasecontract/list
    kind: business
    when: 用户查合同列表（默认）
    priority: 1
    params_mapping:
      supplierName: supplier_name
      contractStatus: contract_status
      startDate: date_range.start
      endDate: date_range.end
  - name: getExpiringContracts
    endpoint: /kanban/procurement-efficiency/contractExpired
    kind: business
    when: 用户问"快到期的合同"
    priority: 1
    params_mapping: {}
    note: "返回即将到期的合同列表"
```

## 返回模板

```yaml
render_template: list_table
format: |
  合同列表（共 {total} 条）：
  （表格：合同编号、供应商、金额、状态、到期日）
format_expiring: |
  即将到期合同：{count} 条
  （表格：合同编号、供应商、到期日、剩余天数）
```

## 推荐提问候选池

```yaml
recommendation_pool:
  - text: "这个供应商的订单情况"
    direction: 同主体延伸
    when: has_supplier
  - text: "快到期的合同有哪些"
    direction: 异常项
    when: contract_status != expiring
  - text: "合同金额最大的几个"
    direction: 金额排序
    when: total >= 3
  - text: "这个供应商有风险吗"
    direction: 明细下钻
    when: has_supplier
```
