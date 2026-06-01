# tcoa-context REFERENCE

> 本文件是 `tcoa-context/SKILL.md` 的详细补充参考，按需读取。

## 通用化注记（移植到其他项目时）

`tcoa-*` 系列 skill 的协议本身是**通用流程框架**，与 TCOA.SCM 业务无关。要移植到新项目时区分：

| 类别 | 内容 | 通用 / 专属 |
|---|---|---|
| 状态机协议 | phase 枚举、流转、门禁规则（tcoa-flow-state） | **通用** |
| Session lock 协议 | 多会话隔离、12h 过期 | **通用** |
| 决策树（router） | intentMatch / changeSize / mode 路由 | **通用** |
| 复查框架 | 决定性 vs 启发式两类、R-FORCE-003 | **通用** |
| Token Pressure Mode | 压缩输出规则 | **通用** |
| `.tcoa/` 路径 | 状态文件存放 | 可改名（如 `.flow/`） |
| `/tcoa` 命令名 | 显式入口触发词 | 可改名 |
| `business-rules-mapping` 引用 | 项目业务知识 | **TCOA 专属**——靠"领域 skill 契约"解耦（详见 `docs/skills-research/04-tcoa-as-generic-template.md`） |

**领域 skill 契约**：tcoa-grill 等 skill 在需要业务定位时，按惯例查找 `business-rules-mapping`、`*-domain-knowledge`、`*-business-rules`、`*-feature-map` 等命名的 skill；缺失则降级为 grep + AskUserQuestion，不报错。

详细移植步骤见 `docs/skills-research/04-tcoa-as-generic-template.md`。

## current-context.json 格式（schemaVersion 3）

```json
{
  "schemaVersion": 3,
  "active": [
    { "requirementId": "req-A", "phase": "executing-auto", "updatedAt": "..." },
    { "requirementId": "req-B", "phase": "awaiting-review", "updatedAt": "..." }
  ]
}
```

**关键变化（v2 → v3）**：移除 `focused` 字段。focused 由每个会话独立的 lock 文件维护，避免多会话并行时全局字段被互相覆盖。

迁移规则：
- 旧 schemaVersion=2（含 focused）：删除 focused 字段，schemaVersion 改为 3
- 旧格式（含顶层 requirementId 字段）：转换为单条目 active 数组，schemaVersion=3

## Session Lock 详细规范

### 目录结构
```
.tcoa/sessions/
├── 2026-05-09T103045+0800-asset-repair.lock
├── 2026-05-09T141220+0800-alert-monitor.lock
└── ...
```

### Lock 文件 schema
```json
{
  "requirementId": "2026-04-30_asset-repair-management_v1.0",
  "createdAt": "2026-05-09T10:30:45+08:00",
  "cwd": "D:/Projects/TCOA.SCM"
}
```

### 过期清理
- 默认过期时间：12 小时
- 清理触发点：tcoa-context 首次进入时
- 清理策略：直接删除，不通知用户（过期 lock 视为无效）
- 不做主动后台清理（依赖会话进入）

### 多会话并行示意
```
窗口 A：会话开始 → 锁 asset-repair → lock-A.lock
窗口 B：会话开始 → 列 lock 看到 lock-A.lock 在 asset-repair
        → 询问 / 用户选 alert-monitor → 锁 alert-monitor → lock-B.lock
窗口 A、B 各自独立推进，互不干扰
窗口 A 完成需求 → 删除 lock-A.lock
窗口 B 仍持续，lock-B.lock 保留
```

### 与 active[] 的关系
- active[] 是"全局有哪些需求在进行中"
- session lock 是"本会话锁定了哪个 active"
- 一个 active 可被多个会话同时锁定（不冲突，因为状态机操作的是 execution-state.json，按 requirementId 物理隔离）
- active 移除一个需求时，对应 lock 也要删

### 何时不需要 lock
- changeSize=trivial 的快速路径不写 lock（不会进入 active[]）
- 仅查询类操作（如 `tcoa list`）不写 lock

