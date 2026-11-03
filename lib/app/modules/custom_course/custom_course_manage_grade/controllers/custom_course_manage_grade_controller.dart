import 'dart:io';

import 'package:api/entities/response.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:ui_essentials/ui_essentials.dart';
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
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/image_picker_utils.dart';
import 'package:langwise/utils/toast_utils.dart';

import '../../../../../utils/oss_upload_file_utils/oss_upload_file_utils.dart';
import '../custom_course_manage_grade_sort/controllers/custom_course_manage_grade_sort_controller.dart';
import '../views/custom_course_manage_grade_add_grade_dialog.dart';
import '../views/custom_course_manage_grade_sort_dialog.dart';

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
  final RxInt selectedGradeIndex = 0.obs;
  final RxInt activeLevelId = (-1).obs;
  final Map<int, GlobalKey> levelSectionKeys = <int, GlobalKey>{};
  final Map<int, GlobalKey> levelHeaderKeys = <int, GlobalKey>{};
  final Map<int, GlobalKey> levelTabKeys = <int, GlobalKey>{};
  int? draggingFromGradeIndex;
  int? draggingFromItemIndex;
  bool isDraggingFromTop = false;

  final ScrollController topScrollController = ScrollController();
  final ScrollController gradeScrollController = ScrollController();
  final ScrollController levelTabScrollController = ScrollController();
  final GlobalKey levelTabViewportKey = GlobalKey();

  bool isFirstInit = true; //是否第一次初始化

  bool addGradeScroll = false; //新增年级操作
  int? addGradeID; //新增年级的ID
  bool deleteOperate = false; //删除操作
  bool _hasChange = false;
  bool _programmaticScrolling = false;

  int? studyGradeIndex; //推荐年级的索引

  double get moduleHeaderHeight => 60.wMin;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    gradeScrollController.addListener(_syncActiveLevelByScroll);
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
    gradeScrollController.removeListener(_syncActiveLevelByScroll);
    topScrollController.dispose();
    gradeScrollController.dispose();
    levelTabScrollController.dispose();
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
  Future<void> initServiceData() async {
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
        final int? levelId = level?.levelId;
        if (levelId != null) {
          levelSectionKeys.putIfAbsent(levelId, () => GlobalKey());
          levelHeaderKeys.putIfAbsent(levelId, () => GlobalKey());
          levelTabKeys.putIfAbsent(levelId, () => GlobalKey());
        }
      }

      _clampSelectedGradeIndex();
      _syncActiveLevelFromSelection();

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
      update(['gradeWorkspace']);
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
    for (var i = 0; i < (courseEntity.value.levelList?.length ?? 0); i++) {
      if (courseEntity.value.levelList![i]?.tier == courseEntity.value.studyTier) {
        final int? targetLevelId = courseEntity.value.levelList![i]?.levelId;
        if (targetLevelId == null) return;
        scrollToLevel(targetLevelId);
        break;
      }
    }
  }

  //滚动到新增的年级位置
  void scrollToAddGrade() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (addGradeID == null) return;
    for (var i = 0; i < (courseEntity.value.levelList?.length ?? 0); i++) {
      if (courseEntity.value.levelList![i]?.levelId == addGradeID) {
        scrollToLevel(addGradeID);
        break;
      }
    }
  }

  //如果是从课程详情进来的，就滚动到当前年级的位置
  void scrollToGrade() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (levelId == null) return;
    for (var i = 0; i < (courseEntity.value.levelList?.length ?? 0); i++) {
      if (courseEntity.value.levelList![i]?.levelId == levelId) {
        scrollToLevel(levelId);
        break;
      }
    }
  }

  void selectGrade(int index) {
    final List<CourseLevelEntityLevelList?> levels =
        courseEntity.value.levelList ?? const <CourseLevelEntityLevelList?>[];
    if (levels.isEmpty) {
      selectedGradeIndex.value = 0;
      activeLevelId.value = -1;
      return;
    }
    final int safeIndex = index.clamp(0, gradesList.length - 1);
    final int? targetLevelId = safeIndex < levels.length ? levels[safeIndex]?.levelId : null;
    if (targetLevelId == null) {
      selectedGradeIndex.value = safeIndex;
      _syncActiveLevelFromSelection();
      return;
    }
    scrollToLevel(targetLevelId);
  }

  void _clampSelectedGradeIndex() {
    final List<CourseLevelEntityLevelList?> levels =
        courseEntity.value.levelList ?? const <CourseLevelEntityLevelList?>[];
    if (levels.isEmpty) {
      selectedGradeIndex.value = 0;
      activeLevelId.value = -1;
      return;
    }
    selectedGradeIndex.value = selectedGradeIndex.value.clamp(0, levels.length - 1);
  }

  void _syncActiveLevelFromSelection() {
    final List<CourseLevelEntityLevelList?> levels =
        courseEntity.value.levelList ?? const <CourseLevelEntityLevelList?>[];
    if (levels.isEmpty) return;
    final int index = selectedGradeIndex.value.clamp(0, levels.length - 1);
    final int? targetLevelId = levels[index]?.levelId;
    if (targetLevelId == null) return;
    _setActiveLevel(targetLevelId);
  }

  GlobalKey getLevelHeaderKey(int levelId) {
    return levelHeaderKeys.putIfAbsent(levelId, GlobalKey.new);
  }

  GlobalKey getLevelTabKey(int levelId) {
    return levelTabKeys.putIfAbsent(levelId, GlobalKey.new);
  }

  int? _findLevelIndexById(int? levelId) {
    if (levelId == null) return null;
    final List<CourseLevelEntityLevelList?> levels =
        courseEntity.value.levelList ?? const <CourseLevelEntityLevelList?>[];
    for (int index = 0; index < levels.length; index++) {
      if (levels[index]?.levelId == levelId) {
        return index;
      }
    }
    return null;
  }

  void _setActiveLevel(int? levelId) {
    if (levelId == null) return;
    if (activeLevelId.value != levelId) {
      activeLevelId.value = levelId;
    }
    final int? index = _findLevelIndexById(levelId);
    if (index != null && selectedGradeIndex.value != index) {
      selectedGradeIndex.value = index;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _centerActiveLevelTabIfNeeded(levelId);
    });
  }

  void scrollToLevel(int? levelId) {
    if (levelId == null) return;
    _programmaticScrolling = true;
    _setActiveLevel(levelId);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToLevelHeader(levelId);
    });
  }

  void _scrollToLevelHeader(int levelId, {int retry = 0}) {
    if (isClosed) return;
    if (!gradeScrollController.hasClients) {
      if (retry >= 8) {
        _finishProgrammaticScroll();
        return;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToLevelHeader(levelId, retry: retry + 1);
      });
      return;
    }
    final double? targetOffset = _getHeaderScrollOffset(levelId);
    if (targetOffset != null) {
      final double maxOffset = gradeScrollController.position.maxScrollExtent;
      gradeScrollController
          .animateTo(
            targetOffset.clamp(0.0, maxOffset),
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeInOut,
          )
          .whenComplete(_finishProgrammaticScroll);
      return;
    }
    if (retry >= 8) {
      _finishProgrammaticScroll();
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToLevelHeader(levelId, retry: retry + 1);
    });
  }

  void _finishProgrammaticScroll() {
    Future.delayed(const Duration(milliseconds: 80), () {
      _programmaticScrolling = false;
      _syncActiveLevelByScroll();
    });
  }

  void _syncActiveLevelByScroll() {
    if (_programmaticScrolling) return;
    final List<CourseLevelEntityLevelList?> levels =
        courseEntity.value.levelList ?? const <CourseLevelEntityLevelList?>[];
    if (levels.isEmpty || !gradeScrollController.hasClients) return;

    final double probeOffset = gradeScrollController.offset + (moduleHeaderHeight * 0.6);
    int? nextLevelId;
    for (final level in levels) {
      final int? currentLevelId = level?.levelId;
      if (currentLevelId == null) continue;
      final double? headerOffset = _getHeaderScrollOffset(currentLevelId);
      if (headerOffset == null) continue;
      if (headerOffset <= probeOffset) {
        nextLevelId = currentLevelId;
        continue;
      }
      break;
    }
    nextLevelId ??= levels.first?.levelId;
    if (nextLevelId != null && nextLevelId != activeLevelId.value) {
      _setActiveLevel(nextLevelId);
    }
  }

  double? _getHeaderScrollOffset(int levelId) {
    final BuildContext? ctx = levelHeaderKeys[levelId]?.currentContext;
    if (ctx == null || !ctx.mounted || !gradeScrollController.hasClients) {
      return null;
    }
    final RenderObject? renderObject = ctx.findRenderObject();
    if (renderObject == null || !renderObject.attached) return null;
    final RenderAbstractViewport viewport = RenderAbstractViewport.of(renderObject);
    return viewport.getOffsetToReveal(renderObject, 0).offset;
  }

  void _centerActiveLevelTabIfNeeded(int levelId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isClosed || !levelTabScrollController.hasClients) return;
      final BuildContext? itemContext = getLevelTabKey(levelId).currentContext;
      final BuildContext? viewportContext = levelTabViewportKey.currentContext;
      if (itemContext == null || viewportContext == null) return;

      final RenderObject? itemRenderObject = itemContext.findRenderObject();
      final RenderObject? viewportRenderObject = viewportContext.findRenderObject();
      if (itemRenderObject is! RenderBox || viewportRenderObject is! RenderBox) {
        return;
      }
      if (!itemRenderObject.attached || !viewportRenderObject.attached) return;

      final Offset offset = itemRenderObject.localToGlobal(
        Offset.zero,
        ancestor: viewportRenderObject,
      );
      final double itemLeft = offset.dx;
      final double itemRight = itemLeft + itemRenderObject.size.width;
      final double viewportWidth = viewportRenderObject.size.width;
      final double edgePadding = 12.wMin;
      final bool isOutOfView =
          itemLeft < edgePadding || itemRight > viewportWidth - edgePadding;
      if (!isOutOfView) return;

      final double targetOffset = levelTabScrollController.offset +
          itemLeft -
          ((viewportWidth - itemRenderObject.size.width) / 2);
      final double maxOffset = levelTabScrollController.position.maxScrollExtent;
      levelTabScrollController.animateTo(
        targetOffset.clamp(0.0, maxOffset),
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    });
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
      if (askRes) {
        courseEntity.value.autoSort = true;
        ResponseEntity? res = await OfficialCourseDetailsRequest.autoSort(
          courseId!,
          parameters: {'autoSort': true},
        );
        if (res == null) return;
        ToastUtils.showToast(text: "自动整理成功", type: ToastType.success);
        initServiceData();
        return;
      }
      courseEntity.value.autoSort = false;

      //刷新首页数据
      if (Get.isRegistered<HomeController>()) {
        await Get.find<HomeController>().initHomeCardList();
      }
    }

    final String sortTag = '${tagText}_sort_dialog';
    if (Get.isRegistered<CustomCourseManageGradeSortController>(tag: sortTag)) {
      Get.delete<CustomCourseManageGradeSortController>(tag: sortTag, force: true);
    }
    final List<CourseLevelEntityLevelList?> currentLevelList =
        courseEntity.value.levelList ?? <CourseLevelEntityLevelList?>[];
    final CustomCourseManageGradeSortController sortController =
        Get.put<CustomCourseManageGradeSortController>(
      CustomCourseManageGradeSortController(
        initialCourseId: courseId,
        initialLevelList: currentLevelList,
        shouldDisableAutoSortOnSave: courseEntity.value.autoSort != false,
      ),
      tag: sortTag,
    );

    final bool? shouldRefresh = await Get.dialog<bool>(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: 72.wMin,
          vertical: 80.wMin,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 1360.wMin,
            maxHeight: 760.wMin,
          ),
          child: Container(
            padding: EdgeInsets.fromLTRB(
              28.wMin,
              24.wMin,
              28.wMin,
              22.wMin,
            ),
            decoration: BoxDecoration(
              color: AppTheme.cEditBookGradeBackground,
              borderRadius: BorderRadius.circular(22.wMin),
              border: Border.all(
                color: AppTheme.cBorderSecondary.withValues(alpha: 0.28),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.cStaticBlack.withValues(alpha: 0.24),
                  blurRadius: 22.wMin,
                  offset: Offset(0, 10.wMin),
                ),
              ],
            ),
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: 4.wMin,
                    right: 18.wMin,
                  ),
                  child: CustomCourseManageGradeSortDialog(
                    controller: sortController,
                    onClose: () {
                      Get.back(result: false);
                    },
                    onSave: () async {
                      final bool success = await sortController.saveSort();
                      if (success) {
                        Get.back(result: true);
                      }
                    },
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => Get.back(result: false),
                    child: Container(
                      width: 44.wMin,
                      height: 44.wMin,
                      decoration: BoxDecoration(
                        color: AppTheme.cBgTertiary.withValues(alpha: 0.85),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 22.wMin,
                        color: AppTheme.cTextSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
    if (Get.isRegistered<CustomCourseManageGradeSortController>(tag: sortTag)) {
      Get.delete<CustomCourseManageGradeSortController>(tag: sortTag, force: true);
    }
    if (shouldRefresh == true) {
      initServiceData();
    }
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

    update(['gradeWorkspace']);
    update(['topScrollWidget']);
  }

  //拖拽结束，被移动到top区域
  void moveToTop(CourseLevelEntityLevelListModuleList? item, int moveToIndex) async {
    if (item == null) return;

    if (isDraggingFromTop) {
      if (draggingFromItemIndex == null || draggingFromItemIndex! >= topList.length) {
        return;
      }
      topList.removeAt(draggingFromItemIndex!);
    } else {
      if (draggingFromGradeIndex == null ||
          draggingFromItemIndex == null ||
          draggingFromGradeIndex! >= gradesList.length ||
          draggingFromItemIndex! >= gradesList[draggingFromGradeIndex!].length) {
        return;
      }
      gradesList[draggingFromGradeIndex!].removeAt(draggingFromItemIndex!);
      item.levelId = courseEntity.value.levelList?[draggingFromGradeIndex!]?.levelId;
    }

    final int safeIndex = moveToIndex.clamp(0, topList.length);
    topList.insert(safeIndex, item);

    gradesList.refresh();
    topList.refresh();

    // 重置拖拽相关的状态
    draggingFromGradeIndex = null;
    draggingFromItemIndex = null;
    isDraggingFromTop = false;

    update(['gradeWorkspace']);
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

    if (isDraggingFromTop) {
      topList.remove(item);
    } else {
      gradesList[draggingFromGradeIndex!].removeAt(draggingFromItemIndex!);
    }

    // 添加到grade数组
    if (moveToIndex >= gradesList[moveToGradeIndex].length) {
      gradesList[moveToGradeIndex].add(item);
    } else {
      gradesList[moveToGradeIndex].insert(moveToIndex, item);
    }

    gradesList.refresh();
    topList.refresh();

    // 重置拖拽相关的状态
    draggingFromGradeIndex = null;
    draggingFromItemIndex = null;
    isDraggingFromTop = false;

    update(['gradeWorkspace']);
    update(['topScrollWidget']);
  }
}
