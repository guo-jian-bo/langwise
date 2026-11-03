
import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../app/modules/management/common/commons.dart';
import '../../../theme/theme.dart';
import '../../entities/entities.dart';
import 'same_group_compare_highlight_text_utils.dart';

class SameGroupCompareHighlightTextWidget extends StatefulWidget {
  final PatternBlueprintSentenceBriefEntity? sentenceStruct;
  final SentencePatternCompareContrastFocusEntity? contrastFocus;
  final int? sentenceId;
  final double? fontSize;
  final Color? fontColor;
  final Color? highlightColor;
  final Color? highlightBackgroundColor;
  final bool showSentenceTag;
  final bool showSentenceDefinition;
  final bool showCopyTags;
  final String? emptyLabel;
  final bool isManagement;
  const SameGroupCompareHighlightTextWidget({
    super.key,
    this.sentenceStruct,
    this.contrastFocus,
    this.sentenceId,
    this.fontSize,
    this.fontColor,
    this.highlightColor,
    this.highlightBackgroundColor,
    this.showSentenceTag = true,
    this.showSentenceDefinition = false,
    this.showCopyTags = true,
    this.emptyLabel,
    this.isManagement = false,
  });

  @override
  State<SameGroupCompareHighlightTextWidget> createState() => _SameGroupCompareHighlightTextWidgetState();
}

class _SameGroupCompareHighlightTextWidgetState extends State<SameGroupCompareHighlightTextWidget> {
  @override
  Widget build(BuildContext context) {
    final sentenceText = widget.sentenceStruct?.content;
    if (sentenceText == null || sentenceText.isEmpty) return _buildEmptyWidget();

    final fragmentList = SameGroupCompareHighlightTextUtils.buildSentenceFragmentList(
      sentenceText: sentenceText,
      contrastFocus: widget.contrastFocus,
      sentenceStruct: widget.sentenceStruct,
    );
    return _buildContentWidget(fragmentList);
  }

  Widget _buildEmptyWidget() {
    if (widget.emptyLabel == null || widget.emptyLabel!.isEmpty) return const SizedBox.shrink();

    return Text(
      widget.emptyLabel!,
      style: TextStyle(
        fontSize: widget.fontSize ?? 20.wMin,
        fontWeight: FontWeight.w500,
        color: widget.fontColor ?? AppTheme.cTextTertiary.color,
      ),
    );
  }

  Widget _buildContentWidget(List<SameGroupCompareSentenceFragment> fragmentList) {
    final definitionText = widget.sentenceStruct?.definition;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: 4.wMin,
          runSpacing: 4.wMin,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _buildSentenceTextWidget(fragmentList),
            if (widget.showCopyTags && widget.showSentenceTag && widget.sentenceId != null) _buildSentenceTagWidget(),
          ],
        ),
        Visibility(
          visible: widget.showSentenceDefinition && definitionText != null,
          child: Container(
            margin: EdgeInsets.only(top: 10.wMin),
            child: Text(
              definitionText??'',
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextTertiary.color,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSentenceTextWidget(List<SameGroupCompareSentenceFragment> fragmentList) {
    return SelectableText.rich(
      TextSpan(
        style: TextStyle(
          fontSize: widget.fontSize ?? 20.wMin,
          fontWeight: FontWeight.w500,
          color: widget.fontColor ?? AppTheme.cTextPrimary.color,
        ),
        children: fragmentList.map((item) {
          if (!item.isHighlight) return TextSpan(text: item.text);
          return TextSpan(
            text: " ${item.text} ",
            style: TextStyle(
              color: widget.highlightColor ?? AppTheme.cSurfaceWarning.color,
              height: 1.4,
              backgroundColor: widget.highlightBackgroundColor ?? AppTheme.cSurfaceWarning.color.withValues(alpha: 0.12),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSentenceTagWidget() {
    return CopyTagWidget(
      name: "句子",
      value: widget.sentenceId?.toString() ?? '',
      isShow: widget.isManagement,
    );
  }
}
