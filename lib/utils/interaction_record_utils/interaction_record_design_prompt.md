# 交互时长上报设计提示词

请基于 Langwise Flutter 项目现有的播放上报能力，设计并实现一套“交互时长上报”模块。该模块需要与现有播放上报逻辑解耦，但在会话维度、上报时机和失败重试上与播放上报协同工作。

## 一、目标

实现一个独立的交互时长统计与持久化模块，用于统计页面激活后的交互活跃时长，并在播放上报时一并上报一个时长字段。

该模块的核心目标：

1. 独立于现有 `PlayRecordManager` 的播放时长统计逻辑。
2. 与播放记录共享同一个 `sessionId`。
3. 使用同一个数据库文件，但单独建立交互记录表。
4. 在播放开始时同步启动交互会话，在切歌、退出、播放结束等时机同步结束或切换会话。
5. 在播放上报时，通过 `sessionId` 获取对应交互时长，并拼接到同一个请求中。
6. 播放上报失败或本地重试时，交互数据要与播放记录一起重试，并保持状态一致。

## 二、业务规则

### 1. 会话规则

1. 交互会话与播放记录会话一一对应。
2. 一首内容对应一个 `sessionId`。
3. 切换曲目时，需要先结束旧交互会话，再开启新交互会话。
4. 交互会话开始时机必须与对应页面当前播放上报实现保持一致，不强制统一为某一个固定时点。
5. 对于不同播放器页面，允许在 `open` 前、`open` 后或播放器开始首帧播放时启动交互会话，但必须与同页 `PlayRecordManager.startTracking()` 的既有口径对齐，不得脱离页面现状强行改时机。

### 2. 交互活跃规则

满足任一条件时，页面视为“活跃”：

1. 用户在页面上产生交互行为。
2. 播放器处于持续播放中。
3. 播放器发生自动切歌等自动行为，可视为一次活跃刷新。
4. 页面上的弹窗、抽屉、底部面板等仍属于当前页面交互，算活跃。

用户交互行为包括但不限于：

1. 点击
2. 双击
3. 长按
4. 拖动
5. 滚动
6. 手指触摸
7. 手势滑动

### 3. Idle 规则

当同时满足以下条件时，进入 idle 计时：

1. 没有新的用户交互
2. 播放器不再持续播放
3. 没有自动切歌等活跃事件

进入 idle 后：

1. 从 0 开始计时
2. 最多只额外累计 30 秒
3. 超过 30 秒后冻结，不再继续增加交互时长
4. 如果期间重新发生用户交互或恢复持续播放，则退出 idle，重新进入 active

### 4. 页面失活规则

以下情况视为页面失活：

1. 跳转到别的页面
2. 当前路由被新的完整页面覆盖
3. App 进入后台
4. 锁屏

其中后台或锁屏是否算失活，需要由配置参数控制：

1. 某些页面允许后台播放，则可配置后台不失活
2. 某些页面不允许后台继续统计，则进入后台后立即失活

桌面端补充规则：

1. Windows、macOS、Linux 桌面端的 `inactive`、`hidden` 不应立即视为后台失活。
2. 桌面端只在 `paused`、`detached` 等真正离开前台的生命周期下才通知后台挂起。
3. 该规则应优先放在 `InteractionSessionContainer.didChangeAppLifecycleState()` 中统一处理，而不是分散写在各业务页面。

默认建议：

1. 路由完全覆盖时立即失活
2. 后台和锁屏默认失活

### 5. 时长语义

1. 交互时长不是纯用户点击时长。
2. 交互时长本质上是页面活跃参与时长。
3. 只要持续播放中，即使用户不碰页面，也算交互活跃时长。
4. 因此正常连续播放期间，交互时长通常会接近甚至等于播放时长。

## 三、架构边界

### 1. 交互模块与播放模块关系

交互模块必须独立，不把交互计时逻辑塞进 `PlayRecordManager`。

推荐拆分为以下组件：

1. `InteractionSessionManager`
2. `InteractionRecordDatabase`
3. `InteractionRecordModel`
4. `InteractionRecordConstants`
5. `InteractionPageListener` 或 `InteractionSessionContainer`
6. 可选的 `PlayerActivityAdapter`

### 2. `PlayRecordManager` 的职责

`PlayRecordManager` 只负责：

1. 开始播放记录会话
2. 停止播放记录会话
3. 播放完成上报
4. 切歌上报
5. 退出页面上报
6. 本地失败重试
7. 在上报前通过 `sessionId` 查询交互时长并拼接请求

`PlayRecordManager` 不负责：

1. 监听鼠标事件
2. 监听触摸事件
3. 计算 idle 30 秒
4. 维护交互状态机

### 3. `InteractionSessionManager` 的职责

`InteractionSessionManager` 负责：

1. 开启交互会话
2. 结束交互会话
3. 切换交互会话
4. 记录用户活跃事件
5. 记录播放器活跃事件
6. 管理 active / idle / suspended 状态
7. 统计累计交互时长
8. 落本地数据库
9. 查询当前会话交互时长
10. 为播放上报和重试提供按 `sessionId` 查询能力

