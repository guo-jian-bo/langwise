# 通用设置按钮群组可配置说明

## 目标与验收口径
- 让 `GeneralSettingButtonWidget` 和对应设置弹窗支持按群组配置显示内容。
- 默认行为保持不变：不传配置时，仍展示发音、文本显示、倍速、视觉模式四组。
- 调用方可按需只显示部分群组，例如只显示“文本显示”和“视觉模式”。

## 改动点列表
- 在 `general_setting_button_widget.dart` 中新增 `GeneralSettingGroup` 枚举。
- 为 `GeneralSettingButtonWidget` 增加 `groups` 参数。
- 为 `GeneralSettingDialog.showSetting` 与 `GeneralSettingDialogWidget` 同步增加 `groups` 参数。
- 按 `groups` 动态渲染按钮摘要内容与弹窗内的设置分组。

## 关键设计 / 关键决策
- 采用显式枚举控制群组，而不是多个布尔参数，避免后续参数继续膨胀。
- 默认值保持为全部群组，确保现有页面无需改动。
- 分隔线只在相邻可见群组之间渲染，不为隐藏群组预留空白。

## 兼容性影响与注意事项
- 现有调用方不传 `groups` 时，表现与改造前一致。
- 若调用方传入空数组，按钮摘要和弹窗内容都会为空，当前不额外兜底。

## 示例
```dart
const GeneralSettingButtonWidget(
  hideTranslationOption: true,
  groups: [
    GeneralSettingGroup.textDisplay,
    GeneralSettingGroup.visual,
  ],
)
```

## TODO
- 若后续出现更多页面级设置差异，可继续沿用 `GeneralSettingGroup` 扩展新群组。
