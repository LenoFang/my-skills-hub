# TCOA 持久化规范（引用文档）

> 本文件**不是 skill**，不会被 skill 加载链自动加载。各 tcoa-* skill 在需要时按需读取。
>
> 从 `tcoa-flow-state` §十/§十一 提取，作为统一持久化格式参考。状态机定义仍在 `tcoa-flow-state/SKILL.md`。

---

## 一、context-snapshot.md（会话上下文持久化）

> 解决跨会话/跨窗口续跑时丢失「用户原始描述、关键词、已查询代码上下文」的问题。`execution-state.json` 只管 phase 等结构化状态，**业务知识与会话上下文一律写入 `context-snapshot.md`**。

### 1.1 文件位置与归属
- 路径：`<requirementPath>/context-snapshot.md`
- 由 `tcoa-context`（新需求初始化子流程）创建，由所有 tcoa-* skill 在退出/关键节点追加
- trivial 快速路径**不创建**此文件（无需求目录）

### 1.2 文件结构（固定模板）
```markdown
# Context Snapshot — <requirementId>

> 本文件记录会话上下文。每次 skill 切换或重大查询节点会自动追加。开新窗口续跑时由 tcoa-context 读取并注入上下文。

## 1. 需求概要
- **原始描述**：<用户首次输入>
- **关键词**：<逗号分隔，最多 20 个>
- **涉及模块/文件**：<逗号分隔，动态更新>
- **changeSize 初判**：<trivial|small|medium|large>
- **mode**：<auto|manual>
- **tools**：<gsd, openspec, ...>

## 2. 用户补充输入（按时间倒序）
- [YYYY-MM-DDTHH:mm:ss+08:00] <一句话摘要>
- ...

## 3. 已查询代码上下文
- <file_path:line> — <一句话说明>
- ...

## 4. 关键决策与已排除方案
- [YYYY-MM-DDTHH:mm:ss+08:00] 决策：<内容> | 理由：<一句话>
- ...

## 5. Skill 切换轨迹
- [YYYY-MM-DDTHH:mm:ss+08:00] <from-skill> → <to-skill> | 进展：<一句话>
- ...

## 6. Review/Git 摘要
- [YYYY-MM-DDTHH:mm:ss+08:00] review-<结果>：CRITICAL:N HIGH:N MEDIUM:N LOW:N | 简评：<一句话>
- [YYYY-MM-DDTHH:mm:ss+08:00] git-<动作>：<分支|commit hash> | 备注：<一句话>

## 7. Doc Status（双目录文档状态）

> 跟踪 `requirements/<id>/` 与 `openspec/changes/<slug>/` 两侧文档的完成度。仅在 tools 含 `openspec` 时维护；纯 GSD 项目可保留空表或省略本节。

| 文档 | requirements/ | openspec/changes/ | 主写入位置 |
|---|---|---|---|
| proposal.md | ☐ | ☐ | openspec |
| spec.md | ☐ | ☐ | openspec |
| design.md | ☐ | ☐ | requirements |
| tasks.md | ☐ | n/a | requirements |
```

### 1.3 写入时机（批量优先）

> **核心原则**：减少写入频率，避免 context window 耗尽和权限弹窗疲劳。除 §1 初始化外，所有写入均采用**退出 skill 时批量写入**策略。

#### 1.3.1 即时写入（仅 1 次，skill 生命周期内不重复）
| 时机 | 写入哪一节 | 写入者 |
|---|---|---|
| 需求初始化完成 | §1 全段 + §5 首条 + §7 初始化全 ☐ | `tcoa-context`（新需求初始化子流程） |

