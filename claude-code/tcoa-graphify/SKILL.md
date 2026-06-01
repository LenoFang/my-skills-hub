---
name: tcoa-graphify
description: Project-level graphify routing and analysis skill for TCOA.SCM. Use when the user mentions `graphify`, `graphify-out`, graph docs, or asks for graph-based architecture, impact, refactor, debugging, or regression analysis in this repo. First read `graphify-out/GRAPH_AGENT_GUIDE.md` and `graphify-out/GRAPH_MODEL_PROMPTS.md`, then route to the smallest relevant module graph and only read the minimum needed graph docs before checking source.
---

# TCOA Graphify

## Workflow

1. Read repo-root `graphify-out/GRAPH_AGENT_GUIDE.md`.
2. Read repo-root `graphify-out/GRAPH_MODEL_PROMPTS.md`.
3. Do not start by reading the whole repository.
4. Map the request to the smallest relevant module graph:
   - `front-pc`: read `front-pc/graphify-out/GRAPH_INDEX.md` for PC frontend routes, pages, components, store, or API binding work.
   - `code-backend/project-pc`: read `code-backend/project-pc/graphify-out/GRAPH_INDEX.md` for PC backend controllers, APIs, page-entry, or backend flow work.
   - `code-backend/project-mobile`: read `code-backend/project-mobile/graphify-out/GRAPH_INDEX.md` for mobile backend, H5 backend, or POS-related backend work.
   - `code-backend/base-service`: read `code-backend/base-service/graphify-out/GRAPH_INDEX.md` for shared service logic.
   - `code-backend/base-dao`: read `code-backend/base-dao/graphify-out/GRAPH_INDEX.md` for shared repository, mapper, or SQL work.
   - `code-backend/base-domain`: read `code-backend/base-domain/graphify-out/GRAPH_INDEX.md` for shared entity, info, enum, or DTO work.
   - `code-backend/base-common`: read `code-backend/base-common/graphify-out/GRAPH_INDEX.md` for shared utility, config, or infrastructure work.
   - `code-backend/admin-backend`: read `code-backend/admin-backend/graphify-out/GRAPH_INDEX.md` for admin or permission backend work.
5. Read only that module's `GRAPH_INDEX.md` first.
6. Read only the smallest supporting graph docs that match the task:
   - architecture or impact: `GRAPH_HOTSPOTS.md`, `GRAPH_CHANGE_BATCHES.md`
   - debugging or regression: `GRAPH_TEST_FOCUS.md`, then `GRAPH_HOTSPOTS.md`
   - refactor planning: `GRAPH_REFACTOR_PRIORITY.md`, `GRAPH_CHANGE_BATCHES.md`, `GRAPH_CONTROLLER_MATRIX.md`
   - controller risk or batch-boundary review: `GRAPH_CONTROLLER_MATRIX.md`, `GRAPH_CHANGE_BATCHES.md`
7. For cross-front-back or cross-shared-layer work, extend the graph read order as `front-pc -> project-pc -> base-service -> base-dao -> base-domain`.
8. For mobile shared-layer work, extend the graph read order as `project-mobile -> base-service -> base-dao -> base-domain`.
9. Use graph docs for navigation, ownership, hotspots, coupling, and regression priority.
10. Return to live source only after the graph pass to confirm exact implementation details.

## Operating Rule

Apply this rule during graphify analysis:

> Do not read the whole repository first. Identify the owning module, read only that module's `graphify-out/GRAPH_INDEX.md`, then add the minimum supporting graph docs such as `GRAPH_HOTSPOTS.md`, `GRAPH_CHANGE_BATCHES.md`, `GRAPH_TEST_FOCUS.md`, `GRAPH_REFACTOR_PRIORITY.md`, and `GRAPH_CONTROLLER_MATRIX.md` only as needed by the task. Return to source code last to confirm implementation details. If the request crosses frontend, backend, or shared layers, extend reads in the order `front-pc -> project-pc -> base-service -> base-dao -> base-domain`. Use graph docs for navigation and risk judgment; use source code for final confirmation. If graph docs and source conflict, trust the source.

## Guardrails

- Prefer Markdown graph docs over `graph_*.html`; open HTML only when the user explicitly wants the visual graph.
- Avoid loading unrelated module graphs.
- Avoid treating repo-root backend graphs as one merged source of truth; use them only to choose the next module slice.
- If a module graph is missing or stale, say so and move to source with minimal additional reading.
- If graph docs and source disagree, trust the source and call out the mismatch.

## 与 GitNexus 的协同

> Graphify 和 GitNexus 提供互补的代码智能视角。明确分工避免重复分析。

### 分工定义

| 维度 | Graphify | GitNexus |
|------|----------|----------|
| **粒度** | 模块级（包/目录/文件组） | 符号级（函数/类/方法） |
| **强项** | 架构总览、模块依赖、hotspot、变更批次 | 调用链追踪、影响分析、重命名安全 |
| **数据** | 静态图谱文档（GRAPH_*.md） | 代码图谱（87K symbols, 250K relationships） |
| **时机** | 理解架构/规划重构时 | 改代码前的影响评估 |

### 在 TCOA 流程中的使用

| 阶段 | Graphify | GitNexus |
|------|----------|----------|
| **tcoa-context**（需求分析） | 定位涉及模块 | — |
| **tcoa-execute**（代码改动前） | 跨模块变更时展示模块依赖 | medium/large 的 impact 预检（必选） |
| **tcoa-review**（代码审查后） | 变更涉及 ≥3 模块时可选展示 | detect_changes 确认变更范围（已有） |

### 协同触发规则

1. **用户显式请求** `/graphify` → 启动 Graphify 分析
2. **跨模块变更**（涉及 ≥2 个 code-backend 子模块）→ 建议 Graphify 模块视图
3. **重构规划** → Graphify 先出 GRAPH_REFACTOR_PRIORITY，GitNexus 再做符号级 impact
4. **单模块/单符号变更** → 仅 GitNexus，不启动 Graphify（避免噪音）

### 注册表集成

Graphify 的命令定义在 `.tcoa/command-registry.json` 的 `graphify.analyze` 中，
`complementsGitNexus: true` 标记表示它与 GitNexus 互补而非替代。
