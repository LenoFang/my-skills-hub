# TCOA Root Skills 使用说明

## 目的
说明父级 `D:\Projects\TCOA.SCM\.claude\skills` 下这套 TCOA root-level skills 该如何实际使用。

---

## 1. 当前目录结构怎么理解

### 真正给宿主识别的技能入口
放在：

- `tcoa-router`
- `tcoa-context`
- `tcoa-requirement-init`
- `tcoa-auto-execute`
- `tcoa-manual-guide`

这些目录都在：

`D:\Projects\TCOA.SCM\.claude\skills\`

### `tcoa-scm` 是什么
`tcoa-scm` 不是额外多余的一层入口 skill，而是：
- 文档集合
- 设计说明集合
- 桥接脚本所在位置

它主要用于：
- 承载部署说明
- 承载状态机说明
- 承载命令映射表
- 提供 `bin/tcoa-scaffold.ps1`

---

## 2. 实际推荐怎么触发

### 推荐入口
优先从：

- `tcoa-router`

开始。

### 原因
因为它负责统一做：
- 上下文判断
- 新建或续跑判断
- auto/manual 分流
- 工具链识别

也就是说，理想的会话入口不是直接手挑某个 skill，而是先由 `tcoa-router` 分流。

---

## 3. 与 `tcoa-scaffold` 的关系

### skill 负责
- 识别意图
- 决定流程
- 决定调用哪个插件命令
- 决定什么时候自动，什么时候确认

### `tcoa-scaffold` 负责
- 建目录
- 写配置
- 写日志
- 写 `metadata.json`
- 写 `execution-state.json`
- 回填标准文档

### 如何调用
推荐统一通过：

```powershell
powershell -ExecutionPolicy Bypass -File ".\.claude\skills\tcoa-scm\bin\tcoa-scaffold.ps1" <command>
```

例如：

```powershell
powershell -ExecutionPolicy Bypass -File ".\.claude\skills\tcoa-scm\bin\tcoa-scaffold.ps1" status
powershell -ExecutionPolicy Bypass -File ".\.claude\skills\tcoa-scm\bin\tcoa-scaffold.ps1" state
powershell -ExecutionPolicy Bypass -File ".\.claude\skills\tcoa-scm\bin\tcoa-scaffold.ps1" execute
```

---

## 4. 自动与半自动的实际区别

### auto
- skill 自动决定下一步
- 如果宿主支持，自动调用插件命令
- 如果宿主不支持，至少自动给出下一条应执行命令
- 自动写状态和文档

### manual
- 每一步先展示：
  - 将调用哪个命令
  - 预期产物是什么
  - 会改哪些文件
- 用户确认后再进入下一步

---

## 5. 当前推荐使用顺序

### 新需求
1. 进入 `tcoa-router`
2. 若无上下文 → `tcoa-requirement-init`
3. 根据模式进入：
   - `tcoa-auto-execute`
   - 或 `tcoa-manual-guide`

### 继续已有需求
1. 进入 `tcoa-router`
2. `tcoa-context` 锁定需求
3. 读取 `execution-state.json`
4. 决定继续 auto 或 manual

---

## 6. 当前最推荐的工作方式

如果你现在就在：

`D:\Projects\TCOA.SCM`

目录开发，那么推荐：

1. root-level `tcoa-*` skill 作为宿主可识别入口
2. `tcoa-scm` 作为说明与桥接支撑目录
3. 所有本地命令统一走：
   - `.\.claude\skills\tcoa-scm\bin\tcoa-scaffold.ps1`

这样最适合迁移，也最不容易和其他项目 skill 冲突。

## 7. 关于旧兼容入口

旧的：

- `.\.claude\scripts\tcoa-scaffold.ps1`

现在已经移除，不再作为支持入口。

后续统一只使用：

- `.\.claude\skills\tcoa-scm\bin\tcoa-scaffold.ps1`

