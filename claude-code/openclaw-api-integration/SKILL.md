---
name: openclaw-api-integration
description: OpenClaw AI助手集成指南：认证流程（API Token + 工号登录）、接口发现API、可用业务接口清单、数据权限说明、调用示例。当 OpenClaw 需要查询 SCM 数据时使用。
---
# OpenClaw AI助手 - SCM 集成指南

> OpenClaw 通过工号登录获取用户会话，然后直接调用 SCM 现有业务接口查询数据。
> 所有数据权限过滤由 SCM 系统自动应用，无需额外处理。

---

## 一、认证流程

### 1.1 获取 API Token

OpenClaw 首先需要通过 appKey/appSecret 获取 Bearer Token，用于调用 `/api/openclaw/*` 接口。

```
POST /api/auth/token
Content-Type: application/json

{"appKey": "openclaw_appkey", "appSecret": "openclaw_appsecret"}

Response:
{
  "code": 0,
  "data": {
    "accessToken": "abc123...",
    "refreshToken": "def456...",
    "expiresIn": 86400
  }
}
```

Token 有效期 24 小时。过期前使用 `POST /api/auth/refresh` 刷新。

### 1.2 工号登录（建立用户会话）

用 Bearer Token 调用工号登录接口，获取用户 Session ID（sid）。

```
POST /api/openclaw/login
Authorization: Bearer {accessToken}
Content-Type: application/json

{"workId": "1013011"}

Response:
{
  "code": 0,
  "data": {
    "sid": "session-id-xxx",
    "userId": "12345",
    "username": "张三",
    "workId": "1013011",
    "department": "信息技术部",
    "departmentId": "100",
    "manageUnit": "WL",
    "permissionList": ["system:materialApply:permission", ...]
  }
}
```

**重要**：sid 有效期 30 分钟，应缓存复用。过期后重新登录即可。

### 1.3 调用业务接口

后续调用 SCM 业务接口时，通过 Cookie 头传递 sid：

```
GET /matapply/mlist?pageNum=1&pageSize=20
Cookie: sid={sessionId}
```

---

## 二、接口发现

### 2.1 获取推荐接口列表

```
GET /api/openclaw/endpoints
Authorization: Bearer {accessToken}

Query Parameters:
  - module (可选): 按模块过滤，如 "物资申请"
  - keyword (可选): 按路径/描述模糊搜索
```

返回按业务模块分组的推荐接口列表，每个接口包含路径、HTTP方法、优先级（level）、AI描述等元数据。
同一模块内按 level 降序排列，OpenClaw 应优先使用高 level 接口，失败后降级到低 level 接口。
管理员可在 SCM 管理后台「API接口管理 → OpenClaw推荐」页面配置哪些接口推荐给 AI。

### 2.2 优先级（Level）说明

| Level | 含义 | 典型接口 |
|-------|------|----------|
| 5 | 最优先 - 数据最全面、最稳定 | `/matapply/mlist`（管理员视图） |
| 4 | 功能完整的标准查询接口 | 带完整过滤参数的列表接口 |
| 3 | 普通可用接口（默认） | 一般查询接口 |
| 2 | 参数复杂或功能有限 | 需要特殊参数格式的接口 |
| 1 | 备用/兜底接口 | 简单但数据有限的接口 |

**调用策略**：同一模块内，先调用 level=5 的接口；如果返回权限不足或异常，降级到 level=4，依次往下。

---

## 三、日志记录

OpenClaw 可通过日志接口记录重要操作日志到 SCM 的 `sys_log` 表。

```
POST /api/openclaw/log
Authorization: Bearer {accessToken}
Content-Type: application/json

{
  "level": "info",         // info / warn / error
  "title": "查询物资申请",
  "content": "调用 /matapply/mlist 返回 23 条数据",
  "module": "物资申请",     // 可选，业务模块
  "refKey": "MA202603001"  // 可选，关联业务单号
}
```

建议在以下场景记录日志：
- 查询到重要数据时（level=info）
- 调用接口失败或降级时（level=warn）
- 出现异常或数据不一致时（level=error）

---

## 四、发送消息

OpenClaw 可通过消息接口发送企微通知。支持三种消息类型：

```
POST /api/openclaw/message
Authorization: Bearer {accessToken}
Content-Type: application/json
```

### 4.1 企微应用消息（发送给指定用户）
```json
{
  "type": "text",
  "receivers": "1013011|1224812",
  "content": "您好，您申请的物资已审批通过"
}
```

### 4.2 企微机器人消息（发送到群）
```json
{
  "type": "robot",
  "content": "SCM库存预警：物料 A001 库存低于安全值",
  "robotKey": ""
}
```

### 4.3 企微机器人 Markdown 消息
```json
{
  "type": "robot_markdown",
  "content": "### 库存预警\n- 物料 A001: 当前 5，安全值 10\n- 物料 B002: 当前 3，安全值 8",
  "robotKey": ""
}
```

`robotKey` 为空时使用系统默认机器人，可在系统配置中查看已配置的机器人列表。

---

## 五、核心业务接口参考

以下接口均需要 Session 认证（`Cookie: sid=xxx`）。

### 3.1 物资申请

| 路径 | 方法 | 说明 |
|------|------|------|
| `/matapply/list` | GET | 我的物资申请列表（个人视图） |
| `/matapply/mlist` | GET | 物资申请管理员列表（按数据权限过滤） |

