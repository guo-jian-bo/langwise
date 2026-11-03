import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/widgets/custom_button/LWCircularButton.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../bindings/mission_control_center_binding.dart';
import '../controllers/mission_control_center_controller.dart';
import '../daily_task/views/mission_control_center_daily_task_view.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cBgPrimary.color,
      body: Column(
        children: [
          const BreadcrumbWidget(),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Obx(
                    () => IndexedStack(
                      index: controller.selectedBottomTabIndex.value,
                      children: [
                        MissionControlCenterDailyTaskView(tagText: tagText),
                        MissionControlCenterStudyPlanCalendarView(
                          tagText: controller.studyPlanCalendarTag,
                        ),
                        MissionControlCenterMilestoneChallengeView(
                          tagText: controller.milestoneChallengeTag,
                        ),
                      ],
                    ),
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
    );
  }

  Widget _buildBottomTabWidget() {
    const tabs = ['每日任务', '超记日历', '里程碑挑战'];
    const tabIcons = [
      'assets/svg/mission/icon_index_0.svg',
      'assets/svg/mission/icon_index_1.svg',
      'assets/svg/mission/icon_index_2.svg',
    ];
    return Obx(() {
      return ClipRRect(
        borderRadius: BorderRadius.circular(999.wMin),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4.wMin, sigmaY: 4.wMin),
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
                  child: LWCircularButtonWidget(
                    text: tabs[index],
                    iconPath: tabIcons[index],
                    iconSpacing: 8,
                    isAction: controller.selectedBottomTabIndex.value == index,
                    color: AppTheme.cLevelA2Text,
                    sclae: 1.02,
                    onTap: () => controller.onTapBottomTab(index),
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
