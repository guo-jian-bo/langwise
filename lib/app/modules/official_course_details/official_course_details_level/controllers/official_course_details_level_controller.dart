import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/custom_course/custom_course_manage_grade/controllers/custom_course_manage_grade_controller.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/app/routes/routes_breadcrumb_utils.dart';
import 'package:langwise/app/routes/tag_routes.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/enum/enum.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/widgets/widgets.dart';
import 'official_course_details_page_mode.dart';

class OfficialCourseDetailsLevelController extends GetxController with RoutesBreadcrumbMixin {
  static void invalidateCache({int? courseId}) {}

  final String tagText;
  OfficialCourseDetailsLevelController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.OFFICIAL_COURSE_DETAILS_LEVEL;

  @override
  String get breadcrumbTitle => "英语教材";

  int? courseId;
  int? levelId;
  int? moduleId;
  int? initialUnitId;
  bool? isFromCustomCourse;
  bool? isFromStudyPlan;
  bool? isSelectModule;
  int? _initialScrollLevelId;
  int? _initialScrollModuleId;
  bool showUnit = false;
  OfficialCourseDetailsPageMode initialMode =
      OfficialCourseDetailsPageMode.browse;
  int? browseRestoreLevelId;
  int? browseRestoreExpandedModuleId;
  bool shouldRestoreExpandedModule = false;
  int? manageAnchorModuleId;
  double manageAnchorOffsetDelta = 0;

  final Map<int, GlobalKey> _levelHeaderKeysById = <int, GlobalKey>{};
  final Map<int, GlobalKey> _levelTabKeysById = <int, GlobalKey>{};
  final Map<int, GlobalKey> _moduleKeysById = <int, GlobalKey>{};

  /// 显示推荐起点
  bool showRecommend = false;
  bool autoOpenDetail = false;
  int? autoOpenLevelId;
  int? autoOpenModuleId;
  bool _autoOpenedDetail = false;

  /// 提示次数
  int tipNum = 0;

  /// 滚动到对应的难度区域 [StudyZoneEnum]
  String? scrollToStudyZoneEnum;

  final ScrollController scrollController = ScrollController();
  final ScrollController levelTabScrollController = ScrollController();
  final GlobalKey levelTabViewportKey = GlobalKey();

  final RxList<CourseLevelTreeLevel> levels = <CourseLevelTreeLevel>[].obs;
  final RxList<ModuleListItem> moduleItems = <ModuleListItem>[].obs;
  final Rx<CourseLevelTreeEntity> courseLevelTree = CourseLevelTreeEntity().obs;
  final RxString courseTitle = ''.obs;
  final RxBool isPageLoading = true.obs;
  final Rx<OfficialCourseDetailsPageMode> pageMode =
      OfficialCourseDetailsPageMode.browse.obs;
  final RxnInt expandedModuleId = RxnInt();
  final RxInt activeLevelId = (-1).obs;
  final RxnInt recentVisitedUnitId = RxnInt();
  bool _programmaticScrolling = false;

  double get moduleHeaderHeight => 60.wMin;
  double get moduleHeaderGap => 12.wMin;
  double get moduleItemGap => 16.wMin;
  int get moduleGridCrossAxisCount => 3;
  double get moduleGridCrossAxisSpacing => 18.wMin;
  double get moduleGridMainAxisSpacing => 18.wMin;