**查询参数（`MaterialApplyQueryInfo`，GET 参数绑定）**：
- `pageNum` / `pageSize` - 分页
- `doType` - 处理类型（待处理/已处理/待出库/已出库）
- `viewType` - 数据视图类型（影响数据权限范围）
- `dateStart` / `dateEnd` - 日期范围
- `keyword` - 关键词

**返回**：`PageResult<MaterialApplyInfo>`（包含 `list` 数组和 `total` 总数）

### 3.2 采购订单

| 路径 | 方法 | 说明 |
|------|------|------|
| `/purchase/order/list` | GET | 我的采购订单列表（个人视图） |
| `/purchase/order/mlist` | GET | 采购订单管理员列表（按数据权限过滤） |

**查询参数（`PurchaseOrderSearchModel`，GET 参数绑定）**：
- `pageNum` / `pageSize` - 分页
- `viewType` - 数据视图类型
- `keyword` - 关键词

**返回**：`PageResult<PurchaseOrderInfo>`

### 3.3 资产信息

| 路径 | 方法 | 说明 |
|------|------|------|
| `/assetData/list` | POST | 资产信息列表（按数据权限过滤） |

**请求体（`MaterialAssetSearchInfo`，JSON Body）**：
```json
{
  "pageNum": 1,
  "pageSize": 20,
  "viewType": "",
  "keyword": ""
}
```

**返回**：`PageResult<MaterialAssetDataVO>`

### 3.4 时效看板

基础路径：`/kanban/procurement-efficiency`

| 路径 | 方法 | 说明 |
|------|------|------|
| `.../materialApplyCount` | GET | 近一月物资申请数 |
| `.../purchaseApplyCount` | GET | 近一月采购申请数 |
| `.../purchaseOrderCount` | GET | 近一月采购订单数 |
| `.../purchaseToPrOverdue` | GET | 采购申请超期列表 |
| `.../materialProcessOverdue` | GET | 物资处理超期列表 |

参数：`refresh=true`（是否刷新缓存，默认 true）
返回：`CommonResultVO`

---

## 六、数据权限说明

### 4.1 viewType 参数

`viewType` 控制数据查询范围，对应 `RegionViewTypeEnum`：

| viewType | 说明 | 数据范围 |
|----------|------|----------|
| (空/不传) | 默认视图 | 根据用户角色自动判断 |
| PERSONAL | 个人视图 | 仅当前用户自己的数据 |
| DEPT | 部门视图 | 当前用户所在部门的数据 |
| MATERIAL | 物资视图 | 按物资管理区域过滤 |
| REGION | 区域视图 | 按区域过滤 |
| ALL | 全部视图 | 所有数据（需超管权限） |

### 4.2 权限自动过滤

- 使用 `/list` 类接口时，系统自动过滤为**当前用户（工号登录的用户）**的个人数据
- 使用 `/mlist` 类接口时，系统根据 `viewType` 和用户角色**自动应用数据权限 SQL**
- 权限数据来自 `PermissionEnum` 配置，由 Shiro Session 中的用户角色决定

---

## 七、通用返回值格式

### 5.1 CommonResultVO

```json
{
  "code": 0,        // 0=成功，非0=失败
  "msg": "成功",
  "count": 10,      // 数据条数（列表时）
  "data": { ... }   // 具体数据
}
```

### 5.2 PageResult

```json
{
  "total": 100,          // 总记录数
  "list": [              // 数据列表
    { "formId": "...", ... }
  ]
}
```

---

## 八、完整调用示例

```bash
# 1. 获取 API Token
curl -X POST http://scm.example.com/scm/api/auth/token \
  -H "Content-Type: application/json" \
  -d '{"appKey":"openclaw_key","appSecret":"openclaw_secret"}'

# 2. 工号登录
curl -X POST http://scm.example.com/scm/api/openclaw/login \
  -H "Authorization: Bearer {accessToken}" \
  -H "Content-Type: application/json" \
  -d '{"workId":"1013011"}'

# 3. 发现可用接口
curl -X GET "http://scm.example.com/scm/api/openclaw/endpoints?module=物资申请" \
  -H "Authorization: Bearer {accessToken}"

# 4. 查询物资申请列表
curl -X GET "http://scm.example.com/scm/matapply/mlist?pageNum=1&pageSize=20" \
  -H "Cookie: sid={sessionId}"

# 5. 查询采购订单列表
curl -X GET "http://scm.example.com/scm/purchase/order/mlist?pageNum=1&pageSize=10" \
  -H "Cookie: sid={sessionId}"
```

---

## 九、关键代码位置

| 功能 | 文件路径 |
|------|----------|
| OpenClaw Controller | `project-pc/.../controller/api/OpenClawController.java` |
| API Token 认证 | `project-pc/.../controller/api/ApiAuthController.java` |
| API 拦截器 | `base-common/.../interceptor/ApiInterceptor.java` |
| 端点扫描器 | `base-service/.../api/impl/ApiEndpointScanner.java` |
| 端点管理服务 | `base-service/.../api/impl/ApiEndpointServiceImpl.java` |
| 用户会话建立 | `base-domain/.../Oauth/UserInfo.java` → `setCurrentUser()` |
| 用户信息生成 | `admin-backend/.../api/AuthorizeUtils.java` → `generateUserInfo()` |
| 数据权限工具 | `base-common/.../utils/PermissionUtil.java` |