## 四、接口设计草图

### 1. 会话配置

建议新增配置类：

```dart
class InteractionSessionConfig {
  final bool allowBackgroundActive;
  final bool allowLockScreenActive;
  final bool routeCoveredAsInactive;
  final bool countContinuousPlaybackAsActive;
  final int idleGraceSeconds;
  final int pointerThrottleMs;

  const InteractionSessionConfig({
    this.allowBackgroundActive = false,
    this.allowLockScreenActive = false,
    this.routeCoveredAsInactive = true,
    this.countContinuousPlaybackAsActive = true,
    this.idleGraceSeconds = 30,
    this.pointerThrottleMs = 400,
  });
}
```

### 2. 会话开始参数

建议新增参数对象：

```dart
class InteractionSessionStartParams {
  final Object? owner;
  final Object? player;
  final String sessionId;
  final String? source;
  final String? type;
  final int? typeId;
  final int? styleId;
  final String? dialect;
  final String? learnType;
  final String contentType;
  final int contentId;
  final double duration;
  final InteractionSessionConfig config;

  const InteractionSessionStartParams({
    this.owner,
    this.player,
    required this.sessionId,
    this.source,
    this.type,
    this.typeId,
    this.styleId,
    this.dialect,
    this.learnType,
    required this.contentType,
    required this.contentId,
    required this.duration,
    this.config = const InteractionSessionConfig(),
  });
}
```

说明：

1. `owner` 用于描述页面宿主，不要求它直接监听所有事件。
2. `player` 为可选，传入时由交互模块自行监听持续播放、暂停、切歌相关信号。
3. 页面原生交互事件仍建议由页面根容器统一转发给管理器。

### 3. 管理器公开接口

建议 `InteractionSessionManager` 暴露以下公开方法：

```dart
class InteractionSessionManager {
  static InteractionSessionManager get instance;

  Future<void> startSession(InteractionSessionStartParams params);

  Future<void> stopSession({
    String? source,
    String? sessionId,
    bool finalizeIdleGrace = true,
  });

  Future<void> switchSession({
    required InteractionSessionStartParams next,
    bool finalizeCurrent = true,
  });

  void notifyUserInteraction([InteractionSignal signal = InteractionSignal.user]);

  void notifyPlaybackActive();

  void notifyPlaybackPaused();

  void notifyPlaybackCompleted();

  void notifyRouteCovered();

  void notifyAppBackground();

  void notifyAppForeground();

  double getCurrentEngagementSeconds({
    String? sessionId,
    bool includeIdleGrace = true,
  });

  Future<InteractionRecordModel?> getRecordBySessionId(String sessionId);

  Future<Map<String, dynamic>?> getReportPayloadBySessionId(String sessionId);

  Future<void> markReportedSuccessBySessionId(String sessionId);

  Future<void> markReportedFailedBySessionId(String sessionId);

  Future<void> retryPendingRecords();

  void dispose();
}
```

### 4. 活跃信号枚举

建议增加轻量枚举，便于日志和调试：

```dart
enum InteractionSignal {
  user,
  mouseMove,
  click,
  doubleTap,
  longPress,
  drag,
  scroll,
  touch,
  playbackActive,
  autoSwitch,
}
```

### 4.1 关键日志要求

交互模块默认不输出高频噪声日志。调试时只保留以下关键状态日志：

1. `开始追踪`
2. `暂停`
3. `恢复`
4. `进入idleGrace`
5. `取消30s等待`
6. `达到挂起上限30s`
7. `进入挂起`
8. `恢复挂起`
9. `上报`

要求：

1. 高频日志如“收到用户交互信号”“启动/取消计时器”“持久化当前记录”“播放器状态流逐条变化”等默认静默。
2. `取消30s等待` 必须打印取消原因，例如 `userInteraction(...)`、`playbackActive(...)`、`routeCovered(...)`、`appBackground(...)`。
3. `进入挂起` 必须携带当前状态、取消原因和关键累计时长，便于快速判断是在哪个阶段被打断。

### 5. 页面监听容器

建议提供一个页面根部包裹组件，用于统一捕捉页面事件：

```dart
class InteractionSessionContainer extends StatefulWidget {
  final Widget child;
  final String source;
  final bool enabled;

  const InteractionSessionContainer({
    super.key,
    required this.child,
    required this.source,
    this.enabled = true,
  });
}
```

该组件职责：

1. 统一监听鼠标移动
2. 统一监听点击
3. 统一监听触摸
4. 统一监听拖动
5. 统一监听滚动
6. 统一节流后调用 `InteractionSessionManager.instance.notifyUserInteraction(...)`

该组件不负责：

1. 会话开始结束
2. 数据库存储
3. 上报逻辑

### 6. 播放器适配

如果播放器类型不统一，建议新增适配层而不是在管理器里硬编码大量分支：

```dart
abstract class InteractionPlayerAdapter {
  Stream<bool> get playingStream;
  Stream<Duration>? get positionStream;
  Future<Duration?> getCurrentPosition();
  void dispose();
}
```

