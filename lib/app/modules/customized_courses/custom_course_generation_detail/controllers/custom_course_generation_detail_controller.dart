import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/home/controllers/home_controller.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../utils/utils.dart';
import '../../../official_course_details/controllers/official_course_details_controller.dart';

class CustomCourseGenerationDetailController extends GetxController {
  int? taskId;
  int? courseId;
  int? levelId;

  final RxList<AiAnimationRunModel> aiAnimationRunList = <AiAnimationRunModel>[].obs;

  final Rx<CourseGenerateStatusResponseEntity> aiProcessStatus = CourseGenerateStatusResponseEntity().obs;

  /// 0创建中 1去学习(成功) 2失败
  final RxInt runType = 0.obs;
  int fromType = 0;
  int moduleId = 0;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      taskId = Get.arguments["taskId"];
      courseId = Get.arguments["courseId"];
      levelId = Get.arguments["levelId"];
      fromType = Get.arguments["fromType"]??0;
      moduleId = Get.arguments["moduleId"]??0;
      getAiProcessStatus();
    }
  }

  Future<void> getAiProcessStatus() async {
    Map<String, dynamic> parameters = {
      "taskId": taskId,
    };
    CourseGenerateStatusResponseEntity? responseEntity = await CustomizedCoursesRequest.getAiProcessStatus(parameters);
    if (responseEntity == null) {
      aiAnimationRunList.add(AiAnimationRunModel(
        name: "课程模块框架构建",
        subName: "处理中",
        error: true,
      ));
      aiAnimationRunList.refresh();
      _runStepAnimation();
      return;
    }
    //如果还没有完成，就重新请求最新进度
    // if (responseEntity.generateStatus == 1) {
    //   _pollingRequest();
    // }
    aiProcessStatus.value = responseEntity;

    aiAnimationRunList.value = [];

    aiAnimationRunList.add(AiAnimationRunModel(
      name: responseEntity.moduleFramework?.stepName ?? "",
      subName: responseEntity.moduleFramework?.statusDescription,
      value: responseEntity.moduleFramework?.statisticsInfo,
      dataCompleted: responseEntity.moduleFramework?.completed ?? false,
      error: responseEntity.moduleFramework?.isFailed ?? false,
    ));

    aiAnimationRunList.add(AiAnimationRunModel(
      name: responseEntity.unitPlan?.stepName ?? "",
      subName: responseEntity.unitPlan?.statusDescription,
      value: responseEntity.unitPlan?.statisticsInfo,
      dataCompleted: responseEntity.unitPlan?.completed ?? false,
      error: responseEntity.unitPlan?.isFailed ?? false,
    ));

    aiAnimationRunList.add(AiAnimationRunModel(
      name: responseEntity.sentenceGeneration?.stepName ?? "",
      subName: responseEntity.sentenceGeneration?.statusDescription,
      value: responseEntity.sentenceGeneration?.statisticsInfo,
      dataCompleted: responseEntity.sentenceGeneration?.completed ?? false,
      error: responseEntity.sentenceGeneration?.isFailed ?? false,
    ));

    aiAnimationRunList.add(AiAnimationRunModel(
      name: responseEntity.lessonGeneration?.stepName ?? "",
      subName: responseEntity.lessonGeneration?.statusDescription,
      value: responseEntity.lessonGeneration?.statisticsInfo,
      dataCompleted: responseEntity.lessonGeneration?.completed ?? false,
      error: responseEntity.lessonGeneration?.isFailed ?? false,
    ));

    aiAnimationRunList.add(AiAnimationRunModel(
      name: responseEntity.contentGeneration?.stepName ?? "",
      subName: responseEntity.contentGeneration?.statusDescription,
      value: responseEntity.contentGeneration?.statisticsInfo,
      dataCompleted: responseEntity.contentGeneration?.completed ?? false,
      error: responseEntity.contentGeneration?.isFailed ?? false,
    ));

    _runStepAnimation();
  }

  //如果没有全部完成，就继续请求
  void _pollingRequest() async {
    await Future.delayed(const Duration(seconds: 3), () {
      getAiProcessStatus();
    });
  }

  Future<void> _runStepAnimation() async {
    // aiAnimationRunList.first.show = true;
    // aiAnimationRunList.refresh();

    for (int i = 0; i < aiAnimationRunList.length; i++) {
      aiAnimationRunList[i].show = true;

      //处理失败的情况
      if (aiAnimationRunList[i].error) {
        runType.value = 2;
        aiAnimationRunList[i].subName = "处理失败";
        aiAnimationRunList[i].isCompleted = true;
        aiAnimationRunList.refresh();
        return;
      }

      //如果当前步骤显示过进度动画，就不再显示进度动画
      if (aiProcessStatus.value.notDisplayed!.length > i) {
        aiAnimationRunList[i].isCompleted = true;
        aiAnimationRunList[i].showProgress = false;
        aiAnimationRunList.refresh();
        continue;
      }

      if (!aiAnimationRunList[i].showProgress) {
        aiAnimationRunList[i].isCompleted = true;
        aiAnimationRunList.refresh();
        continue;
      }

      await Future.delayed(const Duration(milliseconds: 500));

      if (!aiAnimationRunList[i].dataCompleted) {
        //如果还没有完成，就重新请求最新进度
        if (aiProcessStatus.value.generateStatus == 1) {
          _pollingRequest();
        }
        return;
      }

      for (int j = 0; j <= 10; j++) {
        int randomDuration = Random().nextInt(10) + 100;
        await Future.delayed(Duration(milliseconds: randomDuration));
        aiAnimationRunList[i].process = j * 10;
        aiAnimationRunList.refresh();
      }

      await Future.delayed(const Duration(milliseconds: 200));
      aiAnimationRunList[i].isCompleted = true;
      aiAnimationRunList.refresh();

      if (i + 1 < aiAnimationRunList.length) {
        await Future.delayed(const Duration(milliseconds: 100));
        aiAnimationRunList[i + 1].show = true;
        aiAnimationRunList.refresh();
      }
    }

    await Future.delayed(const Duration(milliseconds: 1000));

    runType.value = 1;
  }

  /// 重新生成
  Future<void> reGenerateCourse() async {
    runType.value = 0;
    aiAnimationRunList.clear();
    if (courseId == null) {
      getAiProcessStatus();
      return;
    }
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> parameters = {
        "courseId": courseId,
      };
      bool res = await CustomizedCoursesRequest.reGenerateCourse(parameters);
      if (!res) return;
      if (Get.isRegistered<OfficialCourseDetailsController>()) {
        await Get.find<OfficialCourseDetailsController>().getModuleList(isLoading: false);
      }

      Get.back(result: true);
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 联系客服
  Future<void> contactCustomerService(BuildContext context) async {
    await QrCodeDialog.reportCustomer(context);
  }

  /// 去学习
  Future<void> goToLearn() async {
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> parameters = {
        "taskId": taskId,
      };
      bool isSuccess = await CustomizedCoursesRequest.customConfirm(parameters);
      if (!isSuccess) return;

      if (Get.isRegistered<HomeController>()) {
        await Get.find<HomeController>().initHomeCardList();
      }
      if (Get.isRegistered<OfficialCourseDetailsController>()) {
        await Get.find<OfficialCourseDetailsController>().getModuleList(isLoading: false, isFirst: true);
      }
      if (fromType == 4) {
        // Get.offNamed(Routes.NEW_CREATE_STUDY_PLAN,arguments: {"fromType": fromType,"moduleId": moduleId,"levelId": levelId,"courseId": courseId, "initPlan": true});

       Get.back(result: true);
       Get.back(result: 1);
      } else {
        Get.back(result: true);
      }
    } finally {
      ToastUtils.hideLoading();
    }
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

class AiAnimationRunModel {
  String name;
  String? subName;
  String? value;
  bool isCompleted = false;
  bool error = false;
  int process = 0;
  bool show = false;
  bool showProgress;
  bool dataCompleted;
  AiAnimationRunModel({
    required this.name,
    this.subName,
    this.value,
    this.error = false,
    this.showProgress = true,
    this.dataCompleted = true,
  });
}
