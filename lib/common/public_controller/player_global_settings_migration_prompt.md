# 播放器全局设置统一改造提示词

你是一个资深 Flutter / GetX 工程师。请在当前项目中完成一次**播放器公共设置统一收口**改造。当前项目已经新增了全局控制器：

- `lib/common/public_controller/player_global_settings_controller.dart`

本次目标是让项目中的 **5 个播放器** 统一使用这个全局控制器管理公共播放设置，而不是继续在各自控制器里重复维护一套相同的状态。

这 5 个播放器分别是：

1. `lib/app/modules/song_mv`
2. `lib/app/modules/zhendu_look`
3. `lib/app/modules/zhendu_perform`
4. `lib/app/modules/listen_and_read/views/listen_and_read_reading_view.dart`
5. `lib/app/modules/listen_and_read/views/listen_and_read_shadowing_view.dart`

其中 `listen_and_read` 虽然共用一个主控制器，但从播放器视角要按 **阅读播放器** 和 **跟读播放器** 两个播放器来处理。

## 一、改造目标

把以下公共设置统一交给 `PlayerGlobalSettingsController`：

1. 字幕显示 `subtitleDisplay`
2. 倍速列表 `expandAudioSpeedList`
3. 播放速度 `playbackRate`
4. 播放模式 `audioControlPlayOrder`
5. 循环次数 `audioLoopCount`
6. 字体大小 `audioFontSize`
7. 当前音量 `volume`
8. 视频填充方式 `fit`

以及统一使用这些方法处理设置变更：

1. `onSubtitleDisplayChange`
2. `onPlaybackRateChange`
3. `onPlayOrderChange`
4. `onLoopCountChange`
5. `onFontSizeChange`
6. `onVolumeChange`
7. `onFitChange`

## 二、必须遵守的边界

### 1. 本次只统一“公共播放器设置”

不要把播放器自己的独有能力硬塞进全局控制器。以下能力**暂时保留在各自播放器控制器内部**：

- `zhendu_look` / `zhendu_perform` 的 `playerTiming`
- `zhendu_look` / `zhendu_perform` 的 `remainingTimeText`
- `listen_and_read_shadowing_controller.dart` 的 `singleSentenceTranslate`

说明：

- `singleSentenceTranslate` 是跟读页面“单句模式”的派生显示状态，但它的初始化来源和正文显示判断要跟全局字幕设置保持一致。
- `playerTiming` / `remainingTimeText` 目前不是 `PlayerGlobalSettingsController` 的职责范围，不要顺手并进去。

### 2. 不要做无关重构

- 不要顺手重构整个播放器架构
- 不要顺手改动与设置无关的播放逻辑
- 不要大面积调整文件结构
- 不要全文件格式化
- 只做这次统一设置真正需要的改动

### 3. 代码风格要求

- 严格跟随现有文件风格
- 注释不能缺失，新增的状态字段、方法、关键同步逻辑都要补简短注释
- 避免不必要的折行
- 不允许嵌套三元表达式

## 三、全局控制器职责

以 `lib/common/public_controller/player_global_settings_controller.dart` 为唯一公共设置来源。

这个控制器负责：

1. 初始化本地播放器公共设置
2. 仅同步 `ConfigController.userSetting` 中与倍速有关的设置：
   - `expandAudioSpeed`
   - `expandAudioSpeedList`
3. 同步 `AudioControlUtils.getSetting()` 中的：
   - 字幕显示
   - 播放模式
   - 循环次数
   - 字号
   - 音量
   - `fit`
4. 对外暴露统一的设置修改方法

这里是本次改造的硬边界：

- `ConfigController` 只和播放器的“倍速设置”有关
- 除了倍速相关信息以外，字幕显示、播放模式、循环次数、字体大小、音量、`fit` 都不要再同步 `ConfigController`
- 这次改造的目标就是把播放器设置从 `ConfigController` 里独立出来

注意：