## intentMatch 判定详细

关键词提取规则：去除停用词后，取名词/动词词根，最少长度 2 字符（中文）或 3 字符（英文）。

## changeSize 判定信号

| 级别 | 判定信号 |
|---|---|
| trivial | "改个文案"、"改个 bug"、"加个日志"、单文件单点 |
| small | "加个字段"、"小功能"、单模块 ≤3 文件 |
| medium | "新功能"、"新增页面"、跨 2-3 模块 |
| large | "重构"、"新模块"、"架构调整"、跨 ≥4 模块 |

判定不清时按 medium 处理并标注 confidence: low。

## mode 判定详细
- "全自动 / 不用确认 / 直接做" → auto
- "半自动 / 一步步 / 每步确认" → manual
- 未明确 + changeSize ∈ {trivial, small} → auto
- 未明确 + changeSize ∈ {medium, large} → auto（但建议提示用户考虑 manual）

## tools 判定详细
- OpenSpec → 加 openspec
- Superpowers → 加 superpowers
- GSD → 加 gsd
- 未指定 → 默认 [gsd]
- changeSize=large 且未指定 → 默认 [gsd, openspec]

## 新需求初始化子流程详细

### 进入条件
- intentMatch=新需求
- phase ∈ {uninitialized, completed} 直接进入
- phase 处于其他状态 → AskUserQuestion 决定：归档/暂停/取消
- changeSize=trivial 跳过

### changeSize 决定的最小产物

| changeSize | 生成文件 |
|---|---|
| trivial | 跳过本子流程 |
| small | metadata.json, changelog.md, raw-requirement.md, tasks.md, execution-state.json, logs/ |
| medium | 上述 + proposal.md, implementation/, generated/ |
| large | 上述 + spec.md(若含 openspec) + design.md(若含 superpowers) |

### execution-state.json 初始内容
```json
{
  "schemaVersion": 2,
  "requirementId": "<id>",
  "phase": "initialized",
  "previousPhase": "uninitialized",
  "mode": "<auto|manual>",
  "tools": ["gsd"],
  "changeSize": "<medium>",
  "skillChain": [...],
  "reviewStatus": {"required": true, "completed": false, "result": null, "findings": []},
  "gitStatus": {"branchCreated": false, "branchName": null, "committed": false, "pushed": false, "merged": false},
  "nextSuggestedSkill": "tcoa-execute",
  "degradations": [],
  "updatedAt": "..."
}
```

### context-snapshot.md 初始化
- §1 填入用户原始描述、关键词、涉及模块、changeSize、mode、tools
- §5 首条 skill 切换记录
- §7 Doc Status 表（仅 tools 含 openspec 时完整）

### metadata.json 初始化
- 填入 requirementId/name/slug/version/changeSize/mode/tools/createdAt
- 仅 tools 含 openspec 时写入 linkedOpenSpecChange

### 推荐命令
```bash
powershell.exe -ExecutionPolicy Bypass -File ".claude/skills/tcoa-scm/bin/tcoa-scaffold.ps1" init-requirement --name "<名称>" --slug "<slug>" --version "1.0" --tools "gsd,openspec"
```

## 返回的统一上下文对象
```json
{
  "projectRoot": "...",
  "requirementsRoot": "...",
  "requirementId": "...",
  "requirementPath": "...",
  "phase": "awaiting-review",
  "mode": "auto",
  "tools": ["gsd"],
  "changeSize": "medium",
  "intentMatch": "续跑",
  "sessionFocused": "...",
  "lockFile": ".tcoa/sessions/2026-05-09T103045+0800-asset-repair.lock",
  "snapshot": { "originalRequest": "...", "keywords": [...], "involvedModules": [...] },
  "warnings": []
}
```

## snapshot 增量更新（续跑场景）
intentMatch=续跑 后，将本次用户输入关键词与 snapshot §1 关键词去重合并，§2 追加用户补充输入摘要（≤80 字）。
