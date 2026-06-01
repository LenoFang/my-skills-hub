---
id: 18
name: 物资申请查询
applicable_roles: [需求人, 采购员, 采购管理层]
---

# 场景 18 — 物资申请查询

## 识别特征

```yaml
hard_rules:
  - pattern: "/(物资申请|领用|物资领用|物资单|领用进度)/"
  - keywords: ["我的物资申请", "物资申请到哪了", "领用进度", "物资单查一下"]
  - negative: ["采购申请"]
  note: "含'采购申请'走场景 02/04，纯'物资申请/领用'走本场景"
```

## 实体契约

```yaml
required_entities: []
optional_entities: [apply_no, status, date_range, applicant_name]
defaults: { page: 1, page_size: 10 }
ask_template: null
inheritable_entities: [apply_no, date_range]
note: "有单号走精确查询+进度，无单号走列表"
```

## 归一化

```yaml
normalize:
  apply_no:
    via: lookupMaterialApplyByNo
    steps:
      - 用 /matapply/list 或 /matapply/mlist + keyword=apply_no 查到内部 ID
      - 取第一条结果的 formId
    on_not_found: exception "未找到该物资申请单"
  status:
    via: local_parser
  date_range:
    via: local_parser
  applicant_name:
    via: lookupUserByName
    on_ambiguous: ask_user
    on_not_found: exception "未找到该员工"
```

## 权限

```yaml
deny_response: "您暂无权限查看物资申请"
```

## cli 候选

```yaml
cli_candidates:
  - name: getMaterialApplyDetail
    endpoint: /matapply/get
    kind: business
    when: 用户提供了物资申请单号
    priority: 1
    params_mapping:
      formId: apply_no.id
  - name: getMaterialApplyProgress
    endpoint: /matapply/progresslist
    kind: business
    when: 用户问物资申请进度且有单号
    priority: 1
    params_mapping:
      formId: apply_no.id
  - name: getMaterialApplyList
    endpoint: /matapply/list
    kind: business
    when: 用户查自己的物资申请列表
    priority: 2
    params_mapping:
      status: status
      startDate: date_range.start
      endDate: date_range.end
  - name: getMaterialApplyMlist
    endpoint: /matapply/mlist
    kind: business
    when: 用户权限为 dept/all scope 或查别人的申请
    priority: 1
    params_mapping:
      applicantId: applicant.user_id
      status: status
      startDate: date_range.start
      endDate: date_range.end
```

## 返回模板

```yaml
render_template_detail: detail_card_material_apply
render_template_list: list_table
format_detail: |
  物资申请 {formNo}：
  状态：{status}
  申请人：{applierName}
  申请时间：{applyTime}
  物料：{materialName} × {quantity}
format_list: |
  共 {total} 条物资申请
  （表格：单号、状态、物料名称、数量、申请时间）
```

## 推荐提问候选池

```yaml
recommendation_pool:
  - text: "这个单子的进度"
    direction: 明细下钻
    when: mode == list AND total >= 1
  - text: "转采购了吗"
    direction: 明细下钻
    when: mode == detail AND status in [已审批, 待采购]
  - text: "对应的采购申请单"
    direction: 同主体延伸
    when: has_linked_pr
  - text: "本月物资申请汇总"
    direction: 同环比
    when: always
```