- `InitController` 里已经注册了 `PlayerGlobalSettingsController`
- `initSettings()` 已经在启动阶段调用
- 后续播放器页面和控制器应该只消费这个全局控制器，不要再各自重复初始化同一批公共状态
- `PlayerGlobalSettingsController` 中像 `subtitleDisplay` 这类状态，初始化来源应改为 `AudioControlUtils.getSetting()`，不要再从 `ConfigController.userSetting.expandLang` 派生

## 四、明确要删除或替换的重复状态

### 1. `song_mv`

文件：

- `lib/app/modules/song_mv/controllers/song_mv_controller.dart`
- `lib/app/modules/song_mv/views/song_mv_view.dart`

需要收口到全局控制器的本地状态包括：

- `playbackRate`
- `audioControlTranslate`
- `audioControlPlayOrder`
- `audioLoopCount`
- `audioFontSize`
- `volume`

这些位置不应再继续直接维护本地重复状态：

- `song_mv_controller.dart:91`
- `song_mv_controller.dart:94`
- `song_mv_controller.dart:97`
- `song_mv_controller.dart:100`
- `song_mv_controller.dart:106`
- `song_mv_controller.dart:109`
- `song_mv_controller.dart:275`
- `song_mv_controller.dart:276`
- `song_mv_controller.dart:366`
- `song_mv_controller.dart:368`
- `song_mv_controller.dart:370`
- `song_mv_controller.dart:465`
- `song_mv_controller.dart:466`
- `song_mv_controller.dart:467`
- `song_mv_controller.dart:468`
- `song_mv_controller.dart:1783`

视图层这些绑定要直接改成全局控制器：

- `song_mv_view.dart:685`
- `song_mv_view.dart:686`
- `song_mv_view.dart:695`
- `song_mv_view.dart:696`
- `song_mv_view.dart:697`
- `song_mv_view.dart:706`
- `song_mv_view.dart:707`
- `song_mv_view.dart:708`
- `song_mv_view.dart:713`
- `song_mv_view.dart:728`
- `song_mv_view.dart:729`
- `song_mv_view.dart:730`
- `song_mv_view.dart:734`

额外注意：

- `song_mv_view.dart:469`
- `song_mv_view.dart:512`
- `song_mv_view.dart:573`
- `song_mv_view.dart:574`

这些歌词显示和字号使用点也要改成读取全局控制器，而不是继续读 `SongMvController` 的本地重复字段。

### 2. `listen_and_read`

文件：

- `lib/app/modules/listen_and_read/controllers/listen_and_read_controller.dart`
- `lib/app/modules/listen_and_read/views/listen_and_read_reading_view.dart`
- `lib/app/modules/listen_and_read/views/listen_and_read_shadowing_view.dart`

主控制器中需要收口的重复状态：

- `playbackRate`
- `translateStatus`
- `contentFontSize`
- `volume`
- `playOrderStatus`
- `playOrderLoopCount`

相关重复初始化和保存逻辑主要在：

- `listen_and_read_controller.dart:75`
- `listen_and_read_controller.dart:78`
- `listen_and_read_controller.dart:81`
- `listen_and_read_controller.dart:84`
- `listen_and_read_controller.dart:87`
- `listen_and_read_controller.dart:90`
- `listen_and_read_controller.dart:188`
- `listen_and_read_controller.dart:189`
- `listen_and_read_controller.dart:193`
- `listen_and_read_controller.dart:194`
- `listen_and_read_controller.dart:195`
- `listen_and_read_controller.dart:196`
- `listen_and_read_controller.dart:197`
- `listen_and_read_controller.dart:883`
- `listen_and_read_controller.dart:891`
- `listen_and_read_controller.dart:899`

阅读播放器视图要直接改成全局控制器：

- `listen_and_read_reading_view.dart:195`
- `listen_and_read_reading_view.dart:197`
- `listen_and_read_reading_view.dart:202`
- `listen_and_read_reading_view.dart:203`
- `listen_and_read_reading_view.dart:205`
- `listen_and_read_reading_view.dart:213`
- `listen_and_read_reading_view.dart:214`
- `listen_and_read_reading_view.dart:215`
- `listen_and_read_reading_view.dart:220`
- `listen_and_read_reading_view.dart:227`
- `listen_and_read_reading_view.dart:228`

