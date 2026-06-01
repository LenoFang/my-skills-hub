---
id: 9
name: 状态筛选查询
applicable_roles: [需求人, 采购员, 采购管理层]
---

# 场景 09 — 状态筛选查询

## 识别特征

```yaml
hard_rules:
  - pattern: "/(待审批|已驳回|审批中|未交付|已完成|待验收|待入库)/"
  - keywords: ["被退回的", "还没批的", "已经完成的"]
```

## 实体契约

```yaml
required_entities: [status]
optional_entities: [date_range, applicant_name, category]
defaults: { page: 1, page_size: 10 }
ask_template: "你想筛选哪个状态？待审批 / 已驳回 / 已完成？"
inheritable_entities: [status, date_range, applicant_name]
```

## 归一化

```yaml
normalize:
  status:
    via: local_parser               # 关键词 → 枚举映射，见 intents.md §2.6
  date_range:
    via: local_parser
  applicant_name:
    via: lookupUserByName
    on_ambiguous: ask_user
    on_not_found: exception "未找到该员工"
```

## 权限

```yaml
deny_response: "您暂无权限查看此类单据"
```

## cli 候选

```yaml
cli_candidates:
  - name: queryPrList
    endpoint: /purchaseApply/list
    kind: business
    when: 上下文偏向 PR（默认）且权限为 personal scope
    priority: 2
    params_mapping:
      status: status
      applicantId: applicant.user_id
      startDate: date_range.start
      endDate: date_range.end
      categoryCode: category.code
  - name: queryPrMlist
    endpoint: /mPurchaseApply/mlist
    kind: business
    when: 用户权限为 dept/all scope
    priority: 1
    params_mapping:
      status: status
      applicantId: applicant.user_id
      startDate: date_range.start
      endDate: date_range.end
      categoryCode: category.code
  - name: queryPoList
    endpoint: /purchase/order/mlist
    kind: business
    when: 上下文偏向 PO（如追问场景 03 后筛状态）
    priority: 2
    params_mapping:
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
  - text: "驳回原因是什么"
    direction: 异常项
    when: status == REJECTED AND total_count >= 1
  - text: "这些单子总金额多少"
    direction: 金额排序
    when: total_count >= 2
  - text: "按品类分布看看"
    direction: 分布下钻
    when: category_count >= 2
  - text: "查其他状态的"
    direction: 状态筛选
    when: always
```
