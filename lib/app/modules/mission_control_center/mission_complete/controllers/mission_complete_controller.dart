import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/tag_routes.dart';
import 'package:langwise/utils/utils.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/https.dart';
import '../../../../routes/routes.dart';
import '../../../../routes/routes_breadcrumb_utils.dart';
import '../../../elements/dialog/elements_collect_result_dialog.dart';
import '../../controllers/mission_control_center_controller.dart';

class MissionCompleteController extends GetxController with RoutesBreadcrumbMixin {
  final String tagText;
  MissionCompleteController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.MISSION_COMPLETE;

  @override
  String get breadcrumbTitle => "任务完成";

  int? missionId;
  bool isLastMission = false;
  TaskMissionEntityMissions? nextMission;

  final Rx<TaskMissionCompleteEntity> missionData = TaskMissionCompleteEntity().obs;

  final RxBool isStarAnimationComplete = false.obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    if (Get.arguments != null) {
      missionId = Get.arguments['missionId'];
      isLastMission = Get.arguments['isLastMission'] ?? false;
      nextMission = Get.arguments['nextMission'];
    }
    getMissionResult();
  }

  Future<void> getMissionResult() async {
    if (missionId == null) return;
    TaskMissionCompleteEntity? missions = await MissionRequest.getMissionResult(missionId!);
    if (missions == null) return;
    missionData.value = missions;

    startStarAnimation(missionData.value.star ?? 0);
  }

  Future<void> startStarAnimation(int star) async {
    List<TaskMissionCompleteEntityStarDetails?> starDetails = missionData.value.starDetails ?? [];

    for (int i = 0; i < starDetails.length; i++) {
      if (starDetails[i] == null) continue;
      if (!starDetails[i]!.isComplete) continue;
      await Future.delayed(const Duration(milliseconds: 500));
      starDetails[i]!.isShowStar = true;
      missionData.refresh();
    }

    await Future.delayed(const Duration(milliseconds: 800));

    isStarAnimationComplete.value = true;
  }

  /// 返回控制中心
  Future<void> backToMissionControlCenter(BuildContext context) async {
    await ElementsCollectResultDialog.checkNewCard(context: context);
    Get.back(result: 0);
  }

  /// 再做一遍
  Future<void> doAgain() async {
    try {
      ToastUtils.showLoading();
      final missionController = TagRoutes.findLast<MissionControlCenterController>(Routes.MISSION_CONTROL_CENTER);
      if (missionController != null) {
        await missionController.getTaskMission(showLoading: false, scrollToCurrent: false);
      }
    } finally {
      ToastUtils.hideLoading();
    }
    Get.back(result: 1);
  }

  /// 继续下一个任务 下一个是测试的时候去测试
  Future<void> continueNextMission() async {
    try {
      ToastUtils.showLoading();
      final missionController = TagRoutes.findLast<MissionControlCenterController>(Routes.MISSION_CONTROL_CENTER);
      if (missionController != null) {
        await missionController.getTaskMission(showLoading: false, scrollToCurrent: false);
      }
    } finally {
      ToastUtils.hideLoading();
    }
    Get.back(result: 2);
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
