---
name: inventory-management
description: "Use when 涉及盘点项目、盘点计划、RFID 盘点代码，或用户提到 '盘点'、'inventory check'、'sqlXmls 动态过滤'、'refinedCondition'、'RadioGroupType'、'errorStatus'。包含数据模型、业务流程、关键代码模式和前后端文件索引。"
---
# 盘点管理模块 (Inventory Management)

## 业务概述

盘点管理覆盖企业固定资产的周期性盘点，包含三个子模块：
- **盘点项目管理** — 创建项目、生成快照、汇总结论
- **盘点计划管理** — 在项目下创建人工/自动化盘点计划，推送待办，收集确认
- **RFID盘点** — 手持设备扫描盘点

### 核心流程

```
创建盘点项目 (InvProject, inventoryStatus=0 进行中)
  ├─ 生成项目快照 (inv_project_snapshot) — 冻结资产当前状态
  │   └─ 分批插入，每批10000条
  ├─ 创建盘点计划 (InvPlan)
  │   ├─ 人工盘点 (planType=0) → 生成 inv_confirm_user + inv_user_record
  │   ├─ 机房自动化 (planType=1) → 生成 inv_confirm_machine
  │   ├─ 电脑自动化 (planType=2) → 生成 inv_confirm_computer
  │   └─ 网络设备自动化 (planType=4) → 生成 inv_confirm_user (networkStatus)
  ├─ 创建RFID盘点 (InvRfPlan) → 生成 inv_rf_confirm_assets
  └─ 关闭项目 (inventoryStatus=1)
```

---

## 数据模型

### 核心表

| 表名 | DTO | Entity | 用途 |
|------|-----|--------|------|
| `inv_project` | InvProject | — | 盘点项目主表 |
| `inv_project_snapshot` | InvProjectSnapshot | — | 项目资产快照（冻结时刻的资产状态） |
| `inv_plan` | InvPlan | InventoryPlanEntity | 盘点计划 |
| `inv_plan_sub` | InvPlanSub | InventoryPlanSubEntity | 计划子表（部门/类别范围） |
| `inv_confirm_user` | InvConfirmUser | InventoryConfirmUserEntity | 员工资产确认（人工盘点核心表） |
| `inv_user_record` | InvUserRecord | InventoryUserRecordEntity | 员工确认记录（待办状态） |
| `inv_confirm_computer` | — | InventoryConfirmComputerEntity | 电脑自动化确认 |
| `inv_confirm_machine` | — | InventoryConfirmMachineEntity | 机房自动化确认 |
| `inv_confirm_manager` | — | InventoryConfirmManagerEntity | 经理级确认 |
| `inv_rf_plan` | InvRfPlan | InventoryRfPlanEntity | RFID盘点计划 |
| `inv_rf_confirm_assets` | InvRfConfirmAssets | InventoryRfConfirmAssetsEntity | RFID资产确认 |

### DTO继承关系

所有盘点DTO继承 `BaseModel`，获得以下关键字段：
- `sqlXmls` / `sqlXmls2` — 动态SQL拼接（核心过滤机制）
- `pageIndex` / `pageSize` — 分页
- `id`, `isValid`, `creatorId`, `modifierId`, `remarks` 等通用字段

### InvProjectSnapshot 关键字段

```
项目快照表 inv_project_snapshot 核心字段：
├─ 资产信息: assetCode, assetName, assetType, assetStatus, assetCategory
├─ 物料信息: materialCode, materialName, matCategoryCode
├─ 组织信息: assetDeptCode, assetDeptName, regionId, regionName, cbdId, cbdName
├─ 人员信息: assetUserCode, assetUserName, assetManagerCode, assetManagerName
├─ 供应商: supplyAdminCode, supplyAdminName
├─ 盘点状态: confirmStatus(0未盘/1盘实/2盘亏/3盘盈), confirmRemarks
├─ 各计划状态: manualStatus, roomStatus, automationStatus, networkStatus, rfidStatus
├─ 各计划ID: manualPlanId, roomPlanId, automationPlanId, networkPlanId, rfidPlanId
├─ 财务字段: originalCost, netBookValue, retireClearAmount
├─ 其他: snCode, rfCode, areaManagerCode, errorStatus, importMark
└─ 项目: projectId, projectName
```

### InvConfirmUser 关键字段

