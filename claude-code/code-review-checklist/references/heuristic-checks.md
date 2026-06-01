# 启发式检查（Report Only）详细参考

> 主 SKILL.md 的子文档。第二轮 B 的检查项及报告话术。
>
> **核心原则**：本类项**需要人判断**，仅报告，**不擅自改**。  
> 这是 Karpathy "Surgical Changes" 原则的落地——避免越界修改。

## 红旗：以下行为禁止

- ❌ 把启发式项的"建议"当成必须修复，自动改完不通知
- ❌ 把"方法过长"当 R-FORCE 处理，主动拆方法
- ❌ 顺手重命名既有变量为"更好"的名字
- ❌ 在未被本次需求触及的文件中报告启发式问题（无关代码不评论）

## 检查项

### 1. 方法长度 > 50 行 → 标注

#### 判定

- 仅检查本次新增 / 修改的方法
- 行数包括方法体内的注释（不含方法签名前的 javadoc）

#### 报告话术

```
[?] MaterialApplyServiceImpl#submitApply 方法 78 行，超过 R-STYLE-001 建议的 50 行。
    建议拆分但未自动修改——拆分点取决于业务边界，请用户决策。
```

### 2. 文件长度 > 500 行 → 标注

#### 判定

- 仅本次新增 / 大幅修改的文件
- 改前已超 500 行的既有文件，**不再次报告**（避免成为周期性噪音）

#### 报告话术

```
[?] MaterialApplyController.java 612 行，超过 R-STYLE-001 建议的 500 行。
    可能需要按业务子域拆分，请用户决策。
```

### 3. 命名是否表意 → 列可疑项

#### 信号

- 单字母变量在非循环 / 非临时场景使用（`u`、`m`、`x`）
- 缩写不通用（`pro`、`mngr`、`hdlr`）
- 函数名与实现不符（`getXxx` 内有写操作）

#### 报告话术

```
[?] 命名疑似不表意：
    - MaterialApplyServiceImpl#processM(): 参数 `m` 含义不清，可能是 material 或 apply
    - MaterialUtil#do2(): "do2" 含义不明
    建议用户检查并重命名。
```

### 4. 是否存在 N+1 查询 → 标注嫌疑

#### 信号

- 在 `for` / `forEach` / `stream` 内调用 Repository / Mapper 方法
- 列表对象的属性 getter 触发懒加载（JPA 关联）

#### 报告话术

```
[?] N+1 嫌疑：
    - MaterialApplyServiceImpl.java:142 在 forEach 中调用 itemRepository.findById()
    建议改为批量查询（findByIds）或 JOIN，请用户决策是否优化。
```

### 5. 是否需要新增异常处理 → 列可能漏处理的路径

#### 信号

- 调用外部接口（HTTP / RPC）但无 try-catch 或上层声明
- 调用可能抛运行时异常的方法（`Integer.parseInt`、`Map.get` 后直接 cast）
- 多步操作中无回滚保障

#### 报告话术

```
[?] 异常路径可能未覆盖：
    - SyncServiceImpl#syncFromCloud() 调用外部 API 但无超时 / 重试 / 异常处理
    建议补 try-catch + 回退策略，请用户确认是否需要。
```

### 6. 注释是否描述了 WHY → 列疑似冗余

#### 信号

- 注释仅复述方法名 / 字段名（`// 设置用户名` 在 `setUserName` 上）
- 注释引用了已修复的 bug 编号或已废弃的临时方案
- 注释包含开发者个人备忘（`// 这里我先这么写`）

#### 报告话术

```
[?] 注释疑似冗余：
    - MaterialApplyServiceImpl.java:88 注释 "// 调用 dao 保存" 复述了方法名
    建议用户决定是否删除或改写。
```

### 7. 是否需要拆分 Service → 列职责过重的类

#### 信号

- 单 Service 类 > 800 行
- 同 Service 中的方法跨多个业务子域（如同时处理"申请"和"审批"和"统计"）
- 注入了 5+ 个 Repository（耦合多模块）

#### 报告话术

```
[?] Service 职责疑似过重：
    - MaterialApplyServiceImpl 940 行，注入 7 个 Repository，方法覆盖申请/审批/统计/撤销
    建议拆为 ApplyService / ApprovalService / StatService，请用户决策。
```

## 输出格式

```markdown
### 第二轮 B：启发式检查（仅报告，请用户决策）
- [?] 方法长度 ：1 项（MaterialApplyServiceImpl#submitApply 78 行）
- [?] N+1 查询嫌疑 ：1 项（SyncServiceImpl.java:142）
- [?] 异常路径 ：2 项（详见上方）
- [?] Service 职责 ：1 项（MaterialApplyServiceImpl 疑似过重）
```

## 与决定性检查的边界判定

模糊场景速判：

| 场景 | 决定性 / 启发式 |
|---|---|
| `@Autowired` 在字段上 | 决定性（R-FORCE-001 明确要求） |
| 方法长度 65 行 | 启发式（拆分点是判断题） |
| 未使用的 import | 决定性（删了不影响行为） |
| 命名 `data` / `info` | 启发式（是否表意是判断题） |
| 缺少 javadoc 的 public 方法 | 决定性（按模板补） |
| 注释空洞但语法正确 | 启发式（重写还是删需要判断） |
| 数字 1 在 if 中 | **看条件**：有现成 Enum → 决定性；没有 → 启发式 |
| Service > 800 行 | 启发式（拆分边界是判断题） |
