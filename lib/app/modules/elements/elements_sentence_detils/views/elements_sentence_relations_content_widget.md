# 关联 Tab 接入说明

## 目标与验收口径

- 接入句子分析页 `relations` tab 的真实 content，不再展示“待接入”。
- 展示逻辑以产品文档 `02.dictionary.md` 第 6 节和 React `SentenceRelationsBoard.tsx` 为准。
- 关联模块按 `assetType` / `code` 分组渲染，仅显示有数据的模块。
- 若五类模块都为空，展示统一空态“还没有关联句”。

## 本次改动点

- 新增 `elements_sentence_relations_content_widget.dart` 作为关联 tab 内容组件。
- `elements_sentence_analysis_view.dart` 中将 `relations` 页签接到真实组件。
- `en_sentence_structure_detail_entity.dart` 补充解析关联分组真实字段：
  - `code`
  - `gradientFrom`
  - `gradientTo`

## 组件复用策略

- `pattern / pyramid`
  - 复用 `SentenceSlotMapWidget`
  - 复用 `SentenceSlotExampleWidget`
- `paradigm`
  - 复用 `SameGroupCompareSentenceTableWidget`
- `pair`
  - 复用 `SentencePairingLinkTableWidget`
- `pair_fork`
  - 复用 `SentencePairingLinkForkTableWidget`

说明：
- Flutter 端当前没有完整的 `SentenceRealizationLadder` 对应 widget，所以 `pattern / pyramid` 采用“骨架 + 代表句列表”的轻量复用方案。
- 不把管理端整页直接搬进前台，只复用已经沉淀好的基础展示组件。

## 交互与规则

- 模块顺序固定为：
  1. `pattern`
  2. `pyramid`
  3. `paradigm`
  4. `pair`
  5. `pair_fork`
- 当前句在 `pattern / pyramid` 的句子列表中显示为“本句”并高亮边框。
- 非当前句显示“拓展学习”，点击后跳转到该句的 `relations` 分析页。
- 空模块不占位，只渲染有数据的模块。

## 非目标

- 本次不改 `chunks / svoca / syntax` 已有内容。
- 不新增新的通用底层 widget。
- 不改后端关系结构，只按当前返回结构做前台消费。

## 兼容性与注意事项

- `relations` 分组标题、说明、图标、渐变色优先使用后端返回数据。
- `pattern / pyramid` 的作用域文案当前仍按 `blueprintScope` 兜底为：
  - `sentence -> 跨子句组合`
  - 其他 -> `子句内装配`
- 若后续前端需要完全对齐 React 的 ladder 交互，可在此组件基础上继续补“阶梯式代表句链”。
