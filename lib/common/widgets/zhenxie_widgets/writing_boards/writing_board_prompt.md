# WritingBoardData 设计与落地提示词

## 目标

请为 `writing_boards` 体系建立一套可扩展的数据驱动方案，让：

1. `BoardBoxWidget` 不再在 `_buildBodyWidget()` 内硬编码业务数据
2. `ZhenxieTaskDetailsController.detailsData` 可以先转换成统一的 `WritingBoardData`
3. 转换逻辑全部放到 `writing_boards/utils/` 下
4. 各种板式共用一套输入模型，但不强行把所有运行时交互都塞进一个 DTO
5. 兼容原型 `ui_ux/src/pages/zhenxie/write/CompositionWritingDetailPage.tsx` 的核心行为
6. 当前阶段所有资源只做本地选择，不在组件内部上传
7. `BoardBoxWidget` 只负责渲染、交互和结果回传，保存草稿 / 提交 / 上传由页面层处理

---

## 本轮新增约束

### 1. 资源选择先不上传

当前阶段：

1. 图片 / 视频 / 音频只保留本地结果
2. 不在 `BoardBoxWidget` 内部上传
3. 不在 `WritImageUploadWidget / WritVideoUploadWidget / WritRecordingUploadWidget` 内部上传
4. 真正上传统一延后到“暂存草稿”或“提交”时由页面层触发

### 2. 组件负责交互，不负责提交

`BoardBoxWidget` 的职责应限定为：

1. 根据 `WritingBoardData` 渲染不同板式
2. 维护必要的输入交互
3. 响应选中拍位、切换范文、选择媒体等行为
4. 把最新结果回传给页面或 controller

不负责：

1. 上传文件
2. 保存草稿接口
3. 提交接口
4. 本地持久化策略

### 3. step 行必须可选中

每个 step 行都要支持“当前选中拍位”联动，包含两类点击：

1. 点击输入框
2. 点击范文文本

都要切换到当前 `beatNid`

补充规则：

1. 点击输入框时，除了切换到对应 `beatNid`，还要让输入框获取焦点
2. 输入框有焦点时，输入框边框颜色为 `#9A3412`
3. 输入框失焦时，不显示输入框边框
4. 非输入框文本区域如果处于选中态，也需要显示选中边框

### 4. 点击拍位圆章的行为

`WritStepTextWidget` 左侧步骤圆章点击规则：

1. 如果不是填空态，则可以弹出 `ZhenxieParagraphStepDetailsDialog`
2. 如果是填空态，要避免误弹或明确禁用

建议把“是否可弹窗”做成数据和回调，不要把弹窗逻辑死写在 widget 内部。

当前阶段已确定：

1. 弹窗逻辑放到外层
2. 管理端允许查看

### 5. step 选中态要能换颜色

你已经明确：

1. 外边框颜色要跟随当前 `beatNid` 改变
2. 圆章文字前景色也要跟着改
3. 颜色来源应和 `paragraphRhetoricalList` 联动
4. 选中状态要和 `ZhenxieTaskDetailsController.selectBeatNid` 联动

### 6. 查看范文的切换规则

这块要与页面按钮逻辑一致：

1. 当前是写作态，点击“查看范文”
   - 如果 `stage.lockExemplarView != true`，直接切到范文
   - 如果锁住了，先弹锁弹窗
2. 当前已经在范文态，点击“继续写作”
   - 直接切回写作态

建议：

1. `BoardBoxWidget` 只消费 `isViewSample`
2. 锁判断和弹窗放在页面 / controller

### 7. 题干素材没有单一 type 字段

当前任务详情 DTO 里没有一个统一的“题干素材类型”字段。

现有字段是：

1. `stemImageUrls`
2. `stemVideoUrls`
3. `stemAudioUrls`

因此当前应在 mapper 中把这三组字段归一成 `materials[]`，每项带 `kind`。

### 8. 页面模式不要只靠 `isViewSample`

这轮已经明确，当前页面实际存在 3 种不同语义：

1. 用户做题
   - 展示任务数据
   - 只允许编辑 `fill == write` 的位置
2. 查看范文
   - 展示范文数据
   - 全部只读
3. 编辑范文
   - 仍然展示范文数据
   - 但标题 / 正文 / 文首 / 文尾全部可编辑
   - 初始值必须使用范文内容回填

因此不要再只靠 `isViewSample` 一个布尔值表达全部状态。

建议拆成两个维度：

1. `contentSource`
   - 当前渲染的是任务数据还是范文数据
2. `editPolicy`
   - 当前按什么规则决定是否可编辑

### 9. `contentSource / editPolicy` 要用“宏对象 + value”方案

这两个字段会经过：

1. 路由参数
2. `Get.arguments`
3. controller 初始化
4. DTO / view model 映射

因此这里不要只定义裸字符串常量，也不要直接把 Dart enum 实例传进页面。

正确做法是：

1. 定义“宏对象”
2. 宏对象内部持有稳定的 `value`
3. 页面路由、`Get.arguments`、接口参数里只传 `value`
4. controller 内部需要时，再通过 `value` 反查对应宏对象

也就是说：

1. 宏要支持 `value`
2. 传输层只传 `value`
3. 业务层可以继续使用宏对象统一收口

