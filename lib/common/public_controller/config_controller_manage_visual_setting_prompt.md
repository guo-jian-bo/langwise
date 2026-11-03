# GeneralSettingButtonWidget 管理端视觉模式轻量改造提示词

你是一个资深 Flutter / GetX 工程师。请在当前项目中做一次轻量、聚焦的设置弹窗改造。**本次只允许修改 `lib/common/widgets/general_setting_button_widget.dart`**，不要合并控制器，不要删除 `ManageSettingController`，不要改 `ConfigController` 结构，也不要顺手调整其他页面逻辑。

本次目标很明确：

1. `GeneralSettingButtonWidget` 增加 `bool isManagement = false` 参数
2. 当 `isManagement == false` 时，继续保持现有用户端行为不变
3. 当 `isManagement == true` 时，在设置弹窗中额外走一套“管理端视觉模式”逻辑
4. 管理端视觉模式整体交互和 UI 结构都要尽量与用户端视觉模式保持一致，但**多一个地区选择**
5. 用户端继续读 `ConfigController`
6. 管理端继续读 `ManageSettingController`
7. 禁止把 `ManageSettingController` 合并进 `ConfigController`
8. 禁止修改 `ManagementController`、`CourseUnitTargetController`、`ConfigController`、`ManageSettingController` 等其他文件

## 一、必须遵守的边界

- 只改 `lib/common/widgets/general_setting_button_widget.dart`
- 不引入新依赖
- 不修改其他文件中的调用逻辑
- 不做控制器合并
- 不删除 `ManageSettingController`
- 不重构当前项目的整体设置架构
- 保持现有代码风格、命名风格、导入顺序和排版习惯
- 改动必须是外科手术式的，只处理这次需求真正需要的内容

## 二、核心思路

这次不是做架构统一，而是做**组件内部场景分流**。

组件需要同时支持两种场景：

### 1. 用户端场景

沿用当前实现：

- 发音
- 文本显示
- 倍速
- 视觉模式

用户端所有设置仍然基于：

- `ConfigController`

### 2. 管理端场景

在不改动外部架构的前提下，让同一个设置组件支持管理端显示与弹窗交互。

管理端视觉模式仍然基于：

- `ManageSettingController`

管理端和用户端最大的区别是：

- 用户端视觉模式：资源类型 + 风格
- 管理端视觉模式：资源类型 + 画风 + 地区

因此，本次只需要在组件内部对“视觉模式”相关逻辑做显式分流。

## 三、唯一允许修改的文件

### `lib/common/widgets/general_setting_button_widget.dart`

这是本次改造的唯一目标文件。

你需要在这个文件中完成以下事项。

## 四、Widget 参数改造要求

### 1. `GeneralSettingButtonWidget`

给 `GeneralSettingButtonWidget` 增加：

- `final bool isManagement;`

构造函数中提供默认值：

- 默认 `false`

这样可以保证原有用户端调用方无需修改也能继续工作。

这里是硬要求：

- `isManagement` 必须默认 `false`
- 不能让外部所有旧调用点都被迫补参数

### 2. 参数透传

`isManagement` 必须继续往下透传到：

- `GeneralSettingDialog.showSetting(...)`
- `GeneralSettingDialogWidget(...)`

禁止在组件内部通过 `Get.isRegistered<ManageSettingController>()` 之类的方式猜测场景。

场景必须只由 `isManagement` 决定。

## 五、顶部摘要 `_buildSettingWidget()` 改造要求

### 1. 用户端保持原状

当 `isManagement == false` 时：

- 继续按当前逻辑读取 `ConfigController`
- 保持现有文案和展示方式不变

### 2. 管理端增加管理端视觉模式摘要

当 `isManagement == true` 时：

- 发音 / 文本显示 / 倍速仍按当前通用逻辑展示
- 视觉模式摘要改为读取 `ManageSettingController`

管理端视觉模式摘要需要显示：

- `资源类型 · 画风名 · 地区名`

这里的语义不是用户端风格名，而是管理端的：

- `defaultResources`
- `selectedStyleKey`
- `getCurrentStyleAreaName()`

如果地区为空，按当前文件现有风格做最小兜底，不要为了显示定义无意义中转变量。

## 六、弹窗状态初始化要求

### 1. 用户端初始化保持原状

继续使用：

- `ConfigController`
- `selectMode`
- `styleList`
- `selectStyle`

### 2. 管理端初始化新增独立逻辑

当 `isManagement == true` 时，视觉模式相关初始化不能再直接套用户端那套字段。

需要从 `ManageSettingController` 读取：

- 当前资源类型
- 当前画风
- 当前地区
- 当前风格分组数据

管理端视觉模式本地状态建议独立维护，例如按实际需要增加：

