import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/utils/utils.dart';
import 'package:scrollview_observer/scrollview_observer.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/enum/enum.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/widgets/widgets.dart';

class OfficialCourseDetailsLevelController extends GetxController {
  static final Map<int, CourseLevelTreeEntity> _levelTreeCacheByCourseId = <int, CourseLevelTreeEntity>{};

  static void invalidateCache({int? courseId}) {
    if (courseId == null) return;
    _levelTreeCacheByCourseId.remove(courseId);
  }
  int? courseId;
  int? levelId;
  int? moduleId;
  bool? isFromCustomCourse;
  bool? isFromStudyPlan;
  bool? isSelectModule;
  int? _initialScrollLevelId;
  bool _reuseCache = false;
  bool showUnit = false;

  /// 显示推荐起点
  bool showRecommend = false;

  /// 提示次数
  int tipNum = 0;

  /// 滚动到对应的难度区域 [StudyZoneEnum]
  String? scrollToStudyZoneEnum;

  final ScrollController scrollController = ScrollController();

  final RxList<CourseLevelTreeLevel> levels = <CourseLevelTreeLevel>[].obs;
  final RxList<ModuleListItem> moduleItems = <ModuleListItem>[].obs;
  final Rx<CourseLevelTreeEntity> courseLevelTree = CourseLevelTreeEntity().obs;
  final RxString courseTitle = ''.obs;
  final RxBool unitsExpanded = true.obs;
  final RxInt activeLevelId = (-1).obs;
  bool _programmaticScrolling = false;
  final ListObserverController listObserverController = ListObserverController();
  int _dispatchObserveRetry = 0;
  int _animateToRetry = 0;

  double get _listVerticalPadding => 16.wMin;

  double get moduleHeaderHeight => 60.wMin;
  double get moduleHeaderGap => 12.wMin;
  double get moduleItemGap => 16.wMin;

  double get moduleCardBaseHeight => 390.wMin;
  int get unitGridCrossAxisCount => 5;
  double get unitGridCrossAxisSpacing => 18.wMin;
  double get unitGridMainAxisSpacing => 18.wMin;
  double get unitTileExtent => 220.wMin;
  double get unitGridPadding => 12.wMin * 2;
  double get knowledgeCountsHeight => 84.wMin;

  final Map<int, int> _firstModuleIndexByLevelId = <int, int>{};

  @override
  void onInit() {
    super.onInit();
    listObserverController.controller = scrollController;
    if (Get.arguments != null) {
      courseId = Get.arguments['courseId'];
      levelId = Get.arguments['levelId'];
      moduleId = Get.arguments['moduleId'];
      isFromCustomCourse = Get.arguments['isFromCustomCourse'] ?? false;
      isFromStudyPlan = Get.arguments['isFromStudyPlan'] ?? false;
      isSelectModule = Get.arguments['isSelectModule'] ?? false;
      _initialScrollLevelId = Get.arguments['scrollToLevelId'] ?? levelId;
      _reuseCache = Get.arguments['reuseCache'] ?? false;
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
    if (!force && _reuseCache) {
      final cached = _levelTreeCacheByCourseId[id];
      if (cached != null) {
        _applyLevelTree(cached);
        return;
      }
    }
    try {
      ToastUtils.showLoading();
      CourseLevelTreeEntity? resp = await OfficialCourseDetailsLevelRequest.getCourseLevelModuleUnitTree(id);
      if (resp == null) return;
      _levelTreeCacheByCourseId[id] = resp;
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
      _dispatchObserveOnce();
      final target = _initialScrollLevelId;
      if (target != null) {
        scrollToLevel(target);
      }
    });
  }

