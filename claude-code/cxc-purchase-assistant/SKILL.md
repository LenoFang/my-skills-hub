---
name: cxc-purchase-assistant
description: 程小采企微机器人运行时 skill — 意图识别、场景路由、cli 编排、结果组装
---

# 程小采 · 采购助手 Skill

> 模型无关的运行时 skill。机器人收到企微消息后加载本文件，按下方主流程完成"识别 → 调 cli → 返回"。

## 定位

- **上游**：企微消息回调 → 中间层服务
- **下游**：已封装的 cli 接口集合（business / lookup / permission）
- **不做**：不硬编码权限角色矩阵；不复刻供应链权限规则；不直接渲染数字到自然语言

## 文件索引

| 文件 | 职责 | 加载时机 |
|---|---|---|
| `intents.md` | 23 类硬规则特征表 + 组合查询规范 + LLM 决策树兜底 | 每次请求 |
| `scenarios/01..23.md` | 23 个场景定义（实体契约 / cli 候选 / 推荐池） | 按命中场景按需加载 |
| `permissions.md` | 权限拉取协议 + 校验伪码 | step 6 |
| `cli-apis.md` | 接口字典（全部端点已覆盖） | step 7 |
| `response-format.md` | 卡片/表格/汇总块模板 + 推荐提问硬规则 | step 10-11 |
| `exceptions.md` | 8 类异常话术 + 引导类推荐 | 异常分支 |
| `call-chain-logger.md` | 调用链日志规范 | 全流程 |

---

## 主流程（13 步）

### Step 1 — 接收消息

```
输入：{ user_id, raw_input, msg_id }
```

### Step 2 — 取/建会话上下文

```
session = get_or_create(user_id)
# 主 TTL 10min；候选歧义独立 TTL 2min
```

### Step 3.0 — 零号分支（歧义确认）

```
if session.pending_disambiguation AND ttl_alive:
    if input matches [数字 | 序号词 | 候选中的 pr_no/po_no 片段]:
        resolved = pick_candidate(input, session.candidates)
        
        # 重要：不能跳过权限校验！
        # 从候选中提取 form_id/order_id，构造 chosen_cli 和 params
        chosen_cli = session.origin_scenario == "01" ? "queryPrDetail" : "queryPoDetail"
        params = { formId: resolved.form_id } or { id: resolved.order_id }
        
        # 仍需走 Step 6 权限校验（详情端点权限可能与列表端点不同）
        → 跳至 Step 6 进行权限校验，然后继续 Step 9
        → 清除 pending_disambiguation
    else:
        清除 candidates，正常进入 step 3
```

> **注意**：即使候选来自上一轮列表查询，也不能假设详情端点权限相同。
> 零号分支必须经过 Step 6 权限校验后才能调用 cli。

### Step 3 — 三信号判定追问

```
is_followup = ttl_alive
              AND no_strong_anchor(input)
              AND (has_pronoun OR is_elliptical)

if is_followup:
    按 last_scenario.inheritable_entities 白名单合并实体
    (new wins on conflict)
```

### Step 4 — 意图识别 + 实体抽取

参见 `intents.md`。

```
1. 先跑硬规则特征表 → 命中即定候选场景（可多个，带 confidence）
2. 未命中 → 走 LLM 决策树
   优先级：PR精确 > PO精确 > 我的X > 人名维度
           > 供应商 > 品类 > 周期统计 > 状态筛选 > 模糊 > 帮助
```

### Step 4.5 — 实体归一化（跨模块 lookup）

```
for each entity in extracted_entities:
    if type == date_range:
        normalized = local_date_parser(raw)
    elif type in lookup_types:
        normalized = call_lookup_cli(raw)
    if ambiguous → 走反问分支（如重名："张三有 2 位，是采购部张三还是研发部张三？"）
    if not_found → 走 exceptions.md "未找到XX"
    回填 entity.normalized
```

### Step 5 — 必填校验

```
for sc in candidate_scenarios:
    missing = sc.required_entities - filled_entities
    if missing:
        → 用 sc.ask_template 反问用户，不进 LLM
        → 写入 session.pending_clarification
        → 结束本轮
```

### Step 6 — 权限校验

参见 `permissions.md`。

