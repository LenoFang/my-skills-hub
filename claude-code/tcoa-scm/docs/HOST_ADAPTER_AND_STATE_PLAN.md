# TCOA Skills 下一阶段计划：宿主适配与状态机

## 目标
补齐当前 skill 体系中最关键但尚未最终落地的两层能力：

1. **宿主适配层**：不同代理环境如何加载、触发、执行这些 skill
2. **状态机层**：如何承接带动态参数的命令链，避免用户手工维护 phase 编号等状态

---

## 一、当前已完成

### 已有能力
- skill 入口与分流：`tcoa-router`
- 上下文识别：`tcoa-context`
- 需求初始化：`tcoa-requirement-init`
- 全自动/半自动执行说明：`tcoa-auto-execute` / `tcoa-manual-guide`
- 本地底座：`tcoa-scaffold`
  - 配置管理
  - 需求目录初始化
  - 当前上下文持久化
  - 执行日志
  - 标准文档回填

### 当前缺口
- 不同宿主环境是否支持 skill 自动触发，尚未逐一验证
- 不同插件命令是否允许 agent 自动发起，尚未逐一验证
- phase 编号、步骤编号等动态参数还没有标准化状态承接机制

---

## 二、Phase 1：宿主适配说明

### 要解决的问题
- skill 放项目内、父级、全局时，各宿主的加载范围是什么
- 哪些宿主支持自动调用 skill
- 哪些宿主只能把 skill 当规则文档
- 哪些宿主能自动调用 `/superpowers:*`、`/opsx:*`、`/gsd-*` 这类命令

### 交付物
1. 宿主适配矩阵文档
2. 每个宿主的推荐放置位置
3. 每个宿主的自动/半自动支持级别

### 期望结果
能回答：
- 这个 skill 在 Claude Code、Cursor、Copilot、Codex 中分别怎么用
- 哪些环境能自动，哪些环境只能半自动

---

## 三、Phase 2：动态参数状态机

### 要解决的问题
像下面这种链路：
- `/gsd-plan-phase xxx`
- `/gsd-execute-phase 1`
- `/gsd-execute-phase 2`

其 `1 / 2` 这种动态参数，不能靠用户自己记忆和手输。

### 推荐状态承接方式
把动态状态统一写入需求目录，例如：
- `metadata.json`
- `generated/gsd-output.md`
- 新增 `execution-state.json`

### 推荐最小状态结构
```json
{
  "currentFlow": "gsd",
  "planId": "...",
  "phases": [
    { "id": 1, "title": "...", "status": "pending" },
    { "id": 2, "title": "...", "status": "pending" }
  ],
  "lastStep": "gsd-plan-phase",
  "nextStep": "gsd-execute-phase",
  "updatedAt": "2026-04-23T00:00:00+08:00"
}
```

### 交付物
1. `execution-state.json` 设计
2. phase / plan / step 状态字段约定
3. `auto` / `manual` 共用的续跑规则

---

## 四、Phase 3：命令插件映射表

### 要解决的问题
skill 不只是“知道有哪些插件”，还要明确：
- 什么场景调用哪个命令
- 上一步返回什么，下一步怎么接
- 哪些返回结果要写状态文件
- 哪些结果要同步进标准文档

### 示例
#### Superpowers
- `/superpowers:brainstorming` → 写入 `generated/superpowers-output.md`
- `/superpowers:writing-plans` → 归并进入 `proposal.md`
- `/superpowers:requesting-code-review` → 归并进入 `design.md` 或评审记录

#### OpenSpec
- `/opsx:propose` → 写入 `proposal.md`
- `/opsx:explore` → 作为模糊需求澄清阶段，完成后再进入 `proposal.md` / `spec.md`

#### GSD
- `/gsd-plan-phase xxx` → 生成 phase 列表，并写入状态文件
- `/gsd-execute-phase <phaseId>` → 根据状态文件继续执行
- `/gsd-progress` → 更新状态摘要

#### E2E
- `/e2e xxxx` → 写入测试结果与测试用例文档

### 交付物
1. 命令插件映射表
2. 每个命令的输入/输出/落盘/状态推进规则

---

## 五、最建议的下一步实施顺序

### Step 1
先补一份：
- `宿主适配矩阵`
- `skill 放置位置建议`
- `自动触发 / 手动触发区别`

### Step 2
再补一份：
- `execution-state.json` 设计
- `phase` / `step` 状态推进规则

### Step 3
最后补：
- `OpenSpec / Superpowers / GSD / e2e` 的命令映射与状态承接表

---

## 六、结论

当前 skill 体系已经完成了：
- 流程定义
- 路由
- 上下文
- 初始化
- auto/manual 分流
- 本地落盘底座

下一阶段真正要补的是：
- **宿主适配**
- **动态参数状态机**
- **命令插件映射表**

这三项补齐后，整套 skill 才会从“可用规则集”升级到“可稳定自动化执行的通用流程体系”。

