import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/widgets/platform_backdrop_filter_widget.dart';
import 'package:langwise/common/widgets/custom_button/LWCircularButton.dart';
import 'package:langwise/common/widgets/tap_scale_widget.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/widgets/guide_engine/guide_engine.dart';
import '../bindings/mission_control_center_binding.dart';
import '../controllers/mission_control_center_controller.dart';
import '../daily_task/views/mission_control_center_daily_task_view.dart';
import '../milestone_challenge/controllers/mission_control_center_milestone_challenge_controller.dart';
import '../milestone_challenge/views/mission_control_center_milestone_challenge_view.dart';
import '../study_plan_calendar/views/mission_control_center_study_plan_calendar_view.dart';

class MissionControlCenterView extends GetView<MissionControlCenterController> {
  final String tagText;
  const MissionControlCenterView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      () => MissionControlCenterView(tagText: tag),
      binding: MissionControlCenterBinding(tagText: tag),
      routeName: Routes.MISSION_CONTROL_CENTER,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  Color get _panelBorderColor => AppTheme.cBgTertiary.color;
  Color _resolveTabAccentColor(int index) {
    switch (index) {
      case 1:
        return const Color(0xFFF97316);
      case 2:
        return const Color(0xFFA855F7);
      case 0:
      default:
        return AppTheme.cLevelA2Text.color;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await controller.handleExit();
      },
      child: Scaffold(
        backgroundColor: AppTheme.cBgPrimary.color,
        body: Column(
          children: [
            Obx(
              () => BreadcrumbWidget(
                onBack: () async {
                  await controller.handleExit();
                },
                actionWidget: controller.selectedBottomTabIndex.value == 2
                    ? _buildMilestoneGuideAction(context)
                    : null,
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: Obx(
                      () {
                        final currentIndex = controller.selectedBottomTabIndex.value;
                        if (controller.isTabContentLoading(currentIndex)) {
                          return const SizedBox.shrink();
                        }
                        return IndexedStack(
                          index: currentIndex,
                          children: [
                            MissionControlCenterDailyTaskView(tagText: tagText),
                            MissionControlCenterStudyPlanCalendarView(
                              tagText: controller.studyPlanCalendarTag,
                            ),
                            MissionControlCenterMilestoneChallengeView(
                              tagText: controller.milestoneChallengeTag,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 15.wMin),
                    child: _buildBottomTabWidget(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestoneGuideAction(BuildContext context) {
    return TapScaleWidget(
      onTap: () => MissionControlCenterMilestoneChallengeView.showGuidelineDialog(
        context,
        Get.find<MissionControlCenterMilestoneChallengeController>(
          tag: controller.milestoneChallengeTag,
        ),
      ),
      sclae: 1.02,
      child: Icon(
          Icons.info_outline_rounded,
          size: 36.wMin,
          color: AppTheme.cTextPrimary.color,
        ),
    );
  }

  Widget _buildBottomTabWidget() {
    const tabs = ['每日任务', '超记日历', '里程碑挑战'];
    const tabIcons = [
      'assets/svg/mission/icon_index_0.svg',
      'assets/svg/mission/icon_index_1.svg',
      'assets/svg/mission/icon_index_2.svg',
    ];
    const widgetIds = [
      GuideWidgetIds.missionControlCenterDailyTaskButton,
      GuideWidgetIds.missionControlCenterSuperCalendarButton,
      GuideWidgetIds.missionControlCenterMilestoneChallengeButton,
    ];
    return Obx(() {
      return ClipRRect(
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
              border: Border.all(color: _panelBorderColor, width: 1.wMin),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(tabs.length, (index) {
                return Padding(
                  padding: EdgeInsets.only(right: index == tabs.length - 1 ? 0 : 12.wMin),
                  child: GuideStepWidget(
                    id: widgetIds[index],
                    onTap: () async{
                      controller.onTapBottomTab(index, widgetId: widgetIds[index]);
                    },
                    sclae: 1.02,
                    child: LWCircularButtonWidget(
                      text: tabs[index],
                      iconPath: tabIcons[index],
                      iconSpacing: 8,
                      isAction: controller.selectedBottomTabIndex.value == index,
                      color: _resolveTabAccentColor(index),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      );
    });
  }
}
