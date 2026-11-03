# elements_phrase_relations_view 说明

## 目标与验收口径

- 为短语详情页右侧分析卡中的“关联”补一个独立承接页。
- 页面按接口 `relations` 分组渲染。
- 每个群组内部直接渲染对应的对照 / 配对 / 搭配组卡片列表。
- 点击卡片可继续二跳到现有甄写详情页。

验收标准：

- 使用 `relations[*].code` 识别群组类型。
- 群组头使用 `title` 和 `color` 展示。
- 群组内容使用 `items[*].payload` 还原成现有实体并复用现有卡片组件。
- 点击 `paradigm / pair / cluster` 三类卡片时，能分别进入对应详情页，并携带 `isManagement=false`。

## 改动点

- 新增短语关联页 `ElementsPhraseRelationsView`
- 新增短语关联页控制器与绑定
- 新增短语关联详情实体
- 新增用户端关联接口与用户端甄写详情接口封装

## 关键设计

- 关联页放在 `elements` 模块下，而不是 `zhenxie` 模块下，因为它是用户词典详情分析链路的一部分。
- 群组类型判断只认 `code`，避免在外层再依赖 `type` 做二次分发。
- `payload` 不重复建三套新模型，直接复用现有：
  - `PhraseParadigmEntity`
  - `PhrasePairEntity`
  - `PhraseMatchEntity`

## 兼容性影响与注意事项

- 本轮详情页 UI 壳子继续复用现有甄写详情页，只做接口分流。
- 新页面只接入用户端跳转，不改管理端列表页入口逻辑。

## TODO

- 若后续需要用户态详情页壳子，再从现有甄写详情页继续拆分页面骨架。
