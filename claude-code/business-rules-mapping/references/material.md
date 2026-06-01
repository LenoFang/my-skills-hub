# 物料信息模块（BIZ-MAT-001 ~ 010）

> 主 SKILL.md 的子文档。物料模块的业务与代码映射。

## BIZ-MAT-001 物料类型定义

**功能描述**：物料根据类型分为三大类，每类有不同的申请/审批流程

**物料类型枚举**：`MaterialTypeEnum`
| Code | 枚举值 | 说明 |
|------|--------|------|
| 0 | REAL_MATERIAL | 实物物料 |
| 1 | VIRTUAL_MATERIAL | 费用物料（非实物） |
| 2 | SERVICE_MATERIAL | 服务物料 |

**物料类别枚举**：`MaterialCategoryEnum`（一级分类前缀）
| Code | 枚举值 | 说明 |
|------|--------|------|
| G | FIX | 固定资产 |
| D | LOW_COST | 低值业务资产 |
| O | ANIMAL | 生物资产 |
| W | CONSUMABLE | 物耗品 |
| H | HOTEL | 酒管物料 |
| F | COST | 费用物料 |
| S | SERVICE | 服务物料 |
| P | WELFARE_GOODS | 福利商品 |

---

## BIZ-MAT-002 物料数据实体结构

**核心实体表**：
| 实体类 | 数据库表 | 说明 |
|--------|----------|------|
| `MaterialInfoEntity` | `material_info` | 物料主数据（最终生效数据） |
| `MaterialFormEntity` | `material_form` | 物料申请单主表 |
| `MaterialFormWhEntity` | `material_form_wh` | 物料申请-仓库属性 |
| `MaterialFormPurEntity` | `material_form_pur` | 物料申请-采购属性 |
| `MaterialFormFinEntity` | `material_form_fin` | 物料申请-财务属性 |

**物料属性分类**（2026-02-03 调整后）：
| 属性类别 | 包含字段 | 存储位置 | 前端显示位置 |
|----------|----------|----------|-------------|
| 基础属性 | 物料编码、名称、类别、型号规格、图片 | `MaterialFormEntity` | 申请信息模块 |
| 仓库属性 | 库存单位、资产编码生成方式、去除用途、允许用途、是否显示、是否转采购、是否IT资产、效期管理、批次管理 | `MaterialFormWhEntity` | 仓库属性模块 |
| 采购属性 | 采购单位、采购转换率、参考含税单价、采购周期、维保说明 | `MaterialFormPurEntity` | 采购属性模块 |
| 财务属性 | 资产类别、**是否允许跨公司调拨、调拨是否计税** | `MaterialFormFinEntity`（逻辑属性） | **财务属性模块**（默认显示） |

**注意**：「是否允许跨公司调拨」和「调拨是否计税」数据库存储在 `MaterialFormWhEntity`，但前端显示在财务属性模块。

**关键字段说明**：
| 字段名 | 数据库字段 | 所在表 | 说明 |
|--------|-----------|--------|------|
| `allowCrossCompanyAllot` | `allow_cross_company_allot` | `MaterialFormWhEntity`、`MaterialInfoEntity` | 是否允许跨公司调拨 |
| `allowAllotCalcTax` | `allow_allot_calc_tax` | `MaterialFormWhEntity`、`MaterialInfoEntity` | 调拨是否计税 |

---

## BIZ-MAT-003 实物物料新增流程

**功能描述**：实物物料新增需要经过多个角色依次完善数据，最终生成物料主数据

**流程状态枚举**：`MaterialFormStatusEnum`
| Code | 枚举值 | 说明 | 角色 |
|------|--------|------|------|
| 0 | DEFAULT | 提交申请 | 申请人 |
| 9 | HEAD_OFFICE_APPROVE | 总部物资管理员审批 | 总部物资员 |
| 1 | PURCHASE_COLLECT | 采购属性收集 | 采购属性收集专员 |
| 2 | FINANCE_COLLECT | 财务属性收集 | 财务属性收集专员 |
| 4 | COMPLETED | 完成 | - |
| 5 | REJECTING | 节点驳回 | - |
| 6 | REJECTED | 驳回 | - |
| 7 | REVOKE | 撤回 | - |

