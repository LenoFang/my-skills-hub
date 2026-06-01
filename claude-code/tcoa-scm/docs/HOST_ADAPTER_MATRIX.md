# TCOA Skills 宿主适配矩阵（联调版）

## 目的
说明这套 skill 在不同代理环境中的推荐放置位置、联调重点、推荐模式和失败回退策略。

> 说明：本矩阵是联调指导文档，不代表所有宿主已经全部实测通过。它的目标是让你能按宿主逐项验证，而不是停留在概念说明。

---

## 1. 当前推荐结构

### 宿主识别入口
放在父级 `.claude/skills/` 下一层目录：

- `tcoa-router`
- `tcoa-context`
- `tcoa-requirement-init`
- `tcoa-auto-execute`
- `tcoa-manual-guide`
- `tcoa-review`
- `tcoa-git-flow`

### 文档与桥接集合
放在：

- `.claude/skills/tcoa-scm/`

该目录负责：
- 部署说明
- 使用说明
- 状态机说明
- 命令插件映射表
- 宿主联调清单
- 桥接脚本 `bin/tcoa-scaffold.ps1`

### 为什么这样分
- 现有其他项目 skill 也是 root-level 一层目录
- 有些宿主可能只扫描 `skills` 下一层目录
- `tcoa-scm` 更适合作为说明文档和桥接集合，而不是唯一入口

---

## 2. 宿主总表

| 宿主环境 | 宿主入口 | 文档/桥接位置 | 当前推荐模式 | 自动触发 skill | 自动调用插件命令 | 当前建议 |
|---|---|---|---|---|---|---|
| Claude Code | root-level `tcoa-*` | `tcoa-scm` | auto + manual | 待验证 | 待验证 | 优先联调 |
| Cursor | root-level `tcoa-*` | `tcoa-scm` | manual 优先 | 待验证 | 待验证 | 先半自动 |
| Copilot | root-level `tcoa-*` | `tcoa-scm` | manual 优先 | 待验证 | 待验证 | 先规则文档模式 |
| Codex | root-level `tcoa-*` | `tcoa-scm` | manual 优先 | 待验证 | 待验证 | 先规则文档模式 |

---

## 3. Claude Code

### 推荐模式
- 先尝试 `auto`
- 若自动不稳定，立即回退 `manual`

### 联调步骤
1. 在仓库父级目录打开会话。
2. 发起一个“新需求 / 继续需求 / 用 OpenSpec + GSD 做某需求”的对话。
3. 观察是否体现 `tcoa-router` 的分流思路：
   - 先识别上下文
   - 再判断新建还是续跑
   - 再判断 auto/manual
4. 验证是否能自然引用 root-level `tcoa-*` skill。
5. 若宿主支持自动调用插件命令，再继续验证：
   - `OpenSpec`
   - `Superpowers`
   - `GSD`
6. 最后验证本地桥接脚本是否能把状态与文档落盘。

### 通过标准
- 能识别 root-level `tcoa-*`
- 至少能稳定进入 `tcoa-router` / `tcoa-context` 的流程语义
- 至少能通过桥接脚本完成状态与文档落盘

### 失败回退
- 若不能自动调插件命令：改为 skill 提示命令、用户手动执行
- 若连 skill 识别都不稳定：按 `tcoa-scm` 文档集合手工走流程

---

## 4. Cursor

### 推荐模式
- `manual` 优先

### 联调步骤
1. 先验证 root-level `tcoa-*` 是否能被当作规则使用。
2. 发起一个需求实现对话，观察是否至少出现：
   - 模式识别
   - 工具识别
   - 新建/续跑判断
3. 再验证是否支持“skill 提示下一条命令”。
4. 最后用桥接脚本检查状态和文档落盘。

### 通过标准
- 能把 skill 当作流程规则使用
- 能把下一条命令和预期产物提示出来
- 能通过桥接脚本落盘状态与文档

### 失败回退
- 将 Cursor 作为“规则说明 + 手动命令执行”的宿主使用

---

## 5. Copilot

### 推荐模式
- `manual`

### 联调步骤
1. 先验证 root-level `tcoa-*` 是否能被会话自然参考。
2. 再验证是否能在需求对话中体现：
   - 先上下文判断
   - 再模式判断
   - 再下一步建议
3. 验证桥接脚本能否在你实际工作目录中稳定执行。

### 通过标准
- 至少能把 skill 当作规则说明使用
- 能结合桥接脚本完成落盘

### 失败回退
- 直接把 `tcoa-scm` 文档集合当操作手册使用

---

## 6. Codex

### 推荐模式
- `manual`

### 联调步骤
1. 先验证是否会读取 `.claude/skills/` 下 root-level `tcoa-*`。
2. 再验证是否能承接上一条命令返回结果继续推进。
3. 最后验证桥接脚本与 `execution-state.json` 是否可正常工作。

### 通过标准
- 能引用 skill 规则
- 能结合桥接脚本推进状态与文档

### 失败回退
- 与 Copilot 同样，先按“规则文档 + 手动执行命令”模式使用

---

## 7. 自动 / 半自动判断标准

### 可进入 auto 的条件
满足以下越多，越适合 `auto`：
- 宿主能稳定识别 root-level `tcoa-*`
- 宿主能自动调用插件命令
- 宿主能承接上一条命令结果继续推进
- 本地桥接脚本稳定可执行

### 应先走 manual 的条件
出现以下任一情况，建议优先 `manual`：
- 宿主不能自动调插件命令
- 宿主不能稳定承接上一条命令结果
- 宿主只能把 skill 当规则文档

---

## 8. 当前最需要验证的点

1. 父级 `.claude` 是否会被目标宿主自动加载
2. root-level `tcoa-*` 是否会被宿主按目录识别
3. 宿主是否允许 agent 自动发起：
   - `/superpowers:*`
   - `/opsx:*`
   - `/gsd-*`
   - `/e2e`
4. 命令执行后的返回结果，宿主是否允许 skill 继续承接

---

## 9. 当前结论

### 已可以确定的
- skill 内容本身应保持通用，不绑定单一宿主
- 当前最佳结构是：root-level `tcoa-*` + `tcoa-scm` 文档集合并存
- 当前最佳结构是：root-level `tcoa-*`（含 `tcoa-review`）+ `tcoa-scm` 文档集合并存
- `tcoa-scaffold` 继续作为本地底座保留

### 仍需联调确认的
- 自动触发能力
- 自动命令调用能力
- 多步命令链的宿主承接能力

因此，下一步最应该做的是：
- 先做宿主联调
- 再决定哪些环境可进 `auto`
- 哪些环境先走 `manual`
