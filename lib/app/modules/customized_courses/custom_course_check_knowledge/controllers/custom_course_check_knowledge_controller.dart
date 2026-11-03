import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/official_course_details/controllers/official_course_details_controller.dart';
import 'package:langwise/app/routes/app_pages.dart';
import 'package:langwise/common/https/customized_courses.dart';
import 'package:langwise/common/widgets/ask_dialog.dart';
import 'package:langwise/common/widgets/input_dialog.dart';
import 'package:langwise/utils/utils.dart';
import '../models/custom_course_check_knowledge_response_entity.dart';
import '../models/custom_course_check_knowledge_word_model.dart';

class CustomCourseCheckKnowledgeController extends GetxController {
  int? courseId;
  int? levelId;
  int? moduleId;

  CustomCourseCheckKnowledgeResponseEntity? knowledgeEntity;
  final RxList<List<CustomCourseCheckKnowledgeWordModel>> unitsList = <List<CustomCourseCheckKnowledgeWordModel>>[].obs;
  final RxList<CustomCourseCheckKnowledgeWordModel> topList = <CustomCourseCheckKnowledgeWordModel>[].obs;
  final RxList<String?> unitNameList = <String?>[].obs;
  int? draggingFromUnitIndex;
  int? draggingFromItemIndex;
  bool isDraggingFromTop = false;

  // 是否显示过提示框
  RxBool isShowTip = false.obs;

  final ScrollController topScrollController = ScrollController();
  List<ScrollController> unitScrollControllerList = <ScrollController>[];

  @override
  void onInit() {
    super.onInit();
    courseId = Get.arguments['courseId'];
    levelId = Get.arguments['levelId'];
    moduleId = Get.arguments['moduleId'];

    initServiceData();
  }

  @override
  void onClose() {
    super.onClose();
    topScrollController.dispose();
    for (var controller in unitScrollControllerList) {
      controller.dispose();
    }
  }

  //保存退出
  void saveExit() async {
    if (Get.isRegistered<OfficialCourseDetailsController>()) {
      OfficialCourseDetailsController officialCourseDetailsController = Get.find<OfficialCourseDetailsController>();
      await officialCourseDetailsController.getModuleList(isPlan: true, isLoading: false);
    }

    Get.until((route) => route.settings.name == Routes.OFFICIAL_COURSE_DETAILS);
  }

  //开始生成
  void startGenerate() async {
    if (Get.isRegistered<OfficialCourseDetailsController>()) {
      OfficialCourseDetailsController officialCourseDetailsController = Get.find<OfficialCourseDetailsController>();
      await officialCourseDetailsController.getModuleList(isPlan: true, isLoading: false);
    }

    try {
      ToastUtils.showLoading();
      bool isSuccess = await CustomizedCoursesRequest.generateCourse(moduleId!);
      if (isSuccess == false) {
        await AskDialog.showUserAsk(
          context: Get.context!,
          content: "生成失败，请重试。",
          define: "确认",
          showCancel: false,
        );
        Get.until((route) => route.settings.name == Routes.OFFICIAL_COURSE_DETAILS);
      } else {
        Get.until((route) => route.settings.name == Routes.OFFICIAL_COURSE_DETAILS);
      }
    } finally {
      ToastUtils.hideLoading();
    }
  }

