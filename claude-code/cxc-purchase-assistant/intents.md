# 意图识别与实体抽取

> 本文件在 SKILL.md Step 4 加载。先跑硬规则特征表，命中即定场景；未命中走 LLM 决策树兜底。

---

## 1. 硬规则特征表（按优先级排序）

优先级从高到低。同时命中多条时，取优先级最高的作为主场景，其余作为备选（confidence 降低）。

**注意**：正则放在 YAML 代码块中，避免 markdown 表格转义 `|` 符号。

```yaml
hard_rules:
  - priority: 1
    scenario_id: "01"
    name: "PR/PO 精确查询"
    patterns:
      - "(PR|pr|采购申请)\\s*\\d{5,}"
      - "(PO|po|采购订单|订单号)\\s*\\d{5,}"
      - "申请单号.*\\d+"
      - "订单号.*\\d+"
    extract: [pr_no, po_no]
    note: "PR 和 PO 精确查询合并在场景 01，由 cli_candidates 根据提取到的实体类型选择调用"

  - priority: 2
    scenario_id: "02"
    name: "我的申请单"
    patterns:
      - "^我的.*(申请|PR|采购申请)"
      - "(我|本人).*(提交|申请|发起)"
    extract: [user_id]
    note: "user_id 从 session 自动获取"

  - priority: 3
    scenario_id: "03"
    name: "我的订单"
    patterns:
      - "^我的.*(订单|PO|采购订单)"
      - "(我|本人).*(经手|处理|创建).*订单"
    extract: [user_id]

  - priority: 4
    scenario_id: "04"
    name: "需求人维度"
    patterns:
      - "<人名>.*(申请|提交|发起|的\\s*单)"
    extract: [applicant_name]

  - priority: 5
    scenario_id: "05"
    name: "采购员维度"
    patterns:
      - "<人名>.*(经手|处理|负责|办理)"
    extract: [handler_name]

  - priority: 6
    scenario_id: "06"
    name: "供应商维度"
    patterns:
      - "<供应商名>.*(订单|PO|供货|交付)"
    extract: [supplier_name]

  - priority: 7
    scenario_id: "07"
    name: "品类维度"
    patterns:
      - "<品类名>.*(采购|订单|申请)"
    extract: [category]

  - priority: 8
    scenario_id: "08"
    name: "周期统计"
    patterns:
      - "(本月|上月|本周|上周|本季度|今年|Q[1-4]).*(量|花了|多少|统计|金额|汇总)"
    extract: [date_range]

  - priority: 9
    scenario_id: "09"
    name: "状态筛选"
    patterns:
      - "(待审批|已驳回|审批中|未交付|已完成|待验收|待入库)"
    extract: [status]

  - priority: 10
    scenario_id: "10"
    name: "模糊匹配"
    patterns:
      - "含物品关键词但无精确单号"
    extract: [keyword]

  - priority: 11
    scenario_id: "11"
    name: "待办概览"
    patterns:
      - "(待办|要我处理|等我|待处理的|我的任务)"
    extract: []
    note: "user_id 从 session 自动获取"

  - priority: 12
    scenario_id: "12"
    name: "超期预警"
    patterns:
      - "(超期|超时|逾期|overdue|效率|时效)"
    extract: [overdue_type]

  - priority: 13
    scenario_id: "13"
    name: "采购风险"
    patterns:
      - "(风险|黑名单|冻结|异常供应商)"
    extract: [risk_type]

  - priority: 14
    scenario_id: "14"
    name: "采购仪表盘"
    patterns:
      - "(花了多少|总金额|采购额|采购量|采购数据|采购概况|整体情况)"
    extract: [date_range, dashboard_dimension]

  - priority: 15
    scenario_id: "15"
    name: "退货查询"
    patterns:
      - "(退货|退回|退货单|退货进度)"
    extract: [return_no, status]

  - priority: 16
    scenario_id: "16"
    name: "合同查询"
    patterns:
      - "(合同|签约|续签|到期)(?!.*风险)"
    extract: [supplier_name, contract_status]
    note: "含'合同风险'走场景 13，纯'合同'走本场景"

  - priority: 17
    scenario_id: "17"
    name: "库存查询"
    patterns:
      - "(库存|存量|有没有货|还有多少|现货|可用量)"
    extract: [material_code, material_name]

  - priority: 18
    scenario_id: "18"
    name: "物资申请查询"
    patterns:
      - "(物资申请|领用|物资领用|物资单|领用进度)(?!.*采购)"
    extract: [apply_no, status]
    note: "含'采购申请'走场景 02/04，纯'物资申请/领用'走本场景"

  - priority: 19
    scenario_id: "19"
    name: "安全库存预警"
    patterns:
      - "(安全库存|低于库存|补货|缺货|库存不足|库存预警)"
    extract: [material_name, category]

  - priority: 20
    scenario_id: "20"
    name: "物料价格查询"
    patterns:
      - "(价格|报价|历史价|单价|价格趋势|比价)(?!.*总金额|花了多少)"
    extract: [material_name, supplier_name]
    note: "含'总金额/花了多少'走场景 14，纯'价格/单价'走本场景"

  - priority: 21
    scenario_id: "21"
    name: "物资调拨查询"
    patterns:
      - "(调拨|调拨单|资产调拨|物资调拨|调拨进度)"
    extract: [allot_no, status]

  - priority: 22
    scenario_id: "22"
    name: "资产处置查询"
    patterns:
      - "(资产处置|报废|处置单|资产闭环|报废进度|处置进度)"
    extract: [form_no, status]

  - priority: 23
    scenario_id: "23"
    name: "盘点查询"
    patterns:
      - "(盘点|盘点计划|盘点结果|盘点差异|盘盈|盘亏)"
    extract: [date_range, inventory_type]

  - priority: 99
    scenario_id: "help"
    name: "帮助引导"
    patterns:
      - "(帮助|怎么用|你能干嘛|功能)"
    extract: []
    note: "帮助场景无对应文件，直接返回帮助文案"
```

