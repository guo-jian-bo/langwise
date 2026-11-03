import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/custom_course/custom_course_manage_grade/controllers/custom_course_manage_grade_controller.dart';
import 'package:langwise/app/routes/app_pages.dart';
import 'package:langwise/app/routes/tag_routes.dart';
import 'package:langwise/common/entities/course_level_entity.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import 'course_module_card_main_content.dart';
import 'course_module_card_shell.dart';

class ManageModuleCard extends StatelessWidget {
  final CourseLevelEntityLevelListModuleList? module;
  final bool isTop;
  final bool readOnly;
  final int? courseId;
  final String tagText;
  final double? width;
  final double? height;
  final bool enableCoverNavigation;
  final Widget? dragHandle;

  const ManageModuleCard({
    super.key,
    required this.module,
    required this.isTop,
    required this.tagText,
    this.readOnly = false,
    this.courseId,
    this.width,
    this.height,
    this.enableCoverNavigation = true,
    this.dragHandle,
  });

  double get _moduleCardBaseHeight => 246.wMin;

  double _resolveCardHeight() {
    if (height != null) return height!;
    return 354.wMin;
  }

  bool get _showStatusMask => module?.completed == false;

  bool get _isStatusFailed => module?.customStatus == 'COURSE_FAIL';

  String get _customStatusTitle {
    final String? title = module?.customStatusTitle?.trim();
    if (title != null && title.isNotEmpty) return title;
    if (_isStatusFailed) return '生成失败';
    return '生成中';
  }

  @override
  Widget build(BuildContext context) {
    final double cardWidth = width ?? 380.wMin;
    final double cardHeight = _resolveCardHeight();
    return CourseModuleCardShell(
      width: cardWidth,
      height: cardHeight,
      mainContentHeight: _moduleCardBaseHeight,
      dividerColor: AppTheme.cBorderSecondary.color.withValues(alpha: 0.7),
      mainContent: CourseModuleCardMainContent(
        cover: _buildCover(),
        title: module?.name ?? '',
        description: module?.description ?? '',
        tierMappings: module?.tierMappings,
        showStatusMask: _showStatusMask,
        statusMaskTitle: _customStatusTitle,
        statusMaskTitleColor:
            _isStatusFailed ? AppTheme.cFeedbackErrorText : AppTheme.cStaticWhite,
      ),
      footer: readOnly ? _buildReadOnlyFooter() : _buildActionRow(),
    );
  }

  Widget _buildCover() {
    final double coverWidth = _moduleCardBaseHeight * 3 / 4;
    return GestureDetector(
      onTap: !enableCoverNavigation
          ? null
          : () {
              if (module == null) return;
              TagRoutes.offNamedUntil(
                Routes.OFFICIAL_COURSE_DETAILS,
                ModalRoute.withName(Routes.APPLICATION),
                arguments: {
                  'courseId': courseId,
                  'levelId': module?.levelId,
                  'moduleId': module?.moduleId,
                  'isNew': module?.newAdd,
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
          height: _moduleCardBaseHeight,
          decoration: BoxDecoration(
            color: AppTheme.cSurfaceLayerBase,
            border: Border.all(color: AppTheme.cBorderSecondary.color),
            borderRadius: BorderRadius.circular(20.wMin),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: module?.coverUrl?.isNotEmpty == true
                    ? CachedImageWidget(
                        module!.coverUrl!,
                        fit: BoxFit.cover,
                        placeholder: buildLoadingWidget(),
                        errorWidget: buildEmptyWidget(),
                      )
                    : buildEmptyWidget(),
              ),
              if (dragHandle != null)
                Positioned(
                  left: 12.wMin,
                  top: 12.wMin,
                  child: dragHandle!,
                ),
              if (module?.newAdd == true)
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
                Get.find<CustomCourseManageGradeController>(tag: tagText).modifyModuleCover(module);
              },
            ),
          ),
          SizedBox(width: 10.wMin),
          Expanded(
            child: _buildFooterButton(
              title: '教材重命名',
              onTap: () {
                Get.find<CustomCourseManageGradeController>(tag: tagText).modifyModuleName(module);
              },
            ),
          ),
          SizedBox(width: 10.wMin),
          Expanded(
            child: _buildFooterButton(
              title: '删除',
              danger: true,
              onTap: () {
                Get.find<CustomCourseManageGradeController>(tag: tagText).deleteModule(module);
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
