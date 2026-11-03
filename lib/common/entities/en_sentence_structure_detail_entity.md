# en_sentence_structure_detail_entity 说明

## 目标与验收口径

- 为句子分析页提供独立实体
- 完全对齐 `/languages/content/card/en/sentence/structure/detail`
- 不复用句子详情页 `v2` 实体，不做新旧兼容

## 改动点列表

- 新增 `EnSentenceStructureDetailEntity`
- 拆出：
  - 顶层句子结构详情
  - `structure`
  - `analysisEntries`
  - `analysisData`
- 单独建模：
  - `relations` 分组列表
  - `tokens`
  - `clauses`
  - `syntax`

## 关键设计

- 句子分析页和句子详情页彻底分开建模
- 新接口 `tokens` 可能不返回 `id`，实体层按数组序补齐 `id`
- `relations` 按新接口列表结构建模，不再沿用旧对象结构

## 兼容性影响与注意事项

- 该实体仅供句子分析页使用
- 句子详情页继续使用 `EnSentenceDetailV2Entity`
- 不在本实体里混入 `media / study / legacy / module / layer`

## TODO

- 后续 `svoca / syntax / relations` 继续直接基于这套实体展开
