---
name: backend-coding-patterns
description: "Use when 编写或修改 Java 后端代码、新建 Controller/Service/Repository/Mapper/Entity/Info/Enum、需要 DI 模板、异常处理、返回值封装、分页查询、日志规范、参数校验、权限控制等场景。涵盖项目分层架构和命名约定。"
---
# 后端编码模式

## R-BE-001 依赖注入方式
必须使用 `@Autowired` + setter 方法注入，禁止字段注入
```java
// 正确
private XxxRepository repository;

@Autowired
public void setRepository(XxxRepository repository) {
    this.repository = repository;
}

// 错误
@Autowired
private XxxRepository repository;
```

## R-BE-003 可选依赖注入
非必须的依赖使用 `@Autowired(required = false)`
```java
@Autowired(required = false)
public void setCacheService(ICacheService cacheService) {
    this.cacheService = cacheService;
}
```

## R-BE-004 Controller 类规范
必须使用 `@RestController` + `@Slf4j` + `@RequestMapping` + `@Api`，并继承 `BaseController`
```java
@RestController
@Slf4j
@RequestMapping(value = "/xxx")
@Api(tags = "模块名称")
public class XxxController extends BaseController {

    private IXxxService service;

    @Autowired
    public void setService(IXxxService service) {
        this.service = service;
    }
}
```

## R-BE-005 Controller 方法规范
每个接口方法必须使用 `@ApiOperation`，重要操作使用 `@AnnotationLog`
```java
@PostMapping("/save")
@ApiOperation(value = "保存", notes = "保存数据", httpMethod = "POST")
@AnnotationLog(remark = "保存操作")
public CommonResultVO<Long> save(@RequestBody XxxInfo info) {
    Long id = service.saveInfo(info);
    return ResultUtil.success(id);
}
```

## R-BE-006 Service 接口规范
Service 接口继承 `IBaseService<TKey, TInfo, TEntity>`
```java
public interface IXxxService extends IBaseService<Long, XxxInfo, XxxEntity> {
    // 自定义方法
}
```

## R-BE-007 Service 实现类规范
实现类继承 `BaseService` 并实现对应接口，使用 `@Service` + `@Slf4j`
```java
@Service
@Slf4j
public class XxxServiceImpl extends BaseService<Long, XxxInfo, XxxEntity>
    implements IXxxService {

    private XxxRepository repository;

    @Autowired
    public void setRepository(XxxRepository repository) {
        this.repository = repository;
    }
}
```

## R-BE-008 Service 必须实现的方法
必须实现三个核心方法：`findEntityList()`、`castToInfo()`、`parseEntity()`

## R-BE-009 castToInfo 方法实现
空值检查 → 创建 Info（使用 builder） → 属性拷贝 → 返回
```java
@Override
public XxxInfo castToInfo(XxxEntity entity) {
    if (null == entity) {
        throw new WarningException("未能找到有效的数据！");
    }
    XxxInfo info = XxxInfo.builder().build();
    SpringContextUtil.copyProperties(entity, info);
    return info;
}
```

## R-BE-010 parseEntity 方法实现
创建 Entity → 判断 ID → 存在则查询 → 属性拷贝 → 设置默认属性 → 返回
```java
@Override
public XxxEntity parseEntity(XxxInfo info) {
    XxxEntity entity = new XxxEntity();

    if (null != info.getId() && info.getId() > 0) {
        Optional<XxxEntity> entityObj = repository.findById(info.getId());
        if (entityObj.isPresent()) {
            entity = entityObj.get();
        }
    }
    SpringContextUtil.copyProperties(info, entity);
    SpringContextUtil.setDefaultProperties(entity);

    return entity;
}
```

## R-BE-011 分页查询实现
使用 PageHelper 分页，参数继承 `BasePageInfo`，返回 `PageResult<T>`
```java
public PageResult<XxxInfo> findPageList(XxxQueryInfo searchInfo) {
    searchInfo.setManageUnit(CommonUtil.getCurrentManageUnitOrDefault());
    PageHelper.startPage(searchInfo.getPageIndex(), searchInfo.getPageSize());
    List<XxxEntity> entityList = findEntityList(searchInfo);
    PageInfo<XxxEntity> pageObj = PageInfo.of(entityList);

    List<XxxInfo> infoList = new ArrayList<>();
    pageObj.getList().forEach(entity -> infoList.add(castToInfo(entity)));

    return PageResult.of(infoList, pageObj.getTotal());
}
```

## R-BE-012 Repository 规范
继承 `JpaRepository<TEntity, TKey>` 和 `JpaSpecificationExecutor`
```java
@Repository
public interface XxxRepository extends JpaRepository<XxxEntity, Long>, JpaSpecificationExecutor {
    List<XxxEntity> findAllByStatusAndIsValid(Integer status, Integer isValid);
}
```

## R-BE-013 Mapper 规范
使用 `@Mapper`，复杂查询使用 `@SelectProvider`
```java
@Mapper
public interface XxxMapper {

    @SelectProvider(type = XxxDynamicSqlProvider.class, method = "getList")
    List<XxxEntity> getList(XxxQueryInfo searchInfo);
}
```