推荐写法：

推荐固定值：
/// 写作板内容来源宏。
class WritingBoardContentSourceMacro {
  /// 内容来源稳定值，用于路由参数、Get.arguments 和持久化传递。
  final String value;

  /// 内容来源调试名，仅用于日志和排查，不参与业务判断。
  final String debugName;

  /// 内容来源宏私有构造。
  const WritingBoardContentSourceMacro._({
    required this.value,
    required this.debugName,
  });

  /// 任务作答数据来源。
  static const WritingBoardContentSourceMacro task = WritingBoardContentSourceMacro._(
    value: 'task',
    debugName: 'task',
  );

  /// 范文数据来源。
  static const WritingBoardContentSourceMacro exemplar = WritingBoardContentSourceMacro._(
    value: 'exemplar',
    debugName: 'exemplar',
  );

  /// 所有可用内容来源宏。
  static const List<WritingBoardContentSourceMacro> values = [
    task,
    exemplar,
  ];

  /// 根据稳定值反查对应内容来源宏。
  static WritingBoardContentSourceMacro fromValue(String? value) {
    for (final item in values) {
      if (item.value == value) return item;
    }
    return task;
  }
  static const String task = 'task';
  static const String exemplar = 'exemplar';
/// 写作板编辑策略宏。
class WritingBoardEditPolicyMacro {
  /// 编辑策略稳定值，用于路由参数、Get.arguments 和持久化传递。
  final String value;

  /// 编辑策略调试名，仅用于日志和排查，不参与业务判断。
  final String debugName;

  /// 编辑策略宏私有构造。
  const WritingBoardEditPolicyMacro._({
    required this.value,
    required this.debugName,
  });

  /// 按任务 stage 的 `fill` 规则决定哪些位置可编辑。
  static const WritingBoardEditPolicyMacro stageRule = WritingBoardEditPolicyMacro._(
    value: 'stage_rule',
    debugName: 'stageRule',
  );

  /// 全部只读，不允许输入。
  static const WritingBoardEditPolicyMacro readOnly = WritingBoardEditPolicyMacro._(
    value: 'read_only',
    debugName: 'readOnly',
  );

  /// 强制全部可编辑，用于范文编辑态。
  static const WritingBoardEditPolicyMacro forceEditable = WritingBoardEditPolicyMacro._(
    value: 'force_editable',
    debugName: 'forceEditable',
  );

  /// 所有可用编辑策略宏。
  static const List<WritingBoardEditPolicyMacro> values = [
    stageRule,
    readOnly,
    forceEditable,
  ];

### 10. 任务页里的“查看范文”必须和“直接进入范文页”拆开

这一轮新增一个非常关键的页面边界：

当前 `zhenxie_task_details` 实际承载两类大功能，但它们不是同一条数据链路。

#### 场景 A：直接进入范文页

指的是：

1. 路由进入时 `contentSource == exemplar`
2. 页面初始化阶段直接查询范文详情
3. 初始就是范文预览页，可继续切换到范文编辑态

这个场景的现有主流程可以保留。

#### 场景 B：从任务页点击“查看范文”

指的是：

1. 路由进入时 `contentSource == task`
2. 页面初始化阶段只查询任务详情
3. 用户点击“查看范文”时，才额外调用范文详情接口
4. 切换后展示的是“任务内的范文预览模式”，不是“重置成独立范文页”

这里必须满足：

1. 任务详情查询与范文详情查询分开
2. 任务数据和范文数据分开缓存
3. 任务态运行时输入状态和范文态运行时输入状态分开缓存
4. 从任务态切到范文预览态时，不能覆盖任务态已填写内容
5. 从范文预览态切回写作态时，要恢复之前的输入框内容、图片、视频、音频选择结果
6. 任务页首次进入时，不允许为了“顺手准备”而提前查询范文详情

也就是说：

1. `getTaskDetailsData()` 只负责任务数据
2. `getExemplarDetailsData()` 只负责范文数据
3. `viewSample()` 在任务页里点击时，要先确保范文详情已按需查询成功，再切换展示源
4. 切回写作态时，要重新绑定任务态对应的 `WritingBoardData + RuntimeState`

推荐 controller 设计：

1. 保留一个“当前展示态”的响应式数据给 View 使用
2. 同时分别持有：
   - `taskDetailsData`
   - `taskKnowledgePointsList`
   - `exemplarDetailsData`
   - `exemplarKnowledgePointsList`
3. 写作板运行时至少拆成：
   - 任务草稿态快照
   - 范文编辑态快照
4. 不要让任务态的 `detailsData` 被范文接口返回值直接覆盖，否则会影响：
   - 提交任务时的 `taskId / stage / compositionWritingId`
   - 写作态文本恢复
   - 媒体作答恢复
   - 右侧资料区内容恢复

补充说明：

1. “任务内的范文预览模式”本质上仍是当前页面内部的模式切换
2. 它和“独立范文页”的区别在于：
   - 独立范文页：初始化就查范文
   - 任务内范文预览：点击按钮后才查范文
   - 返回写作态时必须恢复任务态草稿，不允许丢状态

