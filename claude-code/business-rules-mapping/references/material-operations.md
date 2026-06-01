# 物资申请与流转模块（BIZ-MO-001 ~ 004）

> 主 SKILL.md 的子文档。只记录已在仓库中确认存在的前端目录、Controller 和 Service。

## BIZ-MO-001 物资申请

**功能描述**：物资申请、申请明细、处理进度、估值等代码入口。

**前端页面路径**：
| 路径 | 说明 |
|---|---|
| `front-pc/src/pages/apply/material` | 物资申请页面 |
| `front-pc/src/pages/apply/materialDept` | 部门物资申请页面 |
| `front-pc/src/pages/handle/material` | 物资处理页面 |
| `front-pc/src/pages/handle/outstock` | 出库处理页面 |

**Controller**：
| Controller | Base path |
|---|---|
| `MaterialApplyController`（PC，`pc.controller.materialapply`） | `/matapply` |
| `MaterialApplyController`（移动端，`mobile.controller`） | 移动端物资申请，注意与 PC 重名、包路径不同 |
| `MaterialApplyValuationController` | `/valuation` |

> 相关 reference：[inventory-freeze.md](inventory-freeze.md)（`MaterialApplySubServiceImpl` 是冻结调用方）、[budget.md](budget.md)（物资申请占用预算）

**Service**：
| Service | 说明 |
|---|---|
| `MaterialApplyServiceImpl` | 物资申请主服务 |
| `MaterialApplySubServiceImpl` | 物资申请明细服务 |
| `MaterialApplyDetailServiceImpl` | 物资申请详情服务 |
| `MaterialApplyBatchServiceImpl` | 物资申请批量处理服务 |
| `MaterialApplySubProgressLogImpl` | 物资申请明细进度日志服务 |
| `MaterialApplyValuationServiceImpl` | 物资申请估值服务 |

---

## BIZ-MO-002 领用、退货、调拨

**前端页面 / Controller / Service 映射**：
| 业务 | 前端路径 | Controller | Service |
|---|---|---|---|
| 物资领用 | `front-pc/src/pages/transfer/matreceive` | `MaterialReceiveController` | `MaterialReceiveServiceImpl`、`MaterialReceiveSubServiceImpl`、`MaterialReceiveBatchServiceImpl` |
| 物资退货 | `front-pc/src/pages/transfer/matreturn` | `MaterialReturnController` | `MaterialReturnServiceImpl`、`MaterialReturnSubServiceImpl` |
| 库存调拨 | `front-pc/src/pages/transfer/stockallot` | `MaterialStockAllotController` | `MaterialStockAllotServiceImpl`、`MaterialStockAllotSubServiceImpl` |
| 资产调拨 | `front-pc/src/pages/transfer/assetallot` | `MaterialAssetAllotController` | `MaterialAssetAllotServiceImpl`、`MaterialAssetAllotSubServiceImpl` |

> 相关 reference：[wolf-approval.md](wolf-approval.md)（库存调拨 `MaterialStockAllotWolfServiceImpl` / 资产调拨 `MaterialAssetAllotWolfServiceImpl`）、[inventory-freeze.md](inventory-freeze.md)（领用 / 调拨为冻结调用方）

---

## BIZ-MO-003 赠品入库、盘盈、处置

**前端页面 / Controller / Service 映射**：
| 业务 | 前端路径 | Controller | Service |
|---|---|---|---|
| 赠品入库 | `front-pc/src/pages/transfer/giftstorage` | `MaterialGiftStorageController` | `MaterialGiftStorageServiceImpl`、`MaterialGiftStorageSubServiceImpl` |
| 盘盈 | `front-pc/src/pages/transfer/assetInventory` | `MaterialInventoryProfitController` | `MaterialInventoryProfitServiceImpl`、`MaterialInventoryProfitSubServiceImpl` |
| 库存处置 | `front-pc/src/pages/transfer/inventorydisposal` | `MaterialInventoryDisposalController` | `MaterialInventoryDisposalServiceImpl`、`MaterialInventoryDisposalSubServiceImpl` |

