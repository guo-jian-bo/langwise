import 'package:flutter/material.dart';
import 'package:langwise/app/modules/zhenxie/common/zhenxie_write_catalog_card_data.dart';
import 'package:langwise/app/modules/zhenxie/common/zhenxie_write_catalog_card_widget.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

class ZhenxieCompositionStageCardWidget extends StatelessWidget {
  static const double _cardHeight = 500;

  final StageCardData stageData;
  final String milestoneLabel;
  final bool showClose;
  final VoidCallback? onClose;

  /// 是否管理端：决定卡片底部动作，管理端给编辑/蓝图/范文/任务，用户端只给蓝图/范文
  final bool isManagement;

  final void Function(String actionText) onAction;
  final String Function(String? fill) fillLabelGetter;

  const ZhenxieCompositionStageCardWidget({
    super.key,
    required this.stageData,
    required this.milestoneLabel,
    required this.isManagement,
    required this.onAction,
    required this.fillLabelGetter,
    this.showClose = false,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return ZhenxieWriteCatalogCardWidget(
      stageData: stageData,
      height: _cardHeight,
      copyLabel: '阶梯',
      isManagement: isManagement,
      showCopyTag: isManagement,
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
                  backgroundColor: AppTheme.cSurfaceTranslucentBase.color,
                  borderColor: AppTheme.cBorderTranslucentSubtle.color,
                  textColor: AppTheme.cTextPrimary.color,
                ),
                _buildActionButton(
                  "范文",
                  backgroundColor: AppTheme.cSurfaceTranslucentBase.color,
                  borderColor: AppTheme.cBorderTranslucentSubtle.color,
                  textColor: AppTheme.cTextPrimary.color,
                ),
                _buildActionButton(
                  "任务",
                  backgroundColor: AppTheme.cSurfaceTranslucentBase.color,
                  borderColor: AppTheme.cBorderTranslucentSubtle.color,
                  textColor: AppTheme.cTextPrimary.color,
                ),
              ]
            : [
                _buildActionButton(
                  "蓝图",
                  backgroundColor: AppTheme.cSurfaceTranslucentBase.color,
                  borderColor: AppTheme.cBorderTranslucentSubtle.color,
                  textColor: AppTheme.cTextPrimary.color,
                ),
                _buildActionButton(
                  "范文",
                  backgroundColor: AppTheme.cFeedbackWarningBg.color.withValues(alpha: 0.12),
                  borderColor: AppTheme.cFeedbackWarningBg.color.withValues(alpha: 0.20),
                  textColor: AppTheme.cFeedbackWarningBg.color,
                ),
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
        height: 48.wMin,
        padding: EdgeInsets.symmetric(horizontal: 18.wMin),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(9999.wMin),
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
