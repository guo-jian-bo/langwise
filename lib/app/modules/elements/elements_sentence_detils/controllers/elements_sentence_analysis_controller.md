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

## 关键设计

- 分析页不依赖详情页传整包数据，只传基础路由参数
- `layer` 优先用显式入参；缺失时再兼容旧 `module`
- 分析页独立走结构分析接口，不再复用详情页 `/detail/v2`
- tab 切换先只改本地状态，不重复请求

## 兼容性影响与注意事项

- 本轮不改左侧媒体区
- 不改单词详情页 UI
- 不改短语详情页 UI
- 不实现 `chunks / svoca / syntax / relations` 具体内容
- 句子分析页数据结构已从 `EnSentenceDetailV2Entity` 切到独立实体

## TODO

- 下一阶段分别接入四个分析内容区
