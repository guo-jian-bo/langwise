import 'package:flutter/material.dart';
import 'package:langwise/app/modules/zhenxie/common/zhenxie_composition_slot_strip_widget.dart';
import 'package:langwise/app/modules/zhenxie/common/zhenxie_write_catalog_card_widget.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../models/zhenxie_composition_stages_models.dart';

class ZhenxieCompositionStageCardWidget extends StatelessWidget {
  static const double _cardHeight = 464;

  final CompositionStageModel stage;
  final CompositionGenreModel? genre;
  final Map<String, ParagraphRhetoricalEntityList> beatMap;
  final List<String> beatOrderList;
  final String difficultyLabel;
  final String milestoneLabel;
  final String coverUrl;
  final Color genreColor;
  final bool showClose;
  final VoidCallback? onClose;

  /// 是否管理端：决定卡片底部动作，管理端给编辑/蓝图/范文/任务，用户端只给蓝图/范文
  final bool isManagement;

  final void Function(String actionText) onAction;
  final String Function(List<LanguageText>? values, String lang) langTextGetter;
  final String Function(String? beatNid) beatNameGetter;
  final String Function(String? fill) fillLabelGetter;
  final String Function(CompositionStageModel stage) headLabelGetter;
  final String Function(CompositionStageModel stage) tailLabelGetter;
  final bool Function(CompositionStageModel stage) hasHeadGetter;
  final bool Function(CompositionStageModel stage) hasTailGetter;

  const ZhenxieCompositionStageCardWidget({
    super.key,
    required this.stage,
    required this.genre,
    required this.beatMap,
    required this.beatOrderList,
    required this.difficultyLabel,
    required this.milestoneLabel,
    required this.coverUrl,
    required this.genreColor,
    required this.isManagement,
    required this.onAction,
    required this.langTextGetter,
    required this.beatNameGetter,
    required this.fillLabelGetter,
    required this.headLabelGetter,
    required this.tailLabelGetter,
    required this.hasHeadGetter,
    required this.hasTailGetter,
    this.showClose = false,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final String blueprintTitle = langTextGetter(stage.compositionBlueprint?.name, 'zh');
    final String title = langTextGetter(stage.name, 'zh');
    final String titleEn = langTextGetter(stage.name, 'en');
    final String description = langTextGetter(stage.description, 'zh');
    final String genreLabel = langTextGetter(genre?.name, 'zh');
    return ZhenxieWriteCatalogCardWidget(
      height: _cardHeight,
      coverUrl: coverUrl,
      difficultyLabel: difficultyLabel,
      blueprintLabel: blueprintTitle,
      title: title,
      titleEn: titleEn,
      entityLabel: '阶梯',
      entityValue: stage.nid ?? '',
      showCopyTag: isManagement,
      genreLabel: genreLabel,
      genreColor: genreColor,
      description: description,
      slotStrip: ZhenxieCompositionSlotStripWidget(
        stage: stage,
        beatMap: beatMap,
        beatOrderList: beatOrderList,
        langTextGetter: langTextGetter,
        beatNameGetter: beatNameGetter,
        headLabelGetter: headLabelGetter,
        tailLabelGetter: tailLabelGetter,
        hasHeadGetter: hasHeadGetter,
        hasTailGetter: hasTailGetter,
      ),
      actions: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        spacing: 10.wMin,
        children: isManagement
            ? [
                _buildActionButton(
                  "编辑",
                  backgroundColor: AppTheme.cSurfaceTranslucentBase.color,
                  borderColor: AppTheme.cBorderTranslucentSubtle.color,
                  textColor: AppTheme.cTextPrimary.color,
                ),
                _buildActionButton(
                  "蓝图",
                  backgroundColor: AppTheme.cMorphemeTagPrefix.color.withValues(alpha: 0.12),
                  borderColor: AppTheme.cMorphemeTagPrefix.color.withValues(alpha: 0.20),
                  textColor: AppTheme.cMorphemeTagPrefix.color,
                ),
                _buildActionButton(
                  "范文",
                  backgroundColor: AppTheme.cFeedbackWarningBg.color.withValues(alpha: 0.12),
                  borderColor: AppTheme.cFeedbackWarningBg.color.withValues(alpha: 0.20),
                  textColor: AppTheme.cFeedbackWarningBg.color,
                ),
                _buildActionButton(
                  "任务",
                  backgroundColor: AppTheme.cBgBrand.color.withValues(alpha: 0.12),
                  borderColor: AppTheme.cBgBrand.color.withValues(alpha: 0.20),
                  textColor: AppTheme.cBgBrand.color,
                ),
              ]
            : [
                _buildActionButton(
                  "蓝图",
                  backgroundColor: AppTheme.cMorphemeTagPrefix.color.withValues(alpha: 0.12),
                  borderColor: AppTheme.cMorphemeTagPrefix.color.withValues(alpha: 0.20),
                  textColor: AppTheme.cMorphemeTagPrefix.color,
                ),
                // _buildActionButton(
                //   "范文",
                //   backgroundColor: AppTheme.cFeedbackWarningBg.color.withValues(alpha: 0.12),
                //   borderColor: AppTheme.cFeedbackWarningBg.color.withValues(alpha: 0.20),
                //   textColor: AppTheme.cFeedbackWarningBg.color,
                // ),
              ],
      ),
    );
  }

  Widget _buildActionButton(
    String text, {
    required Color backgroundColor,
    required Color borderColor,
    required Color textColor,
  }) {
    return GestureDetector(
      onTap: () {
        onAction(text);
      },
      child: Container(
        height: 50.wMin,
        padding: EdgeInsets.all(12.wMin),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(6.wMin),
          border: Border.all(
            color: borderColor,
            width: 1.wMin,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 18.wMin,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            )
          ],
        ),
      ),
    );
  }
}