如果当前项目已有两类播放器：

1. `AudioPlaybackUtils`
2. `Player`

则可分别提供对应适配器，减少 `InteractionSessionManager` 对具体播放器类型的依赖。

## 五、状态机设计

建议交互会话内部采用以下状态：

```dart
enum InteractionSessionState {
  inactive,
  active,
  idleGrace,
  suspended,
}
```

### 状态语义

1. `inactive`
   - 未开始会话或会话已彻底结束
2. `active`
   - 正在累计活跃时长
3. `idleGrace`
   - 无新交互且未持续播放，进入最多 30 秒的补偿期
4. `suspended`
   - 页面失活、被覆盖、后台或锁屏导致暂时停止

### 状态流转

1. `startSession()` -> `active`
2. 收到用户交互 -> 保持 `active`
3. 持续播放中 -> 保持 `active`
4. 播放停止且无新交互 -> 先经过沉淀期，再进入 `idleGrace`
5. `idleGrace` 超过 30 秒 -> 冻结累计
6. `idleGrace` 期间有新交互或重新播放 -> `active`
7. 路由覆盖 / 页面跳转 / 后台 / 锁屏 -> `suspended`
8. 从 `suspended` 恢复：
   - 若仍为当前会话，且业务允许恢复，则可回到 `active`
   - 若当前页面已结束，则直接停止会话
9. `stopSession()` -> `inactive`

## 六、时长计算规则

### 1. 内部存储单位

1. 管理器内部统一用毫秒计算，例如 `accumulatedActiveMs`
2. 对外读取和接口上报时统一转换为秒，保留 `double`

### 2. 基本计算方式

1. `active` 状态时，以时间差累加
2. 播放暂停后不立即进入 `idleGrace`，而是先经过一次短暂沉淀期（默认使用 `pointerThrottleMs` 作为沉淀窗口）
3. 进入 `idleGrace` 后，最多再累加 30 秒
4. 桌面端收到 `inactive`、`hidden` 时，不应打断暂停后的沉淀期和 `idleGrace`
3. `suspended` 状态不累计
4. `inactive` 状态不累计

### 3. 重要口径

以下场景中，交互时长通常接近播放时长：

1. 从开始播放到播放结束期间，没有暂停
2. 没有跳转页面
3. 没有后台失活
4. 没有超过 30 秒的 idle 停留

## 七、数据库设计

建议在与播放记录相同的数据库中新增表：

```sql
CREATE TABLE IF NOT EXISTS interaction_sessions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  session_id TEXT NOT NULL,
  source TEXT,
  type TEXT,
  type_id INTEGER,
  style_id INTEGER,
  dialect TEXT,
  learn_type TEXT,
  content_type TEXT NOT NULL,
  content_id INTEGER NOT NULL,
  duration REAL NOT NULL DEFAULT 0,
  started_at INTEGER NOT NULL,
  last_active_at INTEGER,
  idle_started_at INTEGER,
  ended_at INTEGER,
  accumulated_active_ms INTEGER NOT NULL DEFAULT 0,
  report_status TEXT DEFAULT 'pending',
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  extra TEXT
);
```

建议增加索引：

1. `idx_interaction_session_id`
2. `idx_interaction_report_status`
3. `idx_interaction_created_at`

### 数据表字段说明

1. `session_id`
   - 与播放记录共用
2. `duration`
   - 当前资源总时长，可与播放记录对齐
3. `started_at`
   - 会话开始时间
4. `last_active_at`
   - 最近一次活跃刷新时间
5. `idle_started_at`
   - 进入 idle 的时间
6. `ended_at`
   - 会话结束时间
7. `accumulated_active_ms`
   - 当前累计活跃毫秒数
8. `report_status`
   - `pending` / `failed` / `success`
9. `extra`
   - 预留扩展字段

## 八、与播放上报的集成方式

### 1. 单条实时上报

当前播放上报请求中，每个 `slice` 需要追加交互时长字段：

```json
{
  "type": "unit",
  "typeId": 1,
  "learnType": "listen",
  "styleId": 2,
  "dialect": "us",
  "contentType": "EN_SONG",
  "contentId": 1001,
  "played": 120.0,
  "duration": 180.0,
  "time": 1710000000000,
  "sessionId": "xxx",
  "engagementSeconds": 118.5
}
```

### 2. 批量失败重试

批量重试时也必须：

1. 先拿到待上报播放记录列表
2. 根据每条播放记录的 `sessionId` 查交互记录
3. 将 `engagementSeconds` 拼到每个 `slice`
4. 上报成功则播放记录和交互记录都改为 `success`
5. 上报失败则播放记录和交互记录都改为 `failed`

### 3. 一致性要求

必须保证：

1. 播放记录和交互记录共享 `sessionId`
2. 单条上报状态一致
3. 批量重试状态一致
4. 不允许出现播放成功但交互失败的长期不一致状态

## 九、接入点清单

### 1. 开始播放

在现有播放记录开始逻辑中：

