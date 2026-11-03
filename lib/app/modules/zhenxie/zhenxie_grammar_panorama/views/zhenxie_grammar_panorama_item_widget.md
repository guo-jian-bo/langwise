# ZhenxieGrammarPanoramaItemWidget

## 目标
- 承接语法全景列表页单个卡片 UI。
- 视觉参考 Web 端 `GridListCard.tsx`。
- 列表页采用两列卡片布局。

## 验收口径
- 顶部信息区包含：宫格类型圆点、名称、描述、管理端 ID 标签、CEFR 标签与格子/套数统计。
- 卡片主体表格使用 `GrammarPanoramaMinTableWidget`。
- 小表格优先使用 `sentenceRealizationSets` 中的句子内容渲染。
- 句子文字颜色 `#96DDFA`，背景 `#298AEA` 透明度 `0.12`，字号 `16.wMin`。

## 不做的事
- 不改列表请求与跳转逻辑。
- 不改详情页表格逻辑。