跟读播放器视图要直接改成全局控制器：

- `listen_and_read_shadowing_view.dart:479`
- `listen_and_read_shadowing_view.dart:480`
- `listen_and_read_shadowing_view.dart:482`
- `listen_and_read_shadowing_view.dart:490`
- `listen_and_read_shadowing_view.dart:492`
- `listen_and_read_shadowing_view.dart:497`
- `listen_and_read_shadowing_view.dart:498`
- `listen_and_read_shadowing_view.dart:499`
- `listen_and_read_shadowing_view.dart:504`

额外注意：

- `listen_and_read_reading_view.dart:58`
- `listen_and_read_reading_view.dart:59`
- `listen_and_read_shadowing_view.dart:221`
- `listen_and_read_shadowing_view.dart:222`

这些正文/字幕显示也依赖字体和字幕模式，同样要切到全局控制器。

保留项：

- `listen_and_read_shadowing_controller.dart` 里的 `singleSentenceTranslate` 仍然保留为页面本地状态，但它的初始值和与正文显隐相关的判断要改为基于 `PlayerGlobalSettingsController.subtitleDisplay`。

额外注意：

- `listen_and_read_shadowing_controller.dart:78`

这里当前通过 `ConfigController.userSetting.value.expandLang` 判断 `singleSentenceTranslate` 初始值，这里也要切到：

- `PlayerGlobalSettingsController.subtitleDisplay`

具体目标是：

1. 如果全局字幕显示是 `LangPreference.bilingual`，则单句模式默认仍为 `LangPreference.bilingual`
2. 其它情况下，单句模式默认仍按当前页面逻辑回落到 `LangPreference.original`

注意：

- 这里不要再读 `ConfigController.userSetting.expandLang`
- `singleSentenceTranslate` 的初始化依据现在是播放器自己的全局设置 `subtitleDisplay`

### 3. `zhendu_look`

文件：

- `lib/app/modules/zhendu_look/controllers/zhendu_look_player_controller.dart`
- `lib/app/modules/zhendu_look/views/zhendu_look_view.dart`

需要统一的重复状态：

- `speedMultiplier`
- `translateStatus`
- `contentFontSizeMultiple`
- `playOrderStatus`
- `playOrderLoopCount`
- `volume`
- `fitEnum`

需要替换的重复初始化和保存逻辑主要在：

- `zhendu_look_player_controller.dart:55`
- `zhendu_look_player_controller.dart:58`
- `zhendu_look_player_controller.dart:61`
- `zhendu_look_player_controller.dart:64`
- `zhendu_look_player_controller.dart:67`
- `zhendu_look_player_controller.dart:73`
- `zhendu_look_player_controller.dart:156`
- `zhendu_look_player_controller.dart:157`
- `zhendu_look_player_controller.dart:162`
- `zhendu_look_player_controller.dart:163`
- `zhendu_look_player_controller.dart:164`
- `zhendu_look_player_controller.dart:165`
- `zhendu_look_player_controller.dart:415`
- `zhendu_look_player_controller.dart:429`
- `zhendu_look_player_controller.dart:436`
- `zhendu_look_player_controller.dart:443`
- `zhendu_look_player_controller.dart:455`
- `zhendu_look_player_controller.dart:461`

视图绑定改为全局控制器：

- `zhendu_look_view.dart:181`
- `zhendu_look_view.dart:182`
- `zhendu_look_view.dart:241`
- `zhendu_look_view.dart:251`
- `zhendu_look_view.dart:252`
- `zhendu_look_view.dart:257`
- `zhendu_look_view.dart:258`
- `zhendu_look_view.dart:270`
- `zhendu_look_view.dart:271`

保留项：

- `playerTiming`
- `remainingTimeText`
- `onPlayerTimingChange`

### 4. `zhendu_perform`

文件：