---

## 2. 实体抽取规则

### 2.1 pr_no / po_no

```
PR 号格式：PR + 年月日 + 序号，如 PR20260523001
PO 号格式：PO + 年月日 + 序号，如 PO20260523001
提取正则：/(PR|PO)\d{8,14}/i
若用户只输入数字片段（如"0523001"），标记 confidence=low，走模糊匹配兜底
```

### 2.2 人名

```
提取规则：
1. 非停用词的 2-4 字中文连续字符
2. 排除已知关键词（"采购"、"申请"、"订单"、"本月" 等）
3. 通过 lookup-users cli 验证是否为有效员工（Step 4.5 归一化）
```

### 2.3 供应商名

```
提取规则：
1. 含"公司"、"有限"、"集团"、"科技"、"XX供应商" 等后缀的词组
2. 或被引号包裹的名称
3. 通过 lookup-suppliers cli 验证（Step 4.5 归一化）
```

### 2.4 品类

```
提取规则：
1. 已知品类词库匹配（IT设备、办公用品、服务器、笔记本、耗材、家具...）
2. 含"类"、"类型"后缀的词组
3. 通过 lookup-categories cli 验证（Step 4.5 归一化）
```

### 2.5 date_range

```
日期归一化（local_date_parser，不调 cli）：
  "本月"  → { start: 当月1日, end: 当月末日 }
  "上月"  → { start: 上月1日, end: 上月末日 }
  "本周"  → { start: 本周一, end: 本周日 }
  "上周"  → { start: 上周一, end: 上周日 }
  "本季度"→ { start: 本季首日, end: 本季末日 }
  "今年"  → { start: 1月1日, end: 12月31日 }
  "Q1-Q4" → 对应季度
  "最近N天/周/月" → 动态计算
```

