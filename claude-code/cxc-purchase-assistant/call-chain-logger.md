# 调用链日志规范

> 本文件定义 skill 运行时的调用链日志格式，用于追溯问题。
> 日志文件位置：`~/.scm/logs/skill-trace-YYYY-MM-DD.log`

---

## 1. 日志格式

每次用户询问生成一条完整的调用链日志，格式如下：

```
================================================================================
[2026-05-30T12:34:56.789Z] TraceID: abc123-xyz789
================================================================================

▶ Step 1 — 接收消息
  User ID:    18059
  Work ID:    1013011
  Input:      "PR WPU26052700002 到哪了"
  Session:    新建 / 复用 (TTL: 8m30s)

▶ Step 3 — 追问判定
  Is Followup: false
  Reason:      包含强锚点 (PR号)

▶ Step 4 — 意图识别
  Method:     硬规则命中
  Scenario:   01 - 查单进度（PR 精确查询）
  Confidence: 1.0
  Reason:     匹配正则 /(PR|pr)\s*\d{5,}/

▶ Step 4.5 — 实体抽取
  Entities:
    - pr_no: "WPU26052700002" (raw)
  Normalize:
    - pr_no → lookupPrByNo
      CLI:    scm list purchase-applies --form-no WPU26052700002
      Result: formId=2513, status=待处理
      Time:   156ms

▶ Step 5 — 必填校验
  Required:   [pr_no]
  Filled:     [pr_no]
  Missing:    []
  Result:     ✓ PASS

▶ Step 6 — 权限校验
  User Perms: [system:purchaseApplyV2:list, system:purchaseApplyV2:view, ...]
  Endpoint:   /purchaseApply/detail
  Required:   any_of [system:purchaseApplyV2:view]
  Result:     ✓ PASS

▶ Step 8 — Plan 阶段 (LLM #1)
  Input Tokens:  ~1200
  Output:
    chosen_cli:  queryPrDetail
    params:      {"formId": 2513}
    scenario_id: 01
  Time:        890ms

▶ Step 9 — CLI 调用
  Command:    scm get purchase-apply --id 2513
  Endpoint:   GET /purchaseApply/detail
  Params:     {"formId": 2513}
  Status:     ✓ SUCCESS (200)
  Time:       234ms
  Records:    1
  Size:       2.3KB

▶ Step 10 — Render 阶段 (LLM #2)
  Input Tokens:  ~800
  Output:       "单据 WPU26052700002 当前状态为「待处理」..."
  Time:         456ms

▶ Step 11 — Recommend 阶段 (LLM #3)
  Pool Size:    4
  Filtered:     2 (重复历史)
  Selected:     ["这个单子是谁在处理", "关联订单查一下"]
  Time:         320ms

▶ Step 12 — 返回结果
  AI Summary:   单据 WPU26052700002 当前状态为「待处理」，由方梁于 2026-05-27 提交。
  Data Block:   detail_card_pr (1 record)
  Recommends:   2 条

▶ Step 13 — 更新会话
  last_scenario_id: 01
  last_entities:    {pr_no: "WPU26052700002", form_id: 2513}
  TTL Reset:        10m

────────────────────────────────────────────────────────────────────────────────
  Total Time:   2156ms
  LLM Calls:    3
  CLI Calls:    2
  Status:       ✓ SUCCESS
================================================================================
```

---

## 2. 错误日志格式

当流程中断时，记录错误信息：

```
================================================================================
[2026-05-30T12:34:56.789Z] TraceID: abc123-xyz789
================================================================================

▶ Step 1 — 接收消息
  User ID:    18059
  Input:      "张三的申请单"

▶ Step 4 — 意图识别
  Scenario:   04 - 需求人维度
  Confidence: 0.9

▶ Step 4.5 — 实体抽取
  Entities:
    - applicant_name: "张三" (raw)
  Normalize:
    - applicant_name → lookupUserByName
      CLI:    scm list lookup-users --keyword 张三
      Result: ✗ AMBIGUOUS (2 matches)
        1. 张三 (1001234) - 采购部
        2. 张三 (1005678) - 研发部

▶ INTERRUPT — 反问用户
  Type:       DISAMBIGUATION
  Message:    "找到 2 位叫「张三」的员工，请问是哪一位？"
  Candidates: [{id: 1001234, dept: 采购部}, {id: 1005678, dept: 研发部}]
  Session:    pending_disambiguation = true

────────────────────────────────────────────────────────────────────────────────
  Total Time:   456ms
  LLM Calls:    0
  CLI Calls:    1
  Status:       ⚠ PENDING_DISAMBIGUATION
================================================================================
```

---

## 3. 异常日志格式

```
================================================================================
[2026-05-30T12:34:56.789Z] TraceID: abc123-xyz789
================================================================================

▶ Step 1 — 接收消息
  User ID:    18059
  Input:      "PR12345678901 到哪了"

▶ Step 4.5 — 实体抽取
  Normalize:
    - pr_no → lookupPrByNo
      CLI:    scm list purchase-applies --form-no PR12345678901
      Result: ✗ NOT_FOUND (0 records)

▶ ERROR — 异常处理
  Type:       E01 - 单号不存在
  Message:    "未找到单号 PR12345678901，请确认单号是否正确"
  Exception:  exceptions.md → exception_E01

────────────────────────────────────────────────────────────────────────────────
  Total Time:   234ms
  LLM Calls:    0
  CLI Calls:    1
  Status:       ✗ ERROR (E01)
================================================================================
```

---

## 4. 日志级别

| 级别 | 说明 | 记录内容 |
|------|------|----------|
| TRACE | 详细追踪 | 所有 step + 完整参数 + 完整响应 |
| DEBUG | 调试信息 | 所有 step + 关键参数 + 摘要响应 |
| INFO | 正常信息 | 关键 step + 结果摘要 |
| WARN | 警告 | 反问、降级、重试 |
| ERROR | 错误 | 异常、失败 |

默认级别：`DEBUG`

---

## 5. 日志轮转

- 按日期滚动：`skill-trace-YYYY-MM-DD.log`
- 保留天数：30 天
- 单文件大小限制：100MB（超出后追加 `.1`, `.2` 后缀）

---

## 6. 日志查询

### 按 TraceID 查询
```bash
grep -A 100 "TraceID: abc123" ~/.scm/logs/skill-trace-*.log
```

### 按用户查询
```bash
grep -B 2 -A 50 "User ID:.*18059" ~/.scm/logs/skill-trace-*.log
```

### 按错误查询
```bash
grep -B 10 "Status:.*ERROR" ~/.scm/logs/skill-trace-*.log
```

### 按时间范围查询
```bash
awk '/2026-05-30T12:00/,/2026-05-30T13:00/' ~/.scm/logs/skill-trace-2026-05-30.log
```

---

## 7. 与 CLI 日志关联

CLI 侧日志位置：`~/.scm/logs/cli-calls-YYYY-MM-DD.log`

两份日志通过 **TraceID** 关联：
1. Skill 在 Step 1 生成 TraceID
2. 调用 CLI 时通过环境变量传递：`SCM_TRACE_ID=abc123 scm list ...`
3. CLI 日志中记录相同的 TraceID

```bash
# 查询完整调用链
TRACE_ID="abc123-xyz789"
echo "=== Skill Trace ===" && grep -A 100 "TraceID: $TRACE_ID" ~/.scm/logs/skill-trace-*.log
echo "=== CLI Calls ===" && grep -A 10 "TraceID: $TRACE_ID" ~/.scm/logs/cli-calls-*.log
```
