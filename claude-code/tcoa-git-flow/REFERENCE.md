# tcoa-git-flow REFERENCE

> 本文件是 `tcoa-git-flow/SKILL.md` 的详细补充参考，按需读取。

## 建分支详细

推荐命名规则：
- changeSize=small|medium 且为新功能 → `feature/<slug>`
- changeSize=trivial 且为 bug 修复 → `fix/<slug>`
- 紧急修复 → `hotfix/<slug>`
- changeSize=large 且涉及重构 → `refactor/<slug>`

确认项（AskUserQuestion）：
- 是否创建新分支
- 分支命名建议是否接受

执行后：
- `gitStatus.branchCreated = true`，`gitStatus.branchName = <name>`
- phase → `initialized`（回到初始化完成态）

## 提交详细

提交信息规则（Conventional Commits）：
- 新功能 → `feat: <描述>`
- 缺陷修复 → `fix: <描述>`
- 文档更新 → `docs: <描述>`
- 重构 → `refactor: <描述>`
- 测试 → `test: <描述>`
- 其他维护 → `chore: <描述>`
- 性能 → `perf: <描述>`
- CI/构建 → `ci:` / `build:`

**分拆提交规则（默认）**：
按仓库根下的顶级文件夹分拆为独立 commit：
- `requirements/` → `docs(xxx): ...`
- `code-backend/` → `feat(xxx): ... 后端...`
- `front-pc/` → `feat(xxx): ... PC前端...`
- `front-touch/` → `feat(xxx): ... 移动端前端...`
- 其他顶级文件夹各自独立提交

好处：git log 按文件夹维度清晰可追溯，便于 cherry-pick 和 revert。
仅当用户明确要求"合并提交"时才使用单次 commit。

## 推送详细

确认项：
- 是否推送
- 推送到哪个远端（默认 origin）
- 推送哪个分支（默认当前分支）
- 新分支 → 自动 `-u`

失败处理：
- 网络错误 → 提示用户重试
- 权限拒绝 → 提示用户检查 SSH/token
- 非 fast-forward → 询问用户 pull rebase 还是手动处理

## 合并详细

确认项：
- 是否合并
- 目标分支
- 合并策略（merge / rebase / squash）

冲突处理：
- 发生冲突 → phase 退回 `awaiting-git`
- 明确告知用户冲突文件清单
- 不得使用 `-X theirs/ours` 自动解决
- 不得 `git reset --hard` 放弃合并（除非用户明确要求）

## 归档详细

**适用**：phase = completed 后用户同意归档

执行步骤：
1. 读取 metadata.json，写入 `archived: true` + `archivedAt`
2. 从 current-context.json 的 active 数组移除
3. 若 active 仍有其他需求 → focused 设为 active[0]；否则 focused 设为 null
4. snapshot §6 追加归档记录
5. changelog.md 追加归档记录
6. 若 tools 含 openspec → 顺带询问是否 /opsx:archive

不做：不删除需求目录、不修改已提交代码、不切分支

## context-snapshot 写入要求

本 skill 累积桶：§4（冲突/失败决策）、§5（skill 切换）、§6（git 操作一行格式）。
格式：`[时间] git-<动作>：<分支|commit hash> | 备注：<一句话>`
退出前合并为单次 Edit。
