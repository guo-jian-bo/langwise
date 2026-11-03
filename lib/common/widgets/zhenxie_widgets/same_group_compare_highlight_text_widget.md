# SameGroupCompareHighlightTextWidget 实现提示词

你正在实现 `lib/common/widgets/zhenxie_widgets/same_group_compare_highlight_text_widget.dart`，它用于在“同组对照”表格右侧展示一句库内句，并把当前 member 的焦点槽位着色出来。

## 一、先明确职责边界

这个 widget 只负责“展示一条已经选定好的句子 + 焦点高亮”。

不要把下面这些上游逻辑塞进这个 widget：

- 不要在 widget 内自己从 `sentenceRealizationSetList` 里挑最佳 set
- 不要在 widget 内自己按 `valueNid` 查 binding
- 不要在 widget 内处理整张表的行循环

这些应该在 `SameGroupCompareTableWidget` 的 `_buildItemRowRightWidget` 里先做好，再把当前行真正需要的数据传进来。

## 二、建议 widget 接收的入参

最小必需入参建议如下：

```dart
final PatternBlueprintSentenceBriefEntity? sentenceStruct;
final SentencePatternCompareContrastFocusEntity? contrastFocus;
```

原因：

- `sentenceStruct` 提供整句文本 `content`，还提供 `segmentList`
- `contrastFocus` 提供当前 member 声明的焦点来源：
  - `patternSlotKeys`
  - `templateLiterals`

为了展示句子标签，建议再传：

```dart
final int? sentenceId;
```

说明：

- `sentenceId` 可以直接来自 binding 的 `sentenceId`
- 不建议让子 widget 再去从 `sentenceStruct.sentenceId` 和外层 binding 之间做二次判断，父组件先整理好再传

样式相关建议保留为可选入参：

```dart
final double? fontSize;
final Color? fontColor;
final Color? highlightColor;
final Color? highlightBackgroundColor;
final bool showSentenceTag;
```

可选增强入参：

```dart
final String? emptyLabel;
```

用于无句子时展示空文案；如果当前页面约定“无数据不显示”，则直接返回 `SizedBox.shrink()`。

## 三、父组件应该先传什么

父组件里，应该先基于“当前正在渲染的那一组 set”完成以下整理：

1. 如果页面存在多组 `sentenceRealizationSetList`
   - 先在表格组件里按 `order` 倒序整理整组列表
   - 外层逐组渲染“同组对照 1 / 2 / 3 ...”
2. 对于当前这一个 set
   - 在它的 `bindingList` / `bindings` 里找到 `valueNid == member.valueNid` 的 binding
3. 取出：
   - `binding.sentenceStruct`
   - `binding.sentenceId`
   - `member.contrastFocus`
4. 传给 `SameGroupCompareHighlightTextWidget`

也就是这个 widget 理想上收到的是“当前组、当前行已经确定好的句子数据”，而不是整坨原始列表。

## 四、句子高亮算法目标

目标不是简单把某个 segment 下标染色，而是：

- 基于 `contrastFocus.patternSlotKeys`
- 基于 `contrastFocus.templateLiterals`
- 到 `sentenceStruct.content` 这条完整句子里做文本命中
- 最终生成一组 `TextSpan`

重点：

- 必须使用“基于文本搜索”的命中方式
- 不能依赖 segment 顺序位置去硬切字符串
- 不能假设同名槽位只出现一次
- 不能因为数据不整齐出现 `RangeError`

## 五、推荐实现步骤

### 1. 输入判空

先做最基本保护：

- `sentenceStruct == null` -> 返回 `SizedBox.shrink()`
- `sentenceStruct.content` 为空 -> 返回 `SizedBox.shrink()` 或 `emptyLabel`
- `contrastFocus == null` -> 整句按普通文本显示，不高亮

### 2. 准备目标声明

从 `contrastFocus` 中取出两组声明：

- 焦点槽位：`patternSlotKeys`
- 焦点字面量：`templateLiterals`

处理要求：

- 过滤空字符串
- 保持原顺序
- 去重

### 3. 从 `sentenceStruct.segmentList` 递归收集候选命中文本

不要直接按 segment index 着色，而是先把“可能该高亮的文本”收集出来。

收集规则建议：

- 如果 segment 的 `slotKey` / `sourceSlotKey` / `renderSlotKey` 命中了某个焦点 `patternSlotKey`
  - 取它的 `text`
  - 作为一个 slot 命中候选
- 如果 segment 是字面量段，或它的 `text` 本身就是焦点 `templateLiteral`
  - 作为 literal 命中候选