---

## BIZ-MO-004 物资申请评价

| 类型 | 代码位置 |
|---|---|
| Controller | `MaterialApplyValuationController`，根路径 `/valuation` |
| Service | `MaterialApplyValuationServiceImpl` |
| 已确认 API | `/list`、`/save`、`/exportExcel` |

---

## 变更摘要

| 日期 | 业务编号 | 描述 |
|------|---------|------|
| 2026-05-28 | BIZ-MO-001 ~ 003 | 新增物资申请、领用、退货、调拨、赠品入库、盘盈、处置代码映射 |
| 2026-05-28 | BIZ-MO-004 | 补充物资申请评价 Controller、Service 和 API 入口 |

---

## 审查记录 (2026-05-28)

> 抽样验证 gpt5.5 主体生成内容；以代码为准，未直接改正文，请逐条确认是否落正文。

### ✅ 已核实（与代码一致 —— 准确率极高）
- **后端 30 个类全部命中**：9 个 Controller + 21 个 Service 实现类（含 Sub/Batch/DetailServiceImpl），grep 验证类名 + 包路径全部正确
- **Base path 正确**：
  - `MaterialApplyController` `@RequestMapping("/matapply")`（行 88）
  - `MaterialApplyValuationController` `@RequestMapping("/valuation")`（行 19）
- **BIZ-MO-004 评价 API 全部命中**：`/list`（PostMapping 行 30）、`/save`（PostMapping 行 37）、`/exportExcel`（GetMapping 行 43）
- **前端目录全部存在**且层级正确：
  - BIZ-MO-001：`front-pc/src/pages/apply/material`、`apply/materialDept`、`handle/material`、`handle/outstock` 4 个目录都有 `index.vue`
  - BIZ-MO-002：`transfer/matreceive`、`transfer/matreturn`、`transfer/stockallot`、`transfer/assetallot` 全部存在（list.vue/add.vue/detail.vue 标准结构）
  - BIZ-MO-003：`transfer/giftstorage`、`transfer/assetInventory`、`transfer/inventorydisposal` 全部存在

### ❌ 缺漏（建议补到正文）
- **重名 Controller 漏掉了移动端版本**：除 PC 的 `MaterialApplyController`（project-pc）外，还有 `code-backend/project-mobile/src/main/java/com/tcoa/scm/mobile/controller/MaterialApplyController.java`。当前 BIZ-MO-001 表只指了 PC 版本，定位移动端物资申请会失败。建议在 Controller 列加包路径或注明"含 PC/移动端两套"
- **关联 reference 未交叉引用**：
  - BIZ-MO-002 库存调拨/资产调拨涉及 Wolf 审批，但未引用 `wolf-approval.md` 中的 `MaterialStockAllotWolfServiceImpl` / `MaterialAssetAllotWolfServiceImpl`
  - 物资领用、申请涉及库存冻结，未引用 `inventory-freeze.md`（MaterialReceive/MaterialApplySub 都是冻结调用方）
  - 建议在每个二级标题下加一行"相关 reference：…"提升导航性

### ⚠️ 表达不精确（建议改写但不算错）
- **前端"页面"列指向的是目录**，但 vue 文件多为 `list.vue/add.vue/detail.vue` 多入口而非 `index.vue`。如果未来用 AI 按 reference 去打开"页面"，AI 可能 false-negative。建议把列名从"前端页面"改成"前端目录"，并补充常见入口文件名约定（list / add / detail / mlist / lineTable）
- **缺 base path**：BIZ-MO-002/003 表没列各 Controller 的 `@RequestMapping`，定位时还要二次 grep。BIZ-MO-001 已经做了示范，建议统一补齐

### 📌 结论
material-operations.md 的"清单完整性"与 wolf-approval.md 同级（都是穷举型清单），无错误条目，只有"信息密度可以更高"和"重名漏漏一个移动端 Controller"两类问题。属于安全可直接信任的 reference

