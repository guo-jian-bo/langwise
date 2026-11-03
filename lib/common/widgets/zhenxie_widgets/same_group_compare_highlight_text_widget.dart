
import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../app/modules/management/common/commons.dart';
import '../../../theme/theme.dart';
import '../../entities/entities.dart';
import 'same_group_compare_highlight_text_utils.dart';

class SameGroupCompareHighlightTextWidget extends StatefulWidget {
  final PatternBlueprintSentenceBriefEntity? sentenceStruct;
  final SentencePatternCompareContrastFocusEntity? contrastFocus;
  final List<SentencePatternCompareFocusEntity?>? foci;
  final int? sentenceId;
  final double? fontSize;
  final Color? fontColor;
  final String? contentFontFamily;
  final String? definitionFontFamily;
  final Color? highlightBackgroundColor;
  final bool showSentenceTag;
  final bool showSentenceDefinition;
  final String? emptyLabel;
  final bool isManagement;
  final bool isNormal;
  const SameGroupCompareHighlightTextWidget({
    super.key,
    this.sentenceStruct,
    this.contrastFocus,
    this.foci,
    this.sentenceId,
    this.fontSize,
    this.fontColor,
    this.contentFontFamily,
    this.definitionFontFamily,
    this.highlightBackgroundColor,
    this.showSentenceTag = true,
    this.showSentenceDefinition = false,
    this.emptyLabel,
    this.isManagement = false,
    this.isNormal = false,
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
        foci: widget.foci,
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
        color: widget.fontColor ?? AppTheme.cZhenxieFontTertiary.color,
        fontFamily: widget.definitionFontFamily,
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
            if (widget.isManagement && widget.showSentenceTag && widget.sentenceId != null) _buildSentenceTagWidget(),
            Visibility(
              visible: widget.isManagement,
              child: _buildTagWidget(
                tagText: widget.isNormal ? "已上架": "未上架",
                textColor: widget.isNormal ? AppTheme.cSurfaceSuccess.color : AppTheme.cSurfaceWarning.color,
                bgColor: widget.isNormal ? AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.12) : AppTheme.cSurfaceWarning.color.withValues(alpha: 0.12),
                borderColor: widget.isNormal ? AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.2) : AppTheme.cSurfaceWarning.color.withValues(alpha: 0.2),
              ),
            ),
          ],
        ),
        Visibility(
          visible: widget.showSentenceDefinition && definitionText != null,
          child: Container(
            margin: EdgeInsets.only(top: 8.wMin),
            child: Text(
              definitionText??'',
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cZhenxieFontTertiary.color,
                fontFamily: widget.definitionFontFamily,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSentenceTextWidget(List<SameGroupCompareSentenceFragment> fragmentList) {
    Color highlightBackgroundColor = (widget.highlightBackgroundColor ?? AppTheme.cSurfaceBrand.color);
    return Text.rich(
      TextSpan(
        style: TextStyle(
          fontSize: widget.fontSize ?? 20.wMin,
          fontWeight: FontWeight.w500,
          color: widget.fontColor ?? AppTheme.cZhenxieFontPrimary.color,
          fontFamily: widget.contentFontFamily,
        ),
        children: fragmentList.map((item) {
          if (!item.isHighlight) return TextSpan(text: item.text);
          return WidgetSpan(
            child: Container(
              decoration: BoxDecoration(
                color: highlightBackgroundColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4.wMin),
                border: Border(
                  bottom: BorderSide(
                    color: highlightBackgroundColor.withValues(alpha: 0.8),
                    width: 1.wMin,
                  ),
                ),
              ),
              child: Text(
                " ${item.text} ",
                style: TextStyle(
                  fontSize: widget.fontSize ?? 20.wMin,
                  fontWeight: FontWeight.w500,
                  color: widget.fontColor ?? AppTheme.cZhenxieFontPrimary.color,
                  fontFamily: widget.contentFontFamily,
                ),
              ),
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

  Widget _buildTagWidget({
    required String tagText,
    Color textColor = AppTheme.cTextSecondary,
    Color bgColor = AppTheme.cSurfaceLayerBase,
    Color borderColor = AppTheme.cBorderThin,
  }){
    return Container(
      height: 28.wMin,
      padding: EdgeInsets.symmetric(horizontal: 10.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(99),
        color: bgColor,
        border: Border.all(
          color: borderColor.withValues(alpha: 0.2),
          width: 0.5.wMin,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tagText,
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w400,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  


}
