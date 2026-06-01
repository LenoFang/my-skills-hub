# TCOA Skill 端到端验证手册

> 适用范围：`.claude/skills/tcoa-*`（router/context/flow-state/requirement-init/auto-execute/manual-guide/review/git-flow）+ `tcoa-scaffold`。
> 目标：在不依赖真实远端工具链的前提下，通过本地 CLI 与状态文件，验证流程契约（phase 流转、skillChain 追加、review 必经、git 写操作前置）。

## 0. 术语速查

- **phase**：`tcoa-flow-state §一` 定义的 13 个状态枚举。
- **skillChain**：`execution-state.json.skillChain`，每个 tcoa-* skill 进入时追加一条记录。
- **CLI**：`tcoa-scaffold/src/cli.js`，本手册涉及的命令均通过它落地。
- **包装脚本**：`.claude/skills/tcoa-scm/bin/tcoa-scaffold.ps1`，把 PowerShell 调用转交给 CLI；CLI 命令均可通过它运行。

## 1. 准备工作

```powershell
# 1) 校验 CLI 可用
node tcoa-scaffold/src/cli.js help

# 2) 校验项目级配置（首次运行才需要 init-config）
node tcoa-scaffold/src/cli.js validate-config --project-root D:/Projects/TCOA.SCM

# 3) 查看当前上下文
node tcoa-scaffold/src/cli.js context
```

通过条件：
- `help` 输出包含 `set-phase / append-skill-chain / record-review / record-degradation / record-git-status / validate-phase-transition`。
- `validate-config` 返回 `ok: true` 或仅 warnings。
- `context` 列出 `requirements/` 下的需求目录。

## 2. 测试用例清单（按 phase 流转覆盖）

下表覆盖 `tcoa-flow-state §二` 的全部合法流转，每条用例给出**触发命令**、**预期落盘**、**预期返回字段**。

| # | 用例 | 触发命令 | 预期 phase 流转 | 预期落盘 |
|---|------|----------|-----------------|----------|
| TC-01 | 初始化 trivial 需求（快速路径） | `init-requirement --name "修一个文案" --tools "gsd"` | uninitialized → initialized | `metadata.json`、`tasks.md`、`execution-state.json(phase=initialized)` |
| TC-02 | 初始化 medium 需求（gsd+openspec） | `init-requirement --name "..." --tools "gsd,openspec"` | uninitialized → initialized | 上 + `proposal.md`、`spec.md` |
| TC-03 | 初始化 large 需求（gsd+openspec+superpowers） | `init-requirement --name "..." --tools "gsd,openspec,superpowers"` | uninitialized → initialized | 上 + `design.md` |
| TC-04 | 切换当前上下文 | `use-context --latest` | 不变 | `.tcoa/current-context.json.requirementId` 更新 |
| TC-05 | router 进入记录 | `append-skill-chain --skill tcoa-router` | 不变 | `skillChain += tcoa-router` |
| TC-06 | context 进入记录 | `append-skill-chain --skill tcoa-context` | 不变 | `skillChain += tcoa-context` |
| TC-07 | 进入 auto 执行 | `set-phase --phase executing-auto --skill tcoa-auto-execute` | initialized → executing-auto | `phase=executing-auto`，`skillChain += tcoa-auto-execute` |
| TC-08 | 主流程结束转 review | `set-phase --phase awaiting-review --next-skill tcoa-review` | executing-auto → awaiting-review | `phase=awaiting-review`，`nextSuggestedSkill=tcoa-review` |
| TC-09 | **非法**：跳过 review 直接完成 | `set-phase --phase completed`（在 awaiting-review 时） | （拒绝） | CLI 返回非零退出，`phase` 不变 |
| TC-10 | review 进行中 | `set-phase --phase reviewing --skill tcoa-review` | awaiting-review → reviewing | `phase=reviewing` |
| TC-11 | review 通过 | `record-review --result passed` + `set-phase --phase review-passed` | reviewing → review-passed | `reviewStatus.completed=true, result=passed` |
| TC-12 | review 失败回流 | `record-review --result failed --findings "<json>"` + `set-phase --phase executing-auto --force`（合法回流不需 force） | reviewing → review-failed → executing-auto | `reviewStatus.reviewFailCount++` |
| TC-13 | 进入 git 流程 | `set-phase --phase awaiting-git --skill tcoa-git-flow` | review-passed → awaiting-git | `phase=awaiting-git` |
| TC-14 | 创建分支 | `git-create-branch --slug "<slug>"` + `record-git-status --branchCreated true --branch-name <name>` | 不变 | `gitStatus.branchCreated=true` |
| TC-15 | 提交 | `git-commit-message ...` + `git-commit ...` + `record-git-status --committed true` | 不变 | `gitStatus.committed=true` |
| TC-16 | 推送（预览） | `git-push`（无 `--execute`） | 不变 | 仅打印命令，不修改 gitStatus |
| TC-17 | 推送（执行） | `git-push --execute` + `record-git-status --pushed true` | 不变 | `gitStatus.pushed=true` |
| TC-18 | 合并到目标分支 | `git-merge --target master --execute` + `record-git-status --merged true` | 不变 | `gitStatus.merged=true` |
| TC-19 | 完结 | `set-phase --phase completed --skill tcoa-git-flow` | awaiting-git/git-flowing → completed | `phase=completed` |
| TC-20 | 工具降级留痕 | `record-degradation --from openspec --to gsd-only --reason "timeout"` | 不变 | `degradations[]` 追加，changelog 追加一行 |
| TC-21 | 流转校验（独立） | `validate-phase-transition --from executing-auto --to completed` | 不变（仅查询） | 退出码 2，`allowed:false` |

