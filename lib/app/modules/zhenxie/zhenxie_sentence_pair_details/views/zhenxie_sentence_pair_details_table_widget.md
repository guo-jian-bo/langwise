# ZhenxieSentencePairDetailsTableWidget

## 目标
- 替代旧的 `SentencePairingLinkDetailTableWidget`，仅在句对详情页内部使用。
- 布局参考 `zhenxie_sentence_pattern_compare_sentences_widget.dart` 的双列卡片结构。
- 句子内容、颜色、字重与字体系参考 `zhenxie_sentence_pair_item_widget.dart`。

## 验收口径
- 数据来源、排序规则、管理端上下架/删除/刷新逻辑保持不变。
- 当存在多组句对时，按 `order` 排序后两列排布；当没有句对时，仍展示一个空卡片占位。
- 每张卡片包含标题区、组级操作按钮、from/to 两段句子信息和句子级扩展操作。
- 英文句子内容必须使用 `AppFontValue.robotoMono`。
- 句型名、定义、标题、标签文案统一使用真写模块当前详情页的颜色与衬线字体。
- 组级操作使用 `ManageIpDownEditDelWidget`，句子级操作使用 `SetExpansionButtonsWidget`。

## 不做的事
- 不改控制器方法名、请求逻辑和实体结构。
- 不新增新的业务状态判断。