```
员工确认表 inv_confirm_user 核心字段：
├─ 确认信息: confirmId, planId, confirmStatus, confirmResult
├─ 资产信息: assetCode, assetName, assetType, assetStatus
├─ 人员信息: assetUserCode, assetUserName, assetManagerCode, assetManagerName
├─ 组织信息: assetDeptCode, assetDeptName, regionId, regionName, cbdName
├─ 申诉信息: exceptionType, exceptionMsg
├─ 各计划状态: manualStatus, roomStatus, automationStatus, networkStatus, rfidStatus
├─ 搜索辅助: radioGroupId, containChildren, errorStatus, matCategoryCode, snCode
└─ 供应商: supplyAdminCode, supplyAdminName
```

---

## 枚举速查

| 枚举 | 值 | 说明 |
|------|-----|------|
| **InventoryConfirmResultEnum** | 0=NONE(无), 1=INVENTORY_REAL(盘实), 2=INVENTORY_LOSSES(盘亏), 3=INVENTORY_SURPLUS(盘盈) | 盘点结论 |
| **InventoryPlanTypeEnum** | 0=人工盘点, 1=机房自动化, 2=电脑自动化, 3=门店盘点(@IgnoreParseEnum), 4=网络设备自动化 | 盘点方法 |
| **InventoryPlanStatusEnum** | 0=OPEN(开启), 1=COMPLETED(完成) | 计划状态 |
| **InventoryPlanRangeTypeEnum** | 0=在库, 1=部门中使用, 2=闲置 | 盘点范围 |
| **InventoryConfirmStatusEnum** | 0=NOT_MATCH(未确认/未匹配), 1=OK(无问题), 2=FAILED(确认异常/匹配失败) | 确认匹配状态 |
| **InventoryUserRecordStatusEnum** | 0=WAIT_HANDLED(待处理), 1=COMPLETED(已完成), 2=CLOSED(已结束) | 员工待办状态 |
| **InventoryUserConfirmStatusEnum** | 0=OPEN(开启), 1=CLOSED(关闭) | 员工确认开关 |

---

## 后端文件索引

### Controller层

| 文件 | 路径前缀 | 关键端点 |
|------|---------|---------|
| `InvConfirmUserController` | `/scm/InvConfirmUserController` | listItemDetails(POST), initProject(GET), countProjectTabs(POST), uploadFile(POST), exportExcel(GET) |
| `InventoryProjectController` | `/scm/InventoryProjectController` | 项目CRUD、快照创建 |
| `InventoryPlanController` | `/inventory/plan` | 计划CRUD、初始化、关闭 |
| `InventoryConfirmController` | `/inventory/confirm` | 确认数据查询、导出 |
| `InventoryRfPlanController` | `/scm/InventoryRfPlanController` | RFID计划CRUD |

路径: `code-backend/project-pc/src/main/java/com/tcoa/scm/pc/controller/`

### Service层

| 文件 | 关键方法 |
|------|---------|
| `InvConfirmUserServiceImpl` | listItemDetails(), listRadioGroupProjectType(), listRadioGroupProjectTypeFiltered(), uploadFile(), exportExcel(), updateResult(), batchOperation() |
| `InventoryProjectServiceImpl` | createAndInsertInvProjectSnapshot(), 项目CRUD |
| `InventoryPlanServiceImpl` | addPlan(), initPlan(), closePlan() |
| `InventoryRfPlanServiceImpl` | addPlan(), RFID计划管理 |

路径: `code-backend/base-service/src/main/java/com/tcoa/scm/service/`

### Mapper层

| Mapper XML | 对应表 | 关键SQL |
|-----------|--------|--------|
| `invProjectSnapshotMapper.xml` | inv_project_snapshot | refinedCondition, selectRefinedList, countRefined, selectInventoryResultsFiltered |
| `invConfirmUserMapper.xml` | inv_confirm_user | refinedCondition, selectRefinedList, selectInventoryResults, selectConfirmResults |
| `invProjectMapper.xml` | inv_project | 项目查询 |
| `invPlanMapper.xml` | inv_plan | 计划查询 |
| `invRfConfirmAssetsMapper.xml` | inv_rf_confirm_assets | RFID确认查询 |
| `invUserRecordMapper.xml` | inv_user_record | 员工记录查询 |

路径: `code-backend/base-dao/src/main/resources/mapper/process/`

---

## 核心代码模式

### 1. sqlXmls 动态过滤模式

盘点模块的列表查询采用 **Java代码拼接SQL + XML refinedCondition** 双层过滤：

