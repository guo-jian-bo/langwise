import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/enum/enum.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/widgets/widgets.dart';

class OfficialCourseDetailsLevelController extends GetxController {
  static void invalidateCache({int? courseId}) {}

  int? courseId;
  int? levelId;
  int? moduleId;
  bool? isFromCustomCourse;
  bool? isFromStudyPlan;
  bool? isSelectModule;
  int? _initialScrollLevelId;
  int? _initialScrollModuleId;
  bool showUnit = false;

  final Map<int, GlobalKey> _levelHeaderKeysById = <int, GlobalKey>{};
  final Map<int, GlobalKey> _levelTabKeysById = <int, GlobalKey>{};
  final Map<int, GlobalKey> _moduleKeysById = <int, GlobalKey>{};

  /// 显示推荐起点
  bool showRecommend = false;

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
  final RxBool unitsExpanded = true.obs;
  final RxInt activeLevelId = (-1).obs;
  bool _programmaticScrolling = false;

  double get moduleHeaderHeight => 60.wMin;
  double get moduleHeaderGap => 12.wMin;
  double get moduleItemGap => 16.wMin;

  double get moduleCardBaseHeight => 370.wMin;
  int get unitGridCrossAxisCount => 5;
  double get unitGridCrossAxisSpacing => 18.wMin;
  double get unitGridMainAxisSpacing => 18.wMin;
  double get unitTileExtent => 220.wMin;
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
      courseId = Get.arguments['courseId'];
      levelId = Get.arguments['levelId'];
      moduleId = Get.arguments['moduleId'];
      isFromCustomCourse = Get.arguments['isFromCustomCourse'] ?? false;
      isFromStudyPlan = Get.arguments['isFromStudyPlan'] ?? false;
      isSelectModule = Get.arguments['isSelectModule'] ?? false;
      _initialScrollLevelId = Get.arguments['scrollToLevelId'] ?? levelId;
      _initialScrollModuleId = Get.arguments['scrollToModuleId'] ?? moduleId;
      showRecommend = Get.arguments['showRecommend'] ?? false;
      showUnit = Get.arguments['showUnit'] ?? false;
      scrollToStudyZoneEnum = Get.arguments['scrollToStudyZoneEnum'];

      loadLevelTree();
    }
  }

  /// 获取等级-模块-单元树形数据
  Future<void> loadLevelTree({bool force = false}) async {
    if (courseId == null) return;
    final id = courseId!;
    try {
      ToastUtils.showLoading();
      CourseLevelTreeEntity? resp =
          await OfficialCourseDetailsLevelRequest.getCourseLevelModuleUnitTree(
              id);
      if (resp == null) return;
      _applyLevelTree(resp);
    } finally {
      ToastUtils.hideLoading();
    }
  }

  void _applyLevelTree(CourseLevelTreeEntity resp) {
    courseLevelTree.value = resp;
    courseTitle.value = resp.courseName ?? '';
    final list = resp.levels;
    if (list == null || list.isEmpty) return;
    levels
      ..clear()
      ..addAll(list.whereType<CourseLevelTreeLevel>());
    _refreshModuleItems();
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    if (courseId == null || level.levelId == null || module.moduleId == null)
      return;
    if (_shouldReturnUnitOnly) {
      return;
    }
    Get.toNamed(
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

  void onUnitTap(CourseLevelTreeLevel level, CourseLevelTreeModule module,
      CourseLevelTreeUnit unit) {
    if (courseId == null ||
        level.levelId == null ||
        module.moduleId == null ||
        unit.unitId == null) return;
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
    Get.toNamed(
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
    unitsExpanded.value = !(unitsExpanded.value);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restoreScrollAnchor(anchor);
    });
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

    final res = await Get.toNamed(
      Routes.CUSTOM_COURSE_MANAGE_GRADE,
      arguments: {
        "courseId": courseId,
        "levelId": levelId,
        "moduleId": moduleId,
        "isStudyPlan": isStudyPlan,
      },
    );
    final changed = (res is Map) && (res["changed"] == true);
    if (changed) {
      await loadLevelTree(force: true);
    }
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

  bool _hasDisplayableUnits(CourseLevelTreeModule module) {
    final units = module.units ?? const <CourseLevelTreeUnit?>[];
    return units.whereType<CourseLevelTreeUnit>().isNotEmpty;
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
    if (itemRenderObject is! RenderBox || viewportRenderObject is! RenderBox)
      return;
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

class _LevelScrollAnchor {
  final int? levelId;
  final double offsetDelta;

  const _LevelScrollAnchor({
    required this.levelId,
    required this.offsetDelta,
  });
}
