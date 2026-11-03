import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:lib_common/common.dart';
import 'package:quiz_play/quiz_play.dart';
import 'package:ui_essentials/ui_essentials.dart';
import '../../elements/utils/elements_page_utils.dart';
import '../../../../common/entities/entities.dart';
import '../../../../common/enum/enum.dart';
import '../../../../common/https/https.dart';
import '../../../../common/public_controller/config_controller.dart';
import '../../../../common/values/values.dart';
import '../../../../utils/play_record_utils/play_record_constants.dart';
import '../../../routes/routes.dart';
import '../../../routes/routes_breadcrumb_utils.dart';
import '../../../routes/tag_routes.dart';
import '../../home/controllers/home_controller.dart';
import '../official_course_details_level/controllers/official_course_details_page_mode.dart';
import '../official_course_details_level/controllers/official_course_details_level_controller.dart';
import '../../specialty/controllers/specialty_controller.dart';
import '../../mission_control_center/mission_content_select/models/mission_content_select_model.dart';
import '../official_course_details_target/common/course_details_target_download_dialog.dart';
import '../official_course_details_target/models/course_details_target_content_type_model.dart';
import '../views/asking_for_tasks_dialog.dart';

class OfficialCourseDetailsController extends GetxController with RoutesBreadcrumbMixin {
  final String tagText;
  OfficialCourseDetailsController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.OFFICIAL_COURSE_DETAILS;

  @override
  String get breadcrumbTitle => "课程详情";

  /// 传进来的参数
  int? courseId;
  int? levelId;
  int? moduleId;

  /// 拉取自定义课程创建进度之后 是否需要跳转至进度详情页面
  bool goCustomCourseProgress = false;

  /// 是否是切换教材进来的
  final RxBool isSwitchCourse = false.obs;

  /// 是否可以管理课程
  final RxBool isManageCourse = false.obs;
  bool isNew = false;

  final ScrollController scrollController = ScrollController();
  final ScrollController unitTabScrollController = ScrollController();

  /// 自定义课程当前步骤
  final RxList<CustomCourseStatusEntityStatuses> customCourseStatusList = <CustomCourseStatusEntityStatuses>[].obs;
  final RxBool showCustomCourseStatus = false.obs;
  final RxInt customCourseModuleId = (-1).obs;

  /// 从服务器获取的模块列表
  final RxList<CourseModuleHoursEntityModules> moduleList = <CourseModuleHoursEntityModules>[].obs;

  /// 从服务器获取的列表数据
  final Rx<CourseModuleHoursEntity> detilData = CourseModuleHoursEntity().obs;
  final RxBool isModuleDataLoading = true.obs;
  final RxBool hasLoadedModuleData = false.obs;

  /// 从服务器获取的自定义课程状态
  final Rx<CustomCourseStatusEntity> statusEntity = CustomCourseStatusEntity().obs;

  /// 当前做到的lessonId
  final RxInt currentLessonId = (-1).obs;

  /// 当前做到的unit
  final Rx<CourseModuleHoursEntityUnits> currentUnit = CourseModuleHoursEntityUnits().obs;

  /// 当前做到的lesson
  final Rx<CourseModuleHoursEntityUnitsLessons> currentLessons = CourseModuleHoursEntityUnitsLessons().obs;

  int fromType = 0;
  int? _initialUnitId;
  bool _shouldRefreshSpecialtyOnExit = false;

  final RxInt activeUnitId = (-1).obs;
  bool _programmaticScrolling = false;
  final Map<int, int> _unitIndexById = <int, int>{};
  final List<GlobalKey> _unitSectionKeys = <GlobalKey>[];
  final List<GlobalKey> _unitTabKeys = <GlobalKey>[];
  final GlobalKey unitTabViewportKey = GlobalKey();
  final Rx<Color> chemeColor = Rx(AppTheme.cBgBrand);
  
  int? _unitTabKeysModuleId;
  int? _pendingRestoreUnitId;
  double? _pendingRestoreScrollOffset;

