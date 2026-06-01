---
id: 2
name: 我的申请单
applicable_roles: [需求人, 采购员, 采购管理层]
---

# 场景 02 — 我的申请单

## 识别特征

```yaml
hard_rules:
  - pattern: "/^我的.*(申请|PR|采购申请)/"
  - pattern: "/(我|本人).*(提交|申请|发起)/"
  - keywords: ["我申请的", "我提的单"]
```

## 实体契约

```yaml
required_entities: []               # user_id 从 session 自动获取，无需用户提供
optional_entities: [status, date_range, category]
defaults: { page: 1, page_size: 10, status: all }
ask_template: null                  # 无必填实体，不会触发反问
inheritable_entities: [status, date_range, category]
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
deny_response: "您暂无权限查看采购申请"
```

## cli 候选

```yaml
cli_candidates:
  - name: queryPrList
    endpoint: /purchaseApply/list
    kind: business
    when: always
    priority: 1
    params_mapping:
      applicantId: session.user_id
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
  - text: "有哪些被驳回了"
    direction: 异常项
    when: status_distribution.rejected >= 1
  - text: "待审批的有几个"
    direction: 状态筛选
    when: status_distribution.pending >= 1
  - text: "本月提了多少单"
    direction: 同环比
    when: always
  - text: "{top_category}类的明细"
    direction: 分布下钻
    when: category_count >= 2
```
