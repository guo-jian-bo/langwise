import 'package:flutter/material.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/values/app_font_value.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../../common/widgets/widgets.dart';
import '../../../common/copy_tag_widget.dart';

class WritingTaskCardItemWidget extends StatelessWidget {
  final CourseUnitWritingTaskCardEntity writingTaskCard;
  final String lessonName;
  final String lessonIdText;
  final double topCardHeight;
  final VoidCallback? onTap;
  final bool isManagement;
  final bool reserveTimeSpace;

  const WritingTaskCardItemWidget({
    super.key,
    required this.writingTaskCard,
    required this.lessonName,
    required this.lessonIdText,
    required this.topCardHeight,
    this.onTap,
    this.isManagement = true,
    this.reserveTimeSpace = false,
  });

  @override
  Widget build(BuildContext context) {
    final String cardTitle = writingTaskCard.title ?? '';
    final String cardLessonName = writingTaskCard.lessonName ?? '';
    final String title = _getLanguageText(writingTaskCard.stageName);
    final String stem = _getLanguageText(writingTaskCard.stem);
    final String answerKindLabel = writingTaskCard.answerKindLable ?? '';
    final int taskCount = writingTaskCard.taskCount ?? 0;
    final int compositionTaskCount = writingTaskCard.compositionTaskCount ?? 0;
    final bool isCompositionDone = taskCount > 0 && compositionTaskCount >= taskCount;
    final Color compositionColor = isCompositionDone ? const Color(0xff22C55E) : const Color(0xffF59E0B);
    final Widget child = Column(
      children: [
        Container(
          height: topCardHeight,
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xffD44832).withValues(alpha: 0.12),
              width: 1.wMin,
            ),
            borderRadius: BorderRadius.circular(24.wMin),
            color: AppTheme.cSurfaceTranslucentBase,
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              SizedBox(
                width: topCardHeight,
                height: double.infinity,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: _WritingTaskCardCover(
                        url: writingTaskCard.coverUrl ?? '',
                      ),
                    ),
                    Positioned(
                      top: 12.wMin,
                      left: 12.wMin,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.wMin, vertical: 5.wMin),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                            width: 1.wMin,
                          ),
                          borderRadius: BorderRadius.circular(6.wMin),
                          color: Colors.black.withValues(alpha: 0.6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getWritingAnswerKindIcon(writingTaskCard.answerKind),
                              size: 18.wMin,
                              color: Colors.white,
                            ),
                            SizedBox(width: 4.wMin),
                            Text(
                              writingTaskCard.answerKindLable ?? '',
                              style: TextStyle(
                                fontSize: 14.wMin,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 12.wMin),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (cardTitle.isNotEmpty) ...[
                            Text(
                              cardTitle,
                              style: TextStyle(
                                fontSize: 14.wMin,
                                color: const Color(0xffD44832),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(height: 12.wMin),
                          ],
                          Text(
                            title.isEmpty ? '写作任务' : title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 20.wMin,
                              color: AppTheme.cZhenxieFontPrimary,
                              fontWeight: FontWeight.w600,
                              fontFamily: AppFontValue.sourceHanSerifCN,
                            ),
                          ),
                          SizedBox(height: 12.wMin),
                          Text(
                            stem,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16.wMin,
                              color: AppTheme.cZhenxieFontTertiary,
                              fontWeight: FontWeight.w500,
                              height: 1.3,
                              fontFamily: AppFontValue.sourceHanSerifCN,
                            ),
                          ),
                        ],
                      ),
                    
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _WritingPipelineChip(
                                label: '$taskCount个任务',
                              ),
                              SizedBox(width: 8.wMin),
                              if (isManagement)
                              _WritingPipelineChip(
                                label: '范文 $compositionTaskCount/$taskCount',
                                color: compositionColor,
                              ),
                              Spacer(),
                                 Text(
                                        '任务列表',
                                        style: TextStyle(
                                          fontSize: 16.wMin,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xffD44832),
                                        ),
                                      ),
                                      SizedBox(width: 6.wMin),
                                      Icon(
                                        Icons.chevron_right,
                                        size: 16.wMin,
                                        color:  Color(0xffD44832),
                                      ),

                              
                            ],
                          )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.wMin),
        Text(
          cardLessonName.isEmpty ? '写作任务' : cardLessonName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26.wMin,
            color: AppTheme.cTextPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (reserveTimeSpace) ...[
          SizedBox(height: 4.wMin),
          Opacity(
            opacity: 0,
            child: Text(
              '1 min',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 23.wMin,
                color: AppTheme.cTextPrimary.color.withValues(alpha: 0.6),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          SizedBox(height: 8.wMin),
        ] else
          SizedBox(height: 8.wMin),
        if (lessonIdText.isNotEmpty) ...[
          CopyTagWidget(name: '课时', value: lessonIdText),
          SizedBox(height: 8.wMin),
        ],
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.wMin, vertical: 8.wMin),
          decoration: BoxDecoration(
            color: AppTheme.cBorderPrimary.color.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(999.wMin),
            border: Border.all(
              color: AppTheme.cSurfaceQuaternary.color.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 18.wMin,
                    fontWeight: FontWeight.w400,
                  ),
                  children: [
                    TextSpan(
                      text: '答题形式 ',
                      style: TextStyle(
                        color: AppTheme.cTextPrimary.color,
                      ),
                    ),
                    TextSpan(
                      text: answerKindLabel,
                      style: const TextStyle(
                        color: Color(0xffD44832),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 6.wMin),
              Icon(
                Icons.chevron_right,
                size: 18.wMin,
                color: AppTheme.cTextPrimary.color,
              ),
            ],
          ),
        ),
      ],
    );
    if (onTap == null) return child;
    return TapScaleWidget(
      sclae: 1,
      onTap: onTap,
      child: child,
    );
  }

  String _getLanguageText(List<LanguageText>? list) {
    if (list == null || list.isEmpty) return '';
    for (final LanguageText item in list) {
      if (item.lang?.toLowerCase() == 'zh' && (item.text?.isNotEmpty ?? false)) {
        return item.text!;
      }
    }
    for (final LanguageText item in list) {
      if (item.text?.isNotEmpty ?? false) {
        return item.text!;
      }
    }
    return '';
  }

  IconData _getWritingAnswerKindIcon(String? answerKind) {
    if (answerKind == 'image') return Icons.image_outlined;
    if (answerKind == 'audio') return Icons.mic_none_rounded;
    if (answerKind == 'video') return Icons.videocam_outlined;
    return Icons.text_fields_rounded;
  }
}

class _WritingPipelineChip extends StatelessWidget {
  final String label;
  final Color? color;

  const _WritingPipelineChip({
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final Color textColor = color ?? AppTheme.cTextSecondary.color;
    final Color backgroundColor = color == null ? AppTheme.cSurfaceTranslucentElevated.color : color!.withValues(alpha: 0.12);
    final Color borderColor = color == null ? AppTheme.cBorderTranslucentSubtle.color : color!.withValues(alpha: 0.20);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.wMin, vertical: 6.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999.wMin),
        color: backgroundColor,
        border: Border.all(
          color: borderColor,
          width: 1.wMin,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14.wMin,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _WritingTaskCardCover extends StatelessWidget {
  final String url;

  const _WritingTaskCardCover({
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return Container(
        color: const Color(0xff1A2032),
        alignment: Alignment.center,
        child: buildEmptyWidget(),
      );
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return Container(
          color: const Color(0xff1A2032),
          alignment: Alignment.center,
          child: buildEmptyWidget(),
        );
      },
    );
  }
}
