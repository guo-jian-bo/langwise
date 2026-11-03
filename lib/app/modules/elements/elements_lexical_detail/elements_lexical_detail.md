# 同义反义详情页

## 目标与验收口径
- 新增独立的 lexical detail 页面，承接词典详情页“同义反义”入口。
- 页面结构遵循“顶部门头 + 中部双栏内容区 + 底部义项切换条”。
- 数据对接 `GET /write/zhenxie/lexical/detail`，参数使用 `contentType`、`contentId`、`semanticId`。
- 页面本身不写死 `EN_WORD`，后续可通过路由参数承接 `EN_PHRASE`。

## 改动点列表
- 新增 `LexicalDetailEntity` 及相关子实体，严格对齐接口字段层级。
- 在 `ElementsRequest` 中新增 `getLexicalDetail` 请求方法。
- 新增 `elements_lexical_detail` 模块：
  - `controller`
  - `binding`
  - `view`
- 给 `ElementsDictStampCard` 增加可选 `badgeText`，用于成员卡片左上角标签。
- 在单词详情页里将“同义反义”入口切到新页面。

## 关键设计 / 关键决策
- 成员卡片直接复用 `ElementsDictStampCard`，不额外新搭媒体卡，只补左上角标签能力。
- 同义区按 React 口径使用 4 列网格。
- 反义区按 React 口径使用左右对抗布局，每侧 2 列网格。
- 顶部门头的 `translate / descriptions` 只显示中文，不做兜底。
- 底部义项切换复用 `ElementsSemanticBottomBar`，切换后重新请求接口，不做本地假切换。

## 兼容性影响与注意事项
- 本次只改单词详情页的“同义反义”点击入口，短语详情页入口暂不改。
- 旧的 `EN_WORD_ANALYSIS_CARDS` 页面不删除，仍保留给其他链路使用。
- lexical detail 页面支持通用 `contentType` 参数，但当前只从单词详情页接入。

## 待确认问题或 TODO
- 如果后续接入短语详情页，只需要在路由调用时传入 `EN_PHRASE`。
- 若产品后续要求成员卡片标签分颜色展示，可在 `ElementsDictStampCard.badgeText` 基础上再扩展样式参数。