```
user_perms = fetch_or_cache(user_id, ttl=600s)
for sc in candidate_scenarios:
    for ep in sc.cli_candidates:
        ok = check_endpoint(ep.path, user_perms)
        if not ok: 标记 ep 为拒绝
    if sc 全部 ep 被拒: 标记 sc 为拒绝
若全部 sc 被拒 → exceptions.md "无权限" + sc.deny_response
否则 → 仅保留可执行 sc/ep 进入 step 7
```

### Step 7 — 组装 7 段结构化 prompt

```yaml
## 1. user_input          — 原始问句
## 2. candidate_scenarios — [{ id, name, confidence, reason }]
## 3. extracted_entities   — 已归一化的实体
## 4. user_context         — { user_id, role, permission_scope }
## 5. available_cli_apis   — 仅候选场景关联的子集
## 6. session_context      — 上一轮状态
## 7. expected_output      — 要求返回 JSON: { chosen_cli, params, scenario_id, post_process_hint }
```

### Step 8 — Plan 阶段（LLM #1）

```
输入：7 段 prompt
输出：{ chosen_cli, params, scenario_id, post_process_hint }
校验：chosen_cli ∈ available_cli_apis；params 满足接口 schema
```

### Step 9 — 调用 cli

```
raw_data = call_cli(chosen_cli, params)
异常处理：
  - 空结果   → exceptions.md "结果为空"
  - 超时     → exceptions.md "查询超时"
  - 越权     → exceptions.md "无权限"（兜底）
  - 模糊场景10 多条命中 → 写入 pending_disambiguation，返回候选卡片，跳过 step 10-11
```

### Step 10 — Render 阶段（LLM #2）

参见 `response-format.md`。

```
输入：{ scenario_id, raw_data, user_input, render_template }
输出：ai_summary（仅文字，不含数字渲染）

数据卡片/表格/汇总块由 skill 宿主用 response-format.md 模板预渲染，不进 LLM。
```

### Step 11 — Recommend 阶段（LLM #3）

```
a. [补充数据拉取] 按用户角色选择性拉取一个补充数据源（会话级缓存 600s）：
     - 采购员 → /tranTodo/todoNum（待办数）
     - 采购管理层 → /kanban/procurement-efficiency/purchaseToPrOverdue（超期数）
     - 需求人 → 无补充
   若补充数据有值（如待办数 > 0），注入动态推荐条目到候选池：
     - 待办数 > 0 → "你有 {n} 条待处理，要看看吗？"
     - 超期数 > 0 → "有 {n} 条超期单据，要看明细吗？"

b. 用 raw_data 评估 scenarios/NN.md 中 recommendation_pool 每条的 when 条件
c. 用 raw_data 填占位符（{top_category} / {handler_name} 等）
d. 剔除与本轮 input + history 文本相似度高的
e. 把过滤后池子 + response-format.md 硬规则喂 LLM → 精选 2-4 条
```

### Step 12 — 拼装返回

```
返回企微：{ ai_summary, data_block, recommendations }
展示格式：
  [AI 总结]
  [数据卡片/表格/汇总块]
  💡 试试这样问： {a} | {b} | {c}
```

### Step 13 — 更新会话

```
session.last_scenario_id = scenario_id
session.last_entities = entities（仅 inheritable 白名单内）
session.last_result_ids = ids(raw_data)
session.ttl_reset()
```

---

## 三次 LLM 调用职责清单（防越界）

| 调用 | 输入 | 输出 | 不做的事 |
|---|---|---|---|
| Plan | 7 段 prompt | `{chosen_cli, params, scenario_id}` | 不编造数据；不渲染话术 |
| Render | raw_data + 模板 | ai_summary 文字 | 不输出数字（数字由模板渲染）；不生成推荐 |
| Recommend | 过滤后候选池 + 硬规则 | 2-4 条推荐提问 | 不生成开放式；不重复历史 |

---

## 会话上下文 Schema

```yaml
session[user_id]:
  ttl: 600s
  last_scenario_id: int
  last_entities: { ... }
  last_result_ids: [...]
  pending_disambiguation:
    active: bool
    candidates: [{ pr_no, summary }, ...]
    ttl: 120s
    origin_scenario: int
  pending_clarification:
    active: bool
    scenario_id: int
    missing: [entity_name]
  user_perms_cache:
    perms: [...]
    fetched_at: timestamp
```