- `lib/app/modules/zhendu_perform/controllers/zhendu_perform_player_controller.dart`
- `lib/app/modules/zhendu_perform/views/zhendu_perform_view.dart`

需要统一的重复状态：

- `speedMultiplier`
- `translateStatus`
- `contentFontSizeMultiple`
- `playOrderStatus`
- `playOrderLoopCount`
- `volume`
- `fitEnum`

需要替换的重复初始化和保存逻辑主要在：

- `zhendu_perform_player_controller.dart:57`
- `zhendu_perform_player_controller.dart:60`
- `zhendu_perform_player_controller.dart:63`
- `zhendu_perform_player_controller.dart:66`
- `zhendu_perform_player_controller.dart:69`
- `zhendu_perform_player_controller.dart:75`
- `zhendu_perform_player_controller.dart:148`
- `zhendu_perform_player_controller.dart:149`
- `zhendu_perform_player_controller.dart:153`
- `zhendu_perform_player_controller.dart:154`
- `zhendu_perform_player_controller.dart:155`
- `zhendu_perform_player_controller.dart:156`
- `zhendu_perform_player_controller.dart:365`
- `zhendu_perform_player_controller.dart:378`
- `zhendu_perform_player_controller.dart:386`
- `zhendu_perform_player_controller.dart:393`
- `zhendu_perform_player_controller.dart:404`
- `zhendu_perform_player_controller.dart:410`

视图绑定改为全局控制器：

- `zhendu_perform_view.dart:171`
- `zhendu_perform_view.dart:172`
- `zhendu_perform_view.dart:227`
- `zhendu_perform_view.dart:237`
- `zhendu_perform_view.dart:238`
- `zhendu_perform_view.dart:243`
- `zhendu_perform_view.dart:244`
- `zhendu_perform_view.dart:256`
- `zhendu_perform_view.dart:257`

保留项：

- `playerTiming`
- `remainingTimeText`
- `onPlayerTimingChange`

### 5. `show_big_resource_dialog`

文件：

- `lib/common/widgets/show_big_resource_dialog.dart`

这个页面也要纳入本次设置统一范围，但必须按：

- `show_big_resource_dialog.dart:285` 的 `isLearn`

做显式分流。

#### `isLearn == true`

逻辑保持原样，不要改学习场景：

- 继续使用课程侧设置
- 继续走当前学习场景已有逻辑

#### `isLearn == false`

这个场景要切到播放器全局设置。

以下初始化读取要改：

- `show_big_resource_dialog.dart:339`
- `show_big_resource_dialog.dart:340`
- `show_big_resource_dialog.dart:345`
- `show_big_resource_dialog.dart:346`

也就是当前这些值：

- `translateType`
- `playSpeed`
- `contentFontSizeMultiple`
- `volume`

在 `isLearn == false` 时，不能再继续直接从原来的扩展页设置来源取值，而要改为读取：

- `PlayerGlobalSettingsController.subtitleDisplay`
- `PlayerGlobalSettingsController.playbackRate`
- `PlayerGlobalSettingsController.audioFontSize`
- `PlayerGlobalSettingsController.volume`

同时要注意，这个弹窗里不只是初始化要改，**变更方法也要按 `isLearn` 分流**。

需要同步修改的方法包括：

- `show_big_resource_dialog.dart:453` `onVolumeChange`
- `show_big_resource_dialog.dart:461` `changePlaySpeed`
- `show_big_resource_dialog.dart:474` `onSubtitleChange`
- `show_big_resource_dialog.dart:487` `onSubtitleFontSizeChange`

要求是：

1. `isLearn == true` 时，保持原逻辑不变
2. `isLearn == false` 时，改为调用 `PlayerGlobalSettingsController` 对应方法
3. 同时仍然要保留真实播放器调用，例如：
   - `videoController.setVolume(...)`
   - `videoController.setRate(...)`

额外注意：

- `show_big_resource_dialog.dart:727` 的倍速列表也要按场景分流
- `isLearn == true` 时继续用课程侧列表
- `isLearn == false` 时改用 `PlayerGlobalSettingsController.expandAudioSpeedList`