- 如果 segment 有 `childStruct.segmentList`
  - 递归继续收集

候选项建议统一整理成类似结构：

```dart
class _FocusSearchToken {
  final String text;
  final String source; // slot / literal
  final String key;    // patternSlotKey 或 templateLiteral
}
```

注意：

- 候选 `text` 为空时跳过
- 同一个 key 可能对应多个候选文本
- 同一段文本可能既属于 literal，也属于 slot

### 4. 在整句 `content` 中做全文搜索

对每个候选文本，去 `sentenceStruct.content` 中查找所有命中位置。

要求：

- 使用全文搜索，不要依赖 segment 自带顺序去切
- 同一个文本如果在句子里出现多次，要全部记录候选区间
- 如果候选文本前后只是空白差异，要允许后续合并

推荐区间结构：

```dart
class _FocusRange {
  final int start;
  final int end;
  final List<_FocusSource> sources;
}
```

其中 `sources` 用来记录这个区间是由哪些声明命中的，便于后续调试。

### 5. 合并重叠或相邻区间

把所有区间按 `start`、`end` 排序后做合并。

合并规则建议与 Web 端一致：

- 新区间与上一区间重叠 -> 合并
- 两区间之间只有空白字符 -> 合并
- 否则保留为独立区间

这样可以得到类似 Web `focusEvidence.ranges` 的效果。

### 6. 生成 TextSpan

基于最终区间列表，从左到右切 `sentenceStruct.content`：

- 非命中部分 -> 普通 `TextSpan`
- 命中部分 -> 高亮 `TextSpan`

如果最终没有任何有效区间：

- 不报错
- 不返回空
- 直接整句普通展示

## 六、为什么不要直接照搬 Web 的 focusEvidence

Web 列表卡直接消费的是 `focusEvidence.ranges`，但 Flutter 当前实体里没有这个字段。

Flutter 当前已有的是：

- `SentencePatternCompareContrastFocusEntity.patternSlotKeys`
- `SentencePatternCompareContrastFocusEntity.templateLiterals`
- `SentencePatternCompareSentenceBindingEntity.sentenceStruct`

也就是说，Flutter 现在拿到的是“声明 + 结构化句子”，还没有“预计算好的 ranges”。

所以这里要做的不是照搬 Web 的消费层，而是：

- 以 `contrastFocus` 作为声明输入
- 以 `sentenceStruct` 作为搜索语料
- 在本地还原出可渲染的高亮区间

## 七、当前数据结构和算法的对应关系

上游来源：

- member 焦点声明：
  - `SentencePatternCompareContrastFocusEntity.patternSlotKeys`
  - `SentencePatternCompareContrastFocusEntity.templateLiterals`
- 句子来源：
  - `SentencePatternCompareSentenceBindingEntity.sentenceStruct`
  - `SentencePatternCompareSentenceBindingEntity.sentenceId`

句子结构字段：

- `PatternBlueprintSentenceBriefEntity.content`
- `PatternBlueprintSentenceBriefEntity.segmentList`
- `ZhenxieSentenceMemberSegmentEntity.slotKey`
- `ZhenxieSentenceMemberSegmentEntity.sourceSlotKey`
- `ZhenxieSentenceMemberSegmentEntity.renderSlotKey`
- `ZhenxieSentenceMemberSegmentEntity.text`
- `ZhenxieSentenceMemberSegmentEntity.literal`
- `ZhenxieSentenceMemberSegmentEntity.childStruct`

## 八、建议的 widget 使用方式

父组件建议像这样调用：

```dart
SameGroupCompareHighlightTextWidget(
  sentenceStruct: binding?.sentenceStruct,
  sentenceId: binding?.sentenceId,
  contrastFocus: member?.contrastFocus,
  fontSize: 20.wMin,
  fontColor: AppTheme.cTextPrimary.color,
)
```

## 九、实现要求

- 不要写死示例句子
- 不要写死句子 ID
- 不要在 widget 内部依赖全局列表查找
- 不要基于 index 顺序硬编码高亮
- 不要因为没有命中就抛异常
- 没有高亮时整句正常显示
- 没有句子时返回 `SizedBox.shrink()`

## 十、输出结果预期

最终这个 widget 应该稳定输出两部分：

1. 一句 `SelectableText.rich`
   - 普通部分正常颜色
   - 焦点部分使用 warning 色 + 浅底色
2. 一个可选的 `CopyTagWidget`
   - `name: "句子"`
   - `value: sentenceId?.toString() ?? ''`

如果 `showSentenceTag == false`，则不显示标签。
