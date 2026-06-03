---
name: tcoa-context
description: "[内部 skill，由 tcoa-router 链式调用，不应独立触发] TCOA 当前需求上下文识别与状态加载。判定 intentMatch、changeSize、mode、tools，校验 phase。intentMatch=新需求时执行新需求初始化子流程。多会话并行时通过 session lock 锁定 focused，避免串台。"
---

# tcoa-context

> 所有 tcoa-* skill 的共用前置。

## 强制前置
1. 读取 tcoa-flow-state/SKILL.md 加载状态机
2. 读取 `.tcoa/project-config.json` 获取 requirementsRoot
3. 读取 `.tcoa/current-context.json`：
   - schemaVersion=3：仅含 active 数组，**无 focused 字段**
   - schemaVersion=2：自动迁移（删除 focused 字段，schemaVersion 改为 3）
   - 旧格式（含 requirementId 单条）：自动迁移为 schemaVersion=3
4. 解析 session focused（详见下节"会话级 focused 锁定协议"）
5. 根据 sessionFocused 读取 `<requirementsRoot>/<requirementId>/execution-state.json`
6. 校验 phase 合法性

### 多需求交互逻辑
- active 只有 1 个 → 自动作为 sessionFocused，写 lock
- active 多个 + 用户未指明 → AskUserQuestion 选择 → 写 lock
- 新需求 → 追加到 active，sessionFocused = 新需求 → 写 lock
- 需求完成 → 从 active 移除，删除对应 lock

## 会话级 focused 锁定协议（防多会话串台）

**核心原则**：focused 不存在 `current-context.json`，仅存在每个会话独立的 lock 文件。

### Lock 文件结构

```
.tcoa/sessions/
├── <createdAt>-<requirementId>.lock      # 例：2026-05-09T103045+0800-asset-repair.lock
└── ...
```

Lock 文件内容（JSON）：
```json
{
  "requirementId": "2026-04-30_asset-repair-management_v1.0",
  "createdAt": "2026-05-09T10:30:45+08:00",
  "cwd": "D:/Projects/TCOA.SCM"
}
```

### 协议步骤

**Step 1：会话首次进入 tcoa-context 时，先扫描 lock**

1. 列 `.tcoa/sessions/*.lock`
2. **清理过期 lock**：`createdAt` 超过 12 小时的，删除（不询问，直接清）
3. 列剩余有效 lock

**Step 2：决定 sessionFocused**

按优先级判断：

| 优先级 | 条件 | 动作 |
|---|---|---|
| P0 | 用户输入显式指定（如 `/tcoa asset-repair`、`继续 alert-monitor`） | 锁定到指定需求；若无对应 lock 则新建 lock；若有别人的 lock 也允许（多会话并行） |
| P1 | 仅有一个有效 lock 且其 requirementId 在 active[] 中 | 主动告知用户："检测到本目录最近 lock 在 X 需求，本次也在 X 上继续？" → AskUserQuestion 确认 |
| P2 | active[] 只有 1 个需求 | 自动锁定，新建 lock |
| P3 | active[] 多个需求 + 无明确指示 | AskUserQuestion 必选 → 写 lock |
| P4 | active[] 为空 | sessionFocused=null，phase=uninitialized |

**Step 3：会话内后续 tcoa-* 调用**

- sessionFocused 由会话上下文携带（TaskCreate metadata 或对话状态）
- **若会话内已确定 sessionFocused，不重新扫 lock**
- 仅在会话首次或 compact 后丢失上下文时重走 Step 1-2

**Step 4：会话结束 / 需求完成**

- 需求 phase 变为 `completed` → 从 active[] 移除 + 删除对应 lock
- 会话主动 abort → 删除对应 lock
- 其他情况 lock 保留，靠 12h 过期清理

### Lock 命名规则

`<createdAt-ISO8601紧凑格式>-<requirementId>.lock`

createdAt 格式示例：`2026-05-09T103045+0800`（去掉冒号便于跨文件系统兼容）

## 核心判定

### 1. intentMatch
| 优先级 | 输入特征 | 结论 |
|---|---|---|
| P0 | "新需求/新建" | 新需求 |
| P1 | "继续/接着做" | 续跑 |
| P2 | context 不存在 | 新需求 |
| P3 | 关键词重叠 ≥2 | 续跑 |
| P4 | 关键词重叠 = 0 | 新需求 |
| P5 | 无法判断 | 不确定 → AskUserQuestion |

