# 句子详情旧链路删除说明

## 目标与验收口径

- 删除旧句子详情页的 controller、view、内部分析组件与注入链路
- 删除仅供旧句子详情链路使用的旧分析公共组件
- 保留当前 V2 句子详情入口、旧接口 `getSentencesDetils` 与旧实体 `CardSentencesDetilsEntity`

## 改动范围

- `bindings/elements_sentence_detils_binding.dart`
- 删除旧句子详情链路文件：
  - `controllers/elements_sentence_detils_controller.dart`
  - `views/elements_sentence_detils_content_widget.dart`
  - `views/elements_structure_widget.dart`
  - `views/elements_syntactic_analysis_widget.dart`
- 删除仅供旧链路使用的公共组件：
  - `../../common/elements_sentence_analysis_grid_view_widget.dart`
  - `../../common/elements_sentence_analysis_folding_view_widget.dart`
  - `../../common/elements_word_analysis_table.dart`

## 关键设计 / 关键决策

- `Routes.EN_SENTENCE_DETAIL` 继续保留，仍由 V2 页面承接
- `ElementsSentenceDetilsBinding` 仅保留 V2 controller 注入
- 旧接口和旧实体本轮不删除，避免扩大影响面

## 兼容性影响与注意事项

- 文档中可能仍会保留对旧实现的历史描述，但不再参与运行时链路
- 若后续确认旧接口完全无用，再单独清理 `getSentencesDetils` 与 `CardSentencesDetilsEntity`

## TODO / 待确认

- 后续可单独评估是否继续清理旧接口与旧实体