**流程节点顺序**：
```
申请人提交 (DEFAULT) 
    → 总部物资管理员审批 (HEAD_OFFICE_APPROVE)
    → 采购属性收集 (PURCHASE_COLLECT)
    → 财务属性收集 (FINANCE_COLLECT，仅G/O类需要)
    → 完成 (COMPLETED)
```

**涉及角色常量**：`Constant.RoleCode`
| 常量名 | 角色说明 |
|--------|----------|
| `MATERIAL_HEAD_OFFICE_ADMIN` | 总部物资管理员 |
| `MATERIAL_FORM_PUR_MANAGER` | 采购属性收集管理员 |
| `MATERIAL_FORM_FIN_MANAGER` | 财务属性收集管理员 |
| `MATERIAL_FORM_MAIN_MANAGER` | 主数据管理员 |

**核心逻辑**：
| 方法 | 所在类 | 说明 |
|------|--------|------|
| `add()` | `MaterialFormServiceImpl` | 新增申请提交 |
| `saveMaterialFormInfo()` | `MaterialFormServiceImpl` | 总部物资管理员审批 |
| `savePurchaseProperties()` | `MaterialFormServiceImpl` | 采购属性收集 |
| `saveFinanceProperties()` | `MaterialFormServiceImpl` | 财务属性收集 |

**前端页面路径**：`front-pc/src/pages/materialsmanage/real/`
| 页面文件 | 功能说明 |
|----------|----------|
| `submit.vue` | 新增申请提交 |
| `check.vue` | 总部物资管理员审批 |
| `purchaseCollect.vue` | 采购属性收集 |
| `financeCollect.vue` | 财务属性收集 |
| `approver.vue` | 主数据管理员审批 |
| `list.vue` | 物料查询列表 |

**财务属性显示条件**：
```java
// MaterialFormServiceImpl.checkNeedFinance()
return materialFormEntity.getMfCategoryCode().startsWith("G") ||
       materialFormEntity.getMfCategoryCode().startsWith("O");
```

**跨公司调拨默认不允许的类别**：
```java
// MaterialFormServiceImpl.ALLOT_NOT_ALLOW_CROSS_COMPANY_DEFAULT_LIST
"D.1.1", "G.1.1", "G.2.1.01", "G.2.2", "G.3", "W.1.2", "D.3", "W.2.7", "H.1.2", "G.1.4", "G.1.5"
```

---

## BIZ-MAT-004 实物物料查询

**功能描述**：查询已生效的物料信息，支持编辑部分字段

**核心逻辑**：
| 方法 | 所在类 | 说明 |
|------|--------|------|
| `getPageList()` | `MaterialInfoServiceImpl` | 分页查询物料列表 |
| `getMaterialInfo()` | `MaterialInfoServiceImpl` | 获取物料详情 |
| `update()` | `MaterialInfoServiceImpl` | 主管更新物料信息 |

**前端页面**：`front-pc/src/pages/materialsmanage/real/list.vue`

---

## BIZ-MAT-005 实物物料更新流程

**功能描述**：已生成的物料需要更新属性时，发起更新申请

**流程特点**（2026-02-11 优化）：
- 更新流程采用动态审批，根据修改的属性类型决定审批路径
- 提交时直接确定第一个具体审批状态（11/12/13），不再统一使用 WAIT_APPROVE(3)
- 每个审批节点通过时，由 `determineNextUpdateStatus()` 计算下一个具体状态
- 每个节点操作时校验当前用户角色（`validateUpdateApprovalRole()`）
- 前端可根据 `mfStatus`（11/12/13）直接判断当前阶段和按钮权限
- 可编辑字段：去除用途、允许用途、是否显示、是否转采购、是否IT资产、采购单位、采购转换率、是否允许跨公司调拨、调拨是否计税
- 变更字段在审批页面红色高亮显示

**动态审批状态枚举**（已实现，直接使用具体状态码流转）：
| Code | 枚举值 | 说明 | 审批角色 | 角色常量 |
|------|--------|------|----------|----------|
| 11 | UPDATE_WAREHOUSE_APPROVE | 仓库属性审批 | 总部物资管理员 | `RoleRelationConstant.MATERIAL_HEAD_OFFICE_ADMIN` |
| 12 | UPDATE_PURCHASE_APPROVE | 采购属性审批 | 主数据管理员 | `RoleRelationConstant.MATERIAL_FORM_MAIN_MANAGER` |
| 13 | UPDATE_FINANCE_APPROVE | 财务属性审批 | 资产会计 | `RoleRelationConstant.ASSET_ACCOUNTING` |

