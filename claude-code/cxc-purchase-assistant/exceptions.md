# 异常处理

> 本文件在 SKILL.md 各 step 的异常分支加载。定义 8 类异常的 AI 总结话术、数据块和推荐提问。

---

## 异常总表

| ID | 场景 | AI 总结 | 数据块 | 推荐提问 |
|---|---|---|---|---|
| E01 | 单号不存在 | 未找到对应单据，请确认单号是否正确 | 无 | 引导类 |
| E02 | 无权限 | 您暂无权限查看此单据 | 无 | 引导类 |
| E03 | 需求人查 PO | 采购订单查询仅对采购人员开放 | 无 | 引导类 |
| E04 | 查询超时 | 查询超时，请稍后重试 | 无 | 无 |
| E05 | 结果为空 | 暂未找到符合条件的记录 | 无 | 引导类 |
| E06 | 未识别意图 | 请描述您想查询的内容，输入"帮助"查看更多 | 无 | 引导类 |
| E07 | API 不可用 | 采购系统暂不可用，请稍后重试 | 无 | 无 |
| E08 | 模糊匹配多条 | 找到 {N} 条相关单据，请确认是哪一条 | 候选列表 | 对应推荐 |

---

## 各异常详细定义

### E01 — 单号不存在

触发条件：Step 9 cli 返回空 + 输入含有效单号格式

```
ai_summary: "未找到单号 {input_no} 对应的单据，请确认单号是否正确。"
data_block: 无
recommendations:
  - "查我的申请单"
  - "帮助"
```

### E02 — 无权限

触发条件：Step 6 权限校验全部 sc 被拒

```
ai_summary: "{deny_response}"    # 取自场景子文件的 deny_response 字段
data_block: 无
recommendations:
  - "查我的申请单"
  - "帮助"
```

### E03 — 需求人查 PO

触发条件：Step 6 当用户角色为需求人 + 候选场景含 03(我的订单) / 06(供应商) 等 PO 场景

```
ai_summary: "采购订单查询仅对采购人员开放，您可以查看自己提交的采购申请。"
data_block: 无
recommendations:
  - "我的申请单"
  - "待审批的申请"
```

### E04 — 查询超时

触发条件：Step 9 cli 调用超时

```
ai_summary: "查询超时，请稍后重试。"
data_block: 无
recommendations: 无（不展示推荐）
```

### E05 — 结果为空

触发条件：Step 9 cli 正常返回但数据列表为空

```
ai_summary: "暂未找到符合条件的记录，可以尝试调整筛选条件。"
data_block: 无
recommendations:
  - "换个时间段试试"
  - "查全部状态的"
  - "帮助"
```

### E06 — 未识别意图

触发条件：Step 4 硬规则 + LLM 决策树均无法归类

```
ai_summary: "请描述您想查询的内容，例如'我的申请单'或'PR20260523001到哪了'。输入"帮助"查看完整功能。"
data_block: 无
recommendations:
  - "我的申请单"
  - "本月采购量"
  - "帮助"
```

### E07 — API 不可用

触发条件：Step 9 cli 返回网络错误 / HTTP 5xx

```
ai_summary: "采购系统暂不可用，请稍后重试。"
data_block: 无
recommendations: 无
```

### E08 — 模糊匹配多条

触发条件：Step 9 场景 10 返回 ≥2 条结果

```
ai_summary: "找到 {count} 条相关单据，请确认是哪一条。"
data_block: candidate_list 模板（见 response-format.md §3.5）
recommendations:
  - 取候选列表前 2 条的单号作为推荐（如 "查 PR20260523001" / "查 PR20260520005"）

# 同时写入 session：
session.pending_disambiguation = {
  active: true,
  candidates: [{pr_no, summary}, ...],
  ttl: 120s,
  origin_scenario: 10
}
```

---

## 权限配置缺失（特殊异常）

触发条件：Step 6 端点在 `endpointToPermissions` 中未映射（unmapped）

```
ai_summary: "权限配置缺失，请联系管理员补全相关映射。"
data_block: 无
recommendations:
  - "查我的申请单"
  - "帮助"
# 同时记录日志：{ unmapped_endpoint, user_id, timestamp }
```
