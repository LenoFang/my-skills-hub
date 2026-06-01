# 第一轮：功能完整性详细参考

> 主 SKILL.md 的子文档。需求实现后第一轮复查的判定细节。

## 6 项检查

### 1. 需求逐条对照

- 打开需求文档（MD / proposal.md / raw-requirement.md / Issue）
- 列出所有可分解的功能点（每条独立编号）
- 对每条功能点查找对应实现代码
- 标注：已实现 / 部分实现 / 未实现

### 2. 输入输出异常完整性

每个新增 / 修改的 Service 方法应满足：

- 输入参数完整（方法签名匹配需求描述）
- 返回值类型与需求一致（Info / VO / List / Page）
- 关键路径有异常处理（业务异常使用 BizException，参数校验使用 IllegalArgumentException 或 javax.validation）
- 边界值（空集合、null、超长字符串）至少有一处明确处理

### 3. 桩代码 / TODO 检测

搜索全部本次改动的文件：

- `// TODO`、`// FIXME`、`throw new RuntimeException("not implemented")`
- 空方法体（仅 `return null;`、`return;`、`throw new UnsupportedOperationException()`）
- 待补充的常量值（如 `private static final int X = 0; // TODO`）

发现立即补；无法补的需求需求未明确，**不要随意填默认值**，停下来问用户。

### 4. 前后端接口对齐

| 检查项 | 后端 | 前端 |
|---|---|---|
| URL 路径 | Controller `@RequestMapping` | api 文件中的路径常量 |
| HTTP 方法 | `@GetMapping` / `@PostMapping` | axios 调用方法 |
| 请求参数名 | `@RequestParam` / `@RequestBody` 字段 | params / data 字段 |
| 返回格式 | Info 字段 | 前端解析的字段路径 |
| 分页参数 | `pageIndex` / `pageSize` | 同名 |

任一不对齐立即补对侧。

### 5. 配置项 / 常量遗漏

- 需求文档提到的环境变量是否在 `application-{env}.yml` 配置
- 需求文档提到的字典 / 枚举值是否在 Enum 类定义
- 需求文档提到的常量是否提取（如 "默认每页 20 条" 应在常量类）

### 6. 发现遗漏立即补

- 补完后**重新跑第一轮**直到全部通过，再进入第二轮
- 补的过程中如发现需求本身有歧义，停下来问用户，**不要靠猜**

## 输出格式

```markdown
### 第一轮：功能完整性
- [✓] 需求 1.1 物料申请 Controller ：通过
- [→] 需求 1.2 申请单状态枚举 ：已补（新增 ApplyStatusEnum.java）
- [!] 需求 1.3 审批流分支 ：存在问题（需求未明确驳回后是否允许重新提交，已暂停等用户回答）
```