### 2.6 status

```
状态关键词 → 枚举映射：
  "待审批" / "等审批"     → PENDING_APPROVAL
  "审批中"               → IN_APPROVAL
  "已驳回" / "被退回"     → REJECTED
  "已通过" / "已批准"     → APPROVED
  "待采购" / "未采购"     → PENDING_PURCHASE
  "已下单"               → ORDERED
  "未交付" / "待交货"     → PENDING_DELIVERY
  "待验收"               → PENDING_INSPECTION
  "待入库"               → PENDING_STORAGE
  "已完成" / "已结束"     → COMPLETED
```

---

## 3. LLM 决策树兜底

当硬规则未命中任何场景时，将以下指令喂给 LLM（Plan 阶段 #1 的前置判定）：

```
你是供应链采购助手的意图分类器。根据用户输入，从以下场景中选择最匹配的 1-2 个。

场景列表（ID 与 scenarios/ 目录文件对应）：
01. PR/PO精确查询 — 用户想查某个特定采购申请单或订单的详情/进度（PR 和 PO 合并在此场景）
02. 我的申请单   — 用户想看自己提交的采购申请
03. 我的订单     — 用户想看自己经手的采购订单
04. 需求人维度   — 用户想查某个人提交/申请的单据
05. 采购员维度   — 用户想查某个采购员经手/处理的单据
06. 供应商维度   — 用户想查某个供应商相关的订单
07. 品类维度     — 用户想查某个物资品类的采购情况
08. 周期统计     — 用户想看某段时间的采购数据汇总
09. 状态筛选     — 用户想按状态过滤单据
10. 模糊匹配     — 用户用模糊描述找单据
11. 待办概览     — 用户想知道有什么待处理的事项
12. 超期预警     — 用户想看哪些单据超期/逾期
13. 采购风险     — 用户想看供应商/合同/订单风险情况
14. 采购仪表盘   — 用户想看采购金额/数量等全局数据
15. 退货查询     — 用户想查退货单据的状态或列表
16. 合同查询     — 用户想查合同列表或到期情况
17. 库存查询     — 用户想查某个物料的库存/可用量
18. 物资申请查询 — 用户想查物资申请/领用的进度或列表
19. 安全库存预警 — 用户想看哪些物料低于安全库存
20. 物料价格查询 — 用户想查物料的历史价格或价格趋势
21. 物资调拨查询 — 用户想查调拨单的进度或列表
22. 资产处置查询 — 用户想查报废/处置单的进度或列表
23. 盘点查询     — 用户想查盘点计划、结果或差异
help. 帮助引导   — 用户在问怎么使用（无对应场景文件，直接返回帮助文案）

输出 JSON：
{
  "scenarios": [{ "id": "<场景ID，如 01/02/.../10/help>", "confidence": <0-1>, "reason": "<一句话>" }],
  "entities": { <提取到的实体键值对> }
}

如果完全无法判断，返回 { "scenarios": [{ "id": "help", "confidence": 1, "reason": "无法识别意图" }], "entities": {} }
```

---

## 4. 组合表述处理（多实体同时抽取）

用户经常在一句话里组合多个维度。系统必须支持同时抽取所有实体，而非只识别"主场景"的实体。

### 4.1 核心规则

```yaml
multi_entity_extraction:
  # 规则 1：所有可识别实体都必须抽取，不因"主场景"而丢弃其他实体
  rule: extract_all_recognized_entities

  # 规则 2：主场景 = 硬规则优先级最高的匹配（决定 cli_candidates 选择）
  primary_scenario: highest_priority_match

  # 规则 3：其余实体作为过滤条件，填入主场景的 optional_entities 对应参数
  secondary_entities: merge_into_params

  # 规则 4：若主场景的 cli_candidates.params_mapping 不支持某个 optional 实体，
  #         降级到支持该参数的场景（如场景 09 状态筛选的 cli 支持 status 参数）
  fallback: switch_to_broader_cli
```

