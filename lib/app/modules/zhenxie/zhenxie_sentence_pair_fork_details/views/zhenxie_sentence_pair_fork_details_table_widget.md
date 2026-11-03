# ZhenxieSentencePairForkDetailsTableWidget

## 目标
- 替代分叉详情页中旧的 `SentencePairingLinkForkDetailsTableWidget`。
- 页面内新建组件，复用公共 `SentencePairingLinkForkTableWidget` 作为链路主体。
- 为公共 fork 表格补充句子操作插槽，在 from / to 两侧都能挂载 `SetExpansionButtonsWidget`。

## 验收口径
- 分叉组按 `order` 排序展示。
- 每个分叉组使用真写卡片样式：标题、状态标签、组级上下架/删除操作、下方链路主体。
- 句子级操作按钮逻辑与句型对照详情页一致：支持上下架、内容、视觉、题目、拓展、刷新。
- 不改控制器和数据结构，只透传既有回调。

## 不做的事
- 不新增新的业务判断。
- 不改公共 fork 表格原有的内容展示逻辑，只增加可选插槽能力。
