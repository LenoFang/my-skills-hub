---
name: backend-utility-apis
description: "Use when 调用 CommonUtil、DateUtil、RedisDistributeLock、SystemConfigEnum、EnumDisplay 等项目工具类，或用户提到 '工具类 API'、'配置读取'、'分布式锁'、'枚举显示'、'日期工具'、'读取系统配置'。"
---
# 后端工具类 API 参考

## R-BE-024 工具类使用规范
```java
// 获取当前用户信息
String userName = CommonUtil.getCurrentUserNameOrDefault();
String manageUnit = CommonUtil.getCurrentManageUnitOrDefault();
Integer userId = CommonUtil.getCurrentUserIdOrDefault();

// 时间处理
Timestamp now = DateUtil.getCurrentTimestamp();
String dateStr = DateUtil.timestamp2String(timestamp);
String timeStr = DateUtil.getTimeString("yyyyMMddHHmmss");

// 属性拷贝（忽略null）
SpringContextUtil.copyProperties(source, target);
SpringContextUtil.setDefaultProperties(entity);
```

## R-BE-032 CommonUtil 常用方法
```java
// 当前用户信息
UserInfo user = CommonUtil.getCurrentUser();
String userName = CommonUtil.getCurrentUserName();
String userCode = CommonUtil.getCurrentUserCodeOrDefault();
Integer userId = CommonUtil.getCurrentUserIdOrDefault();

// 管理单元
String manageUnit = CommonUtil.getCurrentManageUnitOrDefault();
Boolean isWL = CommonUtil.IsWL();
Boolean isGL = CommonUtil.IsGL();

// 参数校验
CommonUtil.hasAllRequired(jsonObject, "userId,name,telephone");
```

## R-BE-033 DateUtil 常用方法
```java
// 获取当前时间
Timestamp now = DateUtil.getCurrentTimestamp();
Date today = DateUtil.getSysDate();

// 日期计算
Date tomorrow = DateUtil.getSysDate(1);
Timestamp nextWeek = DateUtil.getTimestamp(7);

// 格式化与解析
String dateStr = DateUtil.timestamp2String(timestamp);
String timeStr = DateUtil.getTimeString("yyyyMMddHHmmss");
Timestamp ts = DateUtil.str2Timestamp("2024-01-01", DateUtil.DATE_FORMAT_SHORT);

// 时间差计算
long hours = DateUtil.betweenHour(startDate, endDate);
long days = DateUtil.betweenDays(startTs, endTs);
```

## R-BE-036 Redis 分布式锁使用规范
使用 `RedisDistributeLock` 进行并发控制，保证锁的获取和释放成对出现
```java
@Autowired
private RedisDistributeLock redisDistributeLock;

public void doSomething(Long id) {
    String lockKey = "scm:模块名_操作名:" + id;
    String lockVal = UUID.randomUUID().toString();
    boolean locked = false;
    try {
        locked = redisDistributeLock.tryLock(lockKey, lockVal, 
                RedisDistributeLock.DEFAULT_FIVE_MINUTES, 3, 1000);
        if (!locked) {
            LogUtils.warn("获取分布式锁失败, id: {}", id);
            return;
        }
        // 业务逻辑
    } finally {
        if (locked) {
            redisDistributeLock.tryUnLock(lockKey, lockVal);
        }
    }
}
```

**常用过期时间常量**：
- `DEFAULT_ONE_SECONDS` = 1000ms
- `DEFAULT_TEN_SECONDS` = 10000ms
- `DEFAULT_HALF_MINUTES` = 30000ms
- `DEFAULT_ONE_MINUTES` = 60000ms
- `DEFAULT_FIVE_MINUTES` = 300000ms
- `DEFAULT_TEN_MINUTES` = 600000ms

## R-BE-037 SystemConfigEnum 通用配置规范
系统配置使用 `SystemConfigEnum` 枚举 + `BaseSystemConfigHandler` 实现

**1. 定义枚举（SystemConfigEnum.java）**：
```java
/**
 * 配置描述
 */
CONFIG_NAME("configCode", "配置名称"),
```

**2. 实现配置处理器**：
```java
@ConfigType(value = SystemConfigEnum.CONFIG_NAME)
@Component
public class XxxConfigHandler extends BaseSystemConfigHandler {
    @Override
    public JSONObject getSystemConfigColumns() {
        JSONObject jsonObject = new JSONObject();
        jsonObject.put(this.CONFIG_VALUE, "配置值字段名");
        jsonObject.put(this.CONFIG_NAME, "配置名称字段名");
        jsonObject.put(this.CONFIG_REMARKS, "备注");
        return jsonObject;
    }
}
```

**3. 读取配置（推荐使用 SystemConfigContext）**：
```java
private SystemConfigContext systemConfigContext;

@Autowired
public void setSystemConfigContext(SystemConfigContext systemConfigContext) {
    this.systemConfigContext = systemConfigContext;
}

List<SystemConfigData> configList = systemConfigContext
        .getInstance(SystemConfigEnum.XXX_CONFIG)
        .getConfigList();
```

**4. 返回字段自动显示（@SystemConfigDisplay）**：
在 Info 类字段上使用，自动生成 `_display` 后缀的显示字段
```java
@SystemConfigDisplay(
    config = SystemConfigEnum.ACCOUNTING_ATTRIBUTION_CONFIG, 
    displayMode = SystemConfigDisplayModeEnum.VALUE_AND_NAME
)
private String companyValue;
```

## R-BE-038 枚举字段显示规范
Info 类使用枚举字段对应 Entity 的状态等字段，配合 `@EnumDisplay` 自动生成显示字段

**Entity 类**：
```java
@Column(name = "status")
private Integer status;

@Column(name = "order_status")
private String orderStatus;
```

**Info 类**：使用枚举类型 + `@EnumDisplay`
```java
@Data
@Builder
public class XxxInfo {
    @EnumDisplay
    @Builder.Default
    private StatusEnum status = StatusEnum.NORMAL;
    
    @EnumDisplay
    @Builder.Default
    private OrderStatusEnum orderStatus = OrderStatusEnum.DRAFT;
}
```

**枚举类**：
```java
// 数值型枚举 - 继承 BaseEnum（历史数据或特殊字段）
public enum StatusEnum implements BaseEnum {
    NORMAL(1, "正常"),
    DISABLED(0, "禁用");
    private Integer code;
    private String msg;
}

// 字符型枚举 - 继承 BaseStringEnum（新字段推荐）
public enum OrderStatusEnum implements BaseStringEnum {
    DRAFT("draft", "草稿"),
    SUBMITTED("submitted", "已提交"),
    APPROVED("approved", "已审批");
    private String value;
    private String msg;
}
```