断言要点：
- 每次写操作后均需读取 `execution-state.json` 与 `changelog.md` 进行核对。
- TC-09 / TC-21 用于验证「绕过 review」的硬性拦截。
- TC-12 用于验证 review 失败计数与回流路径。

## 3. 端到端剧本

### 剧本 A — trivial 快速路径（30 行内文案修改）

用户：`帮我把页面上的“提交”按钮改成“申请”`。

1. **tcoa-router**：识别 changeSize=trivial，询问是否走快速路径。
   - 校验：`append-skill-chain --skill tcoa-router`。
2. **tcoa-context**：phase=uninitialized 或上一需求 completed。
3. 用户确认快速路径 → 跳过 `tcoa-requirement-init`，直接修改文件。
4. **轻量 review**：执行 `record-review --result passed --findings "[]"`；`set-phase --phase review-passed`。
5. 询问 git 操作；用户拒绝 → `set-phase --phase completed`。

断言：`skillChain` 至少包含 `tcoa-router → tcoa-context`，`phase=completed`，`reviewStatus.completed=true`。

### 剧本 B — medium 标准路径（gsd + openspec）

用户：`新增物料申请查询的批量条件支持`。

1. router → context → requirement-init（生成 metadata/proposal/spec/tasks）。
2. `set-phase --phase executing-auto --skill tcoa-auto-execute`。
3. 调用 `openspec-propose` / `gsd-do` / `openspec-apply-change`（本手册不强制真实执行，可用占位符 `execute` 命令）。
4. `set-phase --phase awaiting-review --next-skill tcoa-review`。
5. **review**：`set-phase --phase reviewing` → `record-review --result passed` → `set-phase --phase review-passed`。
6. **git 流程**：`set-phase --phase awaiting-git` → 提交/推送 → `record-git-status` 同步 → `set-phase --phase completed`。

断言：每个 phase 变更都在 `changelog.md` 留痕；`gitStatus.committed=true`。

### 剧本 C — large 严格路径（gsd + openspec + superpowers），review 失败回流

用户：`重构采购申请审批链路`。

1. router → context → requirement-init（带 `tools="gsd,openspec,superpowers"`，落 design.md）。
2. `set-phase --phase executing-auto`。
3. 第一次 review：`record-review --result failed --findings '[{"severity":"HIGH","note":"事务边界缺失"}]'`；`set-phase --phase review-failed`（自动 reviewFailCount=1）。
4. 修复后回到 `set-phase --phase executing-auto`（合法流转）。
5. 二次 review pass → `review-passed` → `awaiting-git` → 完成。

断言：`reviewStatus.reviewFailCount==1`；二次通过后 `result=passed`；`degradations` 数组在任何 superpowers 失败场景下被写入。

## 4. 与 hook 的协作

PreToolUse(Bash) hook（建议规则；本手册仅给出契约，不重复实现）：
- 拦截 `git commit/push/merge` 时调用 `node cli.js validate-phase-transition --from <state.phase> --to git-flowing`，非法（退出码 2）时阻止执行。
- 拦截 `--no-verify`、`--force`（master/main）。

手动验证方式：在 phase=`executing-auto` 时执行 `git commit ...`，期望 hook 报错；在 phase=`awaiting-git` 时执行同样命令，期望放行。

## 5. 失败排查

| 现象 | 可能原因 | 处理 |
|------|----------|------|
| `set-phase` 报 `非法 phase 流转` | 不在 §二 合法流转表中 | 先回到允许的中间态；只有人工干预可加 `--force` |
| `execution-state.json 缺失或未迁移` | 旧 schema 残留 | 运行 `migrate-state --latest` |
| `review` 后无法进入 git | `reviewStatus.completed=false` | 先执行 `record-review --result passed` |
| 流程产物缺 `proposal.md` | `tools` 未含 `openspec` | 重建需求或手工补 tools 字段后重跑 |

## 6. 自检清单（每轮需求收尾）

- [ ] `execution-state.json.phase` ∈ {`completed`, `awaiting-git`(部分完成)}
- [ ] `skillChain` 至少含 router → context → init/auto/manual → review (→ git-flow)
- [ ] `reviewStatus.completed = true`
- [ ] `gitStatus` 与实际操作一致
- [ ] `changelog.md` 覆盖所有 phase 变更与 review 结论
- [ ] `degradations[]` 中的每一项都能在 changelog 找到对应日志

## 7. 维护建议

- 当 `tcoa-flow-state` 修改 phase 枚举或流转时，同步更新 `cli.js` 中的 `PHASE_ENUM` / `PHASE_TRANSITIONS` 与本手册第 2 节。
- 新增 skill 时，在第 3 节剧本中追加它的进入/退出断言。
- CI（如启用）可基于第 2 节用例清单生成回归脚本。