显示层也要同步：

- `show_big_resource_dialog.dart:675`
- `show_big_resource_dialog.dart:676`
- `show_big_resource_dialog.dart:732`
- `show_big_resource_dialog.dart:733`

在 `isLearn == false` 时，正文/字幕显示结果也要真实应用全局的字幕模式和字体大小，而不是只改控制条显示值

## 五、统一后的推荐做法

### 1. 页面/播放器控制器内部拿一次全局控制器引用

不要在同一个文件里到处散落 `Get.find<PlayerGlobalSettingsController>()`。

应在控制器或 View 内部明确持有一个统一引用，例如：

- `final PlayerGlobalSettingsController playerGlobalSettingsController = Get.find<PlayerGlobalSettingsController>();`

然后由这个引用读取和修改公共设置。

### 2. View 直接绑定全局控制器状态

播放器控制条相关配置统一读取：

- `playerGlobalSettingsController.volume.value`
- `playerGlobalSettingsController.playbackRate.value`
- `playerGlobalSettingsController.expandAudioSpeedList`
- `playerGlobalSettingsController.subtitleDisplay.value`
- `playerGlobalSettingsController.audioFontSize.value`
- `playerGlobalSettingsController.audioControlPlayOrder.value`
- `playerGlobalSettingsController.audioLoopCount.value`
- `playerGlobalSettingsController.fit.value`

播放器设置交互统一调用：

- `playerGlobalSettingsController.onVolumeChange`
- `playerGlobalSettingsController.onPlaybackRateChange`
- `playerGlobalSettingsController.onSubtitleDisplayChange`
- `playerGlobalSettingsController.onFontSizeChange`
- `playerGlobalSettingsController.onPlayOrderChange`
- `playerGlobalSettingsController.onLoopCountChange`
- `playerGlobalSettingsController.onFitChange`

### 3. 播放器实例只负责“把全局设置应用到当前播放器”

全局控制器负责保存状态，但**每个播放器实例仍要负责把设置应用到自己的 player/audioPlayerUtils 上**。

例如：

- 音量变化后，要调用当前页面自己的 `player.setVolume(...)` 或 `audioPlayerUtils.setVolume(...)`
- 倍速变化后，要调用当前页面自己的 `player.setRate(...)` 或 `audioPlayerUtils.setPlaybackRate(...)`
- `fit` 变化后，要调用当前页面自己的播放器填充方式更新逻辑

这里是硬要求：

- 不能只改全局状态，不调用真实播放器实例
- 例如 `song_mv_view.dart:699` 这类 `await _controller.audioPlayerUtils.setPlaybackRate(value);` 的真实播放器调用，迁移后仍然必须保留等价调用
- `zhendu_look` / `zhendu_perform` 的 `player.setRate(...)`、`player.setVolume(...)`、`fit` 应用逻辑也都必须继续生效

不要误把“全局状态统一”理解成“播放器实例不需要响应设置变化”。

### 4. 倍速以外不要再联动 `ConfigController`

这次改造后，只有以下两类信息还允许和 `ConfigController` 保持关系：

1. 当前倍速值 `expandAudioSpeed`
2. 倍速选项列表 `expandAudioSpeedList`

除此之外：

- 字幕显示不要再写入 `ConfigController.setUserSetting(expandTranslationType: ...)`
- 正文/字幕显示不要再从 `ConfigController.userSetting.expandLang` 读取
- 播放模式、循环次数、字号、音量、`fit` 都不要再和 `ConfigController` 建立同步关系

也就是说，像以下旧逻辑后续都要去掉：

- `configController.setUserSetting(expandTranslationType: value.code)`
- 基于 `ConfigController.userSetting.value.expandLang` 初始化播放器字幕显示

## 六、容易遗漏的点

### 1. `song_mv` 的用户设置监听不能只删不补

文件：

- `lib/app/modules/song_mv/controllers/song_mv_controller.dart:366`

当前这里监听了 `ConfigController.userSetting`，会把：

- `expandAudioSpeed`

回写到本地状态，并触发：

