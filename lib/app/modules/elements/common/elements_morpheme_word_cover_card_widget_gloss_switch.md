# 词素成员词卡片释义显隐开关说明

## 目标与验收口径
- 为 `ElementsMorphemeWordCoverCardWidget` 增加可选的释义显隐能力。
- 默认保持原行为不变。
- 在 morphology 成员词详情页中，可单独关闭内容区域的 `gloss` 释义展示。

## 改动点列表
- 在 `elements_morpheme_word_cover_card_widget.dart` 中新增 `showGloss` 参数。
- 在 `manage_word_morphology_details_view.dart` 的卡片使用处传入 `showGloss: false`。

## 关键设计 / 关键决策
- 采用页面侧显式传参控制，而不是直接改公共组件默认行为，避免影响词素详情等其他复用场景。
- 关闭释义后，原有发音胶囊按钮仍按原逻辑保留显示。

## 兼容性影响与注意事项
- 不传 `showGloss` 时，卡片行为与改动前一致。
- 当前只有 morphology 详情页关闭了释义，其他页面不受影响。

## TODO
- 若后续还需要控制更多内容块显隐，可继续沿用同类显式参数方案扩展。
