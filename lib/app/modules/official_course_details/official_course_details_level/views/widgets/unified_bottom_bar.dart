import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/custom_course/custom_course_manage_grade/controllers/custom_course_manage_grade_controller.dart';
import 'package:langwise/common/entities/course_level_entity.dart';
import 'package:langwise/common/widgets/custom_button/LWCircularButton.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../controllers/official_course_details_level_controller.dart';
import '../../controllers/official_course_details_page_mode.dart';

class UnifiedBottomBar extends StatelessWidget {
  final String tagText;

  const UnifiedBottomBar({super.key, required this.tagText});

  @override
  Widget build(BuildContext context) {
    final levelController =
        Get.find<OfficialCourseDetailsLevelController>(tag: tagText);
    final manageController =
        Get.find<CustomCourseManageGradeController>(tag: tagText);
    final bool canShowBrowseManageButton =
        levelController.isFromCustomCourse == true &&
            levelController.isFromStudyPlan != true;

    return Obx(() {
      final bool isManageMode =
          levelController.pageMode.value == OfficialCourseDetailsPageMode.manage;
      final bool showTrailingAction = isManageMode || canShowBrowseManageButton;
      return Row(
        children: [
          if (showTrailingAction)
            IgnorePointer(
              child: Opacity(
                opacity: 0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    isManageMode
                        ? _buildFinishManageButton(
                            context,
                            levelController,
                            manageController,
                          )
                        : _buildManageCourseButton(context, levelController),
                    SizedBox(width: 16.wMin),
                  ],
                ),
              ),
            ),
          Expanded(
            child: Center(
              child: isManageMode
                  ? _buildManageBottomLevelBar(context, manageController)
                  : _buildBrowseBottomLevelBar(context, levelController),
            ),
          ),
          if (showTrailingAction)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 16.wMin),
                isManageMode
                    ? _buildFinishManageButton(
                        context,
                        levelController,
                        manageController,
                      )
                    : _buildManageCourseButton(context, levelController),
              ],
            ),
        ],
      );
    });
  }

  Widget _buildManageCourseButton(
    BuildContext context,
    OfficialCourseDetailsLevelController controller,
  ) {
    final color = controller.chemeColor.value;  
    return TapScaleWidget(
      sclae: 1.05,
      onTap: () {
        controller.editCourse(context);
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: PlatformBackdropFilterWidget(
          sigmaX: 10.wMin,
          sigmaY: 10.wMin,
          child: Container(
            height: 64.wMin,
            padding: EdgeInsets.symmetric(horizontal: 18.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: color.withValues(alpha: 0.15),
              border: Border.all(
                color: color.withValues(alpha: 0.2),
                width: 1.wMin,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              "管理教材",
              style: TextStyle(
                color: color,
                fontSize: 24.wMin,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFinishManageButton(
    BuildContext context,
    OfficialCourseDetailsLevelController levelController,
    CustomCourseManageGradeController manageController,
  ) {
    final color = AppTheme.cAmber.color;
    return TapScaleWidget(
      sclae: 1.05,
      onTap: () async {
        final bool canExit = await manageController.confirmExitManageMode();
        if (!canExit) return;
        await levelController.completeManageAction();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: PlatformBackdropFilterWidget(
          sigmaX: 10.wMin,
          sigmaY: 10.wMin,
          child: Container(
            height: 64.wMin,
            padding: EdgeInsets.symmetric(horizontal: 18.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: color.withValues(alpha: 0.15),
              border: Border.all(
                color: color.withValues(alpha: 0.2),
                width: 1.wMin,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              "完成管理",
              style: TextStyle(
                color: color,
                fontSize: 24.wMin,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrowseBottomLevelBar(
    BuildContext context,
    OfficialCourseDetailsLevelController controller,
  ) {
    return Obx(() {
      final levels = controller.visibleLevels;
      if (levels.isEmpty) return const SizedBox.shrink();
      final activeId = controller.activeLevelId.value;

      return Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(999.wMin),
          child: PlatformBackdropFilterWidget(
            sigmaX: 4.wMin,
            sigmaY: 4.wMin,
            child: Container(
              height: 80.wMin,
              padding: EdgeInsets.symmetric(horizontal: 12.wMin),
              decoration: BoxDecoration(
                color: AppTheme.cSurfaceSearchBackground.color,
                borderRadius: BorderRadius.circular(999.wMin),
                border: Border.all(
                  color: AppTheme.cBorderDark.color,
                  width: 1.wMin,
                ),
              ),
              child: ScrollConfiguration(
                behavior:
                    ScrollConfiguration.of(context).copyWith(scrollbars: false),
                child: SingleChildScrollView(
                  key: controller.levelTabViewportKey,
                  controller: controller.levelTabScrollController,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(levels.length, (i) {
                      final item = levels[i];
                      final text = item.name ?? "Level ${i + 1}";
                      final isActive = item.levelId == activeId;
                      return Padding(
                        padding: EdgeInsets.only(
                          right: i == levels.length - 1 ? 0 : 12.wMin,
                        ),
                        child: LWCircularButtonWidget(
                          key: item.levelId == null
                              ? null
                              : controller.getLevelTabKey(item.levelId!),
                          text: text,
                          isAction: isActive,
                          color: controller.chemeColor.value,
                          onTap: () {
                            controller.scrollToLevel(item.levelId);
                          },
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildManageBottomLevelBar(
    BuildContext context,
    CustomCourseManageGradeController controller,
  ) {
    return Obx(() {
      final List<CourseLevelEntityLevelList?> levels =
          controller.courseEntity.value.levelList ?? <CourseLevelEntityLevelList?>[];
      if (levels.isEmpty) return const SizedBox.shrink();
      final int currentActiveLevelId = controller.activeLevelId.value;
      return Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(999.wMin),
          child: PlatformBackdropFilterWidget(
            sigmaX: 4.wMin,
            sigmaY: 4.wMin,
            child: Container(
              height: 80.wMin,
              padding: EdgeInsets.symmetric(horizontal: 12.wMin),
              decoration: BoxDecoration(
                color: AppTheme.cSurfaceSearchBackground.color,
                borderRadius: BorderRadius.circular(999.wMin),
                border: Border.all(
                  color: AppTheme.cBorderDark.color,
                  width: 1.wMin,
                ),
              ),
              child: ScrollConfiguration(
                behavior:
                    ScrollConfiguration.of(context).copyWith(scrollbars: false),
                child: SingleChildScrollView(
                  key: controller.levelTabViewportKey,
                  controller: controller.levelTabScrollController,
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(levels.length, (index) {
                      final CourseLevelEntityLevelList? item = levels[index];
                      final String text = item?.name ?? 'Level ${index + 1}';
                      final bool isActive = item?.levelId == currentActiveLevelId;
                      return Padding(
                        padding: EdgeInsets.only(
                          right: index == levels.length - 1 ? 0 : 12.wMin,
                        ),
                        child: LWCircularButtonWidget(
                          key: item?.levelId == null
                              ? null
                              : controller.getLevelTabKey(item!.levelId!),
                          text: text,
                          isAction: isActive,
                          color: AppTheme.cAmber.color,
                          onTap: () {
                            final int? levelId = item?.levelId;
                            if (levelId == null) {
                              controller.selectGrade(index);
                              return;
                            }
                            controller.scrollToLevel(levelId);
                          },
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
