# zhenxie 短语 item 公共组件抽离说明

## 目标与验收口径

- 先完成短语对照、短语配对、短语搭配组三类卡片 item 的公共化抽离。
- 原有列表页视觉、交互、字段使用方式保持不变。
- 本轮不改接口、不改跳转、不改详情页壳子。

验收标准：

- `zhenxie_phrase_contrast_card_widget.dart`、`zhenxie_phrase_pair_card_widget.dart`、`zhenxie_phrase_match_card_widget.dart` 不再持有各自私有 item 构建逻辑。
- 三类 item 可在 `lib/app/modules/zhenxie/common/` 下被其他 zhenxie 页面直接复用。
- 原有管理端显隐逻辑 `isManagement` 保持不变。

## 改动点

- 新增短语对照 item 公共组件
- 新增短语配对 item 公共组件
- 新增短语搭配组 item 公共组件
- 原三张 card 改为调用公共 item 组件

## 关键设计

- 只下沉 item 层，不顺手抽外层 card 壳子，控制 diff 最小。
- 组件继续直接使用现有实体字段，不新增中间 view model。
- 公共组件仍保留各自内部的正确态 / 空态渲染逻辑，避免过早做跨类型统一抽象。

## 兼容性影响与注意事项

- 现有页面 import 路径会调整到 `zhenxie/common/`。
- 现有布局参数、字号、颜色、管理端 `CopyTagWidget` 行为保持原样。

## TODO

- 后续关联页接入时，直接复用本目录下的三类 item 组件。
