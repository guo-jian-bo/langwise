import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/app_pages.dart';
import 'package:langwise/app/routes/tag_routes.dart';
import 'package:langwise/common/entities/course_level_entity.dart';
import 'package:langwise/common/entities/theme_style_entity.dart';
import 'package:langwise/utils/color_utils.dart';
import 'package:langwise/utils/style_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/widgets/widgets.dart';
import '../../../../../theme/theme.dart';
import '../controllers/custom_course_manage_grade_controller.dart';

class CustomCourseManageGradeCell extends StatelessWidget {
  final CourseLevelEntityLevelListModuleList? wordModel;
  final bool isTop;
  final bool isDragging;
  final int? courseId;
  final bool readOnly;
  final String tagText;
  final double? width;
  final double? height;

  const CustomCourseManageGradeCell({
    super.key,
    required this.wordModel,
    required this.isTop,
    required this.tagText,
    this.readOnly = false,
    this.isDragging = false,
    this.courseId,
    this.width,
    this.height,
  });

  double get _moduleCardBaseHeight => 246.wMin;

  double _resolveCardHeight(double cardWidth) {
    if (height != null) return height!;
    if (isDragging) return 200.wMin * 10 / 7;
    return 354.wMin;
  }

  @override
  Widget build(BuildContext context) {
    final double cardWidth = width ?? (isDragging ? 200.wMin : 380.wMin);
    final double cardHeight = _resolveCardHeight(cardWidth);
    final double contentHeight = isDragging ? 160.wMin : _moduleCardBaseHeight;
    final double preferredCoverWidth = isDragging ? 120.wMin : math.min(220.wMin, cardWidth * 0.38);
    final double limitedCoverHeight = math.min(contentHeight, preferredCoverWidth * 4 / 3);
    final double coverWidth = limitedCoverHeight * 3 / 4;
    final double coverHeight = limitedCoverHeight;

    return SizedBox(
      width: cardWidth,
      height: cardHeight,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cSurfaceLayerElevated,
          borderRadius: BorderRadius.circular(20.wMin),
          border: Border.all(
            color: AppTheme.cBorderSecondary,
            width: 1.wMin,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.wMin),
          child: Column(
            children: [
              SizedBox(
                height: contentHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCover(coverWidth: coverWidth, coverHeight: coverHeight),
                    SizedBox(width: 16.wMin),
                    Expanded(
                      child: _buildContent(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.wMin),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: AppTheme.cBorderSecondary.color.withValues(alpha: 0.7),
                ),
              ),
              if (readOnly)
                _buildReadOnlyFooter()
              else
                _buildActionRow(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCover({
    required double coverWidth,
    required double coverHeight,
  }) {
    return GestureDetector(
      onTap: () {
        if (wordModel == null) return;
        TagRoutes.offNamedUntil(
          Routes.OFFICIAL_COURSE_DETAILS,
          ModalRoute.withName(Routes.APPLICATION),
          arguments: {
            'courseId': courseId,
            'levelId': wordModel?.levelId,
            'moduleId': wordModel?.moduleId,
            'isNew': wordModel?.newAdd,
            'isSwitchCourse': true,
            'goCustomCourseProgress': false,
          },
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.wMin),
        child: Container(
          clipBehavior: Clip.hardEdge,
          width: coverWidth,
          height: coverHeight,
          decoration: BoxDecoration(
            color: AppTheme.cSurfaceLayerBase,
            border: Border.all(color: AppTheme.cBorderSecondary.color),
            borderRadius: BorderRadius.circular(20.wMin),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: wordModel?.coverUrl?.isNotEmpty == true
                    ? CachedImageWidget(
                        wordModel!.coverUrl!,
                        fit: BoxFit.cover,
                        placeholder: buildLoadingWidget(),
                        errorWidget: buildEmptyWidget(),
                      )
                    : buildEmptyWidget(),
              ),
              if (wordModel?.newAdd == true)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(14.wMin, 12.wMin, 14.wMin, 12.wMin),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.72),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Text(
                      '新添加',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18.wMin,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          wordModel?.name ?? '',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 28.wMin,
            color: AppTheme.cTextPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 12.wMin),
        if ((wordModel?.tierMappings?.isNotEmpty ?? false))
          SizedBox(
            height: 48.wMin,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(wordModel?.tierMappings?.length ?? 0, (index) {
                  final ThemeTextEntity? themeTextEntity =
                      wordModel?.tierMappings?[index];
                  final ThemeTextStyleEntity? style =
                      StyleUtils.getCurrentThemeText(themeTextEntity?.style);
                  final Color? textColor =
                      ColorUtils.parseColor(style?.color);
                  final Color? bgColor = ColorUtils.parseColor(style?.backgroundColor);
                  return Container(
                    margin: EdgeInsets.only(right: 6.wMin),
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.wMin,
                      vertical: 4.wMin,
                    ),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(4.wMin),
                      border: Border.all(
                        color: (textColor ?? AppTheme.cStaticWhite)
                            .withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      themeTextEntity?.text?.trim() ?? '',
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.visible,
                      style: TextStyle(
                        color: textColor ?? AppTheme.cStaticWhite,
                        fontSize: 14.wMin,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        
        
        SizedBox(height: 10.wMin),
        Expanded(
          child: Text(
            wordModel?.description ?? '',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 20.wMin,
              color: AppTheme.cTextSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyFooter() {
    return SizedBox(
      height: 44.wMin,
      child: Row(
      children: [
        Expanded(
          child: Text(
            '暂存中，可拖回任意 Level',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 18.wMin,
              color: AppTheme.cTextSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
      ),
    );
  }

  Widget _buildActionRow() {
    return SizedBox(
      height: 40.wMin,
      child: Row(
        children: [
          Expanded(
            child: _buildFooterButton(
              title: '修改封面',
              onTap: () {
                Get.find<CustomCourseManageGradeController>(tag: tagText)
                    .modifyModuleCover(wordModel);
              },
            ),
          ),
          SizedBox(width: 10.wMin),
          Expanded(
            child: _buildFooterButton(
              title: '教材重命名',
              onTap: () {
                Get.find<CustomCourseManageGradeController>(tag: tagText)
                    .modifyModuleName(wordModel);
              },
            ),
          ),
          SizedBox(width: 10.wMin),
          Expanded(
            child: _buildFooterButton(
              title: '删除',
              danger: true,
              onTap: () {
                Get.find<CustomCourseManageGradeController>(tag: tagText)
                    .deleteModule(wordModel);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterButton({
    required String title,
    required VoidCallback onTap,
    bool danger = false,
  }) {
    return TapScaleWidget(
      onTap: onTap,
      child: Container(
        height: 40.wMin,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: danger
              ? AppTheme.cFeedbackErrorText.color.withValues(alpha: 0.1)
              : AppTheme.cTextPrimary.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8.wMin),
        ),
        child: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 18.wMin,
            color: danger
                ? AppTheme.cFeedbackErrorText.color
                : AppTheme.cTextSecondary.color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