- `audioPlayerUtils.setPlaybackRate(...)`

改造后如果删掉这段，必须补上新的同步方案，确保：

1. 全局设置变化时，当前 `song_mv` 播放器实例能同步更新实际倍速
2. 字幕显示变化时，歌词 UI 通过全局设置自身刷新，而不是再依赖 `ConfigController.expandLang`
3. 保留等价的 `audioPlayerUtils.setPlaybackRate(...)` 实际调用，不允许只改 Rx 状态

### 2. 只改 View 不够

如果只把控制条 UI 绑定到全局控制器，但播放器初始化时仍然使用本地旧字段，就会出现：

- UI 显示是新值
- 实际播放器仍然按旧值播放

必须同步检查这些初始化入口：

- `song_mv_controller.dart` 中 `initAudioPlayer`
- `listen_and_read_controller.dart` 中 `initAudioPlayer`
- `zhendu_look_player_controller.dart` 中打开/切歌后的播放器参数应用逻辑
- `zhendu_perform_player_controller.dart` 中打开/切歌后的播放器参数应用逻辑

并且要确认以下真实调用没有丢：

- `audioPlayerUtils.setPlaybackRate(...)`
- `audioPlayerUtils.setVolume(...)`
- `player.setRate(...)`
- `player.setVolume(...)`
- 视频播放器 `fit` 的实际应用

### 3. `expandAudioSpeedList` 也要统一来源

以下页面当前还是直接从 `ConfigController.userSetting.value.expandAudioSpeedList` 读：

- `song_mv_view.dart:696`
- `listen_and_read_reading_view.dart:203`
- `listen_and_read_shadowing_view.dart:480`
- `zhendu_look_view.dart:252`
- `zhendu_perform_view.dart:238`

这些都应该切到：

- `PlayerGlobalSettingsController.expandAudioSpeedList`

并且需要额外覆盖这个入口：

- `lib/app/modules/user_center/controllers/user_center_controller.dart:311`

这里的 `changeOtherPlaySpeed(double? speed)` 在修改扩展页倍速成功后，不能只更新：

- `ConfigController.setUserSetting(expandAudioSpeed: otherPlaySpeed.value)`

还必须同步更新：

- `PlayerGlobalSettingsController.playbackRate`

推荐做法是让这个入口直接调用全局控制器提供的倍速更新方法，确保：

1. 用户中心改了“非课程播放速度”之后
2. `PlayerGlobalSettingsController` 内的倍速立即同步
3. 后续进入任意播放器时读到的都是最新全局倍速

### 4. `listen_and_read` 有两个播放器视图

不要只改 `reading_view`，遗漏 `shadowing_view`。

### 5. 正文/歌词字号与字幕显示不只在控制条里使用

除了控制条弹窗，还要同步改这些展示层：

- `song_mv_view.dart` 的全文歌词、逐句歌词
- `listen_and_read_reading_view.dart` / `listen_and_read_shadowing_view.dart` 的内容区
- `zhendu_look_view.dart` / `zhendu_perform_view.dart` 的字幕区
- `show_big_resource_dialog.dart` 在 `isLearn == false` 时的正文/字幕区

也就是说，不只是控制条的选中项要切到全局设置，**所有正文、歌词、字幕区域的显示结果**都要真实应用全局的：

- 字体大小
- 字幕显示模式

### 6. 循环模式切换后的计数重置

`listen_and_read_controller.dart` 当前在：

- `setPlayOrderStatus`
- `setPlayOrderLoopCount`

里会重置 `currentPlayCount`。

全局控制器本身只负责保存公共设置，不知道每个播放器的播放计数状态。因此：

- 公共设置收口后，各播放器仍需要在本地保留“收到模式变化后如何重置当前播放计数”的业务处理
- 不要因为切到全局控制器，就把这类播放器实例级副作用弄丢了

### 7. `fit` 这次也要进入全局控制器

这次与前一版要求不同，`zhendu_look` 和 `zhendu_perform` 的 `fit` 也要统一收口到 `PlayerGlobalSettingsController`。