1. 播放记录生成 `sessionId`
2. `PlayRecordManager.startTracking()` 启动
3. 同步调用 `InteractionSessionManager.startSession()`，但具体调用点必须服从当前页面既有实现，不强制统一到 `open` 成功之后
4. 交互会话拿到相同的 `sessionId`

### 2. 切歌

在切歌场景中：

1. 先结束旧交互会话
2. 再开启新交互会话
3. 与原有播放切歌逻辑顺序保持一致

### 3. 播放完成

1. 若自然播放结束且没有立即切到下一首
2. 可以允许会话进入 `idleGrace`
3. 最多再累计 30 秒
4. 然后在最终上报或退出时结束会话

### 4. 页面退出

1. 停止播放记录
2. 停止交互会话
3. 固化当前时长
4. 等待上报或进入失败重试

### 5. 页面根监听

在播放器页面根节点统一包一层 `InteractionSessionContainer`：

1. 不在各个按钮埋点
2. 不在各个手势回调中分散写逻辑
3. 所有页面交互统一由根容器转发
4. 四个播放器页面都必须在页面最外层根部包裹，不能只包中间某个内容区域

## 十、模块级接入方案

当前需要覆盖的播放器模块只有以下四个：

1. `lib/app/modules/song_mv`
2. `lib/app/modules/listen_and_read`
3. `lib/app/modules/zhendu_look`
4. `lib/app/modules/zhendu_perform`

要求实现时先围绕这四个模块落地，不要先做过度泛化。

### 1. song_mv

对应文件：

1. `lib/app/modules/song_mv/controllers/song_mv_controller.dart`
2. `lib/app/modules/song_mv/views/song_mv_view.dart`

接入建议：

1. 保持与当前播放上报一致的会话开始时机，即在现有 `PlayRecordManager.startTracking()` 同时启动交互会话。
2. 页面根部已经有 `GestureDetector + MouseRegion + Scaffold` 结构，必须在这一层最外层根部包裹 `InteractionSessionContainer`。
3. 页面内已有 `onTap`、`onDoubleTap`、`onHover` 等交互，交互容器只需统一兜底，不需要逐个业务点埋点。
4. 若传入 `audioPlayerUtils`，则交互模块要监听持续播放状态，并将“持续播放中”视为活跃。

特殊规则：

1. `song_mv` 支持 App 后台继续播放。
2. 因此 `song_mv` 的交互会话默认配置必须与普通页面不同。
3. 当 `song_mv` 在后台仍允许继续播放时，交互模块需要与播放上报逻辑保持一致。
4. 也就是说，只要后台播放仍被视为有效播放态，则交互时长仍继续累计。
5. 如果后续业务需要关闭后台累计，则通过 `InteractionSessionConfig.allowBackgroundActive` 控制，而不是在业务代码里写死分支。

推荐默认配置：

```dart
const InteractionSessionConfig(
  allowBackgroundActive: true,
  allowLockScreenActive: true,
  routeCoveredAsInactive: true,
  countContinuousPlaybackAsActive: true,
)
```

说明：

1. `song_mv` 页面即使不显示在前台，只要仍在合法后台播放，就继续算活跃。
2. 但如果明确结束播放会话、切歌、销毁控制器或被播放上报逻辑视为结束，则交互会话也要同步结束。

### 2. listen_and_read

对应文件：

1. `lib/app/modules/listen_and_read/controllers/listen_and_read_controller.dart`
2. `lib/app/modules/listen_and_read/views/listen_and_read_view.dart`

接入建议：

1. 会话启动、切歌、退出时机与现有播放上报完全对齐。
2. 页面根部已有 `MouseRegion + Scaffold + Stack`，必须在这一层最外层根部包裹 `InteractionSessionContainer`。
3. `ListenAndReadReadingView` 和 `ListenAndReadShadowingView` 是子内容切换，不应单独开新交互会话，仍归属当前播放会话。
4. 只要当前资源持续播放，即使用户没有点击页面，也持续累计交互时长。

推荐默认配置：

```dart
const InteractionSessionConfig(
  allowBackgroundActive: false,
  allowLockScreenActive: false,
  routeCoveredAsInactive: true,
  countContinuousPlaybackAsActive: true,
)
```

### 3. zhendu_look

对应文件：

1. `lib/app/modules/zhendu_look/controllers/zhendu_look_controller.dart`
2. `lib/app/modules/zhendu_look/controllers/zhendu_look_player_controller.dart`
3. `lib/app/modules/zhendu_look/views/zhendu_look_view.dart`

接入建议：

1. 会话开始点必须与 `zhendu_look` 当前页面内的既有播放上报实现保持一致，不强制改为 `open` 成功后才启动。
2. 页面根部已有 `MouseRegion`，主内容区还有 `GestureDetector`，必须在页面最外层根部包裹 `InteractionSessionContainer`，而不是只包内容区。
3. `PageView` 翻页、字幕点击、弹出词典、底部控制器弹层都算当前页面交互。
4. 如果传入 `playerController.player`，交互模块应基于播放器播放状态持续刷新活跃时间。
5. Windows、macOS 桌面端如业务需要，可配置 `allowBackgroundActive`、`allowLockScreenActive` 为 `true`；同时生命周期层必须忽略桌面端 `inactive`、`hidden`，避免暂停后的沉淀期和 `idleGrace` 被假后台事件打断。