- 管理端画风列表
- 管理端地区列表
- 当前选中的地区 code
- 当前选中的画风 key

命名按当前文件风格保持清晰即可。

注意：

- 用户端 `styleList` 使用的是 `TeamStyleEntityStyleItems`
- 管理端地区列表使用的是 `ImageStyleConfigV2Item`

两套数据结构不同，不要强行混成一套字段。

## 七、保存逻辑 `save()` 改造要求

### 1. 用户端

继续保持原保存逻辑：

- 保存发音
- 保存文本显示
- 保存倍速
- 保存用户端视觉模式

### 2. 管理端

当 `isManagement == true` 时：

- 发音 / 文本显示 / 倍速仍按当前通用逻辑保存到 `ConfigController`
- 视觉模式保存到 `ManageSettingController`

管理端视觉模式保存至少需要覆盖：

- 资源类型
- 画风
- 地区
- 对应的 `styleId`

可直接复用：

- `switchResources(...)`
- `setStyleIdByStyleKeyAndAreaCode(...)`

保存完成后仍然保持：

- `Get.back(result: true);`

## 八、视觉模式 UI 改造要求

当前 `groupWidgets.add(_buildVisualWidget());` 这一块，需要根据 `isManagement` 分流。

### 1. 用户端视觉模式

保留现有 `_buildVisualWidget()` 的交互与展示逻辑。

### 2. 管理端视觉模式

新增一套“管理端视觉模式” UI，交互和 UI 结构都要尽量与用户端保持一致，但多一个地区选择。

建议拆分为两个私有方法，避免一个方法内堆过多分支：

- `_buildUserVisualWidget()`
- `_buildManageVisualWidget()`

最终在组装 `groupWidgets` 时按 `isManagement` 选择。

## 九、管理端视觉模式 UI 的具体要求

管理端视觉模式需要至少具备以下选择项：

1. 资源类型选择
   - 图片
   - 视频
2. 画风选择
3. 地区选择

交互要求：

- 管理端视觉模式的 UI 结构要尽量对齐用户端视觉模式，不要单独做成完全不同的弹窗块样式
- 整体风格尽量贴近用户端视觉模式现有写法
- 管理端切换逻辑参考 `lib/app/modules/management/common/manage_list_tool_button_widget.dart` 中 `ManageListToolDialogWidget` 的处理方式
- 切换画风后，必须重新查询对应的地区列表，而不是只在旧列表中做筛选
- 当前地区如果已不在新的地区列表中，应按当前项目习惯回落到可用项
- 最终保存时必须能正确映射到 `styleId`

管理端切换画风时，行为要求要与 `ManageListToolDialogWidget` 保持一致：

1. 更新当前选中的画风
2. 重新调用管理端控制器查询该画风对应的地区列表
3. 检查当前地区是否仍然存在于新地区列表中
4. 如果不存在，自动回落到新地区列表中的第一个可用地区

不要把“切换风格后更新地区”的逻辑简化成只改一个选中值，这样会导致地区与画风不匹配。

如果当前文件里已有用户端视觉模式的局部组件、按钮样式、选中态写法，优先复用，不要重新造一套完全不同的 UI 风格。

## 十、“管理端视觉模式”文案要求

在管理端场景中，视觉模式区域的标题或语义要体现“管理端视觉模式”。

要求：

- 用户端仍然保持原有“视觉模式”语义
- 管理端要明显区分为“管理端视觉模式”

具体实现方式可以按当前文件结构决定，例如：

- 标题直接改为“管理端视觉模式”
- 或在该区域局部文案中体现

但必须让阅读代码和使用 UI 的人都能看出这是管理端专用的视觉设置。

## 十一、禁止事项

本次改造中明确禁止：

1. 修改 `ConfigController`
2. 修改 `ManageSettingController`
3. 修改 `ManagementController`
4. 修改 `CourseUnitTargetController`
5. 修改其他页面调用方
6. 删除任何控制器文件
7. 做控制器合并
8. 顺手做全文件格式化
9. 为了统一数据结构而引入额外复杂抽象

## 十二、实现建议

建议按以下顺序处理：

1. 给 `GeneralSettingButtonWidget` 增加 `isManagement`
2. 把 `isManagement` 透传到 dialog
3. 分离顶部摘要显示逻辑
4. 分离弹窗初始化逻辑
5. 分离视觉模式 UI
6. 分离 `save()` 中视觉模式保存逻辑
7. 自查用户端是否完全保持原行为

## 十三、输出要求

完成后请确保：

1. 只修改了 `lib/common/widgets/general_setting_button_widget.dart`
2. 用户端行为不变
3. 管理端新增了“管理端视觉模式”能力
4. 管理端视觉模式比用户端多一个地区选择
5. 编译通过
6. 静态分析无新增报错

请直接落代码，不要只给方案。
