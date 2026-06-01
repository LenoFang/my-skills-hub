---
name: tcoa-git-flow
description: "[内部 skill，由 tcoa-router 链式调用，不应独立触发] TCOA Git 流程 skill。负责分支创建、提交、推送、合并。配合 PreToolUse hook 强制执行 review 前置条件。"
---

# tcoa-git-flow

## 门禁
- **建分支**：phase ∈ {`initialized`, `branching`}
- **提交/推送/合并**：phase ∈ {`review-passed`, `awaiting-git`, `git-flowing`}
- 进入时写 phase = `branching`（建分支）或 `git-flowing`（其他）

## 触发条件
- tcoa-context init 完成后询问建分支
- tcoa-review review-passed 后询问提交
- 用户显式说"提交/推送/合并/建分支"且 phase 合法

## 硬性安全规则
- 禁止 `--no-verify`、`--force` push、force-with-lease 到 master/main
- 禁止在 phase 非 review-passed/awaiting-git 时 commit/push/merge
- 禁止绕过 pre-commit hook
- 合并冲突必须用户处理

## 子流程

### 1. 建分支（phase: initialized/branching）
- AskUserQuestion 确认分支名
- 命名：feature/<slug>、fix/<slug>、hotfix/<slug>、refactor/<slug>
- 完成后：gitStatus.branchCreated=true，phase → initialized

### 2. 提交（phase: review-passed/awaiting-git）
- 展示 `git diff --stat`，AskUserQuestion 确认
- 按 Conventional Commits 生成消息
- **默认按顶级文件夹分拆 commit**（requirements/、code-backend/、front-pc/ 等各自独立）
- 完成后：gitStatus.committed=true

### 3. 推送（committed=true）
- AskUserQuestion 确认远端和分支
- 新分支自动 `-u`
- 非 fast-forward → 询问用户处理方式

### 4. 合并
- AskUserQuestion 确认目标分支和策略
- 冲突 → phase 退回 awaiting-git，告知冲突文件

### 5. LESSONS 批量提示（归档前）

归档前检查本次需求是否有值得记录的教训（phase 漂移、双写冲突、review 回流、工具异常等）。

**第一步：写需求级 lessons**
若有候选条目，与归档确认合并提示：
```
本次需求完成。以下经验是否写入 requirements/<id>/lessons.md？
- [ ] <候选条目>（tags: <模块/场景>）
确认归档？
```
用户勾选后写入 `requirements/<id>/lessons.md`，格式见模板。

**候选来源**：
- phase 漂移、双写冲突、review 回流、工具异常等
- 从 `decisions.md` 自动提取（决策点 → 经验教训）

**第二步：提升到 repo 级**
写完需求级 lessons 后，判断是否值得提升到 `requirements/LESSONS.md`：
- 跨需求通用（不依赖本次具体业务）→ 提示用户是否提升
- 仅本次特有 → 不提升，静默跳过

无候选条目则整个步骤静默跳过。

### 6. 归档（phase: completed）
- AskUserQuestion 强制确认
- metadata.json 写 archived=true + archivedAt
- 从 active 数组移除
- 可选同步调用 /opsx:archive
- 生成结构化 `summary.md`（若不存在）：

```markdown
## 成功标准
## 偏差记录
## 关键决策
## 经验教训（LESSONS 候选）
## Token 消耗
```

## 完成后
- 更新 gitStatus、写 phase=completed、追加 changelog
- 部分操作完成 → phase 保持 awaiting-git

## 输出契约
```
[skill: tcoa-git-flow]
[phase-before: ...] → [phase-after: branching|git-flowing|completed|awaiting-git]
[sub-flow: branch|commit|push|merge|archive]
[gitStatus: branchCreated|committed|pushed|merged: bool]
[next-skill: none(completed)|tcoa-git-flow(继续)]
```

## 必须 AskUserQuestion 的场景
- 每个子流程进入前
- 非 fast-forward push
- 合并冲突
- 目标为 master/main（二次确认）

## 不做的事
- 不在 phase 不合法时执行 git 写操作
- 不 --no-verify / --force
- 不自动解决冲突
- 不跳过 pre-commit hook

## 详细参考 → 见 REFERENCE.md
