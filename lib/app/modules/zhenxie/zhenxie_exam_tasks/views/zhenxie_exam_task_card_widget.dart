import 'package:flutter/material.dart';
import 'package:langwise/common/entities/language_config_color_entity.dart';
import 'package:langwise/common/values/app_font_value.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../zhenxie_exam/models/zhenxie_exam_models.dart';

class ZhenxieExamTaskCardWidget extends StatelessWidget {
  final ZhenxieExamTaskCardData task;
  final LanguageConfigColorEntityThemeColors? milestoneColors;
  final LanguageConfigColorEntityThemeColors? familyColors;
  final String regionText;
  final String familyText;
  final String milestoneText;
  final String stageText;
  final List<String> topicTexts;
  final List<String> requiredPoints;
  final VoidCallback? onTap;

  const ZhenxieExamTaskCardWidget({
    super.key,
    required this.task,
    required this.milestoneColors,
    required this.familyColors,
    required this.regionText,
    required this.familyText,
    required this.milestoneText,
    required this.stageText,
    required this.topicTexts,
    required this.requiredPoints,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color milestoneColor = milestoneColors?.textColorC ??
        milestoneColors?.colorC ??
        milestoneColors?.backgroundColorC ??
        milestoneColors?.borderColorC ??
        AppTheme.cZhenxieColorPrimary.color;
    final Color familyColor = familyColors?.colorC ??
        familyColors?.textColorC ??
        familyColors?.backgroundColorC ??
        familyColors?.borderColorC ??
        AppTheme.cZhenxieColorPrimary.color;
    final String yearText = task.year?.toString() ?? '';
    final String requiredPointsText = requiredPoints.join('；');
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20.wMin),
        decoration: BoxDecoration(
          color: AppTheme.cZhenxieBackgroundPrimary.color,
          borderRadius: BorderRadius.circular(16.wMin),
          border: Border.all(
            color: AppTheme.cZhenxieBorderPrimary.color,
            width: 1.wMin,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                if (yearText.isNotEmpty) ...<Widget>[
                  Text(
                    yearText,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 15.wMin,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.cZhenxieColorPrimary.color,
                      fontFamily: AppFontValue.robotoMono,
                    ),
                  ),
                  SizedBox(width: 8.wMin),
                ],
                ZhenxieExamTaskChip(
                  text: milestoneText,
                  textColor: milestoneColors?.textColorC ?? milestoneColor,
                  backgroundColor: milestoneColors?.backgroundColorC ?? milestoneColor.withValues(alpha: 0.08),
                  borderColor: milestoneColors?.borderColorC ?? milestoneColor.withValues(alpha: 0.16),
                ),
                SizedBox(width: 8.wMin),
                Expanded(
                  child: Text(
                    regionText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15.wMin,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.cZhenxieFontSecondary.color,
                      fontFamily: AppFontValue.robotoMono,
                    ),
                  ),
                ),
                if (familyText.isNotEmpty) ...<Widget>[
                  SizedBox(width: 8.wMin),
                  ZhenxieExamTaskChip(
                    text: familyText,
                    textColor: familyColor,
                    backgroundColor: familyColor.withValues(alpha: 0.12),
                    borderColor: familyColor.withValues(alpha: 0.2),
                    dotColor: familyColor,
                  ),
                ],
              ],
            ),
            SizedBox(height: 12.wMin),
            Text(
              task.topic,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 24.wMin,
                fontWeight: FontWeight.w600,
                height: 1.35,
                color: AppTheme.cZhenxieFontPrimary.color,
                fontFamily: AppFontValue.sourceHanSerifCN,
              ),
            ),
            if ((task.paperName ?? '').isNotEmpty) ...<Widget>[
              SizedBox(height: 8.wMin),
              Text(
                task.paperName ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cZhenxieFontSecondary.color,
                ),
              ),
            ],
            SizedBox(height: 14.wMin),
                              if (requiredPointsText.isNotEmpty)
                    Text(
                      requiredPointsText,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16.wMin,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.cZhenxieFontSecondary.color,
                        height: 1.6,
                      ),
                    ),
                  Expanded(child: Container(),),
                  Row(
                    children: <Widget>[
                      if (topicTexts.isNotEmpty) ...<Widget>[
                        Expanded(
                          child: Wrap(
                            spacing: 8.wMin,
                            runSpacing: 8.wMin,
                            children: topicTexts
                                .map((item) => ZhenxieExamTaskChip(
                                      text: item,
                                      textColor: AppTheme.cZhenxieFontSecondary.color,
                                      backgroundColor: AppTheme.cZhenxieFontPrimary.color.withValues(alpha: 0.06),
                                      borderColor: AppTheme.cZhenxieBorderPrimary.color,
                                    ))
                                .toList(),
                          ),
                        ),
                        SizedBox(width: 8.wMin),
                      ] else
                        const Spacer(),
                      Text(
                        stageText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16.wMin,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.cZhenxieFontSecondary.color,
                          fontFamily: AppFontValue.sourceHanSerifCN,
                        ),
                      ),
                    ],
                  ),
                
          ],
        ),
      ),
    );
  }
}

class ZhenxieExamTaskChip extends StatelessWidget {
  final String text;
  final Color textColor;
  final Color backgroundColor;
  final Color borderColor;
  final Color? dotColor;

  const ZhenxieExamTaskChip({
    super.key,
    required this.text,
    required this.textColor,
    required this.backgroundColor,
    required this.borderColor,
    this.dotColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 5.wMin),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: borderColor,
          width: 1.wMin,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (dotColor != null) ...<Widget>[
            Container(
              width: 6.wMin,
              height: 6.wMin,
              decoration: BoxDecoration(
                color: dotColor,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            SizedBox(width: 6.wMin),
          ],
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14.wMin,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
