import 'dart:io';

import 'package:api/entities/response.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/home/controllers/home_controller.dart';
import 'package:langwise/app/routes/app_pages.dart';
import 'package:langwise/app/routes/routes_breadcrumb_utils.dart';
import 'package:langwise/app/routes/tag_routes.dart';
import 'package:langwise/common/entities/course_level_entity.dart';
import 'package:langwise/common/https/official_course_details.dart';
import 'package:langwise/common/https/official_course_details_level.dart';
import 'package:langwise/common/widgets/ask_dialog.dart';
import 'package:langwise/common/widgets/delete_dialog.dart';
import 'package:langwise/common/widgets/input_dialog.dart';
import 'package:langwise/app/modules/official_course_details/official_course_details_level/controllers/official_course_details_level_controller.dart';
import 'package:langwise/utils/image_picker_utils.dart';
import 'package:langwise/utils/toast_utils.dart';

import '../../../../../utils/oss_upload_file_utils/oss_upload_file_utils.dart';
import '../views/custom_course_manage_grade_add_grade_dialog.dart';
import 'package:ui_essentials/ui_essentials.dart';

class CustomCourseManageGradeController extends GetxController with RoutesBreadcrumbMixin {
  final String tagText;
  CustomCourseManageGradeController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.CUSTOM_COURSE_MANAGE_GRADE;

  @override
  String get breadcrumbTitle => '编辑教材';

  int? courseId;
  int? levelId;
  int? moduleId;
  bool isStudyPlan = false;

  int tipNum = 0;

  final Rx<CourseLevelEntity> courseEntity = CourseLevelEntity().obs;

  final RxList<List<CourseLevelEntityLevelListModuleList?>> gradesList = <List<CourseLevelEntityLevelListModuleList?>>[].obs;
  final RxList<CourseLevelEntityLevelListModuleList?> topList = <CourseLevelEntityLevelListModuleList?>[].obs;

  final RxList<String?> gradeNameList = <String?>[].obs;
  int? draggingFromGradeIndex;
  int? draggingFromItemIndex;
  bool isDraggingFromTop = false;

  final ScrollController topScrollController = ScrollController();
  final ScrollController gradeScrollController = ScrollController();

  bool isFirstInit = true; //是否第一次初始化

  bool addGradeScroll = false; //新增年级操作
  int? addGradeID; //新增年级的ID
  bool deleteOperate = false; //删除操作
  bool _hasChange = false;

  int? studyGradeIndex; //推荐年级的索引

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    if (Get.arguments != null) {
      courseId = Get.arguments['courseId'];
      levelId = Get.arguments['levelId'];
      moduleId = Get.arguments['moduleId'];
      isStudyPlan = Get.arguments['isStudyPlan'] ?? false;
    }