**审批流程顺序**（提交时确定第一个具体状态，每次审批通过计算下一状态）：
```
仓库属性变更 → status=11 总部物资管理员审批（validateUpdateApprovalRole校验角色）
    → 采购属性变更 → status=12 主数据管理员审批（validateUpdateApprovalRole校验角色）
    → 财务属性变更 → status=13 资产会计审批（validateUpdateApprovalRole校验角色）
    → 完成 (COMPLETED, status=4)
注：只有变更了对应属性才进入该节点，未变更跳过
```

**字段属性归类**：
| 属性类型 | 包含字段 | 审批角色 |
|----------|----------|----------|
| 仓库属性 | 去除用途、允许用途、是否显示、是否转采购、是否IT资产 | 总部物资管理员 |
| 采购属性 | 采购单位、采购转换率 | 主数据管理员 |
| 财务属性 | 是否允许跨公司调拨、调拨是否计税 | 资产会计 |

**字段变更检测配置**：
- 配置类：`MaterialUpdateFieldConfig`（`base-service/.../material/config/`）
- 映射类：`MaterialFieldMapping`（`base-domain/.../viewobject/materialform/`）
- 新增字段时只需在配置类对应方法中添加映射，无需修改判断逻辑

**核心逻辑**：
| 方法 | 所在类 | 说明 |
|------|--------|------|
| `addUpdate()` | `MaterialFormServiceImpl` | 更新申请提交，含变更检测，直接设置具体审批状态(11/12/13) |
| `detectMaterialUpdateChanges()` | `MaterialFormServiceImpl` | 检测变更字段（调用配置类） |
| `determineUpdateInitialStatus()` | `MaterialFormServiceImpl` | 确定初始审批状态，返回具体的 11/12/13 |
| `updPass()` | `MaterialFormServiceImpl` | 动态审批通过，含角色权限校验 |
| `determineNextUpdateStatus()` | `MaterialFormServiceImpl` | 根据当前状态和变更信息确定下一审批状态 |
| `validateUpdateApprovalRole()` | `MaterialFormServiceImpl` | 校验当前用户是否有对应审批节点的角色权限 |
| `getUpdateStatusRoleCode()` | `MaterialFormServiceImpl` | 根据更新流程状态码获取对应角色编码 |
| `getUpdateChangeInfo()` | `MaterialFormServiceImpl` | 获取变更信息（前端高亮用） |
| `getReturnableNodes()` | `MaterialFormServiceImpl` | 获取可退回节点（支持更新流程状态11/12/13） |
| `returnBack()` | `MaterialFormServiceImpl` | 退回操作（支持更新流程） |

**API接口**：
| 接口 | 说明 |
|------|------|
| `GET /materialForm/getUpdateChangeInfo?mfId=` | 获取变更字段信息，用于前端红色高亮 |
| `GET /materialForm/getReturnableNodes?mfId=` | 获取可退回节点列表 |
| `POST /materialForm/return` | 退回至指定节点 |

**退回节点配置**（支持更新流程）：
- `isUpdateFlowStatus()` - 判断是否物料更新流程
- `getUpdateReturnableNodeStatusList()` - 更新流程可发起退回的状态
- `getUpdateReturnableNodes()` - 更新流程可退回的目标节点

**变更信息VO类**：
- `MaterialUpdateChangeInfo` - 变更汇总信息
- `FieldChangeInfo` - 单个字段变更详情
- `MaterialPropertyTypeEnum` - 属性类型枚举

**前端页面路径**：`front-pc/src/pages/materialsmanage/real/update/`
| 页面文件 | 功能说明 |
|----------|----------|
| `submit.vue` | 更新申请提交（可编辑字段扩展） |
| `approver.vue` | 更新审批（变更字段红色高亮）|

---

## BIZ-MAT-006 费用物料（无形资产）流程

**功能描述**：费用物料（非实物）的新增流程

**流程节点**：
```
申请人提交 (DEFAULT) 
    → 财务审核 (FINANCE_APPROVE)
    → 主数据管理员审批 (WAIT_APPROVE)
    → 完成 (COMPLETED)
```