推荐默认配置：

```dart
InteractionSessionConfig(
  allowBackgroundActive: Platform.isWindows || Platform.isMacOS,
  allowLockScreenActive: Platform.isWindows || Platform.isMacOS,
  routeCoveredAsInactive: true,
  countContinuousPlaybackAsActive: true,
)
```

### 4. zhendu_perform

对应文件：

1. `lib/app/modules/zhendu_perform/controllers/zhendu_perform_controller.dart`
2. `lib/app/modules/zhendu_perform/controllers/zhendu_perform_player_controller.dart`
3. `lib/app/modules/zhendu_perform/views/zhendu_perform_view.dart`

接入建议：

1. 该页面的主承载是 `Video(... controls: ...)`，但交互容器仍必须包在页面最外层根部，不能只包 `controls` 返回的局部树。
2. 页面内 `GestureDetector`、字幕区、底部播放器控制器、抽屉列表都算当前页面交互。
3. 播放器传入后，需要监听视频持续播放状态，将其视为活跃累计来源。
4. 页面退出、切歌、播放会话结束时，必须与播放记录同步结束交互会话。
5. Windows、macOS 桌面端如业务需要，可配置 `allowBackgroundActive`、`allowLockScreenActive` 为 `true`；同时生命周期层必须忽略桌面端 `inactive`、`hidden`，避免暂停后的 1 秒沉淀窗口被误判为后台后直接挂起。

推荐默认配置：

```dart
InteractionSessionConfig(
  allowBackgroundActive: Platform.isWindows || Platform.isMacOS,
  allowLockScreenActive: Platform.isWindows || Platform.isMacOS,
  routeCoveredAsInactive: true,
  countContinuousPlaybackAsActive: true,
)
```

### 5. 模块统一要求

以上四个模块统一遵循：

1. 会话开始和结束时机以播放上报为准，不新增另一套业务判断。
2. 页面交互监听必须放在页面最外层根部，不分散写在每个按钮回调里。
3. 只要播放器持续播放中，就持续累计交互时长。
4. 切歌时一定要结束旧交互会话，再开启新交互会话。
5. 上报和失败重试都必须按同一个 `sessionId` 关联播放记录与交互记录。
6. 桌面端 `InteractionSessionContainer` 必须忽略 `inactive`、`hidden`，防止误触发后台挂起。
7. 调试日志默认只保留关键节点，不输出高频噪声日志。

## 十一、Dart 接口签名清单

以下为建议的 Dart 文件级接口签名清单。实现时可以微调细节，但不要偏离职责边界。

### 1. `interaction_record_constants.dart`

建议包含：

```dart
/// 交互时长模块常量
class InteractionRecordConstants {
  /// idle 缓冲默认秒数
  static const int defaultIdleGraceSeconds = 30;

  /// 指针事件默认节流毫秒数
  static const int defaultPointerThrottleMs = 400;

  /// 表名
  static const String tableName = 'interaction_sessions';

  /// 最多保留天数
  static const int maxRetentionDays = 7;

  /// 最大记录条数
  static const int maxRecordCount = 1000;
}

/// 交互记录上报状态
enum InteractionRecordReportStatus {
  pending('pending'),
  failed('failed'),
  success('success');

  final String value;
  const InteractionRecordReportStatus(this.value);
}

/// 交互会话状态
enum InteractionSessionState {
  inactive,
  active,
  idleGrace,
  suspended,
}

/// 交互信号类型
enum InteractionSignal {
  user,
  mouseMove,
  tap,
  doubleTap,
  longPress,
  drag,
  scroll,
  touch,
  playbackActive,
  playbackPaused,
  playbackCompleted,
  autoSwitch,
  popupVisible,
}
```

### 2. `interaction_record_model.dart`

建议包含：

