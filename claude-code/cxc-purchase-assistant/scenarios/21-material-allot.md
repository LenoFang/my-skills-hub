---
id: 21
name: 物资调拨查询
applicable_roles: [需求人, 采购员, 采购管理层]
---

# 场景 21 — 物资调拨查询

## 识别特征

```yaml
hard_rules:
  - pattern: "/(调拨|调拨单|资产调拨|物资调拨|调拨进度)/"
  - keywords: ["调拨单到哪了", "我的调拨申请", "调拨进度", "资产调拨查一下"]
```

## 实体契约

```yaml
required_entities: []
optional_entities: [allot_no, status, date_range, applicant_name]
defaults: { page: 1, page_size: 10 }
ask_template: null
inheritable_entities: [allot_no, date_range]
note: "有单号走精确查询+进度，无单号走列表"
```

## 归一化

```yaml
normalize:
  allot_no:
    via: lookupAllotByNo
    steps:
      - 用 /materialAssetAllot/list + keyword=allot_no 查到内部 ID
      - 取第一条结果的 id
    on_not_found: exception "未找到该调拨单"
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
deny_response: "您暂无权限查看物资调拨信息"
```

## cli 候选

```yaml
cli_candidates:
  - name: getAllotDetail
    endpoint: /materialAssetAllot/get
    kind: business
    when: 用户提供了调拨单号
    priority: 1
    params_mapping:
      id: allot_no.id
  - name: getAllotProgress
    endpoint: /materialAssetAllot/progress/{id}
    kind: business
    when: 用户问调拨进度且有单号
    priority: 1
    params_mapping:
      id: allot_no.id
  - name: getAllotList
    endpoint: /materialAssetAllot/list
    kind: business
    when: 用户查自己的调拨列表
    priority: 2
    params_mapping:
      status: status
      startDate: date_range.start
      endDate: date_range.end
  - name: getAllotMlist
    endpoint: /materialAssetAllot/mlist
    kind: business
    when: 用户权限为 dept/all scope 或查别人的调拨
    priority: 1
    params_mapping:
      applicantId: applicant.user_id
      status: status
      startDate: date_range.start
      endDate: date_range.end
```

## 返回模板

```yaml
render_template_detail: detail_card_allot
render_template_list: list_table
format_detail: |
  调拨单 {formNo}：
  状态：{status}
  发起人：{applierName}
  调出仓库：{fromWarehouse} → 调入仓库：{toWarehouse}
  物料：{materialName} × {quantity}
format_list: |
  共 {total} 条调拨记录
  （表格：单号、状态、物料、数量、调出→调入、时间）
```

## 推荐提问候选池

```yaml
recommendation_pool:
  - text: "这个单子的进度"
    direction: 明细下钻
    when: mode == list AND total >= 1
  - text: "这个物料的库存"
    direction: 同主体延伸
    when: has_material
  - text: "本月调拨了多少"
    direction: 同环比
    when: always
  - text: "待审批的调拨单"
    direction: 异常项
    when: status_distribution.pending >= 1
```
