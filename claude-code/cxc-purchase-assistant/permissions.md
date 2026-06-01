# 权限处理

> 本文件在 SKILL.md Step 6 加载。skill 端只负责"拉权限 + 求交集"，映射表归 cli 项目维护。

---

## 1. 拉取协议

```yaml
cli: current-user              # /scm/getUser 一次返回用户信息 + 权限
params: {}                     # 依赖 session cookie / token
returns:                       # 扁平结构，非嵌套
  userId: Long
  username: String
  workId: String
  departmentId: Long
  department: String
  currentManageUnitName: String
  perms: [permission_code]     # 权限串数组
  urls: [url]                  # 可访问 URL 列表
cache_ttl: 600s                # 与会话上下文 TTL 对齐
```

> **重要**：后端 `/scm/getUser` 返回扁平字段，不是 `{ userInfo: {...}, perms: [...] }` 嵌套结构。
> 取值时用 `data.userId`、`data.perms`，不是 `data.userInfo.user_id`。

---

## 2. 映射来源

权限映射表的**单一事实源**在 cli 项目：

```yaml
mapping_source:
  config: cli/schema/permissions.config.json       # 人工维护的配置
  ts_import: cli/src/commands/generated/permissions.ts    # TS 消费者（自动生成）
  reverse_index: endpointToPermissions
  check_function: checkEndpointPermission          # 辅助函数，可直接调用
```

### 生成命令

```bash
cd cli && npm run gen:permissions
```

### 类型签名

```ts
export type PermissionRequirement = {
  any_of?: string[];   // 缺省时省略（不写空数组）
  all_of?: string[];   // 缺省时省略
};

// key = endpointPath 原值（含前导 /，不规整化）
export const endpointToPermissions: Record<string, PermissionRequirement>;
```

### 三态语义

| 查询结果 | 含义 | 动作 |
|---|---|---|
| `endpointToPermissions[path] === undefined` | unmapped | 保守拒绝 + 记日志 |
| `endpointToPermissions[path] === {}` | 显式声明"无权限要求" | 放行 |
| `endpointToPermissions[path] = { any_of: [...] }` | 正常门槛 | 求交集判定 |

---

## 3. 校验伪码

```python
def check_endpoint(endpoint_path: str, user_perms: list[str]) -> dict:
    required = endpoint_to_permissions.get(endpoint_path)

    if required is None:
        # unmapped → 保守拒绝
        return { "ok": False, "reason": "unmapped", "endpoint": endpoint_path }

    if not required:
        # 显式无门槛 → 放行
        return { "ok": True }

    if "any_of" in required:
        if set(required["any_of"]) & set(user_perms):
            return { "ok": True }
        else:
            return { "ok": False, "reason": "no_matching_permission",
                     "required": required["any_of"] }

    if "all_of" in required:
        if set(required["all_of"]).issubset(set(user_perms)):
            return { "ok": True }
        else:
            missing = set(required["all_of"]) - set(user_perms)
            return { "ok": False, "reason": "missing_permissions",
                     "missing": list(missing) }

    # 无 any_of 也无 all_of（理论上不应出现，等同无门槛）
    return { "ok": True }
```

---

## 4. 多 scope 端点选择策略

同 feature 有多个 scope 端点时（如 `/matapply/list` 个人版、`/matapply/mlist` 管理端），Plan 阶段优先选用户权限覆盖到的**最广 scope** 端点。

```
scope 优先级：all > dept > personal

示例：
  用户权限含 system:matapply:dept
  候选端点：/matapply/list (personal), /matapply/mlist (dept/all)
  → 选 /matapply/mlist（scope 更广，且用户有 dept 权限）
```

---

## 5. 数据级可见性

**skill 不参与**。由后端按透传的 `user_id` 在接口层过滤数据可见性。skill 只确保"有没有权限调这个接口"，不判断"能看到哪些数据"。
