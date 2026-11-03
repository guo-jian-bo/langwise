import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/custom_course/custom_course_manage_grade/controllers/custom_course_manage_grade_controller.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/generated/assets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/enum/enum.dart';
import '../../../../../utils/utils.dart';
import '../../../../routes/routes.dart';
import '../bindings/official_course_details_level_binding.dart';
import '../controllers/official_course_details_level_controller.dart';
import '../controllers/official_course_details_page_mode.dart';
import 'widgets/browse_section.dart';
import 'widgets/manage_section.dart';
import 'widgets/unified_bottom_bar.dart';

class OfficialCourseDetailsLevelView extends GetView<OfficialCourseDetailsLevelController> {
  final String tagText;

  const OfficialCourseDetailsLevelView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      () => OfficialCourseDetailsLevelView(tagText: tag),
      binding: OfficialCourseDetailsLevelBinding(tagText: tag),
      routeName: Routes.OFFICIAL_COURSE_DETAILS_LEVEL,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  Future<bool> _confirmLeaveManageModeIfNeeded() async {
    if (!controller.isManageMode) return true;
    final manageController =
        Get.find<CustomCourseManageGradeController>(tag: tagText);
    return manageController.confirmExitManageMode();
  }

  Future<void> _handleBack() async {
    final bool canLeave = await _confirmLeaveManageModeIfNeeded();
    if (!canLeave) return;
    Get.back();
  }

  Future<bool> _handleBreadcrumbRoute(dynamic item) async {
    final bool canLeave = await _confirmLeaveManageModeIfNeeded();
    return !canLeave;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          backgroundColor: AppTheme.cBgPrimary,
          body: Stack(
            children: [
              Column(
                children: [
                  _buildTitleWidget(),
                  Expanded(child: _buildPageBody(context, constraints)),
                ],
              ),
              Obx(() {
                if (controller.isPageLoading.value) {
                  return const SizedBox.shrink();
                }
                if (controller.pageMode.value == OfficialCourseDetailsPageMode.browse &&
                    (controller.levels.isEmpty || controller.visibleLevels.isEmpty)) {
                  return const SizedBox.shrink();
                }
                return Positioned(
                  bottom: 45.wMin,
                  left: 90.wMin,
                  right: 90.wMin,
                  child: UnifiedBottomBar(tagText: tagText),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPageBody(BuildContext context, BoxConstraints constraints) {
    return Obx(() {
      if (controller.isPageLoading.value) {
        return const SizedBox.shrink();
      }

      final OfficialCourseDetailsPageMode mode = controller.pageMode.value;
      final double bottomPadding = constraints.maxHeight * 0.55;
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 240),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: KeyedSubtree(
          key: ValueKey(mode),
          child: mode == OfficialCourseDetailsPageMode.manage
              ? _buildManageModeBody(bottomPadding)
              : _buildBrowseModeBody(context, bottomPadding),
        ),
      );
    });
  }

  Widget _buildBrowseModeBody(BuildContext context, double bottomPadding) {
    if (controller.levels.isEmpty || controller.visibleLevels.isEmpty) {
      return _buildEmptyState(context);
    }
    return BrowseSection(
      tagText: tagText,
      bottomPadding: bottomPadding,
    );
  }

  Widget _buildManageModeBody(double bottomPadding) {
    return ManageSection(
      tagText: tagText,
      bottomPadding: bottomPadding,
    );
  }

  Widget _buildTitleWidget() {
    return BreadcrumbWidget(
      onBack: () {
        _handleBack();
      },
      onRouteWithItem: (item) async {
        return _handleBreadcrumbRoute(item);
      },
      actionWidget: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildColorInfoItemWidget("舒适区", StudyZoneEnum.comfort),
            SizedBox(width: 20.wMin),
            _buildColorInfoItemWidget("学习区", StudyZoneEnum.study),
            SizedBox(width: 20.wMin),
            _buildColorInfoItemWidget("困难区", StudyZoneEnum.panic),
            SizedBox(width: 20.wMin),
            _buildColorInfoItemWidget("未定级", null),
          ],
        ),
      ),
    );
  }

  Widget _buildColorInfoItemWidget(String title, String? studyZoneEnum) {
    final Color color =
        StatusUtils.getStudyZoneColor(studyZoneEnum) ?? AppTheme.cTextPrimary.color;
    return Row(
      spacing: 4.wMin,
      children: [
        Container(
          width: 10.wMin,
          height: 10.wMin,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 26.wMin,
            color: color,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final bool canEditCourse = controller.isFromCustomCourse == true;
    if (canEditCourse) {
      return _buildCustomCourseEmptyState(context);
    }
    return NotDataWidget(
      message: '当前课程暂时还没有关卡内容哦',
    );
  }

  Widget _buildCustomCourseEmptyState(BuildContext context) {
    return TapScaleWidget(
      onTap: () {
        controller.editCourse(context);
      },
      sclae: 1.01,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 860.wMin),
          child: Padding(
            padding: EdgeInsets.fromLTRB(32.wMin, 56.wMin, 32.wMin, 72.wMin),
            child: Column(
              children: [
                const Spacer(flex: 6),
                Container(
                  width: 112.wMin,
                  height: 112.wMin,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFF59E0B).withValues(alpha: 0.12),
                    border: Border.all(
                      color: Color(0xFFF59E0B).withValues(alpha: 0.2),
                    ),
                  ),
                  child: SvgPicture.asset(
                    Assets.publicIconAdd,
                    width: 44.wMin,
                    height: 44.wMin,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFFF59E0B),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                SizedBox(height: 28.wMin),
                Text(
                  '添加教材',
                  style: TextStyle(
                    fontSize: 34.wMin,
                    color: AppTheme.cTextPrimary.color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 24.wMin),
                _buildCustomCourseGuideItem(1, '这门课还没有加入当前方案'),
                SizedBox(height: 10.wMin),
                _buildCustomCourseGuideItem(2, '或者准备好对应的封面和封底图片'),
                SizedBox(height: 10.wMin),
                _buildCustomCourseGuideItem(3, '确认后就可以开始添加教材'),
                const Spacer(flex: 7),
                ButtonWidget(
                  text: '去添加教材',
                  width: 720.wMin,
                  height: 56.wMin,
                  borderRadius: 10.wMin,
                  color: Color(0xFFF59E0B).withValues(alpha: 0.12),
                  fontSize: 24.wMin,
                  fontColor: Color(0xFFF59E0B),
                  fontWeight: FontWeight.w600,
                  sclae: 1.02,
                  onTap: () {
                    controller.editCourse(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomCourseGuideItem(int index, String text) {
    return Container(

      width: 540.wMin,
      padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 16.wMin),
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceLayerElevated,
        borderRadius: BorderRadius.circular(10.wMin),
        border: Border.all(
          color: AppTheme.cSurfaceGhostBgSubtle,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 22.wMin,
            height: 22.wMin,
            alignment: Alignment.center,
            decoration:BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF59E0B).withValues(alpha: 0.12),
              border: Border.all(
                color: Color(0xFFF59E0B).withValues(alpha: 0.2),
              )
            ),
            child: Text(
              '$index',
              style: TextStyle(
                fontSize: 12.wMin,
                color: Color(0xFFF59E0B),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(width: 10.wMin),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 18.wMin,
                color: AppTheme.cTextSecondary.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