  //修改单元名称
  void modifyUnitName(int unitIndex) async {
    final String? name = await InputDialog.show(context: Get.context!, title: "单元名称", hintText: "请输入单元名称", realName: unitNameList[unitIndex]!);
    if (name == null) {
      return;
    }

    try {
      ToastUtils.showLoading();

      Map<String, dynamic> reqData = {'name': name};
      bool isSuccess = await CustomizedCoursesRequest.modifyUnitName(reqData, knowledgeEntity!.unitList[unitIndex].uid!);
      if (isSuccess == false) return;
      unitNameList[unitIndex] = name;
      update();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  //获取自定义课程知识点
  initServiceData() async {
    try {
      ToastUtils.showLoading();
      knowledgeEntity = await CustomizedCoursesRequest.getCourseKnowledges(moduleId!);
      if (knowledgeEntity != null) {
        unitsList.value = knowledgeEntity!.unitList.map((e) => e.knowledgeList).toList();
        topList.value = knowledgeEntity!.unGrouped.knowledgeList;

        unitScrollControllerList = [];
        List<String?> nameList = [];
        for (int i = 0; i < unitsList.length; i++) {
          unitScrollControllerList.add(ScrollController());
          nameList.add(knowledgeEntity!.unitList[i].name);
        }
        unitNameList.value = nameList;
      }
    } finally {
      ToastUtils.hideLoading();
    }
  }

  //移动知识点接口
  Future<bool> moveKnowledge({
    required int unitId,
    required int unitKnowledgeId,
    required int index,
  }) async {
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {'unitId': unitId, 'unitKnowledgeId': unitKnowledgeId, 'index': index};
      return await CustomizedCoursesRequest.moveKnowledge(reqData);
    } finally {
      ToastUtils.hideLoading();
    }
  }

  //开始拖拽
  void startDrag({int? unitIndex, int? itemIndex, bool fromTop = false}) {
    draggingFromUnitIndex = unitIndex;
    draggingFromItemIndex = itemIndex;
    isDraggingFromTop = fromTop;
  }

  //拖拽结束，被移动到top区域
  void moveToTop(CustomCourseCheckKnowledgeWordModel item, int moveToIndex) async {
    bool isSuccess = await moveKnowledge(
      unitId: knowledgeEntity!.unGrouped.uid!,
      unitKnowledgeId: item.uid!,
      index: moveToIndex + 1,
    );
    if (isSuccess == false) return;

    List<List<CustomCourseCheckKnowledgeWordModel>> oldUnitsList = unitsList.map((list) => List<CustomCourseCheckKnowledgeWordModel>.from(list)).toList();
    List<CustomCourseCheckKnowledgeWordModel> oldTopList = List<CustomCourseCheckKnowledgeWordModel>.from(topList);

    //从原本的数组删除
    if (isDraggingFromTop) {
      oldTopList.removeAt(draggingFromItemIndex!);
    } else {
      oldUnitsList[draggingFromUnitIndex!].removeAt(draggingFromItemIndex!);
    }

    //添加到top数组
    if (moveToIndex >= topList.length) {
      oldTopList.add(item);
    } else {
      oldTopList.insert(moveToIndex, item);
    }

    unitsList.value = oldUnitsList;
    topList.value = oldTopList;

    // 重置拖拽相关的状态
    draggingFromUnitIndex = null;
    draggingFromItemIndex = null;
    isDraggingFromTop = false;
  }

  //拖拽结束，被移动到unit区域
  void moveToUnit(CustomCourseCheckKnowledgeWordModel item, int moveToUnitIndex, int moveToIndex) async {
    bool isSuccess = await moveKnowledge(
      unitId: knowledgeEntity!.unitList[moveToUnitIndex].uid!,
      unitKnowledgeId: item.uid!,
      index: moveToIndex + 1,
    );
    if (isSuccess == false) return;

    List<List<CustomCourseCheckKnowledgeWordModel>> oldUnitsList = unitsList.map((list) => List<CustomCourseCheckKnowledgeWordModel>.from(list)).toList();
    List<CustomCourseCheckKnowledgeWordModel> oldTopList = List<CustomCourseCheckKnowledgeWordModel>.from(topList);

    // 从原本的数组删除
    if (isDraggingFromTop) {
      oldTopList.remove(item);
    } else {
      oldUnitsList[draggingFromUnitIndex!].removeAt(draggingFromItemIndex!);
    }

    // 添加到unit数组
    if (moveToIndex >= unitsList[moveToUnitIndex].length) {
      oldUnitsList[moveToUnitIndex].add(item);
    } else {
      oldUnitsList[moveToUnitIndex].insert(moveToIndex, item);
    }

    unitsList.value = oldUnitsList;
    topList.value = oldTopList;

    // 重置拖拽相关的状态
    draggingFromUnitIndex = null;
    draggingFromItemIndex = null;
    isDraggingFromTop = false;
  }
}
