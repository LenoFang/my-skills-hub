# 采购申请模块（BIZ-PA-001 ~ 003）

> 主 SKILL.md 的子文档。采购申请相关业务与代码映射。

## BIZ-PA-001 采购申请自动同意下单

**功能描述**：采购申请单审批完成后，根据配置（公司编码 + 物料编码前缀）自动触发同意并下达采购订单

**触发入口**：
- `PurchaseApplyWolfServiceImpl.completeForm()` - 审批完成回调

**核心逻辑**：
- `PurchaseApplyServiceImpl.autoAgreePurchaseForm()` - 自动同意主方法
- `PurchaseApplyServiceImpl.autoTransfer2PurchaseOrderByBuyer()` - 按采购员分组自动生成PO单
- `PurchaseApplyServiceImpl.processSavePoFormByBuyer()` - 保存PO单（指定采购员）

**配置**：
- 枚举：`SystemConfigEnum.PURCHASE_APPLY_AUTO_AGREE_CONFIG`
- 处理器：`PurchaseApplyAutoAgreeConfigHandler`
- 配置字段：
  - `configValue` - 公司编码（对应采购申请单 `userCompanyCode`）
  - `configName` - 物料编码前缀（匹配采购申请行 `materialCode` 前缀）

**依赖服务**：
- `IMaterialPriceService.findMaterialPriceByMaterialCodesAndCompanyCode()` - 获取价格库配置
- `ISystemConfigService.findAllByCategory()` - 获取自动同意配置
- `RedisDistributeLock` - 分布式锁防止并发

**分布式锁**：
- Key：`scm:purchase_apply_agree_lock:{formId}`
- 过期时间：5分钟

**采购员来源**：
- 从 `MaterialPriceFullInfo.userCode` 和 `userName` 获取

**涉及表**：
- `fm_purchase_apply` - 采购申请主表
- `fm_purchase_apply_sub` - 采购申请子表
- `sys_config` - 系统配置表
- `material_price` - 物料价格库

---

## BIZ-PA-002 采购申请整单同意

**功能描述**：采购员手动对采购申请单进行整单同意操作

**入口**：
- `PurchaseApplyController.agreePurchaseForm()` - API接口

**核心逻辑**：
- `PurchaseApplyServiceImpl.agreePurchaseForm()` - 整单同意

**关联功能**：
- `PurchaseApplyServiceImpl.autoTransfer2PurchaseOrder()` - 框架协议自动下单

---

## BIZ-PA-003 PO 单自动建单

**功能描述**：根据框架协议自动生成采购订单

**核心逻辑**：
- `PurchaseApplyServiceImpl.autoTransfer2PurchaseOrder()` - 原有自动下单（不区分采购员）
- `PurchaseApplyServiceImpl.autoTransfer2PurchaseOrderByBuyer()` - 按采购员分组下单
- `PurchaseApplyServiceImpl.processSavePoForm()` - 保存PO单
- `PurchaseApplyServiceImpl.processSavePoFormByBuyer()` - 保存PO单（指定采购员）

**分组规则**：
- 相同供应商 + 相同付款类型 + 物料类别（W/D/H/Y 一组，G/O 一组）+ 采购员

---

## 变更摘要

| 日期 | 业务编号 | 描述 |
|------|---------|------|
| 2026-01-27 | BIZ-PA-001 | 新增采购申请自动同意下单功能 |