## R-BE-014 Entity 类规范
使用 `@Data` + `@Entity` + `@Table`，字段必须设置默认值
```java
@Data
@Entity
@Table(name = "table_name")
public class XxxEntity implements Serializable {
    private static final long serialVersionUID = 1L;

    @Column(name = "id")
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "name")
    private String name = "";

    @Column(name = "quantity")
    private Integer quantity = 0;

    @Column(name = "amount")
    private BigDecimal amount = BigDecimal.ZERO;

    @Column(name = "is_valid")
    private Integer isValid = 1;

    @Column(name = "create_time")
    private Timestamp createTime = new Timestamp(System.currentTimeMillis());
}
```

## R-BE-015 Info 类规范
使用 `@Data` + `@Builder`，字段使用 `@Builder.Default` + `@ApiModelProperty`
```java
@Data
@Builder
public class XxxInfo implements Serializable {
    private static final long serialVersionUID = 1L;

    @Builder.Default
    @ApiModelProperty(value = "主键")
    private Long id = 0L;

    @Builder.Default
    @ApiModelProperty(value = "名称")
    private String name = "";

    @Builder.Default
    @ApiModelProperty(value = "数量")
    private Integer quantity = 0;

    @Builder.Default
    @ApiModelProperty(value = "金额")
    private BigDecimal amount = BigDecimal.ZERO;
}
```

## R-BE-016 数值型 Enum 规范
实现 `BaseEnum` 接口，code 为 Integer。**适用场景**：历史数据兼容、特殊字段、与外部系统对接
```java
@Getter
public enum XxxEnum implements BaseEnum {
    NONE(0, "无"),
    ACTIVE(1, "有效"),
    ;

    private Integer code;
    private String msg;

    XxxEnum(Integer code, String msg) {
        this.code = code;
        this.msg = msg;
    }

    public static XxxEnum getByCode(Integer code) {
        for (XxxEnum e : values()) {
            if (e.getCode().intValue() == code.intValue()) {
                return e;
            }
        }
        return null;
    }

    public static XxxEnum getByMsg(String msg) {
        for (XxxEnum e : values()) {
            if (e.getMsg().equals(msg.trim())) {
                return e;
            }
        }
        return null;
    }
}
```

## R-BE-017 字符型 Enum 规范（新字段推荐）
实现 `BaseStringEnum` 接口，code 为 String。**推荐用于新建字段**，便于直接阅读数据库数据，无需查询代码
```java
@Getter
public enum XxxEnum implements BaseStringEnum {
    DRAFT("draft", "草稿"),
    SUBMITTED("submitted", "已提交"),
    APPROVED("approved", "已审批"),
    ;

    private String value;
    private String msg;

    @Override
    @Deprecated
    public Integer getCode() {
        throw new RuntimeException("该枚举不允许使用Code！");
    }

    XxxEnum(String value, String msg) {
        this.value = value;
        this.msg = msg;
    }

    public static XxxEnum getByValue(String value) {
        for (XxxEnum e : values()) {
            if (e.getValue().equalsIgnoreCase(value)) {
                return e;
            }
        }
        return XxxEnum.DRAFT;
    }

    public static XxxEnum getByMsg(String msg) {
        for (XxxEnum e : values()) {
            if (e.getMsg().equalsIgnoreCase(msg.trim())) {
                return e;
            }
        }
        return null;
    }
}
```

**枚举类型选择指南**：
| 场景 | 推荐类型 | 说明 |
|------|---------|------|
| 新建状态字段 | `BaseStringEnum` | 数据库存储如 `draft`、`approved`，可读性好 |
| 历史数据字段 | `BaseEnum` | 兼容已有数据，code 为数值 |
| 是/否字段 | `BaseEnum` | 0/1 足够表达，无需字符串 |
| 与外部系统对接 | 视情况而定 | 根据外部系统要求选择 |

## R-BE-018 异常处理规范
业务异常使用 `WarningException`，禁止直接捕获 `Exception`
```java
if (entity == null) {
    throw new WarningException("数据不存在");
}
```

## R-BE-019 返回值封装规范
- 通用返回: `CommonResultVO`，使用 `ResultUtil.success()` / `ResultUtil.error()`
- 分页返回: `PageResult<T>`，使用 `PageResult.of(list, total)`
```java
return ResultUtil.success(id);
return ResultUtil.success();
return ResultUtil.error("操作失败");
return PageResult.of(infoList, total);
```

## R-BE-020 API 接口规范
- 查询使用 `GET`，其他操作使用 `POST`
- 单条删除使用 `@RequestParam`，批量删除使用 `@RequestBody`
```java
@GetMapping("/list")
public CommonResultVO<List<XxxInfo>> getList(XxxQueryInfo searchInfo)

@PostMapping("/save")
public CommonResultVO<Long> save(@RequestBody XxxInfo info)

@PostMapping("/delete")
public CommonResultVO<Void> delete(@RequestParam Long id)

@PostMapping("/batch-delete")
public CommonResultVO<Void> batchDelete(@RequestBody List<Long> ids)
```