#### 1.3.2 退出 skill 时批量写入（每个 skill 退出前合并为 1 次 Edit）
| 累积内容 | 写入哪一节 | 写入者 |
|---|---|---|
| 用户本轮新输入（关键词新增） | §2 追加；§1「关键词/涉及模块」去重合并 | `tcoa-router` 或 `tcoa-context` |
| 本 skill 内所有 skill 切换记录 | §5 批量追加（按时间排序） | 退出的 skill |
| 本 skill 内查询代码的重要发现（攒满 5 条或退出时） | §3 批量追加（带 file:line） | `tcoa-execute`（auto/manual 模式分支） |
| 本 skill 内用户做出的方案选择/排除 | §4 批量追加 | 当前 skill |
| review 结论 | §6 追加一行 | `tcoa-review` |
| git 操作完成 | §6 追加一行 | `tcoa-git-flow` |
| 本 skill 内所有文档完成状态变更 | §7 一次性勾选所有已完成文档 | 退出的 skill |

#### 1.3.3 实现要求
- 每个 skill 在内存中维护 `pendingSnapshotUpdates` 对象（按 §1-§7 分桶累积）
- **退出 skill 前**（写 phase 流转之前）将所有 pending 合并为**单次 Edit** 写入 `context-snapshot.md`
- 若 pending 为空则不写入（`snapshot-updated: no`）
- §3 代码发现：累积满 5 条时可提前刷盘一次（避免 skill 异常退出丢失过多信息），但不强制
- §7 Doc Status：退出时一次性将所有已完成文档从 ☐ 改为 ☑，仅需 1 次 Edit（不再逐个勾选）
- 写入失败不阻塞主流程，但必须在 changelog 记录写 snapshot 失败的原因

### 1.4 读取时机（强制）
- `tcoa-context` 在加载完 `execution-state.json` 后**必须**读取 `context-snapshot.md`，并把以下字段注入返回的统一上下文对象：
  - `snapshot.originalRequest`（§1 原始描述）
  - `snapshot.keywords`（§1 关键词）
  - `snapshot.involvedModules`（§1 涉及模块/文件）
  - `snapshot.recentMessages`（§2 最近 5 条）
  - `snapshot.discoveredContext`（§3 最近 10 条）
  - `snapshot.decisions`（§4 全部）
  - `snapshot.lastSkillTransition`（§5 最末一行）
  - `snapshot.docStatus`（§7 表的解析结果，形如 `{proposal:{requirements:bool,openspec:bool,primary:'openspec'}, ...}`）
- 文件不存在时不报错，置空对象，仅在 warnings 中提示「snapshot 缺失」

### 1.5 长度与裁剪规则
- 单文件软上限：**500 行**或 **40KB**
- 超过软上限时由下次写入的 skill 执行裁剪：
  - §2 用户补充输入：保留最近 30 条
  - §3 已查询代码上下文：保留最近 50 条（按访问时间）
  - §5 Skill 切换轨迹：保留最近 50 条
  - §1 关键词列表：去重后保留最近 20 个
  - §4 关键决策：**全部保留**（决策不裁剪）
  - §6 Review/Git 摘要：**全部保留**
  - §7 Doc Status：**永不裁剪**（结构化状态表，体积固定）
- 裁剪前先备份到 `<requirementPath>/.backup-snapshot-<timestamp>.md`

### 1.6 输出契约扩展
所有写过 snapshot 的 skill 必须在输出契约中追加一行：
```
[snapshot-updated: yes|no] [snapshot-sections: §1,§2,§5]
```
> 注：`snapshot-sections` 列出的章节因写入者职责不同而异（如 requirement-init 写 §1,§5,§7；execute 写 §3,§5,§7）。上行仅为示例。

### 1.7 关键词提取规则（与 tcoa-context §1 一致）
- 中文：jieba 风格切词，去停用词，最少 2 字
- 英文：split + 小写，最少 3 字
- 同一词根仅保留一个（如 "查询/查询性能" 取「查询」）
- 与 §1 已有关键词去重后合并

