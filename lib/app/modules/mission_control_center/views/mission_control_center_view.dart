import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';
import 'package:langwise/common/stores/user.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../common/mission_control_center_dotted_line_paint.dart';
import '../common/starry_background_widget.dart';
import '../controllers/mission_control_center_controller.dart';
import 'mission_control_center_plan_widget.dart';
import 'mission_control_center_planet_widget.dart';
import 'mission_control_center_special_menu_widget.dart';

class MissionControlCenterView extends GetView<MissionControlCenterController> {
  const MissionControlCenterView({super.key});
  @override
  Widget build(BuildContext context) {
    return StarryBackgroundWidget(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top + 16.wMin),
            _buildTitleWidget(context),
            Expanded(
              child: _buildMissionListWidget(),
            ),
            SizedBox(height: 40.wMin),
            _buildPlanListWidget(),
            SizedBox(height: 40.wMin),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        floatingActionButton: _buildFlotInAdvanceButton(context),
        bottomNavigationBar: _buildBottomMenuWidget(context),
      ),
    );
  }

  Widget _buildFlotInAdvanceButton(BuildContext context) {
    return Obx(() {
      return Visibility(
        visible: controller.isAllCompleted.value,
        child: TapScaleWidget(
          sclae: 1.02,
          onTap: () {
            controller.advanceLearning(context);
          },
          child: Container(
            height: 80.wMin,
            width: 180.wMin,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.cBgBrand.color,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              "我要提前学",
              style: TextStyle(
                fontSize: 24.wMin,
                color: AppTheme.cStaticWhite.color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTitleWidget(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 40.wMin),
        const BackWidget(title: "任务控制中心"),
        const Spacer(),
        Obx(() {
          if (!controller.isTodayMission.value) return const SizedBox.shrink();
          if (controller.missionList.isEmpty) return const SizedBox.shrink();
          return _buildMissionCountWidget(
            borderColor: AppTheme.cSurfaceWarning.color,
            textColor: AppTheme.cSurfaceWarning.color,
            title: "获得学点",
            value: "+${controller.missionEntity.value.missionPoints ?? 0}",
          );
        }),
        SizedBox(width: 24.wMin),
        Obx(() {
          if (!controller.isTodayMission.value) return const SizedBox.shrink();
          if (controller.missionList.isEmpty) return const SizedBox.shrink();

          int currentIndex = controller.currentMissionIndex.value + 1;
          int missionCount = controller.missionEntity.value.missionCount ?? 0;

          return _buildMissionCountWidget(
            borderColor: AppTheme.cFeedbackInfoBorder.color,
            textColor: AppTheme.cFeedbackInfoText.color,
            title: "任务总数",
            value: controller.isAllCompleted.value ? "$missionCount" : "$currentIndex / $missionCount",
            // value: "$missionCount"
          );
        }),
        SizedBox(width: 24.wMin),
        Obx(() {
          if (!controller.isTodayMission.value) return const SizedBox.shrink();
          if (controller.missionList.isEmpty) return const SizedBox.shrink();
          return _buildMissionCountWidget(
            borderColor: AppTheme.cFeedbackSuccessBorder.color,
            textColor: AppTheme.cFeedbackSuccessText.color,
            title: "预计用时",
            value: "${(controller.exerciseDuration.value / 60).round()}分钟",
          );
        }),
        SizedBox(width: 24.wMin),
        Obx(() {
          return Visibility(
            visible: (controller.missionEntity.value.completeShowCount ?? true) && controller.isAllCompleted.value,
            child: TapScaleWidget(
              sclae: 1.03,
              onTap: () {
                controller.showMissionStatisticsDialog(context);
              },
              child: Container(
                height: 54.wMin,
                padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.wMin),
                  color: AppTheme.cSurfaceSecondary.color,
                ),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      "assets/svg/public/icon_polyline.svg",
                      width: 32.wMin,
                      colorFilter: ColorFilter.mode(AppTheme.cTextTertiary.color, BlendMode.srcIn),
                    ),
                    SizedBox(width: 4.wMin),
                    Text(
                      "详细",
                      style: TextStyle(
                        fontSize: 22.wMin,
                        color: AppTheme.cTextPrimary.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 8.wMin),
                    SvgPicture.asset(
                      "assets/svg/public/icon_arrow_down.svg",
                      width: 28.wMin,
                      colorFilter: ColorFilter.mode(AppTheme.cTextTertiary.color, BlendMode.srcIn),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        SizedBox(width: 16.wMin + MediaQuery.of(context).padding.right),
      ],
    );
  }

  Widget _buildMissionCountWidget({
    required Color borderColor,
    required Color textColor,
    required String title,
    required String value,
  }) {
    return Container(
      height: 54.wMin,
      padding: EdgeInsets.symmetric(horizontal: 24.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        color: AppTheme.cSurfaceSecondary.color,
        border: Border(
          left: BorderSide(width: 5.wMin, color: borderColor),
        ),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 22.wMin,
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 8.wMin),
          Text(
            value,
            style: TextStyle(
              fontSize: 32.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionListWidget() {
    return Obx(() {
      if (!controller.isTodayMission.value) {
        return const NotDataWidget(
          message: "没有任务了\n明天再来挑战吧",
        );
      }

      int currentIndex = controller.currentMissionIndex.value;
      bool isAllCompleted = controller.isAllCompleted.value;

      return CustomPaint(
        painter: MissionControlCenterDottedLinePaint(
          missionList: controller.missionList,
          rootKey: controller.listRootKey,
          lineColor: AppTheme.cWhiteAlpha20.color,
          lineWidth: 6.wMin,
          dashSpace: 20.wMin,
          dashWidth: 16.wMin,
        ),
        
        child: ListView.builder(
          key: controller.listRootKey,
          controller: controller.scrollController,
          itemCount: controller.missionList.length,
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.only(left: 88.wMin, right: 200.wMin),
          itemBuilder: (context, index) {
            bool isLock = index > controller.currentMissionIndex.value;
            if(controller.missionList[index].missions.learned) isLock = false;
            if(controller.missionList[index].missions.learning) isLock = false;
            bool isAdmin = UserStore.to.rolePermissions.value.isOfficial;
            if(isAdmin) isLock = false;
            if(index==currentIndex){
              return MissionControlCenterPlanetWidget(
                  missionModel: controller.missionList[index],
                  index: index,
                  currentIndex: isAllCompleted ? -1 : currentIndex,
                  onTap: isLock ? null : () {
                    if(isLock) return;
                    controller.startMission(controller.missionList[index], index, again: false);
                  },
                  onAgainTap: isLock ? null : () {
                    if(isLock) return;
                    controller.startMission(controller.missionList[index], index, again: true);
                  }
              );
            }
            return MissionControlCenterPlanetWidget(
              missionModel: controller.missionList[index],
              index: index,
              currentIndex: isAllCompleted ? -1 : currentIndex,
              onTap: isLock ? null : () {
                if(isLock) return;
                controller.startMission(controller.missionList[index], index, again: false);
              },
              onAgainTap: isLock ? null : () {
                if(isLock) return;
                controller.startMission(controller.missionList[index], index, again: true);
              },
            );
          },
        ),
      );
    });
  }

  /// 计划列表
  Widget _buildPlanListWidget() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Obx(() {
        return Row(
          spacing: 24.wMin,
          mainAxisSize: MainAxisSize.min,
          children: List.generate(controller.missionUnits.length, (index) {
            if(index==0)return MissionControlCenterPlanWidget(planCourse: controller.missionUnits[index],isGuide:true);
            return MissionControlCenterPlanWidget(planCourse: controller.missionUnits[index]);
          }),
        );
      }),
    );
  }

  /// 底部菜单
  Widget _buildBottomMenuWidget(BuildContext context) {
    return Obx(() {
      if (controller.taskMissionMenuList.isEmpty) return const SizedBox();
      return MissionControlCenterSpecialMenuWidget(
        taskMissionMenuList: controller.taskMissionMenuList.toList(),
        onTap: (context, item) {
          controller.showMissionTaskPop(context, item);
        },
      );
    });
  }
  
}
