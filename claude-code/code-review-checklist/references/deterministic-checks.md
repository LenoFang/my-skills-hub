# 决定性检查（Auto-Fix）详细参考

> 主 SKILL.md 的子文档。第二轮 A 的检查项及自动修复模板。
>
> **核心原则**：本类项**有明确规则可执行**，发现即改，无需用户确认。  
> 不属于本类的项请走启发式 → `heuristic-checks.md`。

## 1. 字段 `@Autowired` → setter 注入（R-FORCE-001 / R-BE-002）

### 检测

搜索 Java 文件：

```regex
@Autowired\s+private\s+\w+\s+\w+;
```

### 修复模板

```java
// 改前
@Autowired
private XxxRepository repository;
@Autowired
private IYyyService yyyService;

// 改后
private XxxRepository repository;
private IYyyService yyyService;

@Autowired
public void setRepository(XxxRepository repository) {
    this.repository = repository;
}

@Autowired
public void setYyyService(IYyyService yyyService) {
    this.yyyService = yyyService;
}
```

### 边界

- 同类内字段超过 10 个：先全部转换；如类设计本身有问题（职责过重），**仅报告**，不主动拆分
- `@Resource` / `@Inject`：保留不动（只处理 `@Autowired`）
- 构造器注入：**不是**字段注入，跳过

## 2. 未使用的 import → 删除

### 检测

- IDE 风格：扫描每个 import，判断符号是否在文件内被引用
- 仅删除"本次改动产生孤儿"的 import；**不动**改动前就未使用的 import（避免越界）

### 边界

- 静态 import 谨慎处理：可能用于避免符号歧义
- 注解中使用的类型也算"被引用"

## 3. 硬编码 magic number → 提取常量（限定条件）

### 触发条件（**全部满足**才修）

- 数字在本次改动中新引入
- 项目已有对应常量类（如 `CommonConst`、`SystemConfigEnum`、模块级 `XxxConstant`）
- 数字含义清晰（不是临时计算的索引、循环边界）

### 模板

```java
// 改前
if (status == 1) { ... }

// 改后
if (status == ApplyStatusEnum.SUBMITTED.getCode()) { ... }
```

### 不修的场景（→ 启发式）

- 数字含义不明确 → 报告，让用户决定
- 没有现成常量类 → 报告，让用户决定是否新建
- 是循环边界、数组索引等局部含义 → 不动

## 4. 命名违反 R-NAME-001 ~ 003 → 重命名

### 仅修

- 本次新增的类 / 方法 / 变量 / 常量
- 命名违反明确规则（如 Service 接口未加 `I` 前缀、Entity 未加 `Entity` 后缀）

### 不修

- 既有代码的命名（即使违反规则）→ 仅报告
- 命名"是否表意"这种主观判断 → 启发式

### 命名速查

| 类型 | 模式 | 示例 |
|---|---|---|
| Controller | `XxxController` | `MaterialApplyController` |
| Service 接口 | `IXxxService` | `IMaterialApplyService` |
| Service 实现 | `XxxServiceImpl` | `MaterialApplyServiceImpl` |
| Repository | `XxxRepository` | `MaterialApplyRepository` |
| Mapper | `XxxMapper` | `MaterialApplyMapper` |
| Provider | `XxxDynamicSqlProvider` | `MaterialApplyDynamicSqlProvider` |
| Entity | `XxxEntity` | `MaterialApplyEntity` |
| Info / VO | `XxxInfo` | `MaterialApplyInfo` |
| Enum | `XxxEnum` | `ApplyStatusEnum` |
| 常量 | `UPPER_SNAKE_CASE` | `MAX_RETRY_COUNT` |
| 变量 / 方法 | `camelCase` | `userName` / `findById` |

## 5. 缺少类注释 / 方法注释 → 按模板补

### 类注释模板

```java
/**
 * @program: scm-code-backend
 * @description: <类用途一句话>
 * @author: <作者>
 * @create: 2026-05-09
 **/
```

### 方法注释模板（仅 public 方法强制）

```java
/**
 * <方法用途>
 *
 * @param xxx <参数说明>
 * @return <返回值说明>
 */
```

### 边界

- 私有方法：仅在逻辑非平凡时才补
- getter / setter / 简单透传方法：跳过
- 已有注释但内容空洞（如 `// 方法`）：标注为启发式，让用户决定是否重写

## 6. Repository / Mapper / Entity 后缀错误 → 改

仅在本次新增的类上修。修改前需确认包路径与命名匹配（参考 R-BASE-002）。

## 输出格式

```markdown
### 第二轮 A：决定性检查（已自动修复）
- [→] 字段注入修复 ：已改 3 个类（MaterialApplyServiceImpl 等）
- [→] 未使用 import 删除 ：删 5 处
- [→] Magic number 提取 ：1 处（status==1 → ApplyStatusEnum.SUBMITTED.getCode()）
- [✓] 命名规范 ：通过
```
