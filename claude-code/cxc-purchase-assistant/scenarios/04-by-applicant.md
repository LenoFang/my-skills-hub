---
id: 4
name: 需求人维度查询
applicable_roles: [需求人, 采购员, 采购管理层]
---

# 场景 04 — 需求人维度查询

## 识别特征

```yaml
hard_rules:
  - pattern: 人名 + "/(申请|提交|发起|的\\s*单)/"
  - keywords: ["最近申请了哪些", "提了什么单"]
```

## 实体契约

```yaml
required_entities: [applicant_name]
optional_entities: [status, date_range, category]
defaults: { page: 1, page_size: 10, status: all }
ask_template: "你想查谁的申请单？请告诉我姓名"
inheritable_entities: [applicant_name, date_range]
```

## 归一化

```yaml
normalize:
  applicant_name:
    via: lookupUserByName
    on_ambiguous: ask_user          # "张三有 2 位，是采购部张三还是研发部张三？"
    on_not_found: exception "未找到该员工"
  date_range:
    via: local_parser
```

## 权限

```yaml
deny_response: "您暂无权限查看该用户的申请单"
```

## cli 候选

```yaml
cli_candidates:
  - name: queryPrList
    endpoint: /purchaseApply/list
    kind: business
    when: 用户权限为 personal scope
    priority: 2
    params_mapping:
      applicantId: applicant.user_id
      status: status
      startDate: date_range.start
      endDate: date_range.end
      categoryCode: category.code
  - name: queryPrMlist
    endpoint: /mPurchaseApply/mlist
    kind: business
    when: 用户权限为 dept/all scope
    priority: 1
    params_mapping:
      applicantId: applicant.user_id
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
  - text: "{applicant}还有没批完的吗"
    direction: 异常项
    when: status_distribution.pending >= 1
  - text: "{applicant}被驳回的单子"
    direction: 异常项
    when: status_distribution.rejected >= 1
  - text: "{applicant}本月提了多少"
    direction: 同环比
    when: always
  - text: "按品类看看"
    direction: 分布下钻
    when: category_count >= 2
```
