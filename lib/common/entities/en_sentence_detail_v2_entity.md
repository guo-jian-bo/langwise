# en_sentence_detail_v2_entity 说明

## 目标

为句子详情页 V2 提供独立实体，避免继续把新协议塞进旧 `CardSentencesDetilsEntity`。

## 本次改动

- 新增 `EnSentenceDetailV2Entity`
- 按接口文档拆出：
  - 顶层详情
  - `media`
  - `study`
  - `legacy`
  - `structure`
  - `analysisEntries`
  - `analysisData`
- 兼容句子分析页新的结构分析接口返回
- `analysisData.relations` 兼容旧对象结构与新列表结构

## 设计取舍

- 字段名尽量保持和后端返回一致，方便排查数据来源
- 复用已有公共实体：
  - `LanguageText`
  - `PronunciationsEntity`
  - `LockEntity`
  - `ElementsCardStar`
  - `CardDetilsEntityStat`
  - `CardWordSemanticModuleItem`
- 不改旧实体，先让 V1 / V2 并行

## 非目标

- 不处理旧句子详情页 UI
- 不改单词详情页 UI
- 不改短语详情页 UI
- 不接入 `relations` 真数据逻辑，只保留协议结构

## 注意点

- 该实体是 V2 页面专用，不建议和旧 `CardSentencesDetilsEntity` 混用
- 后续详情壳和分析层应直接读这套实体，避免 controller 再包一层中转字段
- 当前分析页新接口不再保证返回 `media / study / legacy / module / layer`
- `analysisData.tokens` 里可能缺少 `id`，使用时需要兼容按数组序回退
