import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../common/entities/entities.dart';
import '../../../theme/theme.dart';

/// 入句画像 dock 组件。
class PhraseEnterSentencePhraseWidget extends StatelessWidget {
  /// 当前短语卡片数据。
  final List<EnterSentenceEntityPreviewGovernedSlots?>? governedSlots;
  final String? content;
  final Color? mainColor;

  const PhraseEnterSentencePhraseWidget({
    super.key,
    required this.content,
    required this.governedSlots,
    this.mainColor,
  });

  @override
  Widget build(BuildContext context) {
    if (governedSlots == null) return Container();
  
    final leftSlotList = _getGovernedSlotList(attachmentSide: 'left');
    final rightSlotList = _getGovernedSlotList(attachmentSide: 'right');
    final itemList = <Widget>[
      ...leftSlotList.map(_buildGovernedSlotItemWidget),
      _buildPhraseItemWidget(),
      ...rightSlotList.map(_buildGovernedSlotItemWidget),
    ];
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: IntrinsicHeight(
          child: Row(
            spacing: 6.wMin,
            children: itemList,
          ),
        ),
      ),
    );
  }

  /// 按左右侧提取补足位；`either` 归右侧展示。
  List<EnterSentenceEntityPreviewGovernedSlots> _getGovernedSlotList({required String attachmentSide}) {
    final slotList = <EnterSentenceEntityPreviewGovernedSlots>[];
    for (final item in governedSlots ?? const []) {
      if (item == null) continue;
      if (attachmentSide == 'left' && item.attachmentSide == 'left') {
        slotList.add(item);
        continue;
      }
      if (attachmentSide == 'right' && item.attachmentSide != 'left') {
        slotList.add(item);
      }
    }
    return slotList;
  }

  /// 整块短语卡片。
  Widget _buildPhraseItemWidget() {
    final Color cardMainColor = mainColor ?? AppTheme.cTextPrimary.color;
    
    return Container(
      padding: EdgeInsets.all(8.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6.wMin),
        color: mainColor == null ? AppTheme.cSurfaceLayerBase.color : cardMainColor.withValues(alpha: 0.12),
        border: Border.all(
          color: mainColor == null ? AppTheme.cBorderSubtle.color : cardMainColor.withValues(alpha: 0.20),
          width: 0.5.wMin,
        ),
      ),
      child: Column(
        spacing: 10.wMin,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "整块",
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w500,
              color: mainColor == null ? AppTheme.cTextTertiary.color : cardMainColor.withValues(alpha: 0.6),
            ),
          ),
          Text(
            content??'',
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
        ],
      ),
    );
  }

  /// 补足位卡片，保持原始落库顺序，不做合并。
  Widget _buildGovernedSlotItemWidget(EnterSentenceEntityPreviewGovernedSlots item) {
    final Color cardMainColor = mainColor ?? AppTheme.cTextPrimary.color;

    return DottedBorder(
      radius: Radius.circular(6.wMin),
      borderType: BorderType.RRect,
      padding: EdgeInsets.zero,
      color: mainColor == null ? AppTheme.cBorderSubtle.color : cardMainColor.withValues(alpha: 0.20),
      dashPattern: [5.wMin, 3.wMin],
      strokeWidth: 1.wMin,
      child: Container(
        padding: EdgeInsets.all(8.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.wMin),
          color: mainColor == null ? AppTheme.cSurfaceLayerBase.color : cardMainColor.withValues(alpha: 0.05),
        ),
        child: Column(
          spacing: 10.wMin,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _buildGovernedSlotTopLabel(item),
              style: TextStyle(
                fontSize: 16.wMin,
                fontWeight: FontWeight.w500,
                color: mainColor == null ? AppTheme.cTextSecondary.color : cardMainColor.withValues(alpha: 0.6),
              ),
            ),
            Text(
              item.slotKeyNameZh??'',
              style: TextStyle(
                fontSize: 20.wMin,
                fontWeight: FontWeight.w500,
                color: AppTheme.cTextPrimary.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 补足位顶栏文案：左/右侧 + 必填/可省 + 二选一。
  String _buildGovernedSlotTopLabel(EnterSentenceEntityPreviewGovernedSlots item) {
    final sideLabel = item.attachmentSide == 'left' ? '左侧' : '右侧';
    final requiredLabel = item.requiredLabel?.isNotEmpty == true ? item.requiredLabel ?? '' : item.required == true ? '必填' : '可省';
    final isAlternative = (item.slotCategoryNids?.length ?? 0) > 1;
    return isAlternative ? '$sideLabel · $requiredLabel · 二选一' : '$sideLabel · $requiredLabel';
  }

}

/// 入句画像例句组件。
class PhraseEnterSentenceSentenceWidget extends StatelessWidget {

  final EnterSentenceEntityPreviewSentence? sentence;
  final String? content;
  final double? fontSize;

  /// 句子文本颜色，默认主文本色。
  final Color? textColor;

  /// 高亮片段样式，默认警示色文字。
  final TextStyle? highlightStyle;

  /// 译义文本颜色，默认三级文本色。
  final Color? definitionColor;

  /// 译义最大行数，默认不限制。
  final int? definitionMaxLines;
  const PhraseEnterSentenceSentenceWidget({
    super.key,
    this.sentence,
    this.content,
    this.fontSize,
    this.textColor,
    this.highlightStyle,
    this.definitionColor,
    this.definitionMaxLines,
  });

  @override
  Widget build(BuildContext context) {
    final previewSentence = sentence;
    final sentenceCard = previewSentence?.contentCard;
      final sentenceText = sentenceCard?.title ?? '';
      final definitionText = sentenceCard?.subTitle ?? '';
    if (sentenceText.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            style: TextStyle(
              fontSize: fontSize ?? 18.wMin,
              fontWeight: FontWeight.w400,
              color: textColor ?? AppTheme.cTextPrimary.color,
            ),
            children: _buildSentenceSpanList(sentenceText),
          ),
        ),
        if (definitionText.isNotEmpty) ...[
          SizedBox(height: 6.wMin),
          Text(
            definitionText,
            maxLines: definitionMaxLines,
            overflow: definitionMaxLines != null ? TextOverflow.ellipsis : null,
            style: TextStyle(
              fontSize: 14.wMin,
              fontWeight: FontWeight.w400,
              color: definitionColor ?? AppTheme.cTextTertiary.color,
            ),
          ),
        ],
      ],
    );
  }

  /// 构建句子高亮片段，优先使用 ranges，兜底按短语表面匹配。
  List<TextSpan> _buildSentenceSpanList(String sentenceText) {
    final highlightRangeList = _buildHighlightRangeList(sentenceText);
    if (highlightRangeList.isEmpty) return [TextSpan(text: sentenceText)];

    final spanList = <TextSpan>[];
    int cursor = 0;
    for (final range in highlightRangeList) {
      final start = range.start ?? 0;
      final end = range.end ?? start;
      if (start > cursor) {
        spanList.add(TextSpan(text: sentenceText.substring(cursor, start)));
      }
      spanList.add(
        TextSpan(
          text: sentenceText.substring(start, end),
          style: highlightStyle ?? TextStyle(color: AppTheme.cSurfaceWarning.color),
        ),
      );
      cursor = end;
    }
    if (cursor < sentenceText.length) {
      spanList.add(TextSpan(text: sentenceText.substring(cursor)));
    }
    return spanList;
  }

  /// 计算高亮区间，过滤非法区间并按文本顺序输出。
  List<EnterSentenceEntityPreviewSentenceRanges> _buildHighlightRangeList(String sentenceText) {
    final validRangeList = (sentence?.ranges ?? const [])
        .whereType<EnterSentenceEntityPreviewSentenceRanges>()
        .where((item) => (item.start ?? -1) >= 0 && (item.end ?? -1) > (item.start ?? -1) && (item.end ?? 0) <= sentenceText.length)
        .toList();
    if (validRangeList.isNotEmpty) {
      validRangeList.sort((a, b) => (a.start ?? 0).compareTo(b.start ?? 0));
      final dedupedRangeList = <EnterSentenceEntityPreviewSentenceRanges>[];
      int cursor = -1;
      for (final item in validRangeList) {
        if ((item.start ?? -1) < cursor) continue;
        dedupedRangeList.add(item);
        cursor = item.end ?? cursor;
      }
      if (dedupedRangeList.isNotEmpty) return dedupedRangeList;
    }
    return _buildFallbackHighlightRangeList(sentenceText);
  }

  /// ranges 缺失时，按短语表面在句子里顺序匹配全部命中区间。
  List<EnterSentenceEntityPreviewSentenceRanges> _buildFallbackHighlightRangeList(String sentenceText) {
    final phraseText = content ?? '';
    if (phraseText.isEmpty || sentenceText.isEmpty) return const [];

    final rangeList = <EnterSentenceEntityPreviewSentenceRanges>[];
    int start = sentenceText.indexOf(phraseText);
    while (start >= 0) {
      rangeList.add(
        EnterSentenceEntityPreviewSentenceRanges(
          start: start,
          end: start + phraseText.length,
          text: phraseText,
        ),
      );
      start = sentenceText.indexOf(phraseText, start + phraseText.length);
    }
    return rangeList;
  }

  
}