  void _dispatchObserveOnce() {
    if (isClosed) return;
    listObserverController.sliverContexts.removeWhere((c) => !c.mounted);
    if (listObserverController.sliverContexts.isEmpty) {
      listObserverController.innerReattachCallBack?.call();
      if (_dispatchObserveRetry >= 8) return;
      _dispatchObserveRetry += 1;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _dispatchObserveOnce();
      });
      return;
    }
    _dispatchObserveRetry = 0;
    try {
      listObserverController.dispatchOnceObserve(
        sliverContext: listObserverController.sliverContexts.last,
        isForce: true,
      );
    } catch (_) {
      listObserverController.innerReattachCallBack?.call();
      if (_dispatchObserveRetry >= 8) return;
      _dispatchObserveRetry += 1;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _dispatchObserveOnce();
      });
    }
  }

  double getModuleProgress(CourseLevelTreeModule module) {
    final u = module.units ?? [];
    if (u.isEmpty) return 0;
    double sum = 0;
    int count = 0;
    for (final item in u) {
      if (item == null) continue;
      sum += item.progress ?? 0;
      count += 1;
    }
    if (count == 0) return 0;
    return (sum / count * 100).clamp(0, 100);
  }

  void onModuleTap(CourseLevelTreeLevel level, CourseLevelTreeModule module) {
    if (courseId == null || level.levelId == null || module.moduleId == null) return;
    final bool selecting = isSelectModule == true;
    if (selecting) {
      Get.back(
        result: {
          "courseId": courseId,
          "courseName": courseTitle.value,
          "levelId": level.levelId,
          "levelName": level.name,
          "moduleId": module.moduleId,
          "moduleName": module.name,
        },
      );
      return;
    }
    final canPop = Get.key.currentState?.canPop() ?? false;
    if (canPop) {
      Get.back(
        result: {
          "courseId": courseId,
          "courseName": courseTitle.value,
          "levelId": level.levelId,
          "levelName": level.name,
          "moduleId": module.moduleId,
          "moduleName": module.name,
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

  void onUnitTap(CourseLevelTreeLevel level, CourseLevelTreeModule module, CourseLevelTreeUnit unit) {
    if (courseId == null || level.levelId == null || module.moduleId == null || unit.unitId == null) return;
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
    final canPop = Get.key.currentState?.canPop() ?? false;
    if (canPop) {
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
    unitsExpanded.value = !(unitsExpanded.value);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _dispatchObserveOnce();
    });
  }

  void scrollToLevel(int? levelId) {
    if (levelId == null) return;
    int index = _firstModuleIndexByLevelId[levelId] ?? -1;
    if (index < 0) {
      index = moduleItems.indexWhere((e) => e.levelId == levelId);
    }
    if (index < 0) return;
    _programmaticScrolling = true;
    activeLevelId.value = levelId;
    _safeScrollToLevelIndex(index);
  }

  void _safeScrollToLevelIndex(int index) {
    if (isClosed) return;
    listObserverController.sliverContexts.removeWhere((c) => !c.mounted);
    if (listObserverController.sliverContexts.isEmpty) {
      listObserverController.innerReattachCallBack?.call();
      if (_animateToRetry >= 8) {
        _animateToRetry = 0;
        _programmaticScrolling = false;
        return;
      }
      _animateToRetry += 1;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _safeScrollToLevelIndex(index);
      });
      return;
    }

    _animateToRetry = 0;
    try {
      listObserverController
          .animateTo(
            index: index,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            padding: EdgeInsets.only(top: _listVerticalPadding),
            alignment: 0,
            isFixedHeight: false,
            sliverContext: listObserverController.sliverContexts.last,
          )
          .whenComplete(() {
            Future.delayed(const Duration(milliseconds: 80), () {
              _programmaticScrolling = false;
            });
          });
    } catch (_) {
      listObserverController.innerReattachCallBack?.call();
      if (_animateToRetry >= 8) {
        _animateToRetry = 0;
        _programmaticScrolling = false;
        return;
      }
      _animateToRetry += 1;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _safeScrollToLevelIndex(index);
      });
    }
  }

  /// 编辑课程
  Future<void> editCourse(BuildContext context, {isStudyPlan = false}) async {
    if (courseId == null) return;

    bool isPwdRight = await ParentPasswordialog.show(context: context, isCheckHasPassword: false);
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

  void onListObserve(ListViewObserveModel model) {
    if (_programmaticScrolling) return;
    if (moduleItems.isEmpty) return;
    final idx = model.firstChild?.index;
    if (idx == null) return;
    if (idx < 0 || idx >= moduleItems.length) return;
    final id = moduleItems[idx].levelId;
    if (id != activeLevelId.value) {
      activeLevelId.value = id;
    }
  }

  void _refreshModuleItems() {
    final List<ModuleListItem> items = [];
    for (int levelIndex = 0; levelIndex < levels.length; levelIndex++) {
      final level = levels[levelIndex];
      final id = level.levelId ?? -1;
      final modules = level.moduleList ?? const <CourseLevelTreeModule?>[];
      bool headerUsed = false;
      for (int moduleIndex = 0; moduleIndex < modules.length; moduleIndex++) {
        final module = modules[moduleIndex];
        if (module == null) continue;
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
      if (!headerUsed) {
        items.add(
          ModuleListItem(
            levelId: id,
            levelIndex: levelIndex,
            levelName: level.name ?? '',
            module: null,
            showLevelHeader: true,
          ),
        );
      }
    }
    moduleItems
      ..clear()
      ..addAll(items);
    _firstModuleIndexByLevelId
      ..clear();
    for (int i = 0; i < items.length; i++) {
      final id = items[i].levelId;
      _firstModuleIndexByLevelId.putIfAbsent(id, () => i);
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
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
