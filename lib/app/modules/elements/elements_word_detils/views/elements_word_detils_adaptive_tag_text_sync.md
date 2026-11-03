# 单词详情页顶部英文自适应标签文本同步

## 目标与验收口径
- 单词详情页右侧顶部英文区域与短语详情页保持一致。
- 英文正文最多展示两行。
- 当英文正文加标签内容超过两行时，自动缩小英文字号。
- 保留现有难度、词性、语法标签的展示样式与顺序。

## 改动点列表
- `elements_word_detils_content_widget.dart`
  - 右侧顶部英文区域改为复用 `ElementsAdaptiveTagTextWidget`
  - 现有标签组装逻辑改为 `tagItems`

## 关键设计 / 关键决策
- 复用 `elements/common/elements_adaptive_tag_text_widget.dart`
- 不使用 `AutoSizeText.rich`，避免 `WidgetSpan` 标签参与测量时触发断言

## 兼容性影响与注意事项
- 当前只同步单词详情页这一个入口
- 中文副标题、记忆按钮、其他标签使用位置不在本次改动范围

## TODO
- 句子详情页如果后续有同类展示需求，继续复用同一组件
