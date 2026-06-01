---
id: 22
name: 资产处置查询
applicable_roles: [需求人, 采购员, 采购管理层]
---

# 场景 22 — 资产处置查询

## 识别特征

```yaml
hard_rules:
  - pattern: "/(资产处置|报废|处置单|资产闭环|报废进度|处置进度)/"
  - keywords: ["报废单到哪了", "资产处置进度", "我的报废申请", "处置单查一下"]
```

## 实体契约

```yaml
required_entities: []
optional_entities: [form_no, status, date_range, applicant_name]
defaults: { page: 1, page_size: 10 }
ask_template: null
inheritable_entities: [form_no, date_range]
note: "有单号走精确查询+进度，无单号走列表"
```

## 归一化

```yaml
normalize:
  form_no:
    via: lookupClosedLoopByNo
    steps:
      - 用 /closedLoop/mlist + keyword=form_no 查到内部 formId
      - 取第一条结果的 formId
    on_not_found: exception "未找到该处置单"
  status:
    via: local_parser
    mapping:
      "待审批": 1
      "审批中": 2
      "已通过": 3
      "已驳回": 4
      "已取消": 5
      "已关闭": 6
  date_range:
    via: local_parser
  applicant_name:
    via: lookupUserByName
    on_ambiguous: ask_user
    on_not_found: exception "未找到该员工"
```

## 权限

```yaml
deny_response: "您暂无权限查看资产处置信息"
```

## cli 候选

```yaml
cli_candidates:
  - name: getClosedLoopDetail
    endpoint: /closedLoop/get
    kind: business
    when: 用户提供了处置单号
    priority: 1
    params_mapping:
      formId: form_no.id
  - name: getClosedLoopProgress
    endpoint: /closedLoop/progress/list
    kind: business
    when: 用户问处置进度且有单号
    priority: 1
    params_mapping:
      formId: form_no.id
  - name: getClosedLoopList
    endpoint: /closedLoop/mlist
    kind: business
    when: 用户查处置列表
    priority: 2
    params_mapping:
      status: status
      applicantName: applicant_name
      startDate: date_range.start
      endDate: date_range.end
```

## 返回模板

```yaml
render_template_detail: detail_card_closed_loop
render_template_list: list_table
format_detail: |
  资产处置单 {formNo}：
  状态：{status}
  处置类型：{disposalType}
  申请人：{applierName}
  申请时间：{applyTime}
  资产明细：{assetCount} 项
format_list: |
  共 {total} 条资产处置记录
  （表格：单号、状态、处置类型、申请人、资产数、时间）
```

## 推荐提问候选池

```yaml
recommendation_pool:
  - text: "这个单子的审批进度"
    direction: 明细下钻
    when: mode == list AND total >= 1
  - text: "被驳回的处置单"
    direction: 异常项
    when: status_distribution.rejected >= 1
  - text: "本月处置了多少资产"
    direction: 同环比
    when: always
  - text: "待审批的处置单"
    direction: 异常项
    when: status_distribution.pending >= 1
```