**核心逻辑**：
| 方法 | 所在类 | 说明 |
|------|--------|------|
| `financePass()` | `MaterialFormServiceImpl` | 财务审核通过 |
| `addPass()` | `MaterialFormServiceImpl` | 主数据管理员审批通过 |

**前端页面路径**：`front-pc/src/pages/materialsmanage/virtual/`

---

## BIZ-MAT-007 服务物料流程

**功能描述**：服务物料的新增流程

**流程节点**（2026-02-03 优化后）：
```
申请人提交 (DEFAULT)
    → 直接完成 (COMPLETED) 【去除主数据管理员审批】
```

**流程简化说明**：
- 服务物料不再需要主数据管理员审批
- 申请人提交后自动生成物料编码并完成
- 系统通知申请人物料创建成功

**核心逻辑**：
| 方法 | 所在类 | 说明 |
|------|--------|------|
| `processServiceMaterialComplete()` | `MaterialFormServiceImpl` | 服务物料直接完成处理 |

**前端页面**：复用 `virtual/` 目录

---

## BIZ-MAT-008 物料角色权限

**角色枚举**：`MaterialRoleEnum`
| Code | 角色说明 |
|------|----------|
| 14 | 物料管理员审批 |
| 15 | 资产-仓库属性收集专员 |
| 16 | 采购属性收集专员 |
| 17 | 财务属性收集专员 |
| 30 | 非资产-仓库属性收集专员 |

---

## BIZ-MAT-009 驳回与退回机制

**驳回**：审批不通过，需申请人重新提交
- 相关字段：`mfwIsReject`、`mfpIsReject`、`mffIsReject`
- 状态：`REJECTING`（节点驳回）→ `REJECTED`（最终驳回）

**退回**：退回到指定节点重新处理
- 方法：`returnBack()`
- 可退回节点：`MaterialFormStatusEnum.getReturnableNodes()`

---

## BIZ-MAT-010 服务物料独立入口

**功能描述**：服务物料在前端已独立到服务费用类采购菜单，不只复用 `materialsmanage/virtual` 目录。修改服务物料时优先同时检查 `servicefeemanage` 页面与 `MaterialServiceFormController`。

**Controller/API 入口**：
| Controller | Base path | 说明 |
|---|---|---|
| `MaterialServiceFormController` | `/matform/service` | 服务物料初始化、费用明细配置 |
| `MaterialFormController` | `/matform` | 服务物料申请、审批、完成等通用物料表单逻辑 |
| `MaterialCategoryController` | `/matcategory` | 服务物料分类、分类默认配置 |

**前端页面路径**：`front-pc/src/pages/servicefeemanage/`
| 页面/目录 | 功能说明 |
|---|---|
| `list.vue`、`check.vue` | 服务物料信息查询、详情 |
| `index.vue`、`mindex.vue` | 服务物料新增、管理员视图 |
| `submit.vue`、`apply.vue`、`applycheck.vue` | 服务物料申请与详情 |
| `approver.vue`、`deal.vue` | 服务物料审批/处理 |
| `category.vue` | 服务物料分类 |

**路由文件**：`front-pc/src/router/menu/servicefeemanage.js`

---

## 变更摘要

| 日期 | 业务编号 | 描述 |
|------|---------|------|
| 2026-02-03 | BIZ-MAT-002 | 调整物料属性分类，跨公司调拨和计税字段移至财务属性显示 |
| 2026-02-03 | BIZ-MAT-003 | 调整跨公司调拨和计税字段显示位置（申请人提交节点隐藏，财务属性收集节点显示） |
| 2026-02-03 | BIZ-MAT-004 | 实物物料查询页面财务属性默认显示，部分字段改为只读 |
| 2026-02-03 | BIZ-MAT-005 | 更新流程改造：动态审批、可编辑字段扩展、变更高亮、字段映射配置化、退回支持、变更信息 API |
| 2026-02-11 | BIZ-MAT-005 | 优化：提交时直接确定具体审批状态(11/12/13)，每节点增加角色权限校验，财务属性审批角色修正为 ASSET_ACCOUNTING |
| 2026-02-03 | BIZ-MAT-007 | 服务物料流程简化：去除主数据管理员审批节点 |
| 2026-05-28 | BIZ-MAT-010 | 补充服务物料独立前端入口和 `/matform/service` Controller 映射 |