```dart
/// 交互记录数据模型
class InteractionRecordModel {
  /// 主键 ID
  int? id;

  /// 会话 ID
  String sessionId;

  /// 来源标识
  String? source;

  /// 页面类型
  String? type;

  /// 页面类型 ID
  int? typeId;

  /// 风格 ID
  int? styleId;

  /// 方言
  String? dialect;

  /// 学习类型
  String? learnType;

  /// 内容类型
  String contentType;

  /// 内容 ID
  int contentId;

  /// 资源总时长
  double duration;

  /// 会话开始时间
  int startedAt;

  /// 最近活跃时间
  int? lastActiveAt;

  /// idle 开始时间
  int? idleStartedAt;

  /// 会话结束时间
  int? endedAt;

  /// 累计活跃毫秒数
  int accumulatedActiveMs;

  /// 上报状态
  String reportStatus;

  /// 创建时间
  int createdAt;

  /// 更新时间
  int updatedAt;

  /// 扩展字段
  String? extra;

  InteractionRecordModel({
    this.id,
    required this.sessionId,
    this.source,
    this.type,
    this.typeId,
    this.styleId,
    this.dialect,
    this.learnType,
    required this.contentType,
    required this.contentId,
    required this.duration,
    required this.startedAt,
    this.lastActiveAt,
    this.idleStartedAt,
    this.endedAt,
    this.accumulatedActiveMs = 0,
    this.reportStatus = 'pending',
    int? createdAt,
    int? updatedAt,
    this.extra,
  });

  factory InteractionRecordModel.fromMap(Map<String, dynamic> map);

  Map<String, dynamic> toMap();

  Map<String, dynamic> toReportMap();

  InteractionRecordModel copyWith({
    int? id,
    String? sessionId,
    String? source,
    String? type,
    int? typeId,
    int? styleId,
    String? dialect,
    String? learnType,
    String? contentType,
    int? contentId,
    double? duration,
    int? startedAt,
    int? lastActiveAt,
    int? idleStartedAt,
    int? endedAt,
    int? accumulatedActiveMs,
    String? reportStatus,
    int? createdAt,
    int? updatedAt,
    String? extra,
  });

  double get engagementSeconds;
}
```

### 3. `interaction_record_database.dart`

建议包含：

```dart
/// 交互记录数据库
class InteractionRecordDatabase {
  InteractionRecordDatabase._internal();

  static final InteractionRecordDatabase _instance =
      InteractionRecordDatabase._internal();

  static InteractionRecordDatabase get instance => _instance;

  Future<void> initialize();

  Future<int?> insert(InteractionRecordModel record);

  Future<bool> updateRecord(
    int id, {
    int? lastActiveAt,
    int? idleStartedAt,
    int? endedAt,
    int? accumulatedActiveMs,
    String? reportStatus,
    String? extra,
    int? updatedAt,
  });

  Future<bool> updateStatus(
    int id,
    InteractionRecordReportStatus status,
  );

  Future<InteractionRecordModel?> getBySessionId(String sessionId);

  Future<List<InteractionRecordModel>> getPendingRecords({int limit = 50});

  Future<bool> delete(int id);

  Future<bool> deleteByIds(List<int> ids);

  Future<int> cleanExpiredRecords();

  Future<int> cleanExcessRecords();

  Future<void> performCleanup();

  void close();
}
```

### 4. `interaction_player_adapter.dart`

建议包含：

```dart
/// 播放器适配器抽象
abstract class InteractionPlayerAdapter {
  /// 播放状态流
  Stream<bool> get playingStream;

  /// 播放位置流
  Stream<Duration>? get positionStream;

  /// 当前播放位置
  Future<Duration?> getCurrentPosition();

  /// 释放资源
  void dispose();
}

/// AudioPlaybackUtils 适配器
class AudioPlaybackInteractionAdapter implements InteractionPlayerAdapter {
  /// 音频播放器实例
  final AudioPlaybackUtils audioPlaybackUtils;

  AudioPlaybackInteractionAdapter(this.audioPlaybackUtils);

  @override
  Stream<bool> get playingStream;

  @override
  Stream<Duration>? get positionStream;

  @override
  Future<Duration?> getCurrentPosition();

  @override
  void dispose();
}

/// Player 适配器
class GenericPlayerInteractionAdapter implements InteractionPlayerAdapter {
  /// 通用播放器实例
  final Player player;

  GenericPlayerInteractionAdapter(this.player);

  @override
  Stream<bool> get playingStream;

  @override
  Stream<Duration>? get positionStream;

  @override
  Future<Duration?> getCurrentPosition();

  @override
  void dispose();
}
```

### 5. `interaction_session_manager.dart`

建议包含：

