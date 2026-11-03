# Elements Sentence Analysis Binding

## 目标与验收口径

- 为句子分析页提供独立 binding
- 不复用句子详情页 binding，避免页面职责混杂

## 改动点列表

- 新增 `ElementsSentenceAnalysisBinding`
- 只注册 `ElementsSentenceAnalysisController`

## 关键设计

- 分析页按独立页面处理，后续支持从更多入口直达
- 保持 tag 级实例隔离，与现有元素详情页一致

## 兼容性影响与注意事项

- 不影响原句子详情页 binding
- 不影响单词、短语、词素详情页
