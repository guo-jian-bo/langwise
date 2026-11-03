import 'package:flutter/material.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../common/commons.dart';

class ManageUnitGrammarPatternSkeletonWidget extends StatelessWidget {
  final PatternBlueprintEntity? data;
  final List<String> skeletonChips;

  const ManageUnitGrammarPatternSkeletonWidget({
    super.key,
    this.data,
    required this.skeletonChips,
  });

  static const List<Color> _slotColors = [
    Color(0xff0EA5E9),
    Color(0xffF59E0B),
    Color(0xffF43F5E),
    Color(0xff8B5CF6),
    Color(0xff00BC7D),
    Color(0xff14B8A6),
    Color(0xffF97316),
    Color(0xff84CC16),
    Color(0xffD946EF),
    Color(0xff6366F1),
  ];

  @override
  Widget build(BuildContext context) {
    if (data != null) {
      return SentenceSkeletonWidget(
        data: data!,
      );
    }

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 24.wMin),
      padding: EdgeInsets.all(16.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfaceLayerBase.color,
        border: Border.all(
          width: 1.wMin,
          color: AppTheme.cBorderThin.color,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '句型骨架',
            style: TextStyle(
              fontSize: 28.wMin,
              fontWeight: FontWeight.w500,
              color: AppTheme.cTextPrimary.color,
            ),
          ),
            SizedBox(height: 10.wMin),
            Text(
              '查看当前 Target 的槽位结构与模板。',
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextTertiary.color,
              ),
            ),
          SizedBox(height: 16.wMin),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(8.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.wMin),
              color: AppTheme.cSurfaceLayerBase.color,
              border: Border.all(
                color: AppTheme.cBorderThin.color,
                width: 0.8.wMin,
              ),
            ),
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                scrollbars: false,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: IntrinsicHeight(
                  child: Row(
                    spacing: 2.wMin,
                    children: List.generate(skeletonChips.length, (index) {
                      final Color color = index < _slotColors.length
                          ? _slotColors[index]
                          : _slotColors[index % _slotColors.length];
                      return _buildSlotItem(
                        slotName: skeletonChips[index],
                        tagText: '骨架',
                        primaryColor: skeletonChips[index] == '.'
                            ? AppTheme.cTextPrimary.color
                            : color,
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        
        
        ],
      ),
    );
  }

  Widget _buildSlotItem({
    required String slotName,
    required String tagText,
    required Color primaryColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 8.wMin),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6.wMin),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.3),
          width: 0.8.wMin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tagText,
            style: TextStyle(
              fontSize: 16.wMin,
              fontWeight: FontWeight.w400,
              color: primaryColor.withValues(alpha: 0.8),
            ),
          ),
          SizedBox(height: 4.wMin),
          Text(
            slotName,
            style: TextStyle(
              fontSize: 24.wMin,
              fontWeight: FontWeight.w500,
              color: primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class ManageUnitGrammarRepresentSentenceWidget extends StatelessWidget {
  final ManageUnitGrammarTargetDetailSentenceEntity sentence;
  final PatternBlueprintSentenceBriefEntity? analyzedSentence;
  final int index;
  final bool isSentenceAnalyseRunning;
  final VoidCallback? onTapExpandStudy;
  final VoidCallback? onTapAnalyseGrammar;
  final VoidCallback? onTapRemoveFromGrammar;
  final VoidCallback? onTapRemoveFromUnit;
  final bool isManagement;

  const ManageUnitGrammarRepresentSentenceWidget({
    super.key,
    required this.sentence,
    this.analyzedSentence,
    required this.index,
    this.isSentenceAnalyseRunning = false,
    this.onTapExpandStudy,
    this.onTapAnalyseGrammar,
    this.onTapRemoveFromGrammar,
    this.onTapRemoveFromUnit,
    this.isManagement = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasSegments = analyzedSentence?.segmentList?.isNotEmpty == true;
    final bool hasContent = sentence.content?.isNotEmpty == true;
    final bool hasDefinition = analyzedSentence?.definition?.isNotEmpty == true;
    final bool isNewCreated = sentence.access == 'INTERNAL';
    final bool shouldShowAnalyseButton = sentence.hasStructure != true && hasContent;
    return Container(
      padding: EdgeInsets.all(8.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        color: AppTheme.cSurfaceLayerBase.color,
        border: Border.all(
          width: 0.8.wMin,
          color: AppTheme.cBorderThin.color,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      spacing: 4.wMin,
                      children: [
                        _buildTagWidget(tagText: '代表句${index + 1}'),
                        if (isNewCreated)
                          _buildTagWidget(
                            tagText: '新创建',
                            textColor: const Color(0xffF59E0B),
                            bgColor: const Color(0xffF59E0B).withValues(alpha: 0.12),
                            borderColor: const Color(0xffF59E0B).withValues(alpha: 0.2),
                          ),
                        CopyTagWidget(
                          name: '句子',
                          isShow: isManagement,
                          value: (sentence.contentId ??
                                      analyzedSentence?.sentenceId ??
                                      sentence.uid)
                                  ?.toString() ??
                              '',
                        ),
                      ],
                    ),
                    if (hasSegments || hasContent || hasDefinition)
                      SizedBox(height: 12.wMin),
                    if (hasSegments)
                      SentenceSlotExampleWidget(
                        isManagement: isManagement,
                        segmentList: analyzedSentence?.segmentList,
                      )
                    else if (hasContent)
                      Text(
                        sentence.content ?? '',
                        style: TextStyle(
                          fontSize: 26.wMin,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.cTextPrimary.color,
                        ),
                      ),
                    if (shouldShowAnalyseButton) ...[
                      SizedBox(height: 12.wMin),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: _buildAnalyseButton(
                          isAnalysing: isSentenceAnalyseRunning,
                          onTap: onTapAnalyseGrammar,
                        ),
                      ),
                    ],
                    if (hasDefinition) ...[
                      SizedBox(height: 12.wMin),
                      Text(
                        analyzedSentence?.definition ?? '',
                        style: TextStyle(
                          fontSize: 18.wMin,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.cTextPrimary.color,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: 12.wMin),
              _ManageUnitGrammarSentenceActionButtons(
                onTapRemoveFromGrammar: onTapRemoveFromGrammar,
                onTapRemoveFromUnit: onTapRemoveFromUnit,
                onTapExpandStudy: onTapExpandStudy,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTagWidget({
    required String tagText,
    Color textColor = AppTheme.cTextSecondary,
    Color bgColor = AppTheme.cSurfaceLayerBase,
    Color borderColor = AppTheme.cBorderThin,
  }) {
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

  Widget _buildAnalyseButton({
    required bool isAnalysing,
    VoidCallback? onTap,
  }) {
    return UnconstrainedBox(
      alignment: Alignment.centerLeft,
      constrainedAxis: Axis.vertical,
      child: IntrinsicWidth(
        child: ButtonWidget(
          text: isAnalysing ? '分析中' : '分析语法',
          height: 34.wMin,
          padding: EdgeInsets.symmetric(horizontal: 14.wMin),
          color: const Color(0xffF59E0B).withValues(alpha: 0.12),
          border: Border.all(
            width: 0.8.wMin,
            color: const Color(0xffF59E0B).withValues(alpha: 0.35),
          ),
          fontSize: 18.wMin,
          fontColor: const Color(0xffF59E0B),
          fontWeight: FontWeight.w500,
          sclae: onTap == null || isAnalysing ? 1 : 1.01,
          onTap: isAnalysing ? null : onTap,
        ),
      ),
    );
  }
}

class _ManageUnitGrammarSentenceActionButtons extends StatelessWidget {
  final VoidCallback? onTapRemoveFromGrammar;
  final VoidCallback? onTapRemoveFromUnit;
  final VoidCallback? onTapExpandStudy;

  const _ManageUnitGrammarSentenceActionButtons({
    this.onTapRemoveFromGrammar,
    this.onTapRemoveFromUnit,
    this.onTapExpandStudy,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildSentenceActionButton(
          text: '从语法移除',
          textColor: AppTheme.cTextSecondary.color,
          borderColor: AppTheme.cBorderSubtle.color,
          backgroundColor: AppTheme.cSurfaceLayerBase.color,
          onTap: onTapRemoveFromGrammar,
        ),
        SizedBox(height: 6.wMin),
        _buildSentenceActionButton(
          text: '从单元移除',
          textColor: const Color(0xffFCA5A5),
          borderColor: const Color(0xffFB7185).withValues(alpha: 0.35),
          backgroundColor: const Color(0xffFB7185).withValues(alpha: 0.12),
          onTap: onTapRemoveFromUnit,
        ),
        SizedBox(height: 6.wMin),
        _buildSentenceActionButton(
          text: '拓展学习',
          textColor: AppTheme.cTextSecondary.color,
          borderColor: AppTheme.cBorderSubtle.color,
          backgroundColor: AppTheme.cSurfaceLayerBase.color,
          rightIcon: Icon(
            Icons.chevron_right_rounded,
            size: 20.wMin,
            color: AppTheme.cTextSecondary.color,
          ),
          onTap: onTapExpandStudy,
        ),
      ],
    );
  }

  Widget _buildSentenceActionButton({
    required String text,
    required Color textColor,
    required Color borderColor,
    required Color backgroundColor,
    Widget? rightIcon,
    VoidCallback? onTap,
  }) {
    return ButtonWidget(
      text: text,
      height: 34.wMin,
      padding: EdgeInsets.only(
        left: 14.wMin,
        right: rightIcon == null ? 14.wMin : 8.wMin,
      ),
      color: backgroundColor,
      border: Border.all(
        width: 0.8.wMin,
        color: borderColor,
      ),
      fontSize: 18.wMin,
      fontColor: textColor,
      fontWeight: FontWeight.w500,
      sclae: onTap == null ? 1 : 1.01,
      rightIcon: rightIcon,
      onTap: onTap,
    );
  }
}