```dart
/// 交互会话配置
class InteractionSessionConfig {
  /// 是否允许后台继续累计
  final bool allowBackgroundActive;

  /// 是否允许锁屏继续累计
  final bool allowLockScreenActive;

  /// 路由完全覆盖时是否立即失活
  final bool routeCoveredAsInactive;

  /// 是否将持续播放视为活跃
  final bool countContinuousPlaybackAsActive;

  /// idle 缓冲秒数
  final int idleGraceSeconds;

  /// 指针事件节流毫秒数
  final int pointerThrottleMs;

  const InteractionSessionConfig({
    this.allowBackgroundActive = false,
    this.allowLockScreenActive = false,
    this.routeCoveredAsInactive = true,
    this.countContinuousPlaybackAsActive = true,
    this.idleGraceSeconds = 30,
    this.pointerThrottleMs = 400,
  });
}

/// 交互会话开始参数
class InteractionSessionStartParams {
  /// 页面宿主
  final Object? owner;

  /// 播放器适配器
  final InteractionPlayerAdapter? playerAdapter;

  /// 会话 ID
  final String sessionId;

  /// 来源标识
  final String? source;

  /// 页面类型
  final String? type;

  /// 页面类型 ID
  final int? typeId;

  /// 风格 ID
  final int? styleId;

  /// 方言
  final String? dialect;

  /// 学习类型
  final String? learnType;

  /// 内容类型
  final String contentType;

  /// 内容 ID
  final int contentId;

  /// 资源总时长
  final double duration;

  /// 交互配置
  final InteractionSessionConfig config;

  const InteractionSessionStartParams({
    this.owner,
    this.playerAdapter,
    required this.sessionId,
    this.source,
    this.type,
    this.typeId,
    this.styleId,
    this.dialect,
    this.learnType,
    required this.contentType,
    required this.contentId,
    required this.duration,
    this.config = const InteractionSessionConfig(),
  });
}

/// 当前会话运行时快照
class InteractionSessionSnapshot {
  /// 会话 ID
  final String sessionId;

  /// 当前状态
  final InteractionSessionState state;

  /// 是否播放中
  final bool isPlaybackActive;

  /// 是否后台累计
  final bool isBackgroundAllowed;

  /// 累计活跃毫秒数
  final int accumulatedActiveMs;

  /// 最近活跃时间
  final int? lastActiveAt;

  /// idle 开始时间
  final int? idleStartedAt;

  const InteractionSessionSnapshot({
    required this.sessionId,
    required this.state,
    required this.isPlaybackActive,
    required this.isBackgroundAllowed,
    required this.accumulatedActiveMs,
    this.lastActiveAt,
    this.idleStartedAt,
  });

  /// 当前累计秒数
  double get engagementSeconds;
}

/// 交互会话管理器
class InteractionSessionManager {
  InteractionSessionManager._internal();

  static final InteractionSessionManager _instance =
      InteractionSessionManager._internal();

  static InteractionSessionManager get instance => _instance;

  /// 当前数据库记录 ID
  int? _currentRecordId;

  /// 当前会话 ID
  String? _currentSessionId;

  /// 当前来源标识
  String? _currentSource;

  /// 当前交互记录
  InteractionRecordModel? _currentRecord;

  /// 当前会话状态
  InteractionSessionState _state = InteractionSessionState.inactive;

  /// 当前是否处于持续播放
  bool _isPlaybackActive = false;

  /// 最近一次指针事件时间
  int? _lastPointerSignalAt;

  /// 播放器订阅
  StreamSubscription<bool>? _playingSub;

  /// idle 计时器
  Timer? _idleTimer;

  /// 启动会话
  Future<void> startSession(InteractionSessionStartParams params);

  /// 停止会话
  Future<void> stopSession({
    String? source,
    String? sessionId,
    bool finalizeIdleGrace = true,
  });

  /// 切换会话
  Future<void> switchSession({
    required InteractionSessionStartParams next,
    bool finalizeCurrent = true,
  });

  /// 通知用户交互
  void notifyUserInteraction([
    InteractionSignal signal = InteractionSignal.user,
  ]);

  /// 通知播放中
  void notifyPlaybackActive();

  /// 通知暂停
  void notifyPlaybackPaused();

  /// 通知播放完成
  void notifyPlaybackCompleted();

  /// 通知弹层显隐
  void notifyPopupVisibilityChanged(bool visible);

  /// 通知路由覆盖
  void notifyRouteCovered();

  /// 通知进入后台
  void notifyAppBackground();

  /// 通知回到前台
  void notifyAppForeground();

  /// 获取当前累计秒数
  double getCurrentEngagementSeconds({
    String? sessionId,
    bool includeIdleGrace = true,
  });

  /// 获取当前会话快照
  InteractionSessionSnapshot? getCurrentSnapshot();

  /// 根据会话 ID 查询记录
  Future<InteractionRecordModel?> getRecordBySessionId(String sessionId);

  /// 根据会话 ID 获取上报字段
  Future<Map<String, dynamic>?> getReportPayloadBySessionId(String sessionId);

  /// 根据会话 ID 标记成功
  Future<void> markReportedSuccessBySessionId(String sessionId);

  /// 根据会话 ID 标记失败
  Future<void> markReportedFailedBySessionId(String sessionId);

  /// 重试待上报记录
  Future<void> retryPendingRecords();

  /// 释放资源
  void dispose();
}
```

### 6. `interaction_session_container.dart`

建议包含：

```dart
/// 页面根部交互监听容器
class InteractionSessionContainer extends StatefulWidget {
  /// 子组件
  final Widget child;

  /// 来源标识
  final String source;

  /// 是否启用监听
  final bool enabled;

  const InteractionSessionContainer({
    super.key,
    required this.child,
    required this.source,
    this.enabled = true,
  });

  @override
  State<InteractionSessionContainer> createState() =>
      _InteractionSessionContainerState();
}

/// 页面根部交互监听容器状态
class _InteractionSessionContainerState
    extends State<InteractionSessionContainer>
    with WidgetsBindingObserver, RouteAware {
  /// 上次滚动事件时间
  int? _lastScrollAt;

  /// 上次拖动事件时间
  int? _lastDragAt;

  /// 上次鼠标移动时间
  int? _lastMouseMoveAt;

  @override
  void initState();

  @override
  void didChangeDependencies();

  @override
  void dispose();

  @override
  void didPushNext();

  @override
  void didPopNext();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state);

  /// 处理鼠标移动
  void _handleMouseHover(PointerHoverEvent event);

  /// 处理点击
  void _handleTap();

  /// 处理双击
  void _handleDoubleTap();

  /// 处理长按
  void _handleLongPress();

  /// 处理拖动
  void _handlePanUpdate(DragUpdateDetails details);

  /// 处理滚动
  bool _handleScrollNotification(ScrollNotification notification);

  @override
  Widget build(BuildContext context);
}
```

