# 关联 Tab 复用说明

## 目标与验收口径

- 句子分析页 `relations` tab 改为直接复用句组双列卡片列表。
- `relations` 数据不再使用结构分析详情接口返回的 `analysisData.relations`。
- `relations` 改为调用 `/languages/write/zhenxie/sentence/realization/set/unified/pages` 分页获取。
- 分页 `limit` 固定为 `8`。
- 展示效果与单元目标页句组 tab 保持一致。
- 若无关联数据，展示空态“当前句子暂无关联”。

## 本次改动点

- `elements_sentence_relations_content_widget.dart` 改为只消费分析页 controller 内的分页列表状态。
- 复用 `sentence_grammar_group_list_widget.dart`，不在当前文件内维护单独的五类关联卡片分支。
- 删除原先按 group 分段的标题、色点与分组容器。

## 组件复用策略

- 直接复用单元目标页与句法模块共用的 `SentenceGrammarGroupListWidget`。
- 具体卡片分支继续走共享组件内部的五类资产渲染逻辑，不在当前页面重复实现。

## 交互与规则

- `relations` 列表顺序直接跟随后端分页接口返回顺序，不做前端重排。
- 页面展示改为双列平铺句组卡片，不再保留旧版分组头。
- 仅在首次切到 `relations` tab 或直接以 `relations` 进入分析页时请求。
- 保持底部留白，避免被底部层级切换栏遮挡。

## 非目标

- 本次不改 `chunks / svoca / syntax` 已有内容。
- 不改句子详情页右侧的关联预览卡片。
- 不改后端返回结构。

## 兼容性与注意事项

- 句子分析页外层已有左右留白，复用句组列表时不能再叠加单元目标页的横向 padding。
- 当前分页接口请求体按 `sentenceIds: [contentId]` 传参。