    initServiceData();
  }

  @override
  void onClose() {
    topScrollController.dispose();
    gradeScrollController.dispose();
    super.onClose();
  }

  //返回
  void back() async {
    if (topList.isNotEmpty) {
      bool? res = await AskDialog.showUserCancelAsk(
        context: Get.context!,
        title: "存在未分配的教材",
        content: "暂存区内还有 ${topList.length} 本书籍未移动到新年级。\n如果现在离开，这些书籍将自动返回原来的位置。",
        cancel: "仍然离开",
        define: "继续编辑",
      );
      if (res == null) return;
      if (res) {
        return;
      }
    }

    if (deleteOperate) {
      //回到首页
      TagRoutes.offNamedUntil(Routes.APPLICATION, ModalRoute.withName(Routes.APPLICATION));
    } else {
      Get.back(result: {"changed": _hasChange});
    }
  }

  void _markChanged() {
    _hasChange = true;
    OfficialCourseDetailsLevelController.invalidateCache(courseId: courseId);
  }

  //获取数据
  initServiceData() async {
    if (courseId == null) return;
    try {
      ToastUtils.showLoading();

      CourseLevelEntity? entity = await OfficialCourseDetailsLevelRequest.getCourseLevelList(courseId!, parameters: {'emptyLevel': 1});

      if (entity == null) return;
      courseEntity.value = entity;

      gradesList.value = [];
      gradeNameList.value = [];
        topList.value = [];


      for (var i = 0; i < (courseEntity.value.levelList?.length ?? 0); i++) {
        CourseLevelEntityLevelList? level = courseEntity.value.levelList![i];
        gradeNameList.add(level?.name ?? '');
        List<CourseLevelEntityLevelListModuleList?> moduleList = level?.moduleList ?? [];
        gradesList.add(moduleList);
      }

      bool isHaveLevel = false;
      String? studyTips;
      if (entity.studyTier != null) {
        // 没有推荐年级
        if (tipNum > 0) return;
        tipNum += 1;
        studyTips = entity.studyTips;

        for (var i = 0; i < (entity.levelList?.length ?? 0); i++) {
          if (entity.levelList![i]?.tier == entity.studyTier) {
            studyGradeIndex = i;
            isHaveLevel = true;
            break;
          }
        }

        if (isHaveLevel) {
          scrollToStudyGrade();
        } else {
          final askRes = await AskDialog.showUserAsk(
            context: Get.context!,
            title: '没有检测到相应年级',
            content: "如果想要添加「$studyTips」的教材，请先创建一个新等级",
            cancel: '暂不添加',
            define: "去添加",
          );
          if (askRes) {
            addGrade(studyTier: entity.studyTier);
          }
        }
      } else {
        if (isFirstInit) {
          isFirstInit = false;
          scrollToGrade();
        }
      }

      if (moduleId == -1) {
        topList.value = [];
      }
      update();
      update(['topScrollWidget']);

      //如果新增了年级，需要滚动到新增的年级位置
      if (addGradeScroll) {
        addGradeScroll = false;
        scrollToAddGrade();
      }
    } finally {
      ToastUtils.hideLoading();
    }
  }

  //如果是从课程详情进来的，就滚动到当前年级的位置
  void scrollToStudyGrade() async {
    await Future.delayed(const Duration(milliseconds: 500));

    double width = 380.wMin;
    double offset = 0;
    for (var i = 0; i < (courseEntity.value.levelList?.length ?? 0); i++) {
      if (courseEntity.value.levelList![i]?.tier == courseEntity.value.studyTier) {
        gradeScrollController.animateTo(
          offset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
        );
        break;
      } else {
        offset = offset + 20.wMin + (width + 20.wMin) * (gradesList[i].length + 1) + 40.wMin;
      }
    }
  }

  //滚动到新增的年级位置
  void scrollToAddGrade() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (addGradeID == null) return;

    double width = 380.wMin;
    double offset = 0;
    for (var i = 0; i < (courseEntity.value.levelList?.length ?? 0); i++) {
      if (courseEntity.value.levelList![i]?.levelId == addGradeID) {
        gradeScrollController.animateTo(
          offset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
        );
        break;
      } else {
        offset = offset + 20.wMin + (width + 20.wMin) * (gradesList[i].length + 1) + 40.wMin;
      }
    }
  }

  //如果是从课程详情进来的，就滚动到当前年级的位置
  void scrollToGrade() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (levelId == null) return;

    double width = 380.wMin;
    double offset = 0;
    for (var i = 0; i < (courseEntity.value.levelList?.length ?? 0); i++) {
      if (courseEntity.value.levelList![i]?.levelId == levelId) {
        gradeScrollController.animateTo(
          offset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
        );
        break;
      } else {
        offset = offset + 20.wMin + (width + 20.wMin) * (gradesList[i].length + 1) + 40.wMin;
      }
    }
  }

  //新增年级
  void addGrade({int? studyTier}) async {
    Map<String, dynamic>? newGrap = await CustomCourseManageGradeAddGradeDialog.show(
      context: Get.context!,
      courseId: courseId!,
      studyTier: studyTier,
    );
    if (newGrap == null) return;
    String name = newGrap['name'];
    int tier = newGrap['tier'];

    for (var i = 0; i < (courseEntity.value.levelList?.length ?? 0); i++) {
      if (courseEntity.value.levelList![i]?.name == name) {
        // 年级已存在, 询问用户是否继续
        bool askRes = await AskDialog.showUserAsk(
          context: Get.context!,
          title: '温馨提示',
          content: '您已经有名称为 $name 的年级，是否继续？',
        );
        if (!askRes) {
          return;
        }
      }
    }

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "courseId": courseId,
        "name": name,
        "tier": tier,
      };
      ResponseEntity? res = await OfficialCourseDetailsRequest.addGrade(data: reqData);
      if (res?.data == null) return;
      ToastUtils.showToast(text: "新增成功", type: ToastType.success);
      _markChanged();
      addGradeID = res!.data['uid'];
      addGradeScroll = true;

      //刷新数据
      initServiceData();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  //修改年级名称
  void modifyGradeName(int gradeIndex) async {
    String? resName = await InputDialog.show(
      context: Get.context!,
      title: "等级重命名",
      content: "新等级名称",
      hintText: "请输入新等级名称",
      realName: gradeNameList[gradeIndex],
    );
    if (resName == null) return;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "name": resName,
      };
      bool res = await OfficialCourseDetailsRequest.editLevel(courseEntity.value.levelList![gradeIndex]!.levelId!, reqData);
      if (!res) return;
      ToastUtils.showToast(text: "修改成功", type: ToastType.success);
      _markChanged();

      //刷新数据
      initServiceData();
      //如果上个界面的年级和修改的年级一样，就刷新首页数据
      if (levelId == courseEntity.value.levelList![gradeIndex]!.levelId!) {
        if (Get.isRegistered<HomeController>()) {
          await Get.find<HomeController>().initHomeCardList();
        }
      }
    } finally {
      ToastUtils.hideLoading();
    }
  }

  //删除年级
  void deleteGrade(int gradeIndex) async {
    bool res = await DeleteDialog.show(
      context: Get.context!,
      title: "删除年级",
      subTitle: "确认要删除当前年级吗？",
    );
    if (!res) return;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> parameters = {
        "courseId": courseId,
      };
      bool res = await OfficialCourseDetailsRequest.levelStatusSwitch(courseEntity.value.levelList![gradeIndex]!.levelId!, parameters);
      if (!res) return;
      ToastUtils.showToast(text: "删除成功", type: ToastType.success);
      _markChanged();
      //刷新数据
      initServiceData();

      //如果上个界面的年级和删除的年级一样，就刷新首页数据
      if (levelId == courseEntity.value.levelList![gradeIndex]!.levelId!) {
        deleteOperate = true;
        //刷新首页数据
        if (Get.isRegistered<HomeController>()) {
          await Get.find<HomeController>().initHomeCardList();
        }
      }
    } finally {
      ToastUtils.hideLoading();
    }
  }

  //修改教材名称
  void modifyModuleName(CourseLevelEntityLevelListModuleList? module) async {
    if (module == null) return;

    String? resName = await InputDialog.show(
      context: Get.context!,
      title: "模块重命名",
      content: "新模块名称",
      hintText: "请输入新模块名称",
      realName: module.name,
    );
    if (resName == null) return;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "name": resName,
      };
      bool res = await OfficialCourseDetailsRequest.editModule(module.moduleId!, reqData);
      if (!res) return;
      ToastUtils.showToast(text: "修改成功", type: ToastType.success);
      _markChanged();
      //刷新数据
      initServiceData();

      //如果上个界面的教材和修改的教材一样，就刷新首页数据
      if (moduleId == module.moduleId!) {
        if (Get.isRegistered<HomeController>()) {
          await Get.find<HomeController>().initHomeCardList();
        }
      }
    } finally {
      ToastUtils.hideLoading();
    }
  }

  //修改教材封面
  void modifyModuleCover(CourseLevelEntityLevelListModuleList? module) async {
    if (module == null) return;

    File? file = await ImagePickerUtils.selectPicture(context: Get.context!, withCircleUi: false, cropAspectRatio: 3 / 4);
    if (file == null) return;
    try {
      ToastUtils.showLoading();
      final record = await OssUploadFileUtils.uploadUserFile(filePath: file.path);
      if (record?.key == null) return;
      String key = record!.key!;
      Map<String, dynamic> reqData = {
        "cover": key,
      };
      bool res = await OfficialCourseDetailsRequest.editModule(module.moduleId!, reqData);
      if (!res) return;
      ToastUtils.showToast(text: "修改成功", type: ToastType.success);
      _markChanged();

      //刷新数据
      initServiceData();

      //如果上个界面的教材和修改的教材一样，就刷新首页数据
      if (moduleId == module.moduleId!) {
        if (Get.isRegistered<HomeController>()) {
          await Get.find<HomeController>().initHomeCardList();
        }
      }
    } finally {
      ToastUtils.hideLoading();
    }
  }

  //删除教材
  void deleteModule(CourseLevelEntityLevelListModuleList? module) async {
    if (module == null) return;

    bool res = await DeleteDialog.show(
      context: Get.context!,
      title: "删除教材",
      subTitle: "确认要删除当前教材吗？",
    );
    if (!res) return;

    try {
      ToastUtils.showLoading();
      bool res = await OfficialCourseDetailsRequest.moduleStatusSwitch(module.moduleId!);
      if (!res) return;
      ToastUtils.showToast(text: "删除成功", type: ToastType.success);
      _markChanged();
      //刷新数据
      initServiceData();

      //如果上个界面的教材和删除的教材一样，就刷新首页数据
      if (moduleId == module.moduleId!) {
        deleteOperate = true;
        if (Get.isRegistered<HomeController>()) {
          await Get.find<HomeController>().initHomeCardList();
        }
      }
    } finally {
      ToastUtils.hideLoading();
    }
  }

  //新增教材
  void addModule(int gradeIndex, String cefr,CourseLevelEntityLevelList? levelModel) {
    bool isOk = true;
    for (CourseLevelEntityLevelList? levelModel in courseEntity.value.levelList ?? []) {
      for (CourseLevelEntityLevelListModuleList? moduleModel in levelModel?.moduleList ?? []) {
        if (moduleModel?.completed == false) {
          isOk = false;
          break;
        }
      }
    }

    if (isOk) {
      TagRoutes.toNamed(
        Routes.CUSTOM_COURSE,
        arguments: {
          'courseId': courseId,
          'levelId': courseEntity.value.levelList?[gradeIndex]?.levelId,
          'cefr': cefr,
          'levelName':cefr,
          'gradeIndex':levelModel?.tier??0,
          'isFromManage': true,
          'fromType': 1,
        },
      );
    } else {
      ToastUtils.showToast(text: "存在正在生成的教材，完成后才能新增教材", type: ToastType.error);
    }
  }

  //级别排序
  void sortGrade() async {
    if (courseEntity.value.autoSort == null) {
      final askRes = await AskDialog.showUserAsk(
        title: '是否自动整理？',
        context: Get.context!,
        content: "系统会把课程改为「英语教材」并按年级和学期顺序排好。",
        define: "自动整理",
        cancel: "我要手动排序",
      );
      bool autoSort = false;
      if (askRes) {
        autoSort = true;
      }
      courseEntity.value.autoSort = autoSort;

      //调用整理接口
      ResponseEntity? res = await OfficialCourseDetailsRequest.autoSort(courseId!, parameters: {'autoSort': autoSort});
      if (res == null) return;
      ToastUtils.showToast(text: "自动整理成功", type: ToastType.success);
      if (autoSort) {
        initServiceData();
        return;
      }

      //刷新首页数据
      if (Get.isRegistered<HomeController>()) {
        await Get.find<HomeController>().initHomeCardList();
      }
    }

    //跳转手动整理界面
    await TagRoutes.toNamed(
      Routes.CUSTOM_COURSE_MANAGE_GRADE_SORT,
      arguments: {'courseId': courseId},
    );
    initServiceData();
  }

  //移动教材接口
  Future<bool> moveModule({
    required int moduleId,
    required int? levelId,
    required int? targetLevelId,
    required int target,
  }) async {
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        'moduleId': moduleId,
        'levelId': levelId,
        'targetLevelId': targetLevelId,
        'target': target,
        'courseId': courseId!,
      };
      ResponseEntity? res = await OfficialCourseDetailsRequest.moveModule(
        parameters: {
          'courseId': courseId!,
        },
        data: reqData,
      );
      return res != null;
    } finally {
      ToastUtils.hideLoading();
    }
  }

  //开始拖拽
  void startDrag({int? gradeIndex, int? itemIndex, bool fromTop = false}) {
    draggingFromGradeIndex = gradeIndex;
    draggingFromItemIndex = itemIndex;
    isDraggingFromTop = fromTop;

    update(['topScrollWidget']);
  }

  //拖拽结束，被移动到top区域
  void moveToTop(CourseLevelEntityLevelListModuleList? item, int moveToIndex) async {
    if (item == null) return;

    List<List<CourseLevelEntityLevelListModuleList?>> oldGradeList = gradesList.map((list) => List<CourseLevelEntityLevelListModuleList?>.from(list)).toList();
    List<CourseLevelEntityLevelListModuleList?> oldTopList = List<CourseLevelEntityLevelListModuleList?>.from(topList);

    //从原本的数组删除
    if (isDraggingFromTop) {
      oldTopList.removeAt(draggingFromItemIndex!);
    } else {
      oldGradeList[draggingFromGradeIndex!].removeAt(draggingFromItemIndex!);
    }

    //添加到top数组
    if (moveToIndex >= topList.length) {
      if (!isDraggingFromTop) {
        //如果是从grade区域拖拽到top区域，item的levelId需要赋值
        item.levelId = courseEntity.value.levelList?[draggingFromGradeIndex!]?.levelId;
      }
      oldTopList.add(item);
    } else {
      if (!isDraggingFromTop) {
        //如果是从grade区域拖拽到top区域，item的levelId需要赋值
        item.levelId = courseEntity.value.levelList?[draggingFromGradeIndex!]?.levelId;
      }
      oldTopList.insert(moveToIndex, item);
    }

    gradesList.value = oldGradeList;
    topList.value = oldTopList;

    // 重置拖拽相关的状态
    draggingFromGradeIndex = null;
    draggingFromItemIndex = null;
    isDraggingFromTop = false;

    update(['topScrollWidget']);
  }

  //拖拽结束，被移动到grade区域
  void moveToGrade(CourseLevelEntityLevelListModuleList? item, int moveToGradeIndex, int moveToIndex) async {
    if (item == null) return;

    bool isSuccess = await moveModule(
      moduleId: item.moduleId!,
      levelId: isDraggingFromTop ? item.levelId : courseEntity.value.levelList?[draggingFromGradeIndex!]?.levelId,
      targetLevelId: courseEntity.value.levelList?[moveToGradeIndex]?.levelId,
      target: moveToIndex,
    );
    if (isSuccess == false) return;

    List<List<CourseLevelEntityLevelListModuleList?>> oldGradeList = gradesList.map((list) => List<CourseLevelEntityLevelListModuleList?>.from(list)).toList();
    List<CourseLevelEntityLevelListModuleList?> oldTopList = List<CourseLevelEntityLevelListModuleList?>.from(topList);

    // 从原本的数组删除
    if (isDraggingFromTop) {
      oldTopList.remove(item);
    } else {
      oldGradeList[draggingFromGradeIndex!].removeAt(draggingFromItemIndex!);
    }

    // 添加到grade数组
    if (moveToIndex >= gradesList[moveToGradeIndex].length) {
      oldGradeList[moveToGradeIndex].add(item);
    } else {
      oldGradeList[moveToGradeIndex].insert(moveToIndex, item);
    }

    gradesList.value = oldGradeList;
    topList.value = oldTopList;

    // 重置拖拽相关的状态
    draggingFromGradeIndex = null;
    draggingFromItemIndex = null;
    isDraggingFromTop = false;

    update(['topScrollWidget']);
  }
}
