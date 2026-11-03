# Elements Sentence Analysis View

## 目标与验收口径

- 新增句子分析页壳
- 页面支持根据 `contentId / layer / module` 进入
- 页面进入后自行请求 `/en/sentence/detail/v2`
- 先展示统一分析壳与 tab 切换，占位承接四块分析内容

## 改动点列表

- 新增 `ElementsSentenceAnalysisView`
- 底部展示四层切换条
- 中间内容区按 layer 切换
- 新增 `ElementsSentenceChunkContentWidget`
- `chunks` 已接入首版可用 UI，`svoca / syntax / relations` 仍为占位
- 页面当前直接消费 `EnSentenceStructureDetailEntity`

## 关键设计

- 分析页与详情页解耦，单独持有自己的加载状态
- tab 切换暂不重复请求，先切本地层状态
- `analysisEntries` 作为底部层切换真相源
- `chunks` 首版按“新 UI + 新数据链路”重做，不复用旧版句子结构分析 UI
- 语块页首版拆成两段：
  - 上半：按 token 轨道和 clause 分行展示语块
  - 下半：折叠结构卡承接 clause 语块详情
- 句子分析页独立走 `/languages/content/card/en/sentence/structure/detail`

## 兼容性影响与注意事项

- 本轮只实现 `chunks` 首版可用 UI
- `svoca / syntax / relations` 仍未接入真实内容
- 进入分析页后仍遵守权益锁态
- 页面不再依赖详情页 `v2` 接口
- 语块页当前为首版可用，不一次做满产品文档里的全部规则
- 当前仍未完全覆盖：
  - 缩写回贴原文
  - 余文补齐
  - 嵌套语块赢者规则
  - 连接词被更大 span 包住时的严格跳过规则

## TODO

- 补齐 `chunks` 精细规则
- 接入 `svoca` 内容
- 接入 `syntax` 内容
- 接入 `relations` 占位态
