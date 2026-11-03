# 句组双列列表组件说明

## 目标与验收口径

- 抽出单元目标页与句子分析页共用的句组双列卡片列表。
- 列表布局、卡片分支和点击跳转保持与单元目标页原实现一致。
- 支持通过参数覆盖空态文案与列表 padding，便于不同页面复用。

## 本次改动点

- 新增 `sentence_grammar_group_list_widget.dart`。
- 统一承接以下句组资产卡片分支：
  - `EN_SENTENCE_PATTERN`
  - `EN_SENTENCE_PARADIGM`
  - `EN_SENTENCE_PATTERN_PAIR`
  - `EN_SENTENCE_PATTERN_PAIR_FORK`
  - `EN_SENTENCE_GRAMMAR_GRID`

## 关键设计

- 组件只负责列表排布和卡片路由，不持有页面状态。
- `isManagement` 继续透传给下层卡片和详情页路由。
- 不在组件内增加搜索、筛选、排序逻辑，保持职责单一。

## 兼容性影响与注意事项

- 默认 padding 保持单元目标页原值。
- 句子分析页复用时应传入自己的 padding，避免与外层页面留白叠加。

## 非目标

- 不改具体卡片 widget 的内部展示逻辑。
- 不改句组实体字段结构。