```
Java Service层 (listItemDetails / listRadioGroupProjectTypeFiltered)
  ├─ 复杂条件 → 拼接到 sqlXmls 字符串
  │   ├─ assetName: OR 模糊匹配 ASSET_CODE 和 ASSET_NAME
  │   ├─ assetDeptName: 部门层级查询 (buildQueryConditions)
  │   ├─ errorStatus: 多状态一致性检查（见下文）
  │   └─ matCategoryCode: 子查询 material_info
  ├─ 已处理的字段设为 null（防止 refinedCondition 重复过滤）
  └─ 设置 dto.setSqlXmls(sqlXmls)

XML Mapper层 (refinedCondition)
  ├─ 简单字段 → 直接 LIKE/= 过滤
  │   ├─ assetUserCode, assetManagerCode
  │   ├─ regionId, cbdName, supplyAdminCode
  │   ├─ assetStatus, snCode, areaManagerCode
  │   └─ projectId (必传)
  └─ ${sqlXmls} → 追加Java层拼接的复杂条件
```

**关键原则**：Java层处理过的字段必须 `setXxx(null)`，否则 refinedCondition 会重复过滤。

### 2. assetName OR 模糊匹配

```java
if (StringUtils.isNotBlank(dto.getAssetName())) {
    sqlXmls += " AND (`ASSET_CODE` LIKE CONCAT('%', '" + dto.getAssetName() + "', '%') "
             + "OR `ASSET_NAME` LIKE CONCAT('%', '" + dto.getAssetName() + "', '%')) ";
    dto.setAssetName(null);
    dto.setAssetCode(null);
}
```

### 3. 部门层级查询 (buildQueryConditions)

```java
// InvConfirmUserServiceImpl.buildQueryConditions(assetDeptName, containChildren)
// 位于 ~line 2011
// containChildren=true 时查询部门及所有子部门
// 生成 AND ASSET_DEPT_CODE IN (...) 条件
```

### 4. errorStatus 一致性检查

errorStatus 是前端传入的筛选值，用于判断各盘点方式结论是否一致：
- `errorStatus == 2`（不一致）：各状态字段（manualStatus, roomStatus, automationStatus, networkStatus, rfidStatus）中存在不同非零值
- `errorStatus == 1`（一致）：所有非零状态值相同
- 对应SQL非常复杂（约90行），涉及 CASE WHEN 多字段交叉比较

### 5. RadioGroupType Tab计数模式

前端tab栏显示各盘点状态的数量：

```java
// 项目详情页 — 查询 inv_project_snapshot
// 5个tab: 全部(-1), 盘实(1), 盘亏(2), 盘盈(3), 未盘(0)
// 对应 confirmStatus 字段

// 计划详情页 — 查询 inv_confirm_user
// 7个tab: 全部(-1), 盘实(1), 盘亏(2), 盘盈(3), 未盘(0), 申诉中(4), 已申诉(5)
// 对应 confirmStatus + exceptionType 组合
```

**计数联动**：tab计数必须跟随筛选条件变化，不能只按 projectId/planId 统计。使用 `listRadioGroupProjectTypeFiltered()` 传入完整搜索条件。

### 6. refinedCondition XML片段模式

```xml
<sql id="refinedCondition">
    <if test="projectId != null">AND `PROJECT_ID` = #{projectId}</if>
    <if test="assetUserCode != null and assetUserCode != ''">
        AND `ASSET_USER_CODE` LIKE CONCAT('%', #{assetUserCode}, '%')
    </if>
    <!-- ... 其他简单字段 ... -->
</sql>

<select id="selectRefinedList" resultType="...">
    SELECT * FROM table_name
    <where><include refid="refinedCondition" /></where>
    <![CDATA[ ${sqlXmls} ]]>
    ORDER BY ... LIMIT #{pageIndex}, #{pageSize}
</select>
```

### 7. 盘点结论导入模式

```java
// InvConfirmUserServiceImpl.uploadFile() ~line 998
// 1. 解析Excel (EasyExcel)
// 2. 校验行数上限（5000条）
// 3. 匹配资产编码 → 更新 confirmStatus
// 4. 返回错误列表 (JSON数组) 或纯文本错误消息
// 前端需同时处理JSON和纯文本两种错误格式
```

---

## 前端文件索引

### 页面

