# ElementsAnalysisCardWidget 右上角入口调整

## 目标与验收口径

- 将 `ElementsAnalysisCardWidget` 的“查看更多”入口从右下角移动到整个卡片右上角。
- 入口紧贴卡片右上角放置，不额外增加外层 padding。
- 删除标题区右侧的编号和英文标题展示。

## 改动点列表

- `elements_analysis_cards_widget.dart`
  - 使用 `Stack` 承载卡片内容与右上角入口。
  - 删除标题区右侧 `index + englishTitle` 区块。
  - 删除底部右下角“查看更多”入口。
  - 新增右上角固定入口，圆角方向改为 `topRight + bottomLeft`。

## 关键设计

- 保留卡片主体结构、渐变头部、左侧色条和中文标题。
- 仅调整“查看更多”入口位置，不改点击行为。

## 兼容性影响与注意事项

- 当前 `englishTitle` 与 `index` 参数仍保留，避免扩大调用侧 diff。
- 若后续确认完全不再使用，可再单独清理字段与入参。