### 1.8 不做的事
- 不把代码片段大段贴入 §3（仅 file:line + 一句话说明）
- 不在 snapshot 中记录敏感信息（token、密码、内部 IP）
- 不替代 changelog.md（changelog 记动作，snapshot 记上下文知识）
- 不在 trivial 快速路径创建 snapshot

---

## 二、metadata.json（需求级元数据）

> 需求级元数据。**不被 tcoa-context 主动注入上下文**，仅在需要时由对应 skill 按需读取。结构化字段一律放这里，避免污染 snapshot 和 execution-state。

### 2.1 文件位置
- 路径：`<requirementPath>/metadata.json`
- 由 `tcoa-context`（新需求初始化子流程）创建，由各 skill 按需更新
- trivial 快速路径**不创建**

### 2.2 固定字段
```json
{
  "requirementId": "2026-04-25_alert-monitor_v1.0",
  "name": "告警监控",
  "slug": "alert-monitor",
  "version": "1.0",
  "changeSize": "medium",
  "mode": "auto",
  "tools": ["gsd", "openspec"],
  "linkedOpenSpecChange": "openspec/changes/alert-monitor",
  "archived": false,
  "reviewFailCount": 0,
  "degradationCount": 0,
  "e2eStatus": null,
  "buildCheckStatus": null,
  "createdAt": "2026-04-25T09:00:00+08:00",
  "completedAt": null,
  "archivedAt": null,
  "updatedAt": "2026-04-25T09:00:00+08:00"
}
```

### 2.3 字段语义
| 字段 | 类型 | 含义 | 写入者 |
|---|---|---|---|
| `requirementId` | string | 需求唯一标识，与目录名一致 | tcoa-context(init) |
| `name` / `slug` / `version` | string | 需求基础信息 | tcoa-context(init) |
| `changeSize` | enum | trivial/small/medium/large | tcoa-context(init) / 实测升级时改写 |
| `mode` | enum | auto/manual | tcoa-context(init) / 模式切换时改写 |
| `tools` | string[] | 工具链 | tcoa-context(init) |
| `linkedOpenSpecChange` | string/null | 关联的 openspec change 目录（仅引用路径，不复制内容）；仅在 tools 含 `openspec` 时由 tcoa-context(init) 写入，纯 GSD 项目为 null | tcoa-context(init) |
| `archived` | boolean | 是否归档（true 时 current-context 不再指向此目录） | git-flow archive 子流程 |
| `reviewFailCount` | int | review 失败次数累计 | review |
| `degradationCount` | int | 降级次数累计（与 execution-state.degradations.length 一致） | execute（auto/manual 分支） |
| `e2eStatus` | enum/null | null \| pass \| fail \| skipped | review（e2e 子流程） |
| `buildCheckStatus` | enum/null | null \| pass \| fail \| skipped | review |
| `createdAt` / `completedAt` / `archivedAt` / `updatedAt` | ISO8601 | 时间戳 | 各 skill 按动作写入 |

### 2.4 写入约束
- 只追加/改写本表定义的字段，**禁止写入业务知识**（业务知识写 snapshot）
- 每次写入必须刷新 `updatedAt`
- `reviewFailCount` 和 `degradationCount` 仅累加，不重置（用于跨轮统计）
- `archived = true` 后**禁止任何 skill 继续修改本文件**（除非用户显式恢复）

### 2.5 读取时机
- `tcoa-context`：仅在需要 archived 标志判断续跑时读取（不注入上下文）
- `tcoa-review`：读取 reviewFailCount 决定是否强制人工
- `tcoa-git-flow archive`：读取并写入 archived/archivedAt
- 其他 skill 仅按本表「写入者」职责更新对应字段

### 2.6 与 execution-state.json 的边界
- **execution-state.json**：当前 phase、skillChain、reviewStatus、gitStatus 等**会话期状态**
- **metadata.json**：requirement 级**长期元数据**，跨会话/跨 review 轮次不变
- 同名字段（如 reviewFailCount）以 metadata.json 为权威，execution-state 仅做缓存