| 文件 | 路由 | 用途 |
|------|------|------|
| `projectManage.vue` | /assetcycle/inventory/projectManage | 盘点项目列表 |
| `projectManageDetail.vue` | /assetcycle/inventory/projectManageDetail | 盘点项目详情（快照列表、筛选、tab计数、导入导出） |
| `planList.vue` | /assetcycle/inventory/planList | 盘点计划列表 |
| `detail.vue` | /assetcycle/inventory/detail | 盘点计划详情（确认数据、申诉管理） |
| `confirmList.vue` | /assetcycle/inventory/confirmList | 确认列表 |
| `check.vue` | /assetcycle/inventory/check | 资产检查 |
| `dashboard.vue` | /assetcycle/inventory/dashboard | 盘点大屏 |

路径: `front-pc/src/pages/assetcycle/inventory/`

### API函数命名规范

```javascript
// 格式: {ControllerName}{MethodName}
// 示例:
InvConfirmUserControllerListItemDetails     // 项目详情列表
InvConfirmUserControllerInitProject         // 项目初始化（获取tab计数）
InvConfirmUserControllerCountProjectTabs    // 按筛选条件统计tab计数
InvConfirmUserControllerUploadFile          // 导入盘点结论
InvConfirmUserControllerExportExcel         // 导出
```

路径: `front-pc/src/utils/api/api.js`

### 前端关键模式

**searchForm 与 selectList 联动**：
```javascript
// searchForm 包含所有筛选字段
// selectList() 将 searchForm 作为参数调用后端
// 每次 selectList() 后调用 refreshProjectCounts() 刷新tab计数
// radioGroupId 不传入计数接口（计数是跨tab的汇总）
```

**Tab计数刷新**：
```javascript
async refreshProjectCounts() {
    let params = { ...this.searchForm };
    delete params.radioGroupId;  // 计数不受tab选择影响
    delete params.pageIndex;
    delete params.pageSize;
    let res = await this.$API.InvConfirmUserControllerCountProjectTabs(params);
    if (!res.code) {
        this.countsList = res.data;
    }
}
```

**离职人员红色标记**：
```javascript
// 在 columns 的 render 函数中
render: (h, params) => {
    const style = params.row.userResigned ? { color: '#ed4014' } : {};
    return h('span', { style }, params.row.assetUserName);
}
```

---

## 常见开发任务速查

### 增加筛选字段

1. **后端DTO** — 在 InvProjectSnapshot/InvConfirmUser 中添加字段（若不存在）
2. **Mapper XML** — 在 `refinedCondition` 中添加 `<if>` 条件
3. **Service** — 若需复杂逻辑（OR、子查询），在 `listItemDetails()` 中拼接 sqlXmls 并 setNull
4. **Controller** — 通常无需改动（DTO自动绑定）
5. **前端searchForm** — 添加字段和 FormItem
6. **导出** — 确认导出接口透传新字段

### 增加列表列

1. **Mapper XML** — SELECT 中添加字段（若未 SELECT *）
2. **前端columns** — 添加列定义 `{ title: 'xxx', key: 'fieldName', width: N }`
3. **导出** — 添加Excel列

### 修改Tab计数逻辑

1. **项目详情** — 修改 `selectInventoryResultsFiltered` SQL 或 `listRadioGroupProjectTypeFiltered()` 方法
2. **计划详情** — 修改 `selectConfirmResults` SQL 或 `listRadioGroupType()` 方法
3. 确保计数SQL的WHERE条件与列表查询一致

### 修改盘点状态逻辑

1. 定位状态写入代码（通常在 ServiceImpl 的 initPlan/closePlan/updateResult 方法中）
2. 确认涉及的状态字段：manualStatus, roomStatus, automationStatus, networkStatus, rfidStatus
3. 使用 `InventoryConfirmResultEnum` 枚举值

---

## 注意事项

1. **SQL注入风险** — sqlXmls 拼接使用字符串拼接而非参数化，这是历史遗留模式。新增条件时保持一致即可，但注意不要引入用户可控的未转义输入。
2. **分页清除** — 统计计数时必须 `setPageIndex(null); setPageSize(null);`，否则SQL会带 LIMIT。
3. **字段置空** — Java层处理过的字段必须 setNull，否则 refinedCondition 重复过滤导致结果错误。
4. **快照大数据量** — 快照创建分批10000条插入；导出需流式写入（EasyExcel）避免OOM。
5. **R-FORCE-001** — 修改任何 .java 文件时，必须将该文件中的 `@Autowired` 字段注入改为 setter 注入。
6. **盘点项目状态** — `inventoryStatus`: 0=进行中, 1=已关闭。RFID创建计划时需校验项目状态为进行中。
7. **申诉逻辑** — "申诉中"tab应排除已有最终结论（盘实/盘亏）的记录，即 `exceptionType IN (1,3) AND confirmStatus = 0`。
