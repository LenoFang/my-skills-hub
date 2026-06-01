---
id: 11
name: 待办概览
applicable_roles: [需求人, 采购员, 采购管理层]
---

# 场景 11 — 待办概览

## 识别特征

```yaml
hard_rules:
  - pattern: "/(待办|要我处理|等我|待处理的|我的任务)/"
  - keywords: ["有什么要处理的", "待办事项", "我还有什么没做"]
```

## 实体契约

```yaml
required_entities: []
optional_entities: [todo_type]
defaults: {}
ask_template: null
inheritable_entities: []
note: "无必填实体，user_id 从 session 自动获取"
```

## 归一化

```yaml
normalize:
  todo_type:
    via: local_parser
    mapping:
      "采购申请": purchaseApplyHandle
      "验收": purchaseApplyInspected
      "入库": purchaseApplyStorage
      "物资申请": materialApplyHandle
      "出库": materialOutHandle
      "收货": materialReceiveHandle
```

## 权限

```yaml
deny_response: "您暂无权限查看待办"
```

## cli 候选

```yaml
cli_candidates:
  - name: getTodoNum
    endpoint: /tranTodo/todoNum
    kind: business
    when: 用户问总览（默认）
    priority: 1
    params_mapping: {}
    note: "返回各分类待办数量汇总"
  - name: getTodoList
    endpoint: /tranTodo/waitHandoverlist
    kind: business
    when: 用户指定了具体待办类型
    priority: 2
    params_mapping:
      type: todo_type
```

## 返回模板

```yaml
render_template: stats_summary
format: |
  待办汇总：共 {total} 条
  - 采购申请待处理：{purchaseApplyHandle} 条
  - 待验收：{purchaseApplyInspected} 条
  - 待入库：{purchaseApplyStorage} 条
  - 物资申请待处理：{materialApplyHandle} 条
  （仅展示有数据的分类）
```

## 推荐提问候选池

```yaml
recommendation_pool:
  - text: "看看待处理的采购申请"
    direction: 明细下钻
    when: purchaseApplyHandle > 0
  - text: "待验收的单子有哪些"
    direction: 明细下钻
    when: purchaseApplyInspected > 0
  - text: "待入库的看一下"
    direction: 明细下钻
    when: purchaseApplyStorage > 0
  - text: "我的申请单进度"
    direction: 同主体延伸
    when: always
```
