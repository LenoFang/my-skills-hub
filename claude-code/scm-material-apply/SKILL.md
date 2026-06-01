---
name: scm-material-apply
description: 查询当前用户的物资申请单据（待处理 / 已处理 / 出库待处理 / 出库已处理）。当用户问"我的物资申请"、"待审物资单"、"我有什么物资申请要处理"时使用。
---

# scm-material-apply

## 触发条件

用户问到以下任一内容时调用：
- "我的物资申请"
- "待审物资单" / "待处理物资申请" / "需要我审批的物资单"
- "我有什么物资申请要处理"
- "查物资申请"

## 调用方式

CLI 命令（已通过 spawn 注入 `TCOA_WORK_ID` 环境变量，无需在命令里写工号）：

```bash
# 我的待处理物资申请（默认 doType=wait-todo）
scm list material-applies --mine --format json

# 显式指定状态
scm list material-applies --mine --do-type wait-todo --format json
scm list material-applies --mine --do-type did --format json        # 已处理
scm list material-applies --mine --do-type out-todo --format json   # 出库待处理
scm list material-applies --mine --do-type out-did --format json    # 出库已处理
scm list material-applies --mine --do-type all --format json        # 全部
```

## 输出字段（json 格式）

| 字段 | 含义 |
|------|------|
| applyNo | 申请单号 |
| title | 标题 |
| applyUserName | 申请人 |
| deptName | 部门 |
| statusName | 状态显示文本 |
| createTime | 创建时间 |
| total | 列表总数 |

## 失败处理

- 退出码非零 → 把 stderr 原文回复给用户
- 常见错误：
  - `TCOA_WORK_ID is empty` → 提示用户："系统未识别到您的工号，请联系管理员"
  - `appKey and appSecret are required` → CLI 部署侧未配置凭证，提示运维
  - `401` 或 `sid` 失效 → CLI 已自动重新调 `/api/openclaw/session` 重试一次

## 注意事项

- 不要把工号写进命令行参数；工号必须由 spawn 进程通过 `TCOA_WORK_ID` 环境变量注入
- `--mine` 走 `/matapply/list` 个人视图，自动按当前会话用户过滤；不要用 `/mlist`（管理员视图）