## R-BE-021 逻辑删除规范
- 使用 `isValid` 字段：`1` 有效，`0` 已删除
- 查询时必须加 `isValid = 1` 条件
- 软删除方法命名：`softDeleteByXxx`
```java
@Modifying
@Query("UPDATE XxxEntity e SET e.isValid = 0 WHERE e.id = :id")
void softDeleteById(@Param("id") Long id);
```

## R-BE-022 字段更新规范
更新个别字段时，优先使用 `BaseService` 提供的 `updateFields()` 或 `updateSelective()` 方法
```java
// 只更新个别字段
Map<String, Object> fields = new HashMap<>();
fields.put("status", 1);
fields.put("updatedTime", DateUtil.getCurrentTimestamp());
updateFields(id, fields);

// 或使用 updateSelective
XxxEntity entity = new XxxEntity();
entity.setId(id);
entity.setStatus(1);
updateSelective(entity);
```

## R-BE-023 缓存操作规范
- **事务与缓存分离**：`@Transactional` 方法中只删除缓存，禁止刷新缓存
- **缓存Key命名**：`项目前缀:模块:业务标识`，如 `scm:view_permission:123`

## R-BE-026 日志记录规范
- 类上使用 `@Slf4j`
- 日志包含关键业务参数
- 接口方法使用 `@AnnotationLog` 自动记录
```java
log.info("开始处理，ID：{}", id);
log.warn("数据异常，ID：{}，原因：{}", id, reason);
log.error("处理失败，ID：{}，错误：{}", id, e.getMessage(), e);
```

## R-BE-027 LogUtils 模块化日志
复杂业务使用模块化日志，便于追踪和过滤
```java
LogUtils.errorModule("采购模块", "PurchaseServiceImpl", "savePurchase",
    "保存失败", orderId, userId, exception);
LogUtils.infoModule("物资模块", "MaterialServiceImpl", "fillRegion",
    "开始处理", applyId, "");

String json = LogUtils.toLogJson(complexObject);
log.info("参数详情: {}", json);
```

## R-BE-028 异常处理分层规范
按异常类型分层处理，业务异常直接抛出，其他异常需记录日志
```java
try {
    // 业务逻辑
} catch (WarningException e) {
    throw e;
} catch (PessimisticLockException | LockTimeoutException e) {
    log.warn("锁超时，尝试重试: {}", e.getMessage());
} catch (DataAccessException e) {
    log.error("数据访问异常: {}", e.getMessage(), e);
    throw new WarningException("数据保存失败，请联系管理员");
} catch (Exception e) {
    log.error("未知异常: {}", e.getMessage(), e);
    throw new WarningException("操作失败，请联系管理员");
}
```

## R-BE-029 BaseService 保存重试机制
使用 `saveEntityWithRetry` 处理悲观锁超时场景
```java
TEntity saved = saveEntityWithRetry(entity);
List<TEntity> savedList = saveAllEntityWithRetry(entityList);
TEntity entity = findById(id, 5);
```

## R-BE-030 Controller 参数校验规范
使用 `@Validated` + Info 类校验注解
```java
@PostMapping("/save")
public CommonResultVO save(@Validated @RequestBody XxxSaveInfo info) { }

@Data
public class XxxSaveInfo {
    @NotBlank(message = "名称不能为空")
    private String name;

    @NotNull(message = "类型不能为空")
    private Integer type;

    @NotEmpty(message = "明细列表不能为空")
    private List<SubInfo> subList;
}
```

## R-BE-031 权限控制注解
PC端使用 `@RequiredPermission`，Admin端使用 `@PermControl`
```java
// PC端
@RequiredPermission(
    perms = {MenuPermissionCodeEnum.MATERIAL_APPLY_LIST},
    permLogical = Logical.OR,
    roles = {SystemRoleEnum.ADMIN},
    roleLogical = Logical.OR
)
@GetMapping("/list")
public CommonResultVO getList() { }

// Admin端
@PermControl(value = {"material:apply:list"}, logical = Logical.AND)
@GetMapping("/list")
public CommonResultVO getList() { }
```

## R-BE-034 列表转换规范
优先使用 BaseService 方法，复杂场景使用 Stream API
```java
List<TInfo> infoList = castToInfoList(entityList);

List<String> codeList = entityList.stream()
    .map(Entity::getCode)
    .collect(Collectors.toList());

Map<String, List<Info>> groupedMap = infoList.stream()
    .collect(Collectors.groupingBy(Info::getCategory));
```

## R-BE-035 集合初始化规范
使用 Guava 工具类初始化集合
```java
List<String> list = Lists.newArrayList();
List<String> list = Lists.newArrayList("a", "b", "c");
Map<String, Object> map = Maps.newHashMap();
Set<String> set = Sets.newHashSet();
```
