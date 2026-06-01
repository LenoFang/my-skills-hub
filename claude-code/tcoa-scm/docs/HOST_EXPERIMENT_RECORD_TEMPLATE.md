# TCOA Skills 宿主实验记录模板

## 目的
用于把每次宿主联调结果记录下来，避免只靠口头记忆判断某个宿主是否可用。

> 建议：每联调一个宿主，就复制一份本模板，逐项填写。

---

## 1. 基本信息

- 宿主环境：
- 宿主版本：
- 测试日期：
- 测试人：
- 当前项目目录：
- 当前使用模式：`auto / manual`

---

## 2. skill 识别情况

### root-level `tcoa-*` 是否被识别
- [ ] `tcoa-router`
- [ ] `tcoa-context`
- [ ] `tcoa-requirement-init`
- [ ] `tcoa-auto-execute`
- [ ] `tcoa-manual-guide`

### 现象记录
- 是否体现了“先上下文、再分流”的思路：
- 是否体现了 auto/manual 分流：
- 是否体现了工具识别（OpenSpec / Superpowers / GSD）：

---

## 3. 插件命令协作情况

### OpenSpec
- [ ] 能自动调用
- [ ] 只能提示用户手动执行
- [ ] 不能稳定使用

### Superpowers
- [ ] 能自动调用
- [ ] 只能提示用户手动执行
- [ ] 不能稳定使用

### GSD
- [ ] 能自动调用
- [ ] 只能提示用户手动执行
- [ ] 不能稳定使用

### E2E
- [ ] 能自动调用
- [ ] 只能提示用户手动执行
- [ ] 不能稳定使用

---

## 4. 桥接脚本与落盘检查

### 桥接脚本入口
当前唯一支持入口：

```powershell
powershell -ExecutionPolicy Bypass -File ".\.claude\skills\tcoa-scm\bin\tcoa-scaffold.ps1" status
powershell -ExecutionPolicy Bypass -File ".\.claude\skills\tcoa-scm\bin\tcoa-scaffold.ps1" state
powershell -ExecutionPolicy Bypass -File ".\.claude\skills\tcoa-scm\bin\tcoa-scaffold.ps1" execute
```

### 是否通过
- [ ] `status` 正常
- [ ] `state` 正常
- [ ] `execute` 正常

### 产物检查
- [ ] `generated/*.md`
- [ ] `metadata.json`
- [ ] `changelog.md`
- [ ] `execution-state.json`
- [ ] `proposal.md`
- [ ] `tasks.md`
- [ ] `spec.md`
- [ ] `design.md`

---

## 5. auto / manual 判定

### 当前结论
- [ ] 该宿主适合 `auto`
- [ ] 该宿主更适合 `manual`
- [ ] 该宿主只能把 skill 当规则文档

### 判定原因
- 是否能稳定识别 root-level `tcoa-*`：
- 是否能自动调插件命令：
- 是否能承接上一条命令结果继续推进：
- 是否能稳定落盘：

---

## 6. skill / 插件使用追踪（低优先级记录）

> 这是低优先级增强项，先人工记录即可。

### 本次实际使用到的 skill
- 
- 
- 

### 本次实际使用到的插件 / 命令
- 
- 
- 

### 是否需要后续写入 `metadata.json` / `execution-state.json`
- [ ] 需要
- [ ] 暂不需要

---

## 7. 问题与回退方案

### 遇到的问题
- 
- 
- 

### 当前回退方案
- 
- 
- 

---

## 8. 最终结论

### 当前推荐用法
- 

### 是否可进入下一阶段
- [ ] 可以继续扩大使用范围
- [ ] 仍需继续联调
- [ ] 仅适合手工辅助使用

