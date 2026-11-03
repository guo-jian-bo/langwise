# 首页活动时间控制实现提示词

请在 Langwise 项目中实现“首页活动按服务端时间显示/隐藏”的能力，要求如下：

## 目标

- 首页活动数据包含 `started` 和 `ended` 两个时间字段。
- 活动显示必须优先基于服务端时间判断。
- 服务端时间接口在 app 启动时只请求一次。
- 如果服务端时间尚未返回，或接口返回 `null`，则临时使用本地时间。
- 活动需要在运行过程中根据开始/结束时间自动显示或隐藏，不能只在首次加载时判断一次。

## 已确认的落点

- 在 `lib/utils/service_date_utils.dart` 中实现 `ServiceDateUtils` 单例。
- `ServiceDateUtils.init()` 放到 `lib/common/public_controller/init_controller.dart` 的 `init()` 中触发。
- `ServiceDateUtils.init()` 不需要等待完成，直接异步触发即可。
- 请求服务端时间的方法使用 `lib/common/https/auth.dart` 中的 `AuthRequest.getServerTimestamp()`。
- 首页控制器 `lib/app/modules/home/controllers/home_controller.dart` 尽量少改。
- 最多只允许在 `getActivityList()` 中做一次过滤。
- 活动时间解析、活动可见性判断、下一个切换时间点计算，放在 `HomeActivityWidget` 中调用 `ServiceDateUtils` 完成。

## ServiceDateUtils 职责

- 管理服务端时间初始化。
- 统一处理所有和服务端时间相关的方法。
- 提供当前时间，优先使用服务端时间基准推导，失败时回退本地时间。
- 统一解析活动时间字符串。
- 统一判断活动是否可见。
- 统一计算下一个活动切换时间点。

## 时间来源规则

- app 启动时调用一次 `AuthRequest.getServerTimestamp()`。
- 如果返回有效时间戳，记录一个服务端时间基准，再结合本地流逝时长推导“当前服务端时间”。
- 如果返回 `null`，则使用本地时间。
- 如果首页比服务端时间初始化更早完成加载，则先使用本地时间，不阻塞首页。

## 时间解析规则

- `started` 和 `ended` 是服务器返回的带时区时间字符串。
- 使用 `lib/utils/date_format_util.dart` 中的 `DateFormatUtil.tryParseDate()` 解析。
- 如果解析失败，活动直接不显示。

## 活动显示规则

- `started` 和 `ended` 都为空：不显示。
- 只有 `started` 有值、`ended` 为空：`now >= started` 时显示。
- 只有 `ended` 有值、`started` 为空：`now < ended` 时显示。
- `started` 和 `ended` 都有值：`started <= now < ended` 时显示。
- 如果 `started >= ended`，视为脏数据，不显示。

## HomeActivityWidget 行为要求

- 不直接无脑渲染 `homeAdvertList`。
- 先基于 `ServiceDateUtils` 过滤出当前可见活动，再渲染。
- 需要计算“最近一个开始或结束边界时间”。
- 只挂一次性 `Timer` 到最近边界，不要每秒轮询。
- 到达边界时间后，重新计算可见活动，并重新安排下一次 `Timer`。
- 页面销毁时必须取消 `Timer`，避免内存泄漏。
- 页面回到前台时建议重新计算一次，避免后台挂起导致时间不准。

## HomeController 限制

- 保持现有职责，避免把时间调度逻辑放进 `HomeController`。
- 如确实需要，最多只在 `getActivityList()` 中做一次初始过滤。
- 持续的显示/隐藏切换由 `HomeActivityWidget` 自己处理。

## 注意事项

- `ServiceDateUtils` 需要提供清晰、可复用的方法，避免把时间判断逻辑散落到 UI 中。
- 注意不要依赖用户手动修改本地系统时间。
- 如果 `AuthRequest.getServerTimestamp()` 当前带缓存，请确认时间接口是否允许缓存；如果不允许，改造时应避免拿到旧时间。
- 代码风格遵循项目现有规范：命名使用 camelCase / PascalCase，职责清晰，避免深层嵌套。

## 验收标准

- 首页活动能根据 `started/ended` 正确显示和隐藏。
- 服务端时间接口只在启动时请求一次。
- 服务端时间未就绪时，首页仍可正常展示，并临时使用本地时间。
- 到达活动开始时间时，活动可自动显示。
- 到达活动结束时间时，活动可自动隐藏。
- 时间解析失败或脏数据不会误显示活动。