### 4.2 抽取流程

```
输入："张三上个月被驳回的申请单"

Step 1 — 并行抽取所有实体：
  applicant_name: "张三"     (人名规则命中)
  date_range: "上个月"       (日期规则命中 → { start: 2026-04-01, end: 2026-04-30 })
  status: "被驳回"           (状态关键词命中 → REJECTED)

Step 2 — 确定主场景：
  硬规则命中：
    - 场景 04（需求人维度）priority=4 ← 人名 + 申请
    - 场景 09（状态筛选）priority=9 ← "被驳回"
    - 场景 08（周期统计）priority=8 ← "上个月"
  主场景 = 04（优先级最高）

Step 3 — 合并实体到主场景：
  场景 04 的 optional_entities 包含 [status, date_range, category]
  → status=REJECTED 和 date_range 都可合并
  → 最终 extracted_entities = { applicant_name: "张三", status: REJECTED, date_range: {...} }

Step 4 — Plan 阶段 params_mapping：
  cli: /purchaseApply/list (或 /mPurchaseApply/mlist)
  params: { applicantId: <张三的user_id>, status: REJECTED, startDate: 2026-04-01, endDate: 2026-04-30 }
```

### 4.3 更多组合示例

```yaml
examples:
  - input: "IT设备本月花了多少"
    entities: { category: "IT设备", date_range: "本月" }
    primary: "07"  # 品类维度（priority=7 < 周期统计 priority=8，但品类是名词锚点优先）
    note: "当品类+周期同时出现，品类为主场景（名词锚点 > 时间修饰）"

  - input: "审批中的订单有哪些"
    entities: { status: "审批中" }
    primary: "09"  # 状态筛选
    note: "单一实体，直接走对应场景"

  - input: "深圳奥雅上个月的订单"
    entities: { supplier_name: "深圳奥雅", date_range: "上个月" }
    primary: "06"  # 供应商维度
    note: "供应商为主锚点，date_range 作为过滤条件"

  - input: "马家辉处理的被驳回的单子"
    entities: { handler_name: "马家辉", status: "被驳回" }
    primary: "05"  # 采购员维度
    note: "handler 为主锚点，status 作为过滤条件"
```

### 4.4 主场景判定优先级（名词锚点 > 时间/状态修饰）

```yaml
anchor_priority:
  # 名词锚点（决定"查什么"）— 优先级高
  - pr_no / po_no        # 精确单号永远最高
  - applicant_name       # 人名
  - handler_name         # 采购员名
  - supplier_name        # 供应商名
  - category             # 品类名

  # 修饰条件（决定"怎么过滤"）— 作为 optional 合并
  - status               # 状态
  - date_range           # 时间范围
  - keyword              # 模糊关键词

  # 判定规则：
  # 1. 有名词锚点 → 主场景由最高优先级的名词锚点决定
  # 2. 只有修饰条件 → 按硬规则 priority 排序选主场景
  # 3. 多个名词锚点 → 取 priority 最高的（如同时有人名+品类，人名优先）
```

### 4.5 场景文件 optional_entities 与 params_mapping 对齐要求

每个场景的 `cli_candidates.params_mapping` 必须覆盖该场景声明的所有 `optional_entities`：

```yaml
# 场景 04 示例（已对齐）：
optional_entities: [status, date_range, category]
cli_candidates:
  - params_mapping:
      applicantId: applicant.user_id
      status: status                    # ← 覆盖 optional status
      startDate: date_range.start       # ← 覆盖 optional date_range
      endDate: date_range.end
      categoryCode: category.code       # ← 覆盖 optional category（新增）
```

若某个 optional_entity 在 params_mapping 中无对应字段，说明后端不支持该组合过滤，应从 optional_entities 中移除或标注 `unsupported`。
