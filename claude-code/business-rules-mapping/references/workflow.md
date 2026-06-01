# 审批流程模块（BIZ-WOLF-001）

> 主 SKILL.md 的子文档。审批系统（Wolf）相关业务与代码映射。

## BIZ-WOLF-001 采购申请审批回调

**功能描述**：处理审批系统的回调事件

**入口**：
- `WolfCallbackController` - 回调接口

**实现类**：
- `PurchaseApplyWolfServiceImpl`

**回调方法**：
| 方法 | 说明 |
|------|------|
| `submitForm()` | 提交审批 |
| `agreeForm()` | 审批同意 |
| `rejectForm()` | 审批驳回 |
| `completeForm()` | 审批完成 |
| `recallForm()` | 撤回申请 |

---

## 变更摘要

| 日期 | 业务编号 | 描述 |
|------|---------|------|
| — | — | 尚未单独记录 |
