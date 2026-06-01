---
id: 10
name: 模糊匹配查询
applicable_roles: [需求人, 采购员, 采购管理层]
---

# 场景 10 — 模糊匹配查询

## 识别特征

```yaml
hard_rules:
  - 含物品关键词（"服务器"、"笔记本"、"打印机"等）但无精确单号
  - 含"那个"、"之前的"等指代词 + 采购/申请/订单
  - 单号片段不完整（仅数字，无 PR/PO 前缀）
```

## 实体契约

```yaml
required_entities: [keyword]
optional_entities: [status, date_range]
defaults: { page: 1, page_size: 5 }       # 模糊匹配默认少量返回
ask_template: "请描述更多细节，比如物品名称、大概时间"
inheritable_entities: []                   # 模糊匹配结果不继承
```

## 归一化

```yaml
normalize:
  keyword:
    via: local_parser                      # 直接取原文关键词，不调 cli
  date_range:
    via: local_parser
```

## 权限

```yaml
deny_response: "您暂无权限查看相关单据"
```

## cli 候选

```yaml
cli_candidates:
  - name: queryPrList
    endpoint: /purchaseApply/list
    kind: business
    when: 上下文偏向 PR（默认）
    priority: 1
    params_mapping:
      keyword: keyword
      status: status
      startDate: date_range.start
      endDate: date_range.end
  - name: queryPoList
    endpoint: /purchase/order/mlist
    kind: business
    when: 上下文偏向 PO
    priority: 2
    params_mapping:
      keyword: keyword
      status: status
      startDate: date_range.start
      endDate: date_range.end
```

## 返回模板

```yaml
render_template: candidate_list            # 多条时用候选列表
# 若仅 1 条命中 → 自动转场景 01 走详情查询
```

## 多条命中处理（零号分支联动）

```yaml
on_match_multiple:
  action: return_candidates
  max_candidates: 5
  set_session:
    pending_disambiguation: true
    candidates: [{ pr_no, summary }, ...]
    disambiguation_ttl: 120s
    origin_scenario: 10

# 用户下一轮回复数字/序号/单号片段 → Step 3.0 零号分支接管
# 用户回复其他内容 → 清除 candidates，正常走意图识别
```

## 推荐提问候选池

```yaml
recommendation_pool:
  - text: "是不是{candidate_1_no}"
    direction: 明细下钻
    when: candidate_count >= 1
  - text: "查{candidate_2_no}"
    direction: 明细下钻
    when: candidate_count >= 2
  - text: "加个时间范围缩小下"
    direction: 状态筛选
    when: candidate_count >= 3
  - text: "换个关键词试试"
    direction: 明细下钻
    when: candidate_count == 0
```