  /// 根据稳定值反查对应编辑策略宏。
  static WritingBoardEditPolicyMacro fromValue(String? value) {
    for (final item in values) {
      if (item.value == value) return item;
    }
    return stageRule;
  }
  static const String readOnly = 'read_only';
  static const String forceEditable = 'force_editable';

补充约束：

1. `WritingBoardData` 里可以同时保留：
   - `String contentSource`
   - `String editPolicy`
2. 如果 controller 或 mapper 里需要分支判断，优先：
   - `WritingBoardContentSourceMacro.fromValue(contentSource)`
   - `WritingBoardEditPolicyMacro.fromValue(editPolicy)`
3. 页面间传参、序列化、持久化时，一律使用：
   - `WritingBoardContentSourceMacro.xxx.value`
   - `WritingBoardEditPolicyMacro.xxx.value`

当前页面推荐只允许以下 3 种组合：

1. `task + stage_rule`
   - 用户做题
2. `exemplar + read_only`
   - 查看范文
3. `exemplar + force_editable`
   - 编辑范文

不建议出现：

1. `task + read_only`
2. `task + force_editable`
3. `exemplar + stage_rule`

除非后续业务明确新增对应场景。

### 10. 本轮新增变量和方法必须补注释

这轮涉及：

1. 新增宏对象
2. 新增 `contentSource / editPolicy`
3. 新增 runtime state
4. 新增 controller 方法
5. 新增 mapper / factory / parse 方法

因此本轮新增代码中，所有新增的变量和方法都必须带简短准确的注释。

要求：

1. 成员变量注释要说明：
   - 它存的是什么
   - 为什么存在
   - 何时变化
2. 方法注释要说明：
   - 它做什么
   - 何时调用
   - 关键副作用
3. `fromValue()`、`copyWith()`、`_rebuildWritingBoardState()` 这类方法也不能省注释
4. 不能只给类写注释，内部新增字段和方法也要写
5. 提示词中的示例代码如果新增了变量和方法，也应同步带注释，避免落地时遗漏

---

## 先做的判断

### 不要把所有东西都塞进 `WritingBoardData`

`BoardBoxWidget` 下的样式虽然多，但真正变化的维度并不多，主要是：

1. 板式皮肤：`skinNid`
2. 作答类型：`answerKind`
3. 文首 / 文尾结构
4. 正文拍位列表
5. 每拍当前显示的是输入态还是范文态
6. 媒体作答区是图片 / 视频 / 音频哪一种
7. 图像素材区、默认媒体、已有答案、范文答案

真正复杂的是运行时交互，不是静态渲染数据本身：

1. `TextEditingController`
2. `FocusNode`
3. 音视频播放器
4. 录音中间态
5. 选择文件后的本地 `File`
6. 暂存 / 提交过程中的脏数据

所以建议拆成三层：

1. `WritingBoardData`
   - 纯渲染数据
   - 来自 `task details`
   - 可安全在 controller 中持有
2. `WritingBoardRuntimeState`
   - 运行时输入态
   - 例如每拍当前输入文本、头尾输入值、当前选中的本地媒体
3. `WritingBoardControllers`
   - 输入框控制器 / FocusNode / 播放器等
   - 由 utils 构建与释放

---

## 推荐目录职责

### `model/writing_board_data.dart`

这里只放“纯数据模型”，不要放：

1. `TextEditingController`
2. `FocusNode`
3. `Player`
4. `VideoController`
5. `File`
6. `StreamSubscription`

### `utils/`

建议拆成下面几类文件：

1. `writing_board_mapper.dart`
   - `ZhenxieTaskDetailsEntity -> WritingBoardData`
2. `writing_board_runtime_state.dart`
   - 运行时可编辑状态模型
3. `writing_board_controller_bundle.dart`
   - 输入框控制器集合
4. `writing_board_media_utils.dart`
   - 媒体答案、范文答案、默认素材转换
5. `writing_board_factory.dart`
   - 对外统一入口，组合 mapper + runtime state + controller bundle

---

## 推荐数据结构

### 1. 顶层 `WritingBoardData`

建议字段：

```dart
class WritingBoardData {
  final String? skinNid;
  final String? answerKind;
  final bool isViewSample;
  final bool isManagement;
  final String contentSource;
  final String editPolicy;
  final bool showHead;
  final bool showTail;
  final bool headEditable;
  final bool tailEditable;
  final String? headLabel;
  final String? tailLabel;
  final String? headText;
  final String? tailText;
  final List<WritingBoardStepData> steps;
  final List<WritingBoardMaterialData> materials;
  final WritingBoardMediaAnswerData? mediaAnswer;
  final WritingBoardMediaAnswerData? exemplarMediaAnswer;
}
```

说明：

1. `skinNid`
   - 决定 `BoardBoxWidget` 用哪种板式容器
2. `answerKind`
   - 决定 `picture_page` 下是正文 / 图片 / 视频 / 音频
3. `contentSource`
   - `task / exemplar`
   - 控制当前页面展示任务数据还是范文数据
4. `editPolicy`
   - `stage_rule / read_only / force_editable`
   - 控制当前页面如何判定可编辑区域
5. `showHead/showTail`
   - 来自 `blueprint.frame + stage.headFill/tailFill`
6. `headEditable/tailEditable`
   - `stage_rule` 下参考原型 `editingExemplar || headFill == 'write'`
   - 但这里要按当前 `editPolicy` 统一计算，不要继续写死成 `!isViewSample`
7. `headText/tailText`
   - 当前画面要展示的文首 / 文尾内容
8. `steps`
   - 正文拍位列表
9. `materials`
   - 顶部图像 / 音频 / 视频素材
10. `mediaAnswer`
   - 当前作答媒体区
11. `exemplarMediaAnswer`
   - 查看范文时使用

### 2. `WritingBoardStepData`

```dart
class WritingBoardStepData {
  final String beatNid;
  final String beatLabel;
  final String? paragraphTypeNid;
  final String? paragraphTypeName;
  final String? usageName;
  final String? usageDescription;
  final String fill;
  final bool selected;
  final bool editable;
  final bool hidden;
  final bool canOpenStepDialog;
  final Color? beatColor;
  final Color? beatForegroundColor;
  final String? text;
  final String? placeholder;
  final int? paragraphId;
}
```

说明：

1. `fill`
   - `write / given / hidden`
2. `editable`
   - 不能再简单写成 `fill == write && !isViewSample`
   - 应该按 `editPolicy` 计算：
     1. `stage_rule`
        - `fill == write`
     2. `read_only`
        - `false`
     3. `force_editable`
        - `true`，但仅对可见 step 生效
3. `selected`
   - 是否等于当前 controller 的 `selectBeatNid`
4. `canOpenStepDialog`
   - 是否允许点击左侧拍位圆章弹出详情
5. `beatColor / beatForegroundColor`
   - 来自 `paragraphRhetoricalList`
6. `text`
   - 当前展示文案
   - 写作态用草稿 / 当前输入初值
   - 范文态用 exemplar paragraph content
7. `paragraphId`
   - 方便后续点“评点这段”
8. `focused`
   - 输入框当前是否持有焦点

### 3. `WritingBoardMaterialData`

```dart
class WritingBoardMaterialData {
  final String kind; // image / video / audio
  final String url;
  final String? key;
}
```

用途：

1. `WritLookImageWidget` 顶部素材区
2. 后续看图写作不止图片时，也能扩展

### 4. `WritingBoardMediaAnswerData`

```dart
class WritingBoardMediaAnswerData {
  final String kind; // image / video / audio
  final int minCount;
  final int maxCount;
  final List<WritingBoardMediaItemData> items;
}
```

### 5. `WritingBoardMediaItemData`

```dart
class WritingBoardMediaItemData {
  final String? key;
  final String? url;
  final String? localPath;
}
```

说明：

1. `url`
   - 服务端已有答案 / 范文答案
2. `localPath`
   - 本地新选文件
3. 不要在纯 DTO 里直接放 `File`

---

## 运行时状态建议

### `WritingBoardRuntimeState`

```dart
class WritingBoardRuntimeState {
  final String contentSource;
  final String editPolicy;
  String headText;
  String tailText;
  Map<String, String> stepTextMap;
  List<WritingBoardMediaItemData> answerImages;
  List<WritingBoardMediaItemData> answerVideos;
  List<WritingBoardMediaItemData> answerAudios;
}
```

用途：

1. controller 持有当前草稿
2. `BoardBoxWidget` 渲染时读取
3. 后续提交时再从这里拼请求参数
4. 当前阶段只保留本地选择结果，不做上传
5. `contentSource + editPolicy` 需要一起持有，避免任务草稿和范文编辑态串数据

补充建议：

1. 用户做题草稿与范文编辑草稿不要共用同一个 runtime state
2. 至少应拆成：
   - `taskDraftRuntimeState`
   - `sampleEditRuntimeState`

---

## 控制器集合建议

### `WritingBoardControllers`

```dart
class WritingBoardControllers {
  final TextEditingController headController;
  final TextEditingController tailController;
  final Map<String, TextEditingController> stepControllers;

  void dispose() { ... }
}
```

说明：

1. `headController`
   - 仅当 `showHead && headEditable`
2. `tailController`
   - 仅当 `showTail && tailEditable`
3. `stepControllers`
   - key 用 `beatNid`
4. 播放器不要先放进这里
   - 播放器更适合留在具体媒体 widget 内部
   - 或者后面单独抽 `WritingBoardMediaControllers`

---

## `BoardBoxWidget` 的推荐参数

建议把当前：

```dart
final bool isViewSample;
final bool isManagement;
```

升级成：

```dart
final WritingBoardData data;
final WritingBoardRuntimeState? runtimeState;
final WritingBoardControllers? controllers;
final void Function(String beatNid)? onTapStep;
final void Function(String beatNid)? onSelectBeatNid;
final void Function(String beatNid)? onRequestStepFocus;
final void Function(String beatNid, String text)? onStepTextChanged;
final void Function(String text)? onHeadChanged;
final void Function(String text)? onTailChanged;
final void Function(WritingBoardMediaItemData? item)? onImageChanged;
final void Function(WritingBoardMediaItemData? item)? onVideoChanged;
final void Function(WritingBoardMediaItemData? item)? onAudioChanged;
```

如果第一阶段只想少改，可以先保留：

1. `isViewSample`
2. `isManagement`

但 `BoardBoxWidget` 至少要新增：

```dart
final WritingBoardData data;
```

然后内部改成：

1. 用 `data.skinNid` 选板式
2. 用 `data.answerKind` 选 `picture_page` 下的正文 / 图片 / 视频 / 音频
3. 用 `data.steps` 渲染正文
4. 用 `data.headText / tailText` 渲染首尾

---

## 各板式如何映射

### 纯正文类

包括：

1. `sticky_note`
2. `name_tag`
3. `form_blank`
4. `profile_card`
5. `textbook_page`
6. `report_paper`
7. `newspaper_column`

统一走：

1. 外层板式容器不同
2. 内层都是 `WritJustTextWidget`

它们真正需要的数据几乎一致：

1. `steps`
2. `isViewSample`
3. 当前输入文本 / 范文文本

### 首尾结构类

包括：

1. `email_client`
2. `letter_paper`
3. `message_slip`
4. `diary_notebook`
5. `speech_card`
6. `storybook_spread`

统一走：

1. `showHead/showTail`
2. `headLabel/tailLabel`
3. `headText/tailText`
4. `headEditable/tailEditable`
5. `steps`

### 标题 + 正文类

包括：

1. `bulletin_board`

建议也仍然复用头尾结构模型，只是：

1. `headLabel = 标题`
2. `tailLabel = 落款`

### 看图 / 多媒体类

包括：

1. `picture_page`

需要：

1. `materials`
2. `answerKind`
3. `steps` 或 `mediaAnswer`

规则：

1. `answerKind == text`
   - 下方走正文板
2. `answerKind == image`
   - 下方走图片上传
3. `answerKind == video`
   - 下方走视频上传
4. `answerKind == audio`
   - 下方走录音 / 音频上传

---

## 从 `ZhenxieTaskDetailsEntity` 到 `WritingBoardData` 的映射建议

### 顶层来源

1. `detailsData.skinNid`
2. `detailsData.stage?.answerKind`
3. `detailsData.blueprint?.frame`
4. `detailsData.stage?.headFill`
5. `detailsData.stage?.tailFill`
6. `detailsData.stage?.slots`
7. `detailsData.blueprint?.slots`
8. `detailsData.memberList`
9. `detailsData.members`
10. `detailsData.headText`
11. `detailsData.tailText`
12. `detailsData.stemImageUrls / stemVideoUrls / stemAudioUrls`
13. `detailsData.answerImageKeys / answerImageUrls / answerVideoKeys / answerVideoUrls / answerAudioKeys / answerAudioUrls`
14. `paragraphRhetoricalList`
15. `selectBeatNid`

### 关键映射规则

#### 1. 首尾显示规则

参考原型：

1. `showHead = frame.hasHead && headFill != hidden`
2. `showTail = frame.hasTail && tailFill != hidden`
3. `contentSource == exemplar && editPolicy == force_editable` 时：
   - 所有可见文首 / 文尾都可编辑
4. `editPolicy == stage_rule` 时：
   - `headEditable = headFill == write`
   - `tailEditable = tailFill == write`
5. `editPolicy == read_only` 时：
   - `headEditable = false`
   - `tailEditable = false`

#### 2. 正文 steps 规则

1. 以 `stage.slots` 为准，不是以 `blueprint.slots` 全量平铺
2. `fill == hidden` 的拍不要进可写 steps
3. `paragraphTypeNid` 以 `stage.slots[].paragraphTypeNid` 为准
4. `usageName / usageDescription` 从 `blueprint.slots[].allowedParagraphs[]` 里按 `paragraphTypeNid` 匹配
5. `selected = step.beatNid == selectBeatNid`
6. `beatColor / beatForegroundColor` 从 `paragraphRhetoricalList` 匹配当前拍位
7. 输入框焦点状态要参与 step 边框显示
8. `editPolicy == force_editable` 时：
   - 所有可见 step 都应 `editable = true`
   - 不再受 `fill == write / given` 限制
9. `contentSource == exemplar` 时：
   - step 的初始文本应来自范文段落内容
10. `contentSource == task && editPolicy == stage_rule` 时：
   - 才按当前任务答题语义处理 `write / given`
11. 当前真实接口样本已经确认：
   - `task detail` 返回的 `memberList[].content` / `memberList[].paragraph.content` 可能就是当前草稿正文
   - 因此 `fill == write` 时也不能默认清空
   - 必须把接口已返回的文本当成任务草稿初值喂给写作板

#### 3. 范文态正文

1. `contentSource == exemplar` 时，正文显示 `memberList` 对应段落内容
2. 如果没有 `memberList`，至少能用 `members + paragraphId` 做占位映射
3. 点击范文文本也要回调当前 `beatNid`
4. 如果是“编辑范文”：
   - 展示仍然来自范文
   - 但表现层要切成输入框
   - 输入框初始值也来自范文

#### 4. 媒体态正文

1. `answerKind != text` 时，正文 steps 可以为空
2. 渲染改走 `mediaAnswer`
3. 组件只回传本地媒体选择结果，不执行上传
4. 当前真实接口样本已经确认：
   - `task detail` 返回的 `answerImageUrls / answerVideoUrls / answerAudioUrls`
   - 在任务作答态下应视为“当前草稿媒体答案”
   - mapper 构建 `mediaAnswer` 时不能只保留空壳，必须把现有草稿媒体一并带入 `items`

---

## 当前最缺的字段

如果要把 `BoardBoxWidget` 真正做成和原型一致，当前协议或实体层最缺这些字段：

### A. 草稿态字段

这里要按真实接口返回修正旧判断。

当前这轮已拿到的 `task detail` 样本表明：接口本身已经会返回“当前作答草稿”的一部分，不能再按“完全没有草稿字段”处理。

已确认的草稿来源：

1. 正文草稿：
   - `memberList[].content`
   - `memberList[].paragraph.content`
2. 媒体草稿：
   - `answerImageKeys / answerImageUrls`
   - `answerVideoKeys / answerVideoUrls`
   - `answerAudioKeys / answerAudioUrls`
3. 文首 / 文尾：
   - 仍使用顶层 `headText / tailText`
   - 但具体语义要结合 `stage.headFill / tailFill` 判断

因此当前推荐结论应改为：

1. 接口返回的草稿内容要先进入 `WritingBoardData`，作为首屏初值
2. `WritingBoardRuntimeState` 负责承接“进入页面后用户继续编辑”的增量状态
3. controller 重建写作板时，优先级应为：
   - 本地 runtime 快照
   - 接口已返回的草稿内容
   - 兜底空值
4. 不要在 `mapTaskDetailsToWritingBoardData()` 里把 `fill == write` 的任务态文本直接写死成空字符串
5. 不要在任务态 `mediaAnswer` 里只创建空 `items`

### B. 文首 / 文尾“给定态”文案来源

如果 `headFill == given` / `tailFill == given`，需要明确：

1. 给定内容到底来自 `headText/tailText`
2. 还是来自任务自己的固定字段

结合交接文档、任务详情 DTO 和原型代码，当前可以确认：

1. 原型在 `given` 态下显示的是范文实例的 `headText / tailText`
2. 任务详情接口已经把这两个字段拍平到了 DTO 顶层
3. 因此 Flutter 侧如果拿的是任务详情 DTO，应直接使用顶层 `detailsData.headText / detailsData.tailText`
4. 不需要再额外从别的“固定字段”里找一层

### C. step 输入框的稳定主键

虽然现在能用 `beatNid` 做 key，但更稳的字段最好有：

1. `slotId`
2. 或者明确 `beatNid` 在 stage 中唯一

### D. 媒体答案的 key/url 同时态

目前有：

1. `answerImageKeys`
2. `answerImageUrls`
3. `answerVideoKeys`
4. `answerVideoUrls`
5. `answerAudioKeys`
6. `answerAudioUrls`

但如果是“本地刚选未上传”，还缺：

1. 本地文件路径
2. 上传中状态
3. 上传失败状态

当前这轮你已经明确：

1. 第一阶段不需要上传中
2. 第一阶段不需要失败重试
3. 但仍需要本地文件结果

所以这轮最少先补：

1. 本地文件路径
2. 本地选择状态

### E. 顶部素材区的结构化模型

现在是：

1. `stemImageUrls`
2. `stemVideoUrls`
3. `stemAudioUrls`

但 `WritLookImageWidget` 顶部现在只会渲染图片卡片，后续若要兼容多媒体素材，最好统一成：

1. `materials[]`
2. 每项自带 `kind`

补充结论：

1. 题干素材类型不是由 `stage.answerKind` 决定
2. `stage.answerKind` 只决定底部“答卷区”是正文 / 图片 / 视频 / 音频哪一种
3. 顶部题干素材区要单独读取：
   - `stemImageUrls`
   - `stemVideoUrls`
   - `stemAudioUrls`
4. 前端应把这三组数据归一成 `materials[]`
5. 每个素材卡片继续使用统一矩形容器，但内部根据 `kind` 切换成图片预览 / 视频预览 / 音频占位样式

### F. 每拍点击后的业务能力

原型里支持：

1. 选中当前拍
2. 查看给定段 / 范文段
3. 评点这段

当前 Flutter 这套板子还缺：

1. 点击某拍后的回调标准
2. 给定段 / 范文段对应的 paragraph 详情对象
3. 点击左侧拍位圆章是否允许弹详情

### G. 范文切换判定来源

当前页面已经有：

1. `isViewSample`
2. `stage.lockExemplarView`
3. `viewSample(context)`

建议继续保持：

1. 组件层只吃 `isViewSample`
2. 锁判断和弹窗放 controller / page

但这轮需要补充一个更高优先级结论：

1. `isViewSample` 可以继续保留给旧逻辑兼容
2. 但它只能表达“当前是否展示范文”
3. 不能继续承担“当前是否只读”的职责
4. “是否可编辑”以后应由 `editPolicy` 决定

### H. 题干素材展示形式

当前已经明确：

1. 题干素材可能同时存在图片 / 视频 / 音频
2. 如果素材类型不同，需要根据 `kind` 显示对应 UI
3. 即便不是图片，也继续使用统一矩形卡片容器
4. 矩形卡片内部内容按类型切换，不再固定只显示图片

### I. 多资源作答区 UI 规则

当前已经明确：

1. 作答区图片 / 视频 / 音频能力设计上支持多个
2. 具体最多几个，以 `answerMinCount / answerMaxCount` 为准
3. 作答区 UI 需要改成：
   - 上方显示“已选资源列表”
   - 下方显示“添加资源按钮区”
4. 当已选数量达到 `maxCount` 时：
   - 隐藏添加按钮
   - 或保留数量展示但不再允许继续添加
5. 每个已选资源卡片需要支持删除

推荐交互：

1. 图片
   - 网格或横向列表展示
   - 卡片右上角删除
2. 视频
   - 纵向卡片列表
   - 展示缩略图、时长、删除
3. 音频
   - 纵向卡片列表
   - 展示文件信息、播放、删除
4. 如果同一类型存在多个入口，例如图片有“选择图片 / 拍照上传”
   - 未达上限时显示全部入口按钮
   - 达到上限后统一隐藏

---

## 这轮建议新增字段

如果按你这轮交互要求推进，`WritingBoardData / WritingBoardStepData` 至少要补：

1. `materials`
   - 统一承载题干图片 / 视频 / 音频
2. `selected`
   - 每拍是否选中
3. `beatColor`
   - 拍位主色
4. `beatForegroundColor`
   - 圆章前景色
5. `canOpenStepDialog`
   - 是否允许点左侧圆章弹详情
6. `headEditable / tailEditable`
7. `mediaAnswer.items[].localPath`
8. `focused`
   - 当前 step 输入框是否聚焦
9. `contentSource`
   - `task / exemplar`
10. `editPolicy`
   - `stage_rule / read_only / force_editable`
11. 任务态草稿初值
   - 正文来自 `memberList`
   - 媒体来自 `answer*Keys / answer*Urls`

页面 / controller 回调至少要补：

1. `onSelectBeatNid`
2. `onTapStep`
3. `onRequestStepFocus`
4. `onStepTextChanged`
5. `onHeadChanged`
6. `onTailChanged`
7. `onImageChanged`
8. `onVideoChanged`
9. `onAudioChanged`

---

## 第一阶段推荐落地顺序

### 第一步：先把数据模型定住

只完成：

1. `WritingBoardData`
2. `WritingBoardStepData`
3. `WritingBoardMaterialData`
4. `WritingBoardMediaAnswerData`
5. `WritingBoardMediaItemData`

### 第二步：在 `utils/` 建 mapper

新增：

1. `mapTaskDetailsToWritingBoardData()`
2. `buildWritingBoardRuntimeState()`
3. `buildWritingBoardControllers()`
4. 统一的 `contentSource / editPolicy` 解析方法
5. 明确“接口草稿初值 -> runtime state -> 页面提交数据”的覆盖顺序

### 第三步：让 `BoardBoxWidget` 先吃 `WritingBoardData`

先不要一口气改所有内部子组件，只先把：

1. `skinNid`
2. `answerKind`
3. `headText/tailText`
4. `steps`
5. `materials`

喂进去

### 第四步：再逐个替换内部硬编码

顺序建议：

1. `WritStepTextWidget`
2. `WritHeadBoxWidget`
3. `WritJustTextWidget`
4. `WritHeadTailWidget`
5. `WritTitleWidget`
6. `WritLookImageWidget`
7. `WritImageUploadWidget`
8. `WritVideoUploadWidget`
9. `WritRecordingUploadWidget`

---

## 建议分步骤推进

这块工作量确实不小，建议按下面 4 个阶段拆开做，每一阶段都保证可以单独验收。

### 阶段 1：数据层先站稳

目标：

1. 建立 `WritingBoardData`
2. 建立 `WritingBoardRuntimeState`
3. 建立 `WritingBoardControllers`
4. 建立 `ZhenxieTaskDetailsEntity -> WritingBoardData` 的 mapper

这一阶段先不大改 UI，只要把数据通路打通。

验收点：

1. `BoardBoxWidget` 不再写死 `skinNid`
2. `BoardBoxWidget` 不再写死 `answerKind`
3. 顶部题干素材已能归一成 `materials[]`
4. step 已能映射出 `selected / beatColor / beatForegroundColor`

### 阶段 2：正文写作交互

目标：

1. 先改 `WritStepTextWidget`
2. 再改 `WritJustTextWidget / WritHeadTailWidget / WritTitleWidget`
3. 打通 `selectBeatNid`
4. 打通输入框焦点与选中态边框

验收点：

1. 点击输入框会切换当前 `beatNid`
2. 点击输入框会自动获取焦点
3. 聚焦时输入框显示 `#9A3412` 边框
4. 失焦时输入框边框隐藏
5. 非输入框文本在选中态也能显示边框
6. 左侧拍位圆章的弹窗逻辑已外置

### 阶段 3：题干素材区 + 多资源作答区

目标：

1. 改 `WritLookImageWidget`
2. 改 `WritImageUploadWidget`
3. 改 `WritVideoUploadWidget`
4. 改 `WritRecordingUploadWidget`

重点：

1. 顶部题干素材支持图片 / 视频 / 音频混合展示
2. 底部作答区支持多个资源
3. 资源列表与按钮区分层展示
4. 达到 `maxCount` 后隐藏添加按钮

验收点：

1. 顶部题干区不再固定只渲染图片
2. 底部图片 / 视频 / 音频作答区支持多个资源
3. 删除资源后按钮能重新出现
4. 组件只回传本地结果，不执行上传

### 阶段 4：页面整合与提交占位

目标：

1. controller 持有完整 runtime state
2. 页面把按钮行为统一接到 controller
3. 暂存 / 提交先保留占位方法
4. 查看范文 / 继续写作切换完全对齐页面逻辑
5. `编辑范文` 接到独立的范文编辑态

验收点：

1. 页面可以拿到完整的文本结果和媒体结果
2. `saveDraft()` / `submitTask()` 已接线但仍可空实现
3. `viewSample()` 行为与锁逻辑完全正确
4. `navigateToEditPage()` 不再切回普通写作态，而是切到 `exemplar + force_editable`
5. `saveSample()` 只处理范文编辑态保存

---

## 本轮新增的页面状态结论

当前页面不要再抽象成“只有两种状态”。

更准确的结论是：

1. 页面仍然只有一个
2. 但页面内至少有 3 种业务模式

### 模式 1：用户做题

1. `contentSource = task`
2. `editPolicy = stage_rule`
3. 展示任务数据
4. 只允许编辑任务里 `fill == write` 的区域

### 模式 2：查看范文

1. `contentSource = exemplar`
2. `editPolicy = read_only`
3. 展示范文数据
4. 全部只读

### 模式 3：编辑范文

1. `contentSource = exemplar`
2. `editPolicy = force_editable`
3. 仍然展示范文数据
4. 标题 / 正文 / 文首 / 文尾全部改成输入框
5. 输入框初值全部使用范文内容回填

---

## 控制器层推荐落地

以 `ZhenxieTaskDetailsController` 为例，建议：

### 1. 页面入参仍然允许继续传字符串

例如：

```dart
Get.toNamed(
  Routes.ZHENXIE_TASK_DETAILS,
  arguments: {
    'pageType': 1,
    'compositionUid': compositionUid,
    'contentSource': 'exemplar',
    'editPolicy': 'read_only',
  },
);
```

### 2. `onInit` 中统一解析字符串 value

原则：

1. 先读 `Get.arguments['contentSource']`
2. 再读 `Get.arguments['editPolicy']`
3. 如果没传，再按旧逻辑兜底：
   - `pageType == 1` 默认 `exemplar + read_only`
   - `pageType == 0` 默认 `task + stage_rule`

### 3. `navigateToEditPage()` 的职责

当 `pageType == 1` 时，不应该再写成“切换为写作模式 编辑范文”，而应该改成：

1. `contentSource = exemplar`
2. `editPolicy = force_editable`
3. 用范文详情初始化 `sampleEditRuntimeState`
4. 重建写作板

### 4. `saveSample()` 的职责

1. 从 `sampleEditRuntimeState` 读取最新范文输入
2. 组装保存参数
3. 调范文保存接口
4. 成功后切回：
   - `contentSource = exemplar`
   - `editPolicy = read_only`
5. 再刷新详情或本地回写 `detailsData`

---

## 第一阶段验收标准

1. `BoardBoxWidget` 不再写死 `skinNid` 和 `answerKind`
2. `WritJustTextWidget` 不再写死 3 段假数据
3. `WritHeadTailWidget` 不再写死 `Dear Tom / Your`
4. `WritLookImageWidget` 顶部素材能从 `detailsData` 映射出来
5. `picture_page + video/audio/image/text` 四种分支能靠 `WritingBoardData.answerKind` 切换
6. controller 中只保留“拿详情 + 转 view model + 管理 runtime state”
7. 纯 DTO 与运行时 controller 分离
8. step 点击输入框 / 范文文本时能联动当前 `selectBeatNid`
9. step 选中态颜色能跟随 `paragraphRhetoricalList`
10. 查看范文切换逻辑与页面按钮一致
11. 编辑范文时所有可见标题 / 正文 / 文首 / 文尾都能进入输入态
12. 编辑范文进入时，输入框初值全部来自范文内容

---

## 结论

`WritingBoardData` 应该是“统一渲染模型”，不是“把所有输入框控制器和媒体播放器塞进去的大对象”。

最稳的方案是：

1. `detailsData -> WritingBoardData`
2. `WritingBoardData + runtime state + controllers -> BoardBoxWidget`

这轮新增后的更完整结论是：

1. 页面不拆
2. 不再只靠 `isViewSample` 表达全部状态
3. 增加两个字符串字段：
   - `contentSource`
   - `editPolicy`
4. 传入页面、controller 持有、mapper 计算、widget 渲染，全部基于这两个 value 串起来
5. `isViewSample` 仅作为“当前是否展示范文”的兼容字段保留

如果只先做第一阶段，当前最需要你补确认的字段有：

1. 当 `headFill / tailFill == given` 时，文首 / 文尾展示文案直接使用任务详情 DTO 顶层的 `detailsData.headText / detailsData.tailText`
2. 草稿保存这轮先不考虑，controller 里保留空方法占位即可
3. 提交参数结构这轮先不考虑，controller 里保留空方法占位即可
4. 题干素材没有统一类型字段时，先把 `stemImageUrls / stemVideoUrls / stemAudioUrls` 归一成 `materials[]`；注意这和 `stage.answerKind` 是两套语义，再根据 `kind` 切换卡片内部 UI
5. 点左侧拍位圆章时，管理端允许查看，具体弹窗逻辑由外层传入