要求是：

1. 全局控制器新增 `fit` 状态
2. 全局控制器新增 `onFitChange`
3. `zhendu_look_view.dart` / `zhendu_perform_view.dart` 的 `fitConfig` 改为直接绑定全局控制器
4. 两个视频播放器的实际 `fit` 应用逻辑仍然保留在各自播放器控制器里

注意：

- 这里只统一状态来源和设置入口
- 不要顺手改动其它与视频播放无关的业务逻辑

## 七、实施顺序建议

按下面顺序改，避免中途状态错乱：

1. 先补强 `PlayerGlobalSettingsController` 的职责边界和注释
2. 在 5 个播放器相关控制器 / View 中接入全局控制器引用
3. 先替换 View 层控制条绑定
4. 再替换正文、歌词、字幕区域对公共设置的读取
5. 再删除各播放器控制器里的重复状态与重复初始化
6. 最后补上播放器实例对全局设置变化的实际应用逻辑

## 八、完成标准

改造完成后必须满足：

1. 5 个播放器都从 `PlayerGlobalSettingsController` 读取公共设置
2. 不再在各播放器控制器里重复维护同一批公共状态
3. 修改任意一个播放器的公共设置后，其他播放器再次进入时能读到同样的设置
4. 当前正在使用的播放器实例在设置变更后，实际播放效果会同步变化
5. `listen_and_read` 的阅读和跟读两个播放器都已覆盖
6. `zhendu_perform` 已纳入统一范围
7. `fit` 已纳入 `PlayerGlobalSettingsController`
8. `playerTiming`、`remainingTimeText` 这类非公共设置没有被误并入公共控制器
9. `singleSentenceTranslate` 的初始化与正文显示逻辑已正确对齐全局字幕设置
10. 除了倍速及倍速列表外，其它播放器设置都不再依赖 `ConfigController`
11. `user_center_controller.dart:311` 修改非课程倍速后，会同步更新 `PlayerGlobalSettingsController`
12. `show_big_resource_dialog.dart` 已按 `isLearn` 正确分流：`true` 保持原逻辑，`false` 切到播放器全局设置

## 九、改造后请重点自查

请重点检查以下问题：

1. 是否还存在任意一个播放器继续直接读写本地重复的：
   - 倍速
   - 字幕模式
   - 字号
   - 音量
   - 播放模式
   - 循环次数
   - `fit`
2. 是否还有页面继续直接读：
   - `ConfigController.userSetting.value.expandAudioSpeedList`
3. 是否删掉了本地状态，却忘了把设置应用到真实播放器实例
4. 是否误删了播放计数重置逻辑
5. 是否遗漏了 `listen_and_read_shadowing_view.dart`
6. 是否遗漏了 `zhendu_perform`
7. `listen_and_read_shadowing_controller.dart:78` 是否已经改为基于全局 `subtitleDisplay`
8. 是否还存在任何播放器继续通过 `ConfigController` 同步字幕模式、字号、模式、循环、音量或 `fit`
9. `user_center_controller.dart:311` 是否已经补上对 `PlayerGlobalSettingsController` 的倍速同步
10. `show_big_resource_dialog.dart` 是否已经按 `isLearn` 做了初始化、显示和修改方法的完整分流

## 十、补充说明

如果你发现 `PlayerGlobalSettingsController` 当前还缺少以下能力，可以在真正编码时做最小补强，但不要扩大改动范围：

1. 仅对倍速相关配置的持续监听
2. 对 `expandAudioSpeedList` 动态变化的同步
3. 提供一个明确的“从外部入口同步倍速”的方法，给 `user_center_controller.dart:311` 调用
4. 更明确的初始化注释和职责注释

但无论如何，最终都要坚持一个原则：

**播放器公共设置只有一个状态源，就是 `PlayerGlobalSettingsController`。其中只有倍速相关信息允许继续和 `ConfigController` 联动，其它播放器设置必须独立。播放器页面和播放器控制器只负责消费它，并把它应用到各自的真实播放器实例。**