  double get moduleCardBaseHeight => 246.wMin;
  int get unitGridCrossAxisCount => 5;
  double get unitGridCrossAxisSpacing => 18.wMin;
  double get unitGridMainAxisSpacing => 18.wMin;
  double get unitGridPadding => 12.wMin * 2;
  double get knowledgeCountsHeight => 84.wMin;
  bool get _shouldReturnUnitOnly =>
       isFromStudyPlan == true;
  List<CourseLevelTreeLevel> get visibleLevels => levels
      .where((level) => hasDisplayableModules(level))
      .toList(growable: false);

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_syncActiveLevelByScroll);
    if (Get.arguments != null) {
      final Map arguments = Get.arguments;
      courseId = arguments['courseId'];
      levelId = arguments['levelId'];
      moduleId = arguments['moduleId'];
      initialUnitId = arguments['unitId'];
      isFromCustomCourse = arguments['isFromCustomCourse'] ?? false;
      isFromStudyPlan = arguments['isFromStudyPlan'] ?? false;
      isSelectModule = arguments['isSelectModule'] ?? false;
      _initialScrollLevelId = arguments['scrollToLevelId'] ?? levelId;
      _initialScrollModuleId = arguments['scrollToModuleId'] ?? moduleId;
      showRecommend = arguments['showRecommend'] ?? false;
      showUnit = arguments['showUnit'] ?? false;
      scrollToStudyZoneEnum = arguments['scrollToStudyZoneEnum'];
      autoOpenDetail = arguments['autoOpenDetail'] ?? false;
      autoOpenLevelId = arguments['autoOpenLevelId'] ?? levelId;
      autoOpenModuleId = arguments['autoOpenModuleId'] ?? moduleId;
      initialMode = _parseInitialMode(arguments['initialMode']);
      pageMode.value = initialMode;
      recentVisitedUnitId.value = initialUnitId;

      initBreadcrumb(
        tagText,
        title: isManageMode ? _manageBreadcrumbTitle : _browseBreadcrumbTitle,
      );
      loadLevelTree();
    } else {
      initBreadcrumb(tagText, title: _browseBreadcrumbTitle);
      isPageLoading.value = false;
    }
  }

  OfficialCourseDetailsPageMode _parseInitialMode(dynamic rawMode) {
    if (rawMode == OfficialCourseDetailsPageMode.manage) {
      return OfficialCourseDetailsPageMode.manage;
    }
    if (rawMode is String && rawMode.toLowerCase() == 'manage') {
      return OfficialCourseDetailsPageMode.manage;
    }
    return OfficialCourseDetailsPageMode.browse;
  }

  bool get isManageMode =>
      pageMode.value == OfficialCourseDetailsPageMode.manage;
  bool get enteredDirectlyInManageMode =>
      initialMode == OfficialCourseDetailsPageMode.manage;

  String get _browseBreadcrumbTitle =>
      courseTitle.value.isNotEmpty ? courseTitle.value : breadcrumbTitle;

  String get _manageBreadcrumbTitle => '编辑教材';

  void _syncBreadcrumbTitle() {
    updateBreadcrumbTitle(
      isManageMode ? _manageBreadcrumbTitle : _browseBreadcrumbTitle,
    );
  }

  Future<void> enterManageMode() async {
    captureBrowseContext();
    expandedModuleId.value = null;
    pageMode.value = OfficialCourseDetailsPageMode.manage;
    _syncBreadcrumbTitle();
    if (Get.isRegistered<CustomCourseManageGradeController>(tag: tagText)) {
      final manageController = Get.find<CustomCourseManageGradeController>(tag: tagText);
      await manageController.prepareManageMode(
        targetLevelId: browseRestoreLevelId ?? levelId,
        targetModuleId: manageAnchorModuleId ?? browseRestoreExpandedModuleId ?? moduleId,
        targetOffsetDelta: manageAnchorOffsetDelta,
      );
    }
  }

  _BrowseAnchor? _resolveBrowseAnchor() {
    if (!scrollController.hasClients || moduleItems.isEmpty) return null;
    final double currentOffset = scrollController.offset;
    ModuleListItem? targetItem;
    double? targetOffset;
    for (final item in moduleItems) {
      final int? currentModuleId = item.module?.moduleId;
      if (currentModuleId == null) continue;
      final double? itemOffset = _getModuleScrollOffset(currentModuleId);
      if (itemOffset == null) continue;
      if (itemOffset <= currentOffset + moduleHeaderGap) {
        targetItem = item;
        targetOffset = itemOffset;
        continue;
      }
      break;
    }
    targetItem ??= moduleItems.firstOrNull;
    final int? fallbackModuleId = targetItem?.module?.moduleId;
    if (targetItem == null || fallbackModuleId == null) return null;
    targetOffset ??= _getModuleScrollOffset(fallbackModuleId) ?? currentOffset;
    return _BrowseAnchor(
      levelId: targetItem.levelId,
      moduleId: fallbackModuleId,
      offsetDelta: (currentOffset - targetOffset).clamp(0, double.infinity),
    );
  }

  void exitManageMode() {
    pageMode.value = OfficialCourseDetailsPageMode.browse;
    _syncBreadcrumbTitle();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      restoreBrowseContext();
    });
  }

  Future<void> finishManageMode() async {
    exitManageMode();
    await loadLevelTree(
      force: true,
      showPageLoading: false,
      showGlobalLoading: false,
      preserveBrowseContext: true,
    );
  }

  Future<void> completeManageAction() async {
    if (enteredDirectlyInManageMode) {
      Get.back();
      return;
    }
    await finishManageMode();
  }

  Future<void> syncManageModeFromDetails({
    required int? targetLevelId,
    required int? targetModuleId,
  }) async {
    if (!isManageMode) return;
    levelId = targetLevelId ?? levelId;
    moduleId = targetModuleId ?? moduleId;
    if (!Get.isRegistered<CustomCourseManageGradeController>(tag: tagText)) {
      return;
    }
    final manageController =
        Get.find<CustomCourseManageGradeController>(tag: tagText);
    await manageController.prepareManageMode(
      targetLevelId: levelId,
      targetModuleId: moduleId,
    );
  }

  void captureBrowseContext() {
    browseRestoreLevelId = activeLevelId.value == -1
        ? (_initialScrollLevelId ?? visibleLevels.firstOrNull?.levelId ?? levelId)
        : activeLevelId.value;
    browseRestoreExpandedModuleId = expandedModuleId.value;
    shouldRestoreExpandedModule = browseRestoreExpandedModuleId != null;
    final _BrowseAnchor? anchor = _resolveBrowseAnchor();
    if (anchor != null) {
      manageAnchorModuleId = anchor.moduleId;
      manageAnchorOffsetDelta = anchor.offsetDelta;
        browseRestoreLevelId ??= anchor.levelId;
      return;
    }
    manageAnchorModuleId = browseRestoreExpandedModuleId ?? moduleId;
    manageAnchorOffsetDelta = 0;
  }

  void restoreBrowseContext() {
    final int? targetLevelId =
        browseRestoreLevelId ?? _initialScrollLevelId ?? levelId;
    if (targetLevelId != null) {
      scrollToLevel(targetLevelId);
    }

    final int? targetModuleId = browseRestoreExpandedModuleId;
    if (shouldRestoreExpandedModule &&
        _isModuleInLevel(targetModuleId, targetLevelId)) {
      expandedModuleId.value = targetModuleId;
      scrollToModule(targetModuleId);
      return;
    }
    expandedModuleId.value = null;
  }

  bool _isModuleInLevel(int? moduleId, int? targetLevelId) {
    if (moduleId == null || targetLevelId == null) return false;
    final CourseLevelTreeLevel? targetLevel = levels.firstWhereOrNull(
      (level) => level.levelId == targetLevelId,
    );
    if (targetLevel == null) return false;
    return getDisplayableModules(targetLevel)
        .any((module) => module.moduleId == moduleId);
  }

  /// 获取等级-模块-单元树形数据
  Future<void> loadLevelTree({
    bool force = false,
    bool showPageLoading = true,
    bool showGlobalLoading = true,
    bool preserveBrowseContext = false,
  }) async {
    if(!HttpAuthUtils.instance.isAuth(HttpAuthCodes.memberCourseLevelModuleUnitList)) return;
    if (courseId == null) return;
    final id = courseId!;
    if (showPageLoading) {
      isPageLoading.value = true;
    }
    try {
      if (showGlobalLoading) {
        ToastUtils.showLoading();
      }
      CourseLevelTreeEntity? resp =
          await OfficialCourseDetailsLevelRequest.getCourseLevelModuleUnitTree(
              id);
      if (resp == null) return;
      _applyLevelTree(resp, preserveBrowseContext: preserveBrowseContext);
      _syncBreadcrumbTitle();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _tryAutoOpenDetail();
      });
    } finally {
      if (showPageLoading) {
        isPageLoading.value = false;
      }
      if (showGlobalLoading) {
        ToastUtils.hideLoading();
      }
    }
  }

  void _applyLevelTree(
    CourseLevelTreeEntity resp, {
    bool preserveBrowseContext = false,
  }) {
    courseLevelTree.value = resp;
    courseTitle.value = resp.courseName ?? '';
    final list = resp.levels;
    levels
      ..clear()
      ..addAll((list ?? const <CourseLevelTreeLevel?>[]).whereType<CourseLevelTreeLevel>());
    _refreshModuleItems();
    if (preserveBrowseContext) {
      if (!_containsModule(expandedModuleId.value)) {
        expandedModuleId.value = null;
      }
    } else if (showUnit) {
      expandedModuleId.value = _initialScrollModuleId ?? moduleItems.firstOrNull?.module?.moduleId;
    } else if (autoOpenDetail) {
      final targetModuleId = autoOpenModuleId ?? moduleId ?? _initialScrollModuleId;
      if (_containsModule(targetModuleId)) {
        expandedModuleId.value = targetModuleId;
      }
    } else if (!_containsModule(expandedModuleId.value)) {
      expandedModuleId.value = null;
    }
    if (recentVisitedUnitId.value == null) {
      recentVisitedUnitId.value = _resolveInitialRecentVisitedUnitId();
    }
    if (levels.isEmpty) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (preserveBrowseContext) {
        restoreBrowseContext();
        return;
      }
      final targetModuleId = _initialScrollModuleId;
      if (targetModuleId != null && scrollToModule(targetModuleId)) {
        return;
      }
      final target = _initialScrollLevelId;
      if (target != null) {
        scrollToLevel(target);
        return;
      }
      _syncActiveLevelByScroll();
    });
  }

  double getModuleProgress(CourseLevelTreeModule module) {
    final progress = module.progress ?? 0;
    if (progress <= 0) return 0;
    if (progress <= 1) {
      return (progress * 100).clamp(0, 100);
    }
    return progress.clamp(0, 100).toDouble();
  }

  void onModuleTap(CourseLevelTreeLevel level, CourseLevelTreeModule module) {
    if (courseId == null || level.levelId == null || module.moduleId == null) {
      return;
    }
    if (_shouldReturnUnitOnly) {
      return;
    }
    if(!HttpAuthUtils.instance.isAuth(HttpAuthCodes.memberCourseLevelModuleLessonList)) {
      ToastUtils.showToast(text: "无权限");
      return;
    }
    TagRoutes.toNamed(
      Routes.OFFICIAL_COURSE_DETAILS,
      arguments: {
        "courseId": courseId,
        "levelId": level.levelId,
        "moduleId": module.moduleId,
        "isSwitchCourse": false,
        "goCustomCourseProgress": false,
      },
    );
  }

  Future<void> _tryAutoOpenDetail() async {
    
    if (_autoOpenedDetail || !autoOpenDetail) return;
    if (courseId == null) return;
    final int? targetLevelId = autoOpenLevelId ?? levelId;
    final int? targetModuleId = autoOpenModuleId ?? moduleId;
    if (targetLevelId == null || targetModuleId == null) return;
    final int? targetUnitId = _resolveAutoOpenUnitId(targetModuleId);
    _setActiveLevel(targetLevelId);
    if (_containsModule(targetModuleId)) {
      expandedModuleId.value = targetModuleId;
    }
    markRecentVisitedUnit(targetUnitId);

    if(!HttpAuthUtils.instance.isAuth(HttpAuthCodes.memberCourseLevelModuleLessonList)) {
      ToastUtils.showToast(text: "无权限");
      return;
    }

    _autoOpenedDetail = true;
    final dynamic pageRes = await TagRoutes.toNamed(
      Routes.OFFICIAL_COURSE_DETAILS,
      arguments: {
        "courseId": courseId,
        "levelId": targetLevelId,
        "moduleId": targetModuleId,
        "unitId": targetUnitId,
        "isSwitchCourse": false,
        "goCustomCourseProgress": false,
      },
    );
    _applyDetailReturnSelection(pageRes);
    if (isClosed) return;
    await loadLevelTree(
      force: true,
      showPageLoading: false,
      showGlobalLoading: false,
      preserveBrowseContext: true,
    );
    if (pageRes is Map && pageRes['type'] == 0 && Get.currentRoute == Routes.OFFICIAL_COURSE_DETAILS_LEVEL) {
      Get.back(result: pageRes);
    }
  }

  Future<void> onUnitTap(CourseLevelTreeLevel level, CourseLevelTreeModule module,
      CourseLevelTreeUnit unit) async {
    if (courseId == null ||
        level.levelId == null ||
        module.moduleId == null ||
        unit.unitId == null) {
      return;
    }
    markRecentVisitedUnit(unit.unitId);
    if (isFromStudyPlan == true) {
      final unitName = _preferZh(unit.unitTitle) ?? unit.unitName;
      Get.back(
        result: {
          "courseId": courseId,
          "courseName": courseTitle.value,
          "levelId": level.levelId,
          "levelName": level.name,
          "moduleId": module.moduleId,
          "moduleName": module.name,
          "unitId": unit.unitId,
          "unitName": unitName,
        },
      );
      return;
    }
    final bool selecting = isSelectModule == true;
    if (selecting) {
      final unitName = _preferZh(unit.unitTitle) ?? unit.unitName;
      Get.back(
        result: {
          "courseId": courseId,
          "courseName": courseTitle.value,
          "levelId": level.levelId,
          "levelName": level.name,
          "moduleId": module.moduleId,
          "moduleName": module.name,
          "unitId": unit.unitId,
          "unitName": unitName,
        },
      );
      return;
    }
    browseRestoreLevelId = level.levelId;
    browseRestoreExpandedModuleId = module.moduleId;
    shouldRestoreExpandedModule = true;
    if(!HttpAuthUtils.instance.isAuth(HttpAuthCodes.memberCourseLevelModuleLessonList)) {
      ToastUtils.showToast(text: "无权限");
      return;
    }
    final dynamic pageRes = await TagRoutes.toNamed(
      Routes.OFFICIAL_COURSE_DETAILS,
      arguments: {
        "courseId": courseId,
        "levelId": level.levelId,
        "moduleId": module.moduleId,
        "unitId": unit.unitId,
        "isSwitchCourse": false,
        "goCustomCourseProgress": false,
      },
    );
    _applyDetailReturnSelection(pageRes);
    if (isClosed) return;
    await loadLevelTree(
      force: true,
      showPageLoading: false,
      showGlobalLoading: false,
      preserveBrowseContext: true,
    );
  }

  void _applyDetailReturnSelection(dynamic pageRes) {
    if (pageRes is! Map) return;
    final int? nextLevelId = pageRes['levelId'];
    final int? nextModuleId = pageRes['moduleId'];
    final int? nextUnitId = pageRes['unitId'];
    if (nextLevelId != null) {
      browseRestoreLevelId = nextLevelId;
      _initialScrollLevelId = nextLevelId;
    }
    if (nextModuleId != null) {
      browseRestoreExpandedModuleId = nextModuleId;
      shouldRestoreExpandedModule = true;
      _initialScrollModuleId = nextModuleId;
    }
    if (nextUnitId != null) {
      markRecentVisitedUnit(nextUnitId);
    }
  }

  void markRecentVisitedUnit(int? unitId) {
    if (unitId == null) return;
    recentVisitedUnitId.value = unitId;
  }

  bool isRecentVisitedUnit(int? unitId) {
    if (unitId == null) return false;
    return recentVisitedUnitId.value == unitId;
  }

  int? _resolveInitialRecentVisitedUnitId() {
    if (initialUnitId != null) return initialUnitId;
    if (!autoOpenDetail) return null;
    final targetModuleId = autoOpenModuleId ?? moduleId ?? _initialScrollModuleId;
    return _resolveAutoOpenUnitId(targetModuleId);
  }

  int? _resolveAutoOpenUnitId(int? targetModuleId) {
    if (initialUnitId != null) return initialUnitId;
    if (targetModuleId == null) return null;
    final targetItem = moduleItems.firstWhereOrNull(
      (item) => item.module?.moduleId == targetModuleId,
    );
    final units = targetItem?.module?.units ?? const <CourseLevelTreeUnit?>[];
    return units.whereType<CourseLevelTreeUnit>().firstOrNull?.unitId;
  }

  String? _preferZh(List<LanguageText?>? texts) {
    if (texts == null) return null;
    for (final item in texts) {
      if (item == null) continue;
      if (item.lang == "zh" && (item.text?.isNotEmpty ?? false)) {
        return item.text;
      }
    }
    for (final item in texts) {
      if (item == null) continue;
      if (item.text?.isNotEmpty ?? false) {
        return item.text;
      }
    }
    return null;
  }

  void toggleUnitsExpanded() {
    final anchor = _captureScrollAnchor();
    if (expandedModuleId.value != null) {
      expandedModuleId.value = null;
    } else {
      expandedModuleId.value = _findPreferredExpandableModuleId();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restoreScrollAnchor(anchor);
    });
  }

  void toggleModuleExpanded(int? moduleId) {
    if (moduleId == null) return;
    final anchor = _captureScrollAnchor();
    expandedModuleId.value = expandedModuleId.value == moduleId ? null : moduleId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restoreScrollAnchor(anchor);
    });
  }

  bool isModuleExpanded(int? moduleId) {
    if (moduleId == null) return false;
    return expandedModuleId.value == moduleId;
  }

  _LevelScrollAnchor? _captureScrollAnchor() {
    if (!scrollController.hasClients || levels.isEmpty) return null;
    final currentOffset = scrollController.offset;
    final currentLevelId =
        activeLevelId.value == -1 ? levels.first.levelId : activeLevelId.value;
    if (currentLevelId == null || currentLevelId == -1) {
      return _LevelScrollAnchor(levelId: null, offsetDelta: currentOffset);
    }
    final headerOffset = _getHeaderScrollOffset(currentLevelId);
    if (headerOffset == null) {
      return _LevelScrollAnchor(levelId: currentLevelId, offsetDelta: 0);
    }
    return _LevelScrollAnchor(
      levelId: currentLevelId,
      offsetDelta: (currentOffset - headerOffset).clamp(0.0, double.infinity),
    );
  }

  Future<void> _restoreScrollAnchor(_LevelScrollAnchor? anchor, {int retry = 0}) async {
    if (isClosed) return;
    if (!scrollController.hasClients) {
      if (retry >= 8) {
        _syncActiveLevelByScroll();
        return;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _restoreScrollAnchor(anchor, retry: retry + 1);
      });
      return;
    }
    if (anchor == null) {
      _syncActiveLevelByScroll();
      return;
    }
    final levelId = anchor.levelId;
    if (levelId == null || levelId == -1) {
      final target = anchor.offsetDelta
          .clamp(0.0, scrollController.position.maxScrollExtent);
      scrollController.jumpTo(target);
      _syncActiveLevelByScroll();
      return;
    }
    final headerOffset = _getHeaderScrollOffset(levelId);
    if (headerOffset == null) {
      if (retry >= 8) {
        _syncActiveLevelByScroll();
        return;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _restoreScrollAnchor(anchor, retry: retry + 1);
      });
      return;
    }
    final maxOffset = scrollController.position.maxScrollExtent;
    final targetOffset =
        (headerOffset + anchor.offsetDelta).clamp(0.0, maxOffset);
    _programmaticScrolling = true;
    scrollController.jumpTo(targetOffset);
    _finishProgrammaticScroll();
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
    if (!scrollController.hasClients) {
      if (retry >= 8) {
        _finishProgrammaticScroll();
        return;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToLevelHeader(levelId, retry: retry + 1);
      });
      return;
    }
    final targetOffset = _getHeaderScrollOffset(levelId);
    if (targetOffset != null) {
      final maxOffset = scrollController.position.maxScrollExtent;
      scrollController
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

  double? _getHeaderScrollOffset(int levelId) {
    final ctx = _levelHeaderKeysById[levelId]?.currentContext;
    if (ctx == null || !ctx.mounted || !scrollController.hasClients) {
      return null;
    }
    final renderObject = ctx.findRenderObject();
    if (renderObject == null || !renderObject.attached) return null;
    final viewport = RenderAbstractViewport.of(renderObject);
    return viewport.getOffsetToReveal(renderObject, 0).offset;
  }

  GlobalKey getLevelHeaderKey(int levelId) {
    return _levelHeaderKeysById.putIfAbsent(levelId, GlobalKey.new);
  }

  GlobalKey getLevelTabKey(int levelId) {
    return _levelTabKeysById.putIfAbsent(levelId, GlobalKey.new);
  }

  GlobalKey getModuleKey(int moduleId) {
    return _moduleKeysById.putIfAbsent(moduleId, GlobalKey.new);
  }

  /// 编辑课程
  Future<void> editCourse(BuildContext context, {isStudyPlan = false}) async {
    if (courseId == null) return;

    bool isPwdRight = await ParentPasswordialog.show(
        context: context, isCheckHasPassword: false);
    if (!isPwdRight) return;
    await enterManageMode();
  }

  void _syncActiveLevelByScroll() {
    if (_programmaticScrolling) return;
    if (visibleLevels.isEmpty || !scrollController.hasClients) return;
    final probeOffset = scrollController.offset + (moduleHeaderHeight * 0.6);
    int? nextLevelId;
    for (final level in visibleLevels) {
      final id = level.levelId;
      if (id == null) continue;
      final headerOffset = _getHeaderScrollOffset(id);
      if (headerOffset == null) continue;
      if (headerOffset <= probeOffset) {
        nextLevelId = id;
        continue;
      }
      break;
    }
    nextLevelId ??= visibleLevels.first.levelId;
    if (nextLevelId != null && nextLevelId != activeLevelId.value) {
      _setActiveLevel(nextLevelId);
    }
  }

  void _refreshModuleItems() {
    final List<ModuleListItem> items = [];
    for (int levelIndex = 0; levelIndex < levels.length; levelIndex++) {
      final level = levels[levelIndex];
      final id = level.levelId ?? -1;
      final modules = (level.moduleList ?? const <CourseLevelTreeModule?>[])
          .whereType<CourseLevelTreeModule>()
          .where(_hasDisplayableUnits)
          .toList(growable: false);
      bool headerUsed = false;
      for (int moduleIndex = 0; moduleIndex < modules.length; moduleIndex++) {
        final module = modules[moduleIndex];
        items.add(
          ModuleListItem(
            levelId: id,
            levelIndex: levelIndex,
            levelName: level.name ?? '',
            module: module,
            showLevelHeader: !headerUsed,
          ),
        );
        headerUsed = true;
      }
    }
    moduleItems
      ..clear()
      ..addAll(items);
    if (!_containsModule(expandedModuleId.value)) {
      expandedModuleId.value = null;
    }
    final availableLevels = visibleLevels;
    if (availableLevels.isEmpty) {
      activeLevelId.value = -1;
      return;
    }
    final currentVisible = availableLevels.any((level) => level.levelId == activeLevelId.value);
    if (!currentVisible) {
      _setActiveLevel(availableLevels.first.levelId);
    }
  }

  bool hasDisplayableModules(CourseLevelTreeLevel level) {
    final modules = level.moduleList ?? const <CourseLevelTreeModule?>[];
    return modules.whereType<CourseLevelTreeModule>().any(_hasDisplayableUnits);
  }

  List<CourseLevelTreeModule> getDisplayableModules(CourseLevelTreeLevel level) {
    final modules = level.moduleList ?? const <CourseLevelTreeModule?>[];
    return modules.whereType<CourseLevelTreeModule>().where(_hasDisplayableUnits).toList(growable: false);
  }

  bool _hasDisplayableUnits(CourseLevelTreeModule module) {
    final units = module.units ?? const <CourseLevelTreeUnit?>[];
    return units.whereType<CourseLevelTreeUnit>().isNotEmpty;
  }

  bool _containsModule(int? moduleId) {
    if (moduleId == null) return false;
    return moduleItems.any((item) => item.module?.moduleId == moduleId);
  }

  int? _findPreferredExpandableModuleId() {
    final currentLevel = visibleLevels.firstWhereOrNull(
      (level) => level.levelId == activeLevelId.value,
    );
    final currentModules =
        currentLevel == null ? const <CourseLevelTreeModule>[] : getDisplayableModules(currentLevel);
    if (currentModules.isNotEmpty) {
      return currentModules.first.moduleId;
    }
    return moduleItems.firstOrNull?.module?.moduleId;
  }

  void _setActiveLevel(int? levelId) {
    if (levelId == null || levelId == -1) return;
    if (activeLevelId.value != levelId) {
      activeLevelId.value = levelId;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _centerActiveLevelTabIfNeeded(levelId);
    });
  }

  void _centerActiveLevelTabIfNeeded(int levelId) {
    if (isClosed || !levelTabScrollController.hasClients) return;
    final BuildContext? itemContext =
        _levelTabKeysById[levelId]?.currentContext;
    final BuildContext? viewportContext = levelTabViewportKey.currentContext;
    if (itemContext == null || viewportContext == null) return;
    final RenderObject? itemRenderObject = itemContext.findRenderObject();
    final RenderObject? viewportRenderObject =
        viewportContext.findRenderObject();
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
  }

  void _finishProgrammaticScroll() {
    Future.delayed(const Duration(milliseconds: 80), () {
      _programmaticScrolling = false;
      _syncActiveLevelByScroll();
    });
  }

  bool scrollToModule(int? targetModuleId) {
    if (targetModuleId == null) return false;
    final targetItem = moduleItems.firstWhereOrNull(
      (item) => item.module?.moduleId == targetModuleId,
    );
    if (targetItem == null) return false;
    _programmaticScrolling = true;
    _setActiveLevel(targetItem.levelId);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToModuleCard(targetModuleId);
    });
    return true;
  }

  void _scrollToModuleCard(int moduleId, {int retry = 0}) {
    if (isClosed) return;
    if (!scrollController.hasClients) {
      if (retry >= 8) {
        _finishProgrammaticScroll();
        return;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToModuleCard(moduleId, retry: retry + 1);
      });
      return;
    }
    final targetOffset = _getModuleScrollOffset(moduleId);
    if (targetOffset != null) {
      final maxOffset = scrollController.position.maxScrollExtent;
      scrollController
          .animateTo(
            targetOffset.clamp(0.0, maxOffset),
            duration: const Duration(milliseconds: 260),
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
      _scrollToModuleCard(moduleId, retry: retry + 1);
    });
  }

  double? _getModuleScrollOffset(int moduleId) {
    final ctx = _moduleKeysById[moduleId]?.currentContext;
    if (ctx == null || !ctx.mounted || !scrollController.hasClients) {
      return null;
    }
    final renderObject = ctx.findRenderObject();
    if (renderObject == null || !renderObject.attached) return null;
    final viewport = RenderAbstractViewport.of(renderObject);
    return viewport.getOffsetToReveal(renderObject, 0).offset - moduleHeaderGap;
  }

  @override
  void onClose() {
    scrollController.removeListener(_syncActiveLevelByScroll);
    scrollController.dispose();
    levelTabScrollController.dispose();
    super.onClose();
  }
}

class ModuleListItem {
  final int levelId;
  final int levelIndex;
  final String levelName;
  final CourseLevelTreeModule? module;
  final bool showLevelHeader;

  const ModuleListItem({
    required this.levelId,
    required this.levelIndex,
    required this.levelName,
    required this.module,
    required this.showLevelHeader,
  });
}

class _BrowseAnchor {
  final int levelId;
  final int moduleId;
  final double offsetDelta;

  const _BrowseAnchor({
    required this.levelId,
    required this.moduleId,
    required this.offsetDelta,
  });
}

class _LevelScrollAnchor {
  final int? levelId;
  final double offsetDelta;

  const _LevelScrollAnchor({
    required this.levelId,
    required this.offsetDelta,
  });
}
