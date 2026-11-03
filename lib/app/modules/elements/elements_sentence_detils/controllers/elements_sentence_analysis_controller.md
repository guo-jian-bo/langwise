# Elements Sentence Analysis Controller

## 目标与验收口径

- 为句子分析页提供独立 controller
- 页面进入后自行请求 `/languages/content/card/en/sentence/structure/detail`
- 只承接分析页壳和 tab 切换，不实现四块内容 UI

## 改动点列表

- 新增 `ElementsSentenceAnalysisController`
- 读取 `contentId / layer / module`
- 初始化时调用句子结构分析详情接口
- 读取分析页专用 `EnSentenceStructureDetailEntity`
- 维护分析页当前 `analysisLayer`
- 为 `relations` tab 新增独立分页状态与滚动控制器
- `relations` tab 首次进入时调用 `/languages/write/zhenxie/sentence/realization/set/unified/pages`

## 关键设计

- 分析页不依赖详情页传整包数据，只传基础路由参数
- `layer` 优先用显式入参；缺失时再兼容旧 `module`
- 分析页独立走结构分析接口，不再复用详情页 `/detail/v2`
- `chunks / svoca / syntax` 继续复用结构分析详情接口
- `relations` 不再消费结构分析详情里的 `analysisData.relations`
- `relations` 改为按 `sentenceIds: [contentId]` 独立分页请求，`limit` 固定为 `8`
- 非 `relations` 默认不预拉；首次切到 `relations` 或直接以 `relations` 进入时才请求

## 兼容性影响与注意事项

- 本轮不改左侧媒体区
- 不改单词详情页 UI
- 不改短语详情页 UI
- 不改 `chunks / svoca / syntax` 具体内容
- 句子分析页数据结构已从 `EnSentenceDetailV2Entity` 切到独立实体

## TODO

- 关联 tab 如需管理端复用，再补充管理端接口分支
