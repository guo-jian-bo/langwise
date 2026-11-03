# SameGroupCompareSentenceTableWidget 实现提示词

你正在实现 `lib/common/widgets/zhenxie_widgets/same_group_compare_sentence_table_widget.dart`，它用于在“句型对照详情”页展示同组对照的库内句列表。

## 一、职责边界

这个 widget 负责两层渲染：

1. 外层按 `sentenceRealizationSetList` 渲染多组“同组对照”
2. 内层按 `memberList` 渲染每个壳对应的一行内容

它需要完成：

- 按 `order` 倒序整理 `sentenceRealizationSetList`
- 当存在多组 set 时，逐组渲染多个 panel
- 每组 panel 内，再按 `memberList` 顺序渲染所有壳
- 在“当前 set”里按 `valueNid` 找到对应 binding
- 把当前行真正需要的数据传给 `SameGroupCompareHighlightTextWidget`

它不负责：

- 在子 widget 里自己遍历整组 set
- 在高亮 widget 里自己决定当前应该展示哪一组

## 二、渲染结构要求

### 1. 有 `sentenceRealizationSetList`

- 先按 `order` 倒序
- 每个 set 单独渲染一个 panel
- 标题在多组场景下显示：
  - `同组对照 1`
  - `同组对照 2`
- 可补充 `order` 信息，便于管理端核对

### 2. 没有 `sentenceRealizationSetList`

- 仍然保留一个默认 panel
- 标题显示 `同组对照`
- 右上角文案显示 `未通过严格 match · 草稿不着色`

## 三、当前组内的取数规则

每一行都必须基于“当前这一组 set”取 binding，不能跨组兜底，也不能再回退到“最佳 set”。

建议顺序：

1. 当前 panel 确定一个 `SentencePatternCompareSentenceRealizationSetEntity`
2. 在这个 set 的 `bindingList` / `bindings` 里按 `valueNid` 查 binding
3. 把以下数据传给行内容：
   - `binding.sentenceStruct`
   - `binding.sentenceId`
   - `member.contrastFocus`

## 四、样式与交互要求

- 多个 panel 之间要有明确的垂直间距
- 每个 panel 内的行分隔线保持一致
- 句子结构槽只在 `sentenceStruct.segmentList` 非空时展示
- “打开蓝图”继续使用当前 binding 的 `sentenceStruct.patternNid`

## 五、实现提醒

- 优先复用 `SameGroupCompareHighlightTextUtils`
- 如果补工具方法，优先补成“按指定 set 查 binding”的能力
- 不要在这里把多组数据压扁成一组
- 不要删除已有的焦点高亮与结构槽展示能力
