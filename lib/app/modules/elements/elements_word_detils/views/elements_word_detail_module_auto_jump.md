# 单词详情页 module 自动跳转说明

## 目标与验收口径

- 单词详情页首次进入后，如果接口返回的 `module` 存在
- 且该 `module` 与 `analysisData` 中的字段名严格匹配
- 则页面自动跳转到对应分析页面

## 改动范围

- `elements_word_detils_content_widget.dart`

## 本次规则

- 严格按字面匹配，不做业务语义兜底
- 直接使用 `analysisData.toJson()` 的键判断是否命中
- 仅当 `module` 与 `analysisData` 中的字段名完全一致时才触发自动跳转

## 跳转行为

- `grammar` -> 词形变化详情页
- `memory` -> 词源记忆页
- `sentences` -> 例句分析卡片页
- `phrases` -> 短语分析卡片页
- `synonyms` -> 同义词分析卡片页

## 关键决策

- 自动跳转只在首次进入页面时执行一次
- 不影响页面内已有的卡片点击跳转逻辑
- 不修改 controller 与实体结构，逻辑放在当前详情内容组件内完成

## 注意事项

- 当前“是否触发自动跳转”的判断是严格使用 `module` 对 `analysisData` 字段名做匹配
- 分析卡片页已兼容 `sentences / phrases / synonyms` 这类复数字段名，调用方无需再额外做本地映射
