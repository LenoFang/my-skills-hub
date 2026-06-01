# tcoa-review REFERENCE

> 本文件是 `tcoa-review/SKILL.md` 的详细补充参考，按需读取。

## build 门禁详细

### 触发时机
进入 review 后、调用 review 子代理之前执行。trivial/small 跳过。

### 检查策略（从 registry 读取命令）
```
registry = 读取 .tcoa/command-registry.json
gates = registry["tools"]["review"]["buildGates"]

if Java文件改动:
    执行 gates["compile"]["cmd"]（替换 {modules} 为影响模块列表）
    工作目录: gates["compile"]["workingDir"]
    超时: gates["compile"]["timeout"]

if 前端文件改动:
    执行 gates["lint"]["cmd"]
    工作目录: gates["lint"]["workingDir"]
    超时: gates["lint"]["timeout"]

if 仅文档/配置:
    跳过 build 检查
```

模块定位规则（Java）：
- 改动路径含 `code-backend/<module>/` → `-pl code-backend/<module>`
- 多模块改动 → 用逗号拼接 `-pl m1,m2 -am`
- 无法定位 → 退回 `mvn compile -DskipTests -q`（全量），warning「建议拆分需求」

### 失败处理
- 编译/lint 失败 → `metadata.json.buildCheckStatus = "fail"`，phase = `review-failed`
- reviewFailCount 不增（编译错误不计入 review 失败次数）
- snapshot §6 追加：`[时间] build-fail：mvn compile 失败 N 处`
- 不触发自动修复，转回原执行 phase

### 成功处理
- `metadata.json.buildCheckStatus = "pass"`
- snapshot §6 追加：`[时间] build-pass：mvn compile 通过`
- 继续执行测试门禁或 review 子代理

### 跳过条件
- 用户显式要求「跳过 build 检查」→ AskUserQuestion 二次确认 → `buildCheckStatus = "skipped"`
- 仅文档改动 → 自动跳过，不询问

## 测试门禁详细

### 执行方式
```
gate = registry["tools"]["review"]["buildGates"]["test"]
cmd = gate["cmd"]（替换 {modules}）
阻塞: gate["blocking"]  # false — 测试失败不阻塞
```

### 结果处理
| 结果 | 处理 |
|---|---|
| 全部通过 | `testStatus = "pass"`，继续 review |
| 部分/全部失败 | `testStatus = "fail"`，AskUserQuestion 是否继续 |
| 无测试用例 | `testStatus = "no-tests"`，继续 review |
| 超时 | `testStatus = "timeout"`，warning 并继续 |

### 跳过条件
- trivial/small → 自动跳过
- 仅前端改动 → 跳过 Maven test
- 用户显式要求 → `testStatus = "skipped"`

## review 子代理详细

### 引用方式
```
registry = 读取 .tcoa/command-registry.json
subagents = registry["tools"]["review"]["subagents"]
agent_type = subagents["code"]["type"]    # 当前值: "code-reviewer"
Agent(subagent_type=agent_type, ...)
```

### 当前注册表概览
| 注册表 key | subagent_type | 适用 changeSize | 触发条件 |
|---|---|---|---|
| review.subagents.code | code-reviewer | all | 必选 |
| review.subagents.java | java-reviewer | medium/large | Java 文件改动 |
| review.subagents.security | security-reviewer | medium/large | 涉及认证/输入/DB |

### review 路径详细

#### trivial / small → 快速 review
最小检查项：
- 是否改动了不该改的文件
- 是否有明显错误处理缺失
- 是否有明显命名/风格问题
- 是否引入硬编码密钥

#### medium → 标准 review
- 类型安全、错误处理、性能、代码规范、安全性
- 并行：code-reviewer + security-reviewer（涉及认证/输入/DB 时）
- 关注：接口变更兼容性、SQL 注入、权限绕过、事务边界

#### large → 严格 review
- 上述全部 + 架构一致性检查
- 并行：code-reviewer + security-reviewer + java-reviewer
- 必须检查：数据库迁移、分布式锁、缓存一致性

## review-passed 后的可选 e2e 测试

AskUserQuestion：「是否运行 /e2e？」
- 运行 → phase = `e2e-testing`，调用 Skill(skill="e2e")
  - 通过 → `e2eStatus = "pass"`，phase → `awaiting-git`
  - 失败 → `e2eStatus = "fail"`，reviewFailCount++，phase → `review-failed`
- 跳过 → `e2eStatus = "skipped"`

推荐策略：
- trivial/small：默认不主动询问
- medium：询问，推荐运行
- large：询问，强烈推荐

## context-snapshot 写入要求
本 skill 累积桶：§4（review-failed 关键决策）、§5（skill 切换）、§6（review/build/e2e 结论）。
格式：`[时间] review-<结果>：CRITICAL:N HIGH:N MEDIUM:N LOW:N | 简评：<一句话>`
退出前合并为单次 Edit。

## severity 分级
- CRITICAL → 阻塞
- HIGH → 阻塞
- MEDIUM → 记录可放行
- LOW → 记录

## review 结论详细
- 无 CRITICAL/HIGH → review-passed，nextSuggestedSkill = tcoa-git-flow
- 有 CRITICAL/HIGH → review-failed，findings 数组记录具体问题
- reviewFailCount ≤ 2 → 转回执行 phase 修复
- reviewFailCount ≥ 3 → 强制人工介入
- 仅 MEDIUM/LOW → AskUserQuestion 是否放行
