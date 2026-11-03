import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/enum/enum.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/widgets/widgets.dart';

class OfficialCourseDetailsLevelController extends GetxController {
  int? courseId;
  int? levelId;
  int? moduleId;
  bool? isFromCustomCourse;
  bool? isFromStudyPlan;
  bool showUnit = false;

  /// 显示推荐起点
  bool showRecommend = false;

  /// 提示次数
  int tipNum = 0;

  /// 滚动到对应的难度区域 [StudyZoneEnum]
  String? scrollToStudyZoneEnum;

  final ScrollController scrollController = ScrollController();

  final RxList<CourseLevelEntityLevelList> courseLevelList = <CourseLevelEntityLevelList>[].obs;
  final Rx<CourseLevelEntity> courseLevel = CourseLevelEntity().obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      courseId = Get.arguments['courseId'];
      levelId = Get.arguments['levelId'];
      moduleId = Get.arguments['moduleId'];
      isFromCustomCourse = Get.arguments['isFromCustomCourse'] ?? false;
      isFromStudyPlan = Get.arguments['isFromStudyPlan'] ?? false;
      showRecommend = Get.arguments['showRecommend'] ?? false;
      showUnit = Get.arguments['showUnit'] ?? false;
      scrollToStudyZoneEnum = Get.arguments['scrollToStudyZoneEnum'];

      getLevleListData();
    }
  }

  /// 获取等级列表数据
  Future<void> getLevleListData() async {
    if (courseId == null) return;
    try {
      ToastUtils.showLoading();
      CourseLevelEntity? resp = await OfficialCourseDetailsLevelRequest.getCourseLevelList(courseId!);
      if (resp == null) return;
      courseLevel.value = resp;
      List<CourseLevelEntityLevelList?>? list = resp.levelList;
      if (list == null || list.isEmpty) return;
      courseLevelList.clear();
      for (int i = 0; i < list.length; i++) {
        if (list[i] == null) continue;
        courseLevelList.add(list[i]!);
      }

      autoScrollToStudyZone();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 滚动到对应的等级
  void scrollToGrade() async {
    if (levelId == null) return;
    await Future.delayed(const Duration(milliseconds: 500));

    double paddingLeft = 100.wMin;
    double spacing = 32.wMin;

    double offset = 0;
    for (int i = 0; i < courseLevelList.length; i++) {
      List<CourseLevelEntityLevelListModuleList?> moduleList = courseLevelList[i].moduleList ?? [];
      if (moduleList.isEmpty) continue;
      if (levelId == courseLevelList[i].levelId) {
        break;
      }

      int moduleLenght = moduleList.length;
      double itemModuleWidth = (442.wMin + 40.wMin) * moduleLenght - 40.wMin;
      if (offset == 0) offset = paddingLeft;
      offset += (itemModuleWidth + spacing);
    }
    if (offset == 0) return;
    offset -= (spacing - 64.wMin);
    scrollController.animateTo(offset, duration: const Duration(milliseconds: 300), curve: Curves.ease);
  }

  /// 自动滚动到学习区
  Future<void> autoScrollToStudyZone() async {
    if (scrollToStudyZoneEnum == null) return;
    await Future.delayed(const Duration(milliseconds: 500));

    bool haveStudyZone = false;
    for (int i = 0; i < courseLevelList.length; i++) {
      if (courseLevelList[i].studyZone == StudyZoneEnum.study) {
        haveStudyZone = true;
        break;
      }
    }
    if (!haveStudyZone) {
      if (tipNum > 0) return;
      tipNum += 1;
      if (courseLevel.value.studyTips != null && isFromCustomCourse == true) {
        final askRes = await AskDialog.showUserAsk(
          title: '推荐学习起点「${courseLevel.value.studyTips}」',
          context: Get.context!,
          content: "系统检测到您的教材列表里没有「${courseLevel.value.studyTips}」的教材，请先添加教材。",
          define: "去添加",
          cancel: "暂不添加",
        );
        if (askRes) {
          editCourse(Get.context!);
        }
      }
      return;
    }

    double paddingLeft = 100.wMin;
    double spacing = 32.wMin;

    double offset = 0;
    for (int i = 0; i < courseLevelList.length; i++) {
      if (courseLevelList[i].studyZone == null) continue;
      List<CourseLevelEntityLevelListModuleList?> moduleList = courseLevelList[i].moduleList ?? [];
      if (moduleList.isEmpty) continue;
      int moduleLenght = moduleList.length;
      if (courseLevelList[i].studyZone == scrollToStudyZoneEnum) break;
      double itemModuleWidth = (442.wMin + 40.wMin) * moduleLenght - 40.wMin;
      if (offset == 0) offset = paddingLeft;
      offset += (itemModuleWidth + spacing);
    }
    if (offset == 0) return;
    offset -= (spacing - 64.wMin);
    scrollController.animateTo(offset, duration: const Duration(milliseconds: 300), curve: Curves.ease);
  }

  Future<void> checkLevelImage(BuildContext context, CourseLevelEntityLevelListModuleList? module, CourseLevelEntityLevelList? level) async {
    if (courseId == null) return;
    if (module == null || level == null) return;
    if (module.moduleId == null || level.levelId == null) return;

    int? unitId;
    String? unitName;
    int? difficulty;
    if (showUnit) {
      if (!(module.completed ?? true)) {
        return ToastUtils.showToast(text: "当前教材未创建完成");
      }

      dynamic res = await Get.toNamed(
        Routes.COURSE_LEVEL_SELECT_UNIT,
        arguments: {
          "courseId": courseId,
          "levelId": level.levelId,
          "moduleId": module.moduleId,
          "isNew": module.newAdd,
          "subTitle": "已选${courseLevel.value.name ?? ''} > ${module.name ?? ''}",
        },
      );

      if (res == null) return;
      CourseLevelModuleUnitEntityUnits? unit = res;
      if (unit == null) return;

      unitId = unit.unitId;
      unitName = unit.unitName;
      difficulty = unit.difficulty;
    }

    if (isFromCustomCourse == true) {
      //从自定义课程进来的
      Get.offNamedUntil(
        Routes.OFFICIAL_COURSE_DETAILS,
        ModalRoute.withName(Routes.APPLICATION),
        arguments: {
          "courseId": courseId,
          "levelId": level.levelId,
          "moduleId": module.moduleId,
          "isNew": module.newAdd,
          "isSwitchCourse": true,
          "goCustomCourseProgress": false,
        },
      );
    } else {
      Get.back(result: {
        "courseId": courseId,
        "courseName": courseLevel.value.name,
        "moduleId": module.moduleId,
        "moduleName": module.name,
        "levelId": level.levelId,
        "levelName": level.name,
        "unitId": unitId,
        "unitName": unitName,
        "difficulty": difficulty,
      });
    }
  }

  /// 编辑课程
  Future<void> editCourse(BuildContext context, {isStudyPlan = false}) async {
    if (courseId == null) return;

    bool isPwdRight = await ParentPasswordialog.show(context: context, isCheckHasPassword: false);
    if (!isPwdRight) return;

    Get.toNamed(
      Routes.CUSTOM_COURSE_MANAGE_GRADE,
      arguments: {
        "courseId": courseId,
        "levelId": levelId,
        "moduleId": moduleId,
        "isStudyPlan": isStudyPlan,
      },
    )?.then((_) {
      courseLevelList.clear();
      getLevleListData();
    });
  }
}