### 7. `interaction_record_utils.dart`

建议包含：

```dart
library interaction_record_utils;

export 'interaction_record_constants.dart';
export 'interaction_record_model.dart';
export 'interaction_record_database.dart';
export 'interaction_player_adapter.dart';
export 'interaction_session_manager.dart';
export 'interaction_session_container.dart';
```

### 8. 对现有 `PlayRecordManager` 的最小新增接口

`PlayRecordManager` 不负责交互时长计算，但为减少侵入，可以只增加以下少量集成点：

```dart
/// 获取交互上报字段
Future<Map<String, dynamic>> _buildInteractionPayload(String sessionId);

/// 单条上报时拼接交互字段
Future<Map<String, dynamic>> _buildSliceWithInteraction(PlayRecordModel record);

/// 批量上报时拼接交互字段
Future<List<Map<String, dynamic>>> _buildSlicesWithInteraction(
  List<PlayRecordModel> records,
);
```

要求：

1. 不在 `PlayRecordManager` 中实现交互计时状态机。
2. 只通过 `sessionId` 查询交互记录并拼接 `engagementSeconds`。
3. 上报成功失败后，同步调用交互管理器更新状态。

## 十二、实现约束

### 1. 低侵入

实现时必须遵循：

1. 尽量不修改各播放器内部逻辑
2. 尽量不在每个按钮、手势点增加埋点
3. 尽量复用播放上报现有会话时机
4. 尽量通过页面根容器和播放器适配层实现统一监听

### 2. 高内聚

交互模块内部自行处理：

1. 状态机
2. 计时
3. 节流
4. 数据库存储
5. 重试辅助查询

业务页面只负责：

1. 开始会话
2. 结束会话
3. 包装页面监听容器
4. 在必要时传入播放器对象

### 3. 高频事件优化

必须对高频事件做节流，例如：

1. 滚动
2. 拖动

建议：

1. 300ms 到 1000ms 内最多只记一次活跃刷新，允许根据播放器页面特性做适配
2. 不要逐条事件落库
3. 只在关键状态变化或关键生命周期时更新数据库

## 十三、建议的文件划分

建议在目录 `lib/utils/interaction_record_utils/` 下新增：

1. `interaction_record_constants.dart`
2. `interaction_record_model.dart`
3. `interaction_record_database.dart`
4. `interaction_session_manager.dart`
5. `interaction_session_container.dart`
6. `interaction_player_adapter.dart`
7. `interaction_record_utils.dart`

## 十四、产出要求

请输出的实现结果满足以下要求：

1. 代码风格与现有 `play_record_utils` 目录保持一致
2. 尽量复用现有字段语义，如 `type`、`typeId`、`styleId`、`dialect`、`learnType`、`contentType`、`contentId`
3. 所有变量和方法都必须添加清晰注释
4. 提供清晰注释，说明 idle 30 秒和页面失活逻辑
5. 不要把交互时长计算逻辑写进 `PlayRecordManager`
6. `PlayRecordManager` 只在上报时通过 `sessionId` 读取交互时长并拼装请求
7. 批量重试也必须拼接交互时长字段
8. 优先保证架构清晰和可维护性，而不是一次性追求所有边界情况都自动化
9. `InteractionSessionManager` 的调试日志必须区分“关键日志”和“详细日志”；默认详细日志关闭，关键日志只保留排查暂停、恢复、idle 30 秒和挂起问题所需的最小集合

## 十五、补充决策

实现时默认采用以下决策：

1. `engagementSeconds` 作为首个正式上报字段名
2. 自然播放结束但未立即切歌时，允许再进入一次 idle 30 秒
3. 页面被完整新路由覆盖时立即失活
4. 页面进入后台默认立即失活，但可通过配置关闭
5. 后台播放页面由 `InteractionSessionConfig` 控制是否继续累计
6. 当前四个模块中，`song_mv` 默认视为允许后台继续累计的特例页面，其行为与现有播放上报逻辑保持一致
7. `listen_and_read` 默认进入后台即失活，除非后续业务单独调整配置
8. `zhendu_look`、`zhendu_perform` 在 Windows、macOS 桌面端允许通过配置开启后台/锁屏继续累计，同时生命周期监听需忽略桌面端 `inactive`、`hidden`
9. `zhendu_look` 的交互会话启动时机以页面当前实现为准，不因抽象设计而强制改成 `open` 成功后才启动

请严格按照上述设计实现，不要把交互时长当作播放时长复用，也不要将页面交互监听逻辑分散埋在各播放器业务代码中。