### 2. changeSize（推荐后等用户确认）

AI 根据需求描述自动推荐档位，输出：

```
推荐档位：<trivial|small|medium|large>（<理由一句话>）
对应工件：<最小工件列表>
确认？或输入其他档位：
```

等用户确认或修改后再继续。trivial 场景可跳过确认直接执行。

| 档位 | 判定标准 | 最小工件 |
|---|---|---|
| trivial | 单点修复、≤30行、单文件 | `tasks.md` + review 摘要 |
| small | ≤3文件 | `proposal.md` + `design.md` + `tasks.md` + `review.md` |
| medium | 跨模块 | small 档 + `context.md` |
| large | 架构级、前后端联动 | medium 档 + `test.md` + `uat.md` |

### 3. mode
auto（默认）/ manual（用户要求一步步）

### 4. tools
默认 [gsd]；large 默认 [gsd, openspec]；从 registry 检查 installed

## LESSONS 被动检索（新需求初始化时）

intentMatch=新需求 时，在初始化前执行一次轻量检索：

1. 提取关键词：模块名、操作类型（如 `asset-repair`、`freeze`、`controller`）
2. `grep -i "<关键词>" requirements/LESSONS.md -C 3`，最多取 10 条匹配
3. **过滤时间衰减**：跳过 `lastHitAt` 超过 90 天且 `hits=0` 的条目
4. 若有命中，仅展示每条的 `**结论**` 行，提示用户参考
5. 命中后更新该条目的 `hits+1` 和 `lastHitAt=今日`
6. 无命中则静默跳过

> 详细检索规范见 `requirements/LESSONS.md` 头部说明。

## 新需求初始化子流程
当 intentMatch=新需求 且 phase ∈ {uninitialized, completed}：
1. 提取 name/slug/version/mode/tools/changeSize
2. 按 changeSize 生成最小产物集
3. 调用脚手架创建目录
4. **【新增】读取 grill-result（若存在）**
   - 检查 `.tcoa/grill-result.json` 是否存在且未过期（createdAt < 1 小时）
   - 若存在，提取 bizCode/bizName/coreEntities/coreServices/coreControllers/frontendDir
   - 写入 proposal.md §代码上下文
   - 读取后删除 `.tcoa/grill-result.json`（一次性消费）
5. 写入 execution-state.json（phase=initialized）
6. 追加到 `current-context.json` active[]
7. **写入新的 session lock 文件，sessionFocused = 新需求**
8. 写入 context-snapshot.md 和 metadata.json
9. **从 `requirements/_template/` 复制模板文件**：按 changeSize 复制对应工件模板（proposal.md/design.md/tasks.md/decisions.md/lessons.md），已存在的文件不覆盖
10. 询问是否建分支（changeSize ≥ small）

changeSize=trivial 跳过本子流程。

**前端需求额外工件**：需求描述涉及页面/组件/UI 改动时，在 small 及以上档位追加 `ui-design.md`（布局、交互、组件结构说明）。

**grill-result 未命中时**：若 `.tcoa/grill-result.json` 不存在或已过期，proposal.md §代码上下文 留空，由 tcoa-execute 阶段的 GitNexus 预检兜底。

## 输出契约
```
[skill: tcoa-context]
[phase-before: <phase>] → [phase-after: <phase>]
[mode: auto|manual] [changeSize: ...] [tools: gsd,...]
[intentMatch: 续跑|新需求|不确定]
[sessionFocused: <requirementId>] [activeCount: <N>] [lockFile: <filename>]
[next-skill: tcoa-context(init)|tcoa-execute|tcoa-review|tcoa-git-flow]
```

## 必须 AskUserQuestion 的场景
1. intentMatch=不确定
2. phase ∈ {paused, review-failed} 且用户给出新请求
3. requirementPath 已删除
4. 多个 active 需求未指明操作哪个
5. **检测到本目录有未过期 lock + 用户未显式指定 → 确认是否续用该 lock**

## 不做的事
- 不修改 phase（本 skill 前后一致）
- 不执行工具链
- 不在 intentMatch 不确定时擅自决策
- **不读写 `current-context.json` 的 focused 字段（该字段已废弃）**

## 详细参考 → 见 REFERENCE.md

