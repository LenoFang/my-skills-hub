# TCOA Skills 动态参数状态机设计（初版）

## 目标
解决这类命令链中的动态参数承接问题：

- `/gsd-plan-phase xxx`
- `/gsd-execute-phase 1`
- `/gsd-execute-phase 2`
- `/gsd-progress`

核心原则：

> phase 编号、plan 编号、step 编号等动态参数，不能依赖用户手工记忆，必须由状态文件承接。

---

## 1. 推荐状态文件

需求目录下新增：

`execution-state.json`

推荐位置：

`D:\Projects\TCOA.SCM\requirements\<requirementId>\execution-state.json`

---

## 2. 推荐最小结构

```json
{
  "currentFlow": "gsd",
  "currentMode": "auto",
  "planId": null,
  "lastStep": null,
  "nextStep": null,
  "phases": [],
  "trace": {
    "skills": [],
    "plugins": []
  },
  "toolState": {
    "openspec": {},
    "superpowers": {},
    "gsd": {},
    "e2e": {}
  },
  "updatedAt": "2026-04-23T00:00:00+08:00"
}
```

> 说明：`trace.skills` / `trace.plugins` 是低优先级增强字段，用于后续记录“本次需求实现到底用到了哪些 skill 和插件”。当前不要求先自动填充，可先人工记录或后续再落地。

---

## 3. GSD 链路状态承接

### 第一步：`/gsd-plan-phase xxx`
执行后应写入：

```json
{
  "currentFlow": "gsd",
  "lastStep": "gsd-plan-phase",
  "nextStep": "gsd-execute-phase",
  "planId": "plan-001",
  "phases": [
    { "id": 1, "title": "分析", "status": "pending" },
    { "id": 2, "title": "实现", "status": "pending" }
  ]
}
```

### 第二步：`/gsd-execute-phase 1`
执行后更新：

```json
{
  "lastStep": "gsd-execute-phase",
  "nextStep": "gsd-execute-phase",
  "phases": [
    { "id": 1, "title": "分析", "status": "done" },
    { "id": 2, "title": "实现", "status": "pending" }
  ]
}
```

### 第三步：当只剩最后一个 phase
可以把 `nextStep` 改成：
- `gsd-progress`
- 或 `completed`

---

## 4. OpenSpec / Superpowers / E2E 的状态承接

### OpenSpec
建议写入：
- `toolState.openspec.lastCommand`
- `toolState.openspec.lastOutputFile`
- `toolState.openspec.status`

### Superpowers
建议写入：
- `toolState.superpowers.lastCommand`
- `toolState.superpowers.lastOutputFile`
- `toolState.superpowers.status`

### E2E
建议写入：
- `toolState.e2e.lastCommand`
- `toolState.e2e.lastOutputFile`
- `toolState.e2e.status`

---

## 5. auto / manual 共用规则

### auto 模式
- 每一步完成后自动读取 `execution-state.json`
- 如果存在 `nextStep`，自动进入下一步
- 如果命令失败，则根据 skill 规则决定降级或终止

### manual 模式
- 每一步完成后读取 `execution-state.json`
- 将 `nextStep` 和可选项展示给用户
- 用户确认后才进入下一步

---

## 6. 与现有文件的关系

### `metadata.json`
继续存：
- 当前需求整体状态
- 最后执行结果
- 当前阶段

### `execution-state.json`
专门存：
- 命令链级别状态
- phase / step / nextStep
- 动态参数

### `generated/*.md`
继续存：
- 工具原始输出
- 便于人工排查与回填文档

---

## 7. skill 如何使用状态机

### `tcoa-auto-execute`
- 自动读取 `execution-state.json`
- 自动决定是否继续下一条命令
- 自动更新状态与文档

### `tcoa-manual-guide`
- 读取 `execution-state.json`
- 展示当前进度与下一步建议
- 让用户确认是否继续

### `tcoa-router`
- 初次进入时可检测是否存在未完成 `execution-state.json`
- 若存在，则优先提示“续跑当前流程”

---

## 8. 下一步落地建议

1. 在 `tcoa-scaffold` 中新增 `execution-state.json` 的读写能力
2. 定义每类命令的状态推进规则
3. 让 `auto` / `manual` 都统一依赖这份状态文件

---

## 9. 结论

只要 skill 体系要支持：
- 多步命令链
- 动态 phase 编号
- 自动 / 半自动续跑

就必须引入：

> `execution-state.json`

否则整个流程会过度依赖用户人工记忆与手工串联，无法稳定自动化。