  static const int _lessonGridCrossAxisCount = 7;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    scrollController.addListener(_syncActiveUnitByScroll);
    if (Get.arguments != null) {
      print('disnidndisds');
      Map arguments = Get.arguments;
      courseId = arguments['courseId'];
      levelId = arguments['levelId'] ?? 0;
      moduleId = arguments['moduleId'] ?? 0;
      isNew = arguments['isNew'] ?? false;
      isSwitchCourse.value = arguments['isSwitchCourse'] ?? false;
      fromType = arguments['fromType'] ?? 0;
      goCustomCourseProgress = arguments['goCustomCourseProgress'] ?? false;
      _initialUnitId = arguments['unitId'];
      WidgetsBinding.instance.addPostFrameCallback((_) {
        getModuleList(isPlan: true, isFirst: true);
      });
    }
  }

  @override
  void onClose() {
    _refreshSpecialtyHomeCardOnExitIfNeeded();
    scrollController.removeListener(_syncActiveUnitByScroll);
    scrollController.dispose();
    unitTabScrollController.dispose();
    super.onClose();
  }

  Future<void> switchToCourse({
    required int courseId,
    int? levelId,
    int? moduleId,
    int? unitId,
    bool isLoading = false,
  }) async {
    this.courseId = courseId;
    this.levelId = levelId ?? 0;
    this.moduleId = moduleId ?? 0;
    _initialUnitId = unitId;
    isSwitchCourse.value = true;
    goCustomCourseProgress = false;
    showCustomCourseStatus.value = false;
    customCourseModuleId.value = -1;
    hasLoadedModuleData.value = false;
    activeUnitId.value = -1;
    await getModuleList(isPlan: true, isFirst: true, isLoading: isLoading);
  }

  void _refreshSpecialtyHomeCardOnExitIfNeeded() {
    if (!_shouldRefreshSpecialtyOnExit) return;
    if (!SpecialtyController.hasAliveInstance) return;
    final specialtyController =
        TagRoutes.findLast<SpecialtyController>(Routes.SPECIALTY);
    if (specialtyController == null) return;
    unawaited(specialtyController.initHomeCardList());
  }

  /// 获取自定义课程当前步骤
  Future<void> getCustomCourseStatus() async {
    if(!HttpAuthUtils.instance.isAuth(HttpAuthCodes.memberCourseCurrentStatus)) {
      return;
    }
    if (courseId == null) return;
    Map<String, dynamic> reqParameters = {
      "courseId": courseId,
    };
    CustomCourseStatusEntity? resp = await OfficialCourseDetailsRequest.getCustomCourseStatus(reqParameters);
    if (resp == null) return;
    statusEntity.value = resp;

    List<CustomCourseStatusEntityStatuses?> statuses = resp.statuses ?? [];
    customCourseStatusList.clear();
    final CustomCourseStatusEntityStatuses? lastStatus =
        statuses.isNotEmpty ? statuses.last : null;
    final List<CustomCourseStatusEntityStatusesComments?>? lastStatusComments =
        lastStatus?.comments;
    final CustomCourseStatusEntityStatusesComments? lastStatusComment =
        lastStatusComments != null && lastStatusComments.isNotEmpty
            ? lastStatusComments.last
            : null;
    if (lastStatus?.completed == true && isNew && resp.finished == false) {
      goToLearn(lastStatusComment?.jump?.params?['taskId'] ?? 0);
      return;
    }
    for (int i = 0; i < statuses.length; i++) {
      if (statuses[i] == null) continue;
      customCourseStatusList.add(statuses[i]!);
    }

    final PushMessageEntityJump? progressJump =
        customCourseStatusList.isEmpty
            ? null
            : _getLastProgressJump(customCourseStatusList.last);
    print("---课程是否生成完成: ${resp.finished}");
    if (resp.finished == true) {
      showCustomCourseStatus.value = false;
      customCourseModuleId.value = -1;
    } else {
      if (fromType == 4) {
        PushMessageEntityJump? jump = progressJump;
        if (jump == null) return;
        Map<String, dynamic> parameters = jump.params ?? {};
        parameters['fromType'] = fromType;
        parameters['moduleId'] = resp.currentModule?.uid;
        parameters['levelId'] = levelId;
        parameters['courseId'] = courseId;
        await TagRoutes.offNamed(jump.code ?? '', arguments: parameters);
        return;
      }
      customCourseModuleId.value = resp.currentModule?.uid ?? -1;
      if (goCustomCourseProgress) {
        goCustomCourseProgress = false;
        showCustomCourseStatus.value = false;
        if (progressJump != null) {
          print('djisajfjia8');
          await toCustomCoursePage(progressJump);
        }
        return;
      }
      if (!isSwitchCourse.value) {
        showCustomCourseStatus.value = true;
      }
    }
  }

  /// 去学习
  Future<void> goToLearn(int taskId) async {
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
      await getModuleList(isLoading: false, isFirst: true);
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 外部删除等级刷新
  /// 参数 delLId要删除的id
  Future<void> otherDeleteLevelRefresh(int? delLId) async {
    if (courseId == null) return;
    if (delLId == null) return;
    if (delLId != levelId) return;
    getLevleListData(null);
  }

  /// 外部删除模块刷新
  /// 参数 delMId要删除的id
  Future<void> otherDeleteModuleRefresh(int? delMId) async {
    if (courseId == null) return;
    if (delMId == null) return;
    if (delMId != moduleId) return;
    getLevleListData(levelId);
  }

  Future<void> getLevleListData(int? dLid) async {
    if (courseId == null) return;
    CourseLevelEntity? resp = await OfficialCourseDetailsLevelRequest.getCourseLevelList(courseId!);
    if (resp == null) return;
    List<CourseLevelEntityLevelList?>? list = resp.levelList;
    if (list == null || list.isEmpty) return;
    int? lId = dLid;
    int? mId;

    List<CourseLevelEntityLevelListModuleList?> moduleList = [];

    if (lId != null) {
      for (int i = 0; i < list.length; i++) {
        if (list[i] == null) continue;
        moduleList = list[i]!.moduleList ?? [];
        if (list[i]!.levelId == lId) {
          moduleList = list[i]!.moduleList ?? [];
          break;
        }
      }
    }

    if (moduleList.isEmpty) {
      for (int i = 0; i < list.length; i++) {
        if (list[i] == null) continue;
        lId = list[i]!.levelId;
        moduleList = list[i]!.moduleList ?? [];
        if (moduleList.isNotEmpty) {
          break;
        }
      }
    }

    if (moduleList.isEmpty) {
      moduleId = 0;
      getModuleList(isLoading: false);
      return;
    }

    mId = moduleList.first?.moduleId;

    if (lId != null && mId != null) {
      levelId = lId;
      moduleId = mId;
      getModuleList(isLoading: false);
    } else {
      Get.back();
    }
  }

  Future<void> getModuleList({bool isScroll = true, bool isLoading = true, bool isPlan = false, bool onlyRefreshProgress = false, bool isFirst = false}) async {
    final int? previousModuleId = moduleId;
    final bool shouldPreserveViewState = !onlyRefreshProgress && !isScroll && !isFirst;
    final int? visibleUnitId = activeUnitId.value > 0 ? activeUnitId.value : null;
    final double? visibleScrollOffset = scrollController.hasClients ? scrollController.offset : null;
    final bool shouldShowInlineLoading = !hasLoadedModuleData.value || isFirst;
    try {
      if (shouldShowInlineLoading) {
        isModuleDataLoading.value = true;
      }
      if (isLoading) ToastUtils.showLoading();
      CourseModuleHoursEntity? resp = await OfficialCourseDetailsRequest.getModuleClassHours(courseId, levelId, moduleId);
    
    
      if (resp == null) return;
      if (resp.courseId != null) {
          chemeColor.value = resp.specialty == "EN_OFFICIAL" ? AppTheme.cBgBrand : resp.specialty == "EN_PHONICS" ? AppTheme.cPhonics : AppTheme.cAmber;
      }
      if (onlyRefreshProgress) {
        //只刷新进度
        refreshProgress(resp);
        return;
      }

      // 是否自定义课程
      isManageCourse.value = resp.isManageCourse;
      detilData.value = resp;

      updateBreadcrumbTitle(resp.moduleName ?? breadcrumbTitle);

      moduleId = detilData.value.moduleId ?? 0;
      levelId = detilData.value.levelId ?? 0;

      final bool sameModule = previousModuleId == null || previousModuleId == moduleId;
      if (shouldPreserveViewState && sameModule && visibleUnitId != null) {
        _pendingRestoreUnitId = visibleUnitId;
        _pendingRestoreScrollOffset = visibleScrollOffset;
      } else {
        _pendingRestoreUnitId = null;
        _pendingRestoreScrollOffset = null;
      }

      currentLessonId.value = detilData.value.lessonId ?? (-1);

      if (isManageCourse.value && detilData.value.customModuleId == moduleId) {
        await getCustomCourseStatus();
      } else {
        showCustomCourseStatus.value = false;
      }

      List<CourseModuleHoursEntityModules?> modules = detilData.value.modules ?? [];

      moduleList.clear();
      for (int i = 0; i < modules.length; i++) {
        if (modules[i] == null) continue;
        moduleList.add(modules[i]!);
      }
    } finally {
      isModuleDataLoading.value = false;
      hasLoadedModuleData.value = true;
      if (isLoading) ToastUtils.hideLoading();
      if (isFirst) {
        // 首次进入页面, 也要展示蒙层
        // 需要展示蒙层
        getCustomCourseStatus();
      }
    }

    _rebuildUnitIndexMap();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncActiveUnitByScroll();
    });
    scrollToCurrentLesson(isScroll: isScroll, isPlan: isPlan);
  }

  /// 定位到当前做到的地方
  Future<void> scrollToCurrentLesson({bool isScroll = true, bool isPlan = false}) async {
    if (showCustomCourseStatus.value) return;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final int? initialUnitId = _initialUnitId;
      if (initialUnitId != null) {
        _initialUnitId = null;
        final List<CourseModuleHoursEntityUnits?> units = detilData.value.units ?? const <CourseModuleHoursEntityUnits?>[];
        CourseModuleHoursEntityUnits? targetUnit;
        for (final CourseModuleHoursEntityUnits? u in units) {
          if (u == null) continue;
          if (u.unitId == initialUnitId) {
            targetUnit = u;
            break;
          }
        }
        if (targetUnit != null) {
          currentUnit.value = targetUnit;
          _setActiveUnit(initialUnitId);
          if (isScroll) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              scrollToUnit(initialUnitId);
            });
          }
          return;
        }
      }

      final int? restoreUnitId = _pendingRestoreUnitId;
      if (restoreUnitId != null) {
        _pendingRestoreUnitId = null;
        final List<CourseModuleHoursEntityUnits?> units = detilData.value.units ?? const <CourseModuleHoursEntityUnits?>[];
        CourseModuleHoursEntityUnits? targetUnit;
        for (final CourseModuleHoursEntityUnits? u in units) {
          if (u == null) continue;
          if (u.unitId == restoreUnitId) {
            targetUnit = u;
            break;
          }
        }
        if (targetUnit != null) {
          currentUnit.value = targetUnit;
          _setActiveUnit(restoreUnitId);
          _restorePendingScrollOffset();
          return;
        }
        _pendingRestoreScrollOffset = null;
      }

      if (isPlan) {
        final DateTime now = DateTime.now().toLocal();
        final String nowStr = "${now.year}${now.month}${now.day}";
        final String notRemindCourse = StorageUtil().getString(NOT_REMIND_COURSE_KEY);
        if (detilData.value.planNode != null && notRemindCourse != nowStr) {
          final BuildContext? dialogContext = Get.context ?? Get.overlayContext;
          if (dialogContext != null) {
            final int? result = await AskingForTasksDialog.show(context: dialogContext);
            if (result == 1) {
              continuePlan();
              return;
            }
          }
        }
      }

      final List<CourseModuleHoursEntityUnits?> units = detilData.value.units ?? [];
      CourseModuleHoursEntityUnits? targetUnit;
      CourseModuleHoursEntityUnitsLessons? targetLesson;
      for (final CourseModuleHoursEntityUnits? u in units) {
        if (u == null) continue;
        final List<CourseModuleHoursEntityUnitsLessons?> lessons = u.lessons ?? const <CourseModuleHoursEntityUnitsLessons?>[];
        for (final CourseModuleHoursEntityUnitsLessons? l in lessons) {
          if (l == null) continue;
          if (l.uid == currentLessonId.value) {
            targetUnit = u;
            targetLesson = l;
            break;
          }
        }
        if (targetUnit != null) break;
      }

      if (targetUnit != null) {
        currentUnit.value = targetUnit;
      }
      if (targetLesson != null) {
        currentLessons.value = targetLesson;
      }

      final int? unitId = targetUnit?.unitId ?? units.first?.unitId;
      if (unitId == null) return;
      _setActiveUnit(unitId);

      if (isScroll) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollToUnit(unitId);
        });
      }
    });
  }

  PushMessageEntityJump? _getLastProgressJump(
    CustomCourseStatusEntityStatuses status,
  ) {
    final List<CustomCourseStatusEntityStatusesComments?>? comments =
        status.comments;
    if (comments == null || comments.isEmpty) return null;
    return comments.last?.jump;
  }

  void _restorePendingScrollOffset() {
    final double? targetOffset = _pendingRestoreScrollOffset;
    _pendingRestoreScrollOffset = null;
    if (targetOffset == null || !scrollController.hasClients) return;
    final double maxOffset = scrollController.position.maxScrollExtent;
    scrollController.jumpTo(targetOffset.clamp(0.0, maxOffset));
  }

  void scrollToUnit(int? unitId) {
    if (unitId == null) return;
    final unitIndex = _unitIndexById[unitId];
    if (unitIndex == null) return;
    scrollToUnitIndex(unitIndex, unitId: unitId);
  }

  void scrollToUnitIndex(int index, {int? unitId}) {
    final units = detilData.value.units?.whereType<CourseModuleHoursEntityUnits>().toList() ??
        const <CourseModuleHoursEntityUnits>[];
    if (index < 0 || index >= units.length) return;
    _programmaticScrolling = true;
    _setActiveUnit(unitId);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToUnitSectionByIndex(index);
    });
  }

  void _scrollToUnitSectionByIndex(int index, {int retry = 0}) {
    if (isClosed) return;
    if (!scrollController.hasClients) {
      if (retry >= 8) {
        _finishProgrammaticScroll();
        return;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToUnitSectionByIndex(index, retry: retry + 1);
      });
      return;
    }
    final targetOffset = _getUnitSectionOffset(index);
    if (targetOffset == null) {
      if (retry >= 8) {
        _finishProgrammaticScroll();
        return;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToUnitSectionByIndex(index, retry: retry + 1);
      });
      return;
    }
    final maxOffset = scrollController.position.maxScrollExtent;
    scrollController
        .animateTo(
          targetOffset.clamp(0.0, maxOffset),
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeInOut,
        )
        .whenComplete(() {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (isClosed || !scrollController.hasClients) {
              _finishProgrammaticScroll();
              return;
            }
            final calibratedOffset = _getUnitSectionOffset(index);
            if (calibratedOffset == null) {
              _finishProgrammaticScroll();
              return;
            }
            final newMaxOffset = scrollController.position.maxScrollExtent;
            final diff = (scrollController.offset - calibratedOffset).abs();
            if (diff > 2.wMin) {
              scrollController.jumpTo(calibratedOffset.clamp(0.0, newMaxOffset));
            }
            _finishProgrammaticScroll();
          });
        });
  }

  void _syncActiveUnitByScroll() {
    if (_programmaticScrolling) return;
    final units = detilData.value.units?.whereType<CourseModuleHoursEntityUnits>().toList() ?? const <CourseModuleHoursEntityUnits>[];
    if (units.isEmpty || !scrollController.hasClients) return;
    final double probeOffset = scrollController.offset + 60.wMin;
    int safeIndex = 0;
    for (int i = 0; i < units.length; i++) {
      final sectionOffset = _getUnitSectionOffset(i);
      if (sectionOffset == null) continue;
      if (sectionOffset <= probeOffset) {
        safeIndex = i;
        continue;
      }
      break;
    }
    final nextUnitId = units[safeIndex].unitId ?? units.first.unitId;
    if (nextUnitId != null && nextUnitId != activeUnitId.value) {
      _setActiveUnit(nextUnitId);
    }
  }

  void _finishProgrammaticScroll() {
    Future.delayed(const Duration(milliseconds: 80), () {
      _programmaticScrolling = false;
      _syncActiveUnitByScroll();
    });
  }

  void _rebuildUnitIndexMap() {
    _unitIndexById.clear();

    final units = detilData.value.units?.whereType<CourseModuleHoursEntityUnits>().toList() ?? const <CourseModuleHoursEntityUnits>[];
    final currentModuleId = detilData.value.moduleId;
    if (_unitTabKeysModuleId != currentModuleId ||
        _unitTabKeys.length != units.length ||
        _unitSectionKeys.length != units.length) {
      _unitTabKeysModuleId = currentModuleId;
      _unitTabKeys
        ..clear()
        ..addAll(List.generate(units.length, (_) => GlobalKey()));
      _unitSectionKeys
        ..clear()
        ..addAll(List.generate(units.length, (_) => GlobalKey()));
    }
    for (int i = 0; i < units.length; i++) {
      final unit = units[i];
      final id = unit.unitId;
      if (id != null) {
        _unitIndexById[id] = i;
      }
    }

    if (activeUnitId.value == -1) {
      if (units.isNotEmpty) {
        final firstId = units.first.unitId;
        if (firstId != null) {
          _setActiveUnit(firstId);
        }
      }
    }
  }

  GlobalKey getUnitTabKey(int index) {
    if (index < 0) return GlobalKey();
    if (index < _unitTabKeys.length) return _unitTabKeys[index];
    while (_unitTabKeys.length <= index) {
      _unitTabKeys.add(GlobalKey());
    }
    return _unitTabKeys[index];
  }

  GlobalKey getUnitSectionKey(int index) {
    if (index < 0) return GlobalKey();
    if (index < _unitSectionKeys.length) return _unitSectionKeys[index];
    while (_unitSectionKeys.length <= index) {
      _unitSectionKeys.add(GlobalKey());
    }
    return _unitSectionKeys[index];
  }

  void _setActiveUnit(int? unitId) {
    if (unitId == null) return;
    if (activeUnitId.value != unitId) {
      activeUnitId.value = unitId;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _centerActiveUnitTabIfNeeded(unitId);
    });
  }

  void _centerActiveUnitTabIfNeeded(int unitId) {
    if (isClosed || !unitTabScrollController.hasClients) return;
    final int? index = _unitIndexById[unitId];
    if (index == null || index < 0 || index >= _unitTabKeys.length) return;
    final BuildContext? itemContext = _unitTabKeys[index].currentContext;
    final BuildContext? viewportContext = unitTabViewportKey.currentContext;
    if (itemContext == null || viewportContext == null) return;
    final RenderObject? itemRenderObject = itemContext.findRenderObject();
    final RenderObject? viewportRenderObject = viewportContext.findRenderObject();
    if (itemRenderObject is! RenderBox || viewportRenderObject is! RenderBox) return;
    if (!itemRenderObject.attached || !viewportRenderObject.attached) return;
    final Offset offset = itemRenderObject.localToGlobal(Offset.zero, ancestor: viewportRenderObject);
    final double itemLeft = offset.dx;
    final double itemRight = itemLeft + itemRenderObject.size.width;
    final double viewportWidth = viewportRenderObject.size.width;
    final double edgePadding = 12.wMin;
    final bool isOutOfView = itemLeft < edgePadding || itemRight > viewportWidth - edgePadding;
    if (!isOutOfView) return;
    final double targetOffset = unitTabScrollController.offset + itemLeft - ((viewportWidth - itemRenderObject.size.width) / 2);
    final double maxOffset = unitTabScrollController.position.maxScrollExtent;
    unitTabScrollController.animateTo(
      targetOffset.clamp(0.0, maxOffset),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  double? _getUnitSectionOffset(int index) {
    if (!scrollController.hasClients) {
      return null;
    }
    final estimatedOffset = _estimateUnitSectionOffset(index);
    if (index < 0 || index >= _unitSectionKeys.length) {
      return estimatedOffset;
    }
    final BuildContext? ctx = _unitSectionKeys[index].currentContext;
    if (ctx == null || !ctx.mounted) return estimatedOffset;
    final RenderObject? renderObject = ctx.findRenderObject();
    if (renderObject == null || !renderObject.attached) return estimatedOffset;
    final RenderAbstractViewport viewport = RenderAbstractViewport.of(renderObject);
    return viewport.getOffsetToReveal(renderObject, 0).offset;
  }

  double? _estimateUnitSectionOffset(int index) {
    final units = detilData.value.units?.whereType<CourseModuleHoursEntityUnits>().toList() ??
        const <CourseModuleHoursEntityUnits>[];
    if (index < 0 || index >= units.length) return null;
    double offset = 24.wMin;
    for (int i = 0; i < index; i++) {
      offset += _estimateUnitSectionHeight(units[i], isFirst: i == 0);
    }
    final double dividerHeight = index == 0 ? 0 : 1;
    final double topPadding = index == 0 ? 0 : 22.wMin;
    offset += dividerHeight + topPadding;
    return offset;
  }

  double _estimateUnitSectionHeight(
    CourseModuleHoursEntityUnits unit, {
    required bool isFirst,
  }) {
    final lessons = unit.lessons?.whereType<CourseModuleHoursEntityUnitsLessons>().toList() ??
        const <CourseModuleHoursEntityUnitsLessons>[];
    final int lessonCount = lessons.length > 1 ? lessons.length - 1 : 0;
    final int rowCount =
        lessonCount == 0 ? 0 : ((lessonCount + _lessonGridCrossAxisCount - 1) ~/ _lessonGridCrossAxisCount);
    final double gridHeight = rowCount == 0 ? 0 : (rowCount * 360.wMin) + ((rowCount - 1) * 10.wMin);
    final double dividerHeight = isFirst ? 0 : 1;
    final double topPadding = isFirst ? 0 : 22.wMin;
    return dividerHeight + topPadding + 90.wMin + 18.wMin + gridHeight + 40.wMin;
  }

  /// 继续计划
  Future<void> continuePlan() async {
    Get.back(result: {"type": 0});
  }

  /// 只刷新进度
  void refreshProgress(CourseModuleHoursEntity resp) {
    detilData.value.lessonIndex = resp.lessonIndex;
    detilData.value.lessonCount = resp.lessonCount;
    List<CourseModuleHoursEntityUnits?> localUnits = detilData.value.units ?? [];
    List<CourseModuleHoursEntityUnits?> serveUnits = resp.units ?? [];
    List<CourseModuleHoursEntityUnitsLessons?> serverLessons = [];
    for (int i = 0; i < serveUnits.length; i++) {
      if (serveUnits[i] == null) continue;
      serverLessons.addAll(serveUnits[i]?.lessons ?? []);
    }

    for (int i = 0; i < localUnits.length; i++) {
      if (localUnits[i] == null) continue;
      List<CourseModuleHoursEntityUnitsLessons?> lessons = localUnits[i]!.lessons ?? [];
      for (int j = 0; j < lessons.length; j++) {
        if (lessons[j] == null) continue;
        for (var item in serverLessons) {
          if (item == null) continue;
          if (item.uid == lessons[j]?.uid && (lessons[j]?.exerciseIndex != item.exerciseIndex || lessons[j]?.exerciseTotal != item.exerciseTotal)) {
            lessons[j]?.exerciseIndex = item.exerciseIndex;
            lessons[j]?.exerciseTotal = item.exerciseTotal;
          }
        }
      }
    }
    detilData.refresh();
  }

  /// 切换模块
  Future<void> switchModule(int? uid) async {
    if (uid == null) return;
    if (moduleId == uid) return;
    moduleId = uid;
    await getModuleList();
  }

  /// 获取课时下的任务
  Future<void> getLessonTasks(BuildContext context, int? unitId, int? lessonId) async {
    final data = await fetchLessonQuizData(
      context,
      unitId,
      lessonId,
      refreshProgressBeforeFetch: false,
    );
    if (data == null) return;
    toQuizPage(data.unitId, data.lessonId, data.exerciseCurrentId, data.quizList);
  }

  Future<LessonQuizData?> fetchLessonQuizData(
    BuildContext context,
    int? unitId,
    int? lessonId, {
    bool refreshProgressBeforeFetch = true,
  }) async {
    bool experience = await LockUtils.checkExperienceApp(context);
    if (experience) return null;
    bool student = await LockUtils.checkStudent(context);
    if (!student) return null;

    if (courseId == null || levelId == null || moduleId == null || unitId == null || lessonId == null) return null;
    Map<String, dynamic> reqData = {
      "courseId": courseId,
      "levelId": levelId,
      "moduleId": moduleId,
      "unitId": unitId,
      "lessonId": lessonId,
    };
    LessonTasksEntity? taksRes;
    List<QuizModel>? quizList = [];
    try {
      ToastUtils.showLoading();
      if (refreshProgressBeforeFetch) {
        await getModuleList(onlyRefreshProgress: true, isLoading: false, isScroll: false);
      }
      taksRes = await OfficialCourseDetailsRequest.getLessonTasks(reqData);
      if (taksRes == null) return null;
      List<int?> taksIds = taksRes.exerciseIds ?? [];
      List<int> exerciseIds = [];
      for (int i = 0; i < taksIds.length; i++) {
        if (taksIds[i] == null) continue;
        exerciseIds.add(taksIds[i]!);
      }
      if (exerciseIds.isEmpty) return null;
      Map<String, dynamic> parameters = {
        "courseId": courseId,
        "levelId": levelId,
        "moduleId": moduleId,
        "unitId": unitId,
        "lessonId": lessonId,
      };
      quizList = await HomeRequest.getQuizListByIds(exerciseIds, parameters: parameters);
      if (quizList == null) return null;
    } finally {
      ToastUtils.hideLoading();
    }

    return LessonQuizData(
      unitId: unitId,
      lessonId: lessonId,
      exerciseCurrentId: taksRes.exerciseCurrentId,
      quizList: quizList,
    );
  }

  /// 开始做题
  Future<void> toQuizPage(int unitId, int lessonId, int? exerciseCurrentId, List<QuizModel> quizList) async {
    if (quizList.isEmpty) return;

    for (int i = 0; i < quizList.length; i++) {
      quizList[i].testType = "COURSE";
      quizList[i].context = QuizModelContext(
        courseId: courseId,
        levelId: levelId,
        moduleId: moduleId,
        unitId: unitId,
        lessonId: lessonId,
      );
    }

    ToastUtils.showLoading();

    await TagRoutes.toNamed(
      Routes.PRACTICE_QUESTIONS,
      arguments: {
        "quizDatas": quizList,
        "currentQuizId": exerciseCurrentId,
        "questionIsReport": true,
      },
    );
    if (Get.isRegistered<HomeController>()) {
      HomeController homeController = Get.find<HomeController>();
      if (homeController.memberCourseList.isEmpty) {
        homeController.initHomeCardList();
      }
    }
    _shouldRefreshSpecialtyOnExit = true;
    getModuleList(isLoading: false, isScroll: false);
  }

  /// 跳转至单元目标
  Future<void> toTargetPage(int? unitId) async {
    if (courseId == null || levelId == null || moduleId == null || unitId == null) return;
    await TagRoutes.toNamed(
      Routes.OFFICIAL_COURSE_DETAILS_TARGET,
      arguments: {
        "courseId": courseId,
        "levelId": levelId,
        "moduleId": moduleId,
        "unitId": unitId,
      },
    );
  }

  /// 跳转至单元剧场列表
  Future<void> toUnitScriptList(CourseModuleHoursEntityUnits unit) async {
    final unitId = unit.unitId;
    if (courseId == null || moduleId == null || unitId == null) return;
    await TagRoutes.toNamed(
      Routes.OFFICIAL_COURSE_DETAILS_UNIT_SCRIPT_LIST,
      arguments: {
        "courseId": courseId,
        "levelId": levelId,
        "moduleId": moduleId,
        "unitId": unitId,
        "specialty": detilData.value.specialty,
        "isManageCourse": isManageCourse.value,
        "courseName": detilData.value.courseName,
        "moduleName": detilData.value.moduleName,
        "unitName": unit.unitName,
      },
    );
  }

  Future<UnitKnowledgePointsEntity?> getUnitTarget(int? unitId) async {
    if (courseId == null || moduleId == null || unitId == null) return null;
    try {
      ToastUtils.showLoading();
      ConfigController configController = Get.find<ConfigController>();
      return await OfficialCourseDetailsRequest.getUnitTarget(
        courseId!,
        moduleId!,
        unitId,
        styleCode: Uri.encodeComponent(configController.currentShowStyleCode.value),
        mediaMode: configController.currentShowResource.value == ResourceTypeEnum.image ? 0 : 1,
      );
    } finally {
      ToastUtils.hideLoading();
    }
  }

  List<CourseDetailsTargetContentTypeModel> buildKnowledgeTypeModels(List<UnitKnowledgePointsEntityKnowledgeList> list) {
    final wordList = <CourseDetailsTargetContentTypeKnowledgeModel>[];
    final phraseList = <CourseDetailsTargetContentTypeKnowledgeModel>[];
    final sentenceList = <CourseDetailsTargetContentTypeKnowledgeModel>[];
    final textList = <CourseDetailsTargetContentTypeKnowledgeModel>[];
    final songList = <CourseDetailsTargetContentTypeKnowledgeModel>[];

    for (final item in list) {
      final knowledgeModel = CourseDetailsTargetContentTypeKnowledgeModel(
        knowledge: item,
        key: GlobalKey(),
      );
      if (item.isWord) {
        wordList.add(knowledgeModel);
      } else if (item.isPhrase) {
        phraseList.add(knowledgeModel);
      } else if (item.isSentence) {
        sentenceList.add(knowledgeModel);
      } else if (item.isText) {
        textList.add(knowledgeModel);
      } else if (item.isSong) {
        songList.add(knowledgeModel);
      }
    }

    final res = <CourseDetailsTargetContentTypeModel>[];
    if (wordList.isNotEmpty) {
      res.add(
        CourseDetailsTargetContentTypeModel(
          title: "单词",
          knowledges: wordList,
          orgKnowledges: wordList.map((e) => e.knowledge).toList(),
          columnCount: 3,
          type: ElementsCardType.word,
        ),
      );
    }
    if (phraseList.isNotEmpty) {
      res.add(
        CourseDetailsTargetContentTypeModel(
          title: "短语",
          knowledges: phraseList,
          orgKnowledges: phraseList.map((e) => e.knowledge).toList(),
          columnCount: 3,
          type: ElementsCardType.phrase,
        ),
      );
    }
    if (sentenceList.isNotEmpty) {
      res.add(
        CourseDetailsTargetContentTypeModel(
          title: "句子",
          knowledges: sentenceList,
          orgKnowledges: sentenceList.map((e) => e.knowledge).toList(),
          columnCount: 2,
          type: ElementsCardType.sentence,
        ),
      );
    }
    if (songList.isNotEmpty) {
      res.add(
        CourseDetailsTargetContentTypeModel(
          title: "歌曲",
          knowledges: songList,
          orgKnowledges: songList.map((e) => e.knowledge).toList(),
          columnCount: 2,
          type: ElementsCardType.song,
        ),
      );
    }
    if (textList.isNotEmpty) {
      res.add(
        CourseDetailsTargetContentTypeModel(
          title: "文章",
          knowledges: textList,
          orgKnowledges: textList.map((e) => e.knowledge).toList(),
          columnCount: 2,
          type: ElementsCardType.text,
        ),
      );
    }
    return res;
  }

  List<UnitKnowledgePointsEntityKnowledgeList> buildWpsKnowledgeList(List<UnitKnowledgePointsEntityKnowledgeList> list) {
    final res = <UnitKnowledgePointsEntityKnowledgeList>[];
    for (final item in list) {
      if (item.isWord || item.isPhrase || item.isSentence) {
        res.add(item);
      }
    }
    return res;
  }

  Future<void> previewUnit(BuildContext context, int? unitId) async {
    await _toUnitContentSelect(
      context,
      unitId,
      startAction: MissionContentSelectAction.preview,
      learnUploadType: LSRWEnum.listening,
    );
  }

  Future<void> phonicsUnit(BuildContext context, int? unitId) async {
    await _toUnitContentSelect(
      context,
      unitId,
      startAction: MissionContentSelectAction.speakingSoundBlock,
    );
  }

  Future<void> dictationUnit(BuildContext context, int? unitId) async {
    await _toUnitContentSelect(
      context,
      unitId,
      startAction: MissionContentSelectAction.dictation,
      learnUploadType: LSRWEnum.writing,
    );
  }

  Future<void> flashUnit(BuildContext context, int? unitId) async {
    await _toUnitContentSelect(
      context,
      unitId,
      startAction: MissionContentSelectAction.flashNotes,
      learnUploadType: LSRWEnum.reading,
    );
  }

  Future<void> _toUnitContentSelect(
    BuildContext context,
    int? unitId, {
    required String startAction,
    String? learnUploadType,
  }) async {
    if(!HttpAuthUtils.instance.isAuth(HttpAuthCodes.memberCourseContentDetailList)) {
      ToastUtils.showToast(text: "无权限");
      return;
    }

    bool experience = await LockUtils.checkExperienceApp(context);
    if (experience) return;
    bool student = await LockUtils.checkStudent(context);
    if (!student) return;
    if (courseId == null || moduleId == null || unitId == null) return;

    await TagRoutes.toNamed(Routes.MISSION_CONTENT_SELECT, arguments: {
      "startAction": startAction,
      "learnUploadType": learnUploadType,
      "contentSource": "current_course_unit",
      "courseId": courseId,
      "moduleId": moduleId,
      "unitId": unitId,
    });
  }

  Future<void> exploreUnit(int? unitId) async {
    if (courseId == null || levelId == null || moduleId == null || unitId == null) return;
    await TagRoutes.toNamed(
      Routes.INTELLIGENT_SEARCH,
      arguments: {
        "courseId": courseId,
        "levelId": levelId,
        "moduleId": moduleId,
        "unitId": unitId,
      },
    );
  }

  Future<void> downloadUnit(BuildContext context, int? unitId) async {
    bool experience = await LockUtils.checkExperienceApp(context);
    if (experience) return;
    bool student = await LockUtils.checkStudent(context);
    if (!student) return;
    final entity = await getUnitTarget(unitId);
    if (entity == null) return;
    final list = entity.knowledgeList?.whereType<UnitKnowledgePointsEntityKnowledgeList>().toList() ?? [];
    final models = buildKnowledgeTypeModels(list);
    if (models.isEmpty) return;
    await CourseDetailsTargetDownloadDialog.show(
      context: context,
      knowledgeList: models,
      moduleName: entity.moduleName ?? "",
      unitName: entity.unitName ?? "",
    );
  }

  Future<void> playUnitFirstSong(BuildContext context, int? unitId) async {
    bool experience = await LockUtils.checkExperienceApp(context);
    if (experience) return;
    bool student = await LockUtils.checkStudent(context);
    if (!student) return;

    final entity = await getUnitTarget(unitId);
    if (entity == null) return;
    final list = entity.knowledgeList?.whereType<UnitKnowledgePointsEntityKnowledgeList>().toList() ?? [];
    final songs = list.where((e) => e.isSong).toList();
    if (songs.isEmpty) {
      ToastUtils.showToast(text: "暂无歌曲");
      return;
    }

    final first = songs.first;
    final contents = songs
        .map(
          (e) => {
            "contentId": e.contentId,
            "contentType": e.contentType,
            "styleId": e.styleId,
            "dialect": e.dialect,
          },
        )
        .toList();

    await ElementsPageUtils.jumpElementsPage(
      contentId: first.contentId,
      contentType: first.contentType,
      semanticId: first.semanticId,
      styleId: first.styleId,
      dialect: first.dialect,
      semanticIds: [first.semanticId],
      content: first.content,
      contents: contents,
      type: PlayRecordPageType.unit,
      typeId: unitId,
    );
  }

  /// 一键开始：定位当前单元中第一个未完成的课时并开始学习
  void quickStartForUnit(BuildContext context, int? unitId) {
    if (courseId == null || levelId == null || moduleId == null || unitId == null) return;
    final List<CourseModuleHoursEntityUnits?> units = detilData.value.units ?? [];
    CourseModuleHoursEntityUnits? targetUnit;
    for (final u in units) {
      if (u == null) continue;
      if (u.unitId == unitId) {
        targetUnit = u;
        break;
      }
    }
    if (targetUnit == null) return;
    final List<CourseModuleHoursEntityUnitsLessons?> lessons = targetUnit.lessons ?? [];
    if (lessons.isEmpty) return;
    int? lessonId;
    for (int i = 1; i < lessons.length; i++) {
      final item = lessons[i];
      if (item == null) continue;
      if (!item.learned) {
        lessonId = item.uid;
        break;
      }
    }
    lessonId ??= lessons.last?.uid;
    if (lessonId == null) return;
    getLessonTasks(context, unitId, lessonId);
  }

  /// todo 跳转至等级
  Future<void> toLevel() async {
    if (courseId == null) return;

    dynamic pageRes;
    if (detilData.value.specialty == SpecialtyEnum.EN_PHONICS) {
      // 自然拼读课选择等级模块
      pageRes = await TagRoutes.toNamed(
        Routes.PHONICS_COURSE,
        arguments: {
          "courseId": courseId,
          "isSelectModule": true, // 是否是选择
        },
      );
    } else {
      final isCustomCourseEntry =
          isManageCourse.value || detilData.value.customModuleId != null;
      pageRes = await TagRoutes.toNamed(
        Routes.OFFICIAL_COURSE_DETAILS_LEVEL,
        arguments: {
          "courseId": courseId,
          "levelId": levelId,
          "moduleId": moduleId,
          "isFromCustomCourse": isCustomCourseEntry,
          "isSelectModule": true,
          "scrollToLevelId": levelId,
          "showRecommend": true,
          "scrollToStudyZoneEnum": StudyZoneEnum.study,
        },
      );
    }

    if (pageRes == null) return;
    Map? map = pageRes;
    if (map == null || map.isEmpty) return;
    _initialUnitId = map['unitId'];
    levelId = map['levelId'];
    moduleId = map['moduleId'];
    if (levelId == null || moduleId == null) return;
    print("---跳转至等级levelId: $levelId, moduleId:$moduleId---");
    getModuleList();
  }

  /// 跳转至自定义课程页面
  Future<void> toCustomCoursePage(PushMessageEntityJump? jump) async {
    if (jump == null) return;
    await JumpPageUtils.jumpUserPages(jump);
    getModuleList(isLoading: false, isScroll: false);
  }

  /// 编辑教材
  Future<void> editCourse(BuildContext context) async {
    bool isPwdRight = await ParentPasswordialog.show(context: context, isCheckHasPassword: false);
    if (!isPwdRight) return;

    await TagRoutes.toNamed(Routes.OFFICIAL_COURSE_DETAILS_LEVEL, arguments: {
      "courseId": courseId,
      "levelId": levelId,
      "moduleId": moduleId,
      "initialMode": OfficialCourseDetailsPageMode.manage,
    });
    OfficialCourseDetailsLevelController.invalidateCache(courseId: courseId);
    await getModuleList(isLoading: false, isScroll: false);
  }
}

class LessonQuizData {
  final int unitId;
  final int lessonId;
  final int? exerciseCurrentId;
  final List<QuizModel> quizList;

  const LessonQuizData({
    required this.unitId,
    required this.lessonId,
    required this.exerciseCurrentId,
    required this.quizList,
  });
}
