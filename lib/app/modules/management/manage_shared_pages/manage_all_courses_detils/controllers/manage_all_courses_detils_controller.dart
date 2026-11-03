import 'package:api/entities/entities.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/common/stores/stores.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/utils.dart';

import '../../../../../../common/enum/enum.dart';
import '../../../../../routes/routes.dart';
import '../../../dialog/manage_create_relevance_level/view.dart';
import '../../../dialog/manage_create_relevance_module/view.dart';
import '../../../dialog/manage_phonics_create_module_dialog.dart';
import '../../../dialog/manage_edit_level/view.dart';
import '../../../dialog/manage_edit_module/view.dart';
import '../../../utils/utils.dart';
import '../views/manage_all_courses_level_sort_dialog.dart';

class ManageAllCoursesDetilsController extends GetxController with GetTickerProviderStateMixin, ManageBreadcrumbMixin {
  final String tag;
  ManageAllCoursesDetilsController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_ALL_COURSES_DETILS;

  @override
  String get breadcrumbTitle => '课程详情';

  TabController? tabController;
  final ScrollController levelScrollController = ScrollController();
  final ScrollController manageStorageScrollController = ScrollController();
  final List<GlobalKey> _levelTabKeys = <GlobalKey>[];

  CourseResponseEntity? courseInfo;
  final RxList<LevelResponseEntity> levelTabList = <LevelResponseEntity>[].obs;
  final RxInt tabCurrentIndex = 0.obs;
  final RxnInt expandedModuleId = RxnInt();
  final RxMap<int, List<ManageCourseSimpleUnitInfo>> moduleSimpleUnitMap = <int, List<ManageCourseSimpleUnitInfo>>{}.obs;
  final RxMap<int, bool> moduleSimpleUnitLoadingMap = <int, bool>{}.obs;
  final RxBool isManageMode = false.obs;
  final RxList<ModuleResponseEntity> manageTopModuleList = <ModuleResponseEntity>[].obs;
  final Map<int, int> _moduleExpandTapAtMap = <int, int>{};
  final Map<int, int?> _manageTopSourceLevelIdMap = <int, int?>{};
  int? manageDraggingFromLevelIndex;
  int? manageDraggingFromItemIndex;
  bool isManageDraggingFromTop = false;
  bool _hasPendingManageModuleChanges = false;

  final TextEditingController moduleIdSearchController = TextEditingController();
  final TextEditingController bookIdSearchController = TextEditingController();
  final TextEditingController moduleNameSearchController = TextEditingController();
  final TextEditingController moduleDescSearchController = TextEditingController();
  final TextEditingController moduleKeywordSearchController = TextEditingController();
  final RxInt moduleSearchRevision = 0.obs;

  final GlobalKey sortGlobalKey = GlobalKey(debugLabel: 'manage_sort_popup_anchor');

  int? _courseOrLevelUid;
  String? _language;
  String? get language => _language;

  // 从等级列表过来, 隐藏新增单元控件
  bool isFromLevel = false;
  bool get isHideHeader => isFromLevel;

  Worker? _moduleUpdateWorker;
  bool _isAnimatingToLevel = false;

  void onModuleSearch() {
    moduleSearchRevision.value++;
  }

  bool get isModuleSearching {
    final int _ = moduleSearchRevision.value;
    return moduleIdSearchController.text.trim().isNotEmpty ||
        bookIdSearchController.text.trim().isNotEmpty ||
        moduleNameSearchController.text.trim().isNotEmpty ||
        moduleDescSearchController.text.trim().isNotEmpty ||
        moduleKeywordSearchController.text.trim().isNotEmpty;
  }

  List<String> _splitKeywords(String input) {
    final txt = input.trim();
    if (txt.isEmpty) return const <String>[];
    return txt
        .split(RegExp(r'[,，\s]+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  List<ModuleResponseEntity> getFilteredModules(LevelResponseEntity levelEntity) {
    final int _ = moduleSearchRevision.value;
    final rawList = levelEntity.moduleDTOList ?? const [];
    final modules = rawList.whereType<ModuleResponseEntity>().toList();
    if (!isModuleSearching) return modules;

    final uidKeys = _splitKeywords(moduleIdSearchController.text);
    final bookIdKeys = _splitKeywords(bookIdSearchController.text);
    final nameKey = moduleNameSearchController.text.trim().toLowerCase();
    final descKey = moduleDescSearchController.text.trim().toLowerCase();
    final keywordKeys = _splitKeywords(moduleKeywordSearchController.text).map((e) => e.toLowerCase()).toList();

    return modules.where((m) {
      final uid = m.uid.toString();
      final bookId = (m.bookId ?? '').toString();
      final name = (m.name ?? '').toLowerCase();
      final description = (m.description ?? '').toLowerCase();

      if (uidKeys.isNotEmpty && !uidKeys.any(uid.contains)) return false;
      if (bookIdKeys.isNotEmpty && !bookIdKeys.any(bookId.contains)) return false;
      if (nameKey.isNotEmpty && !name.contains(nameKey)) return false;
      if (descKey.isNotEmpty && !description.contains(descKey)) return false;
      if (keywordKeys.isNotEmpty) {
        final combined = '$uid $bookId $name $description';
        if (!keywordKeys.every((k) => combined.contains(k))) return false;
      }
      return true;
    }).toList();
  }

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);

    levelScrollController.addListener(_handleLevelScroll);

    // 监听单元更新通知，当有单元更新时刷新模块列表数据
    final courseUpdateStore = CourseUpdateStore.to;
    _moduleUpdateWorker = ever(courseUpdateStore.needRefreshModuleList, (needRefresh) {
      if (needRefresh) {
        _onFetchData();
        courseUpdateStore.moduleListRefreshed();
      }
    });

    final arguments = Get.arguments;
    _courseOrLevelUid = arguments?["uid"];
    _language = arguments?["language"];
    isFromLevel = arguments?["isFromLevel"] ?? false;

    _onFetchData();
  }

  // 获取数据
  void _onFetchData({bool isRefresh = false}) {
    if (isFromLevel) {
      // 从等级列表过来
      _onFetchModuleList(isRefresh: isRefresh);
    } else {
      // 从课程过来
      onFetchLevelModules();
    }
  }

  void onRefreshModuleImages() {
    _onFetchData(isRefresh: true);
  }

  List<ModuleResponseEntity> getLevelModules(LevelResponseEntity levelEntity) {
    final List rawList = levelEntity.moduleDTOList ?? const [];
    return rawList.whereType<ModuleResponseEntity>().toList();
  }

  LevelResponseEntity? getManageSourceLevelEntity(ModuleResponseEntity moduleEntity) {
    for (final LevelResponseEntity levelEntity in levelTabList) {
      final bool exists = getLevelModules(levelEntity).any((item) => item.uid == moduleEntity.uid);
      if (exists) return levelEntity;
    }
    final int? sourceLevelUid = _manageTopSourceLevelIdMap[moduleEntity.uid];
    if (sourceLevelUid == null) return null;
    for (final LevelResponseEntity levelEntity in levelTabList) {
      if (levelEntity.uid == sourceLevelUid) return levelEntity;
    }
    return null;
  }

  void enterManageMode() {
    expandedModuleId.value = null;
    manageTopModuleList.clear();
    _manageTopSourceLevelIdMap.clear();
    clearManageDragState();
    _hasPendingManageModuleChanges = false;
    isManageMode.value = true;
  }

  Future<void> exitManageMode(BuildContext context) async {
    if (manageTopModuleList.isNotEmpty) {
      final bool? res = await AskDialog.showUserCancelAsk(
        context: context,
        title: "存在未分配的模块",
        content: "暂存区内还有 ${manageTopModuleList.length} 个模块未拖回左侧。\n如果现在离开，本次管理态中的拖拽调整不会保存。",
        cancel: "仍然离开",
        define: "继续编辑",
        defineColor: const Color(0xFFF59E0B),
      );
      if (res == null || res) {
        return;
      }
      await _resetManageModeState();
      return;
    }

    if (_hasPendingManageModuleChanges) {
      final bool success = await _persistManageModuleChanges();
      if (!success) return;
    }
    await _resetManageModeState(reloadData: false);
  }

  Future<void> _resetManageModeState({bool reloadData = true}) async {
    isManageMode.value = false;
    manageTopModuleList.clear();
    _manageTopSourceLevelIdMap.clear();
    clearManageDragState();
    _hasPendingManageModuleChanges = false;
    if (reloadData) {
      _onFetchData(isRefresh: true);
    }
  }

  Future<bool> _persistManageModuleChanges() async {
    try {
      ToastUtils.showLoading();
      for (final LevelResponseEntity levelEntity in levelTabList) {
        final List<ModuleResponseEntity> modules = getLevelModules(levelEntity);
        final response = await LevelUtil.edit(
          uid: levelEntity.uid.toString(),
          config: RequestConfig(
            requireToken: true,
            data: {"moduleIds": modules.map((e) => e.uid).toList()},
          ),
        );
        if (response.data == null) {
          ToastUtils.showManageToast(text: response.message ?? "保存模块排序失败");
          return false;
        }
      }
      ToastUtils.showManageToast(text: "课程管理已保存");
      return true;
    } catch (e) {
      ToastUtils.showManageToast(text: "保存模块排序失败");
      if (kDebugMode) {
        print(e.toString());
      }
      return false;
    } finally {
      ToastUtils.hideLoading();
    }
  }

  void startManageDrag({
    int? levelIndex,
    int? itemIndex,
    required bool fromTop,
  }) {
    manageDraggingFromLevelIndex = levelIndex;
    manageDraggingFromItemIndex = itemIndex;
    isManageDraggingFromTop = fromTop;
  }

  void clearManageDragState() {
    manageDraggingFromLevelIndex = null;
    manageDraggingFromItemIndex = null;
    isManageDraggingFromTop = false;
  }

  bool isManageDraggingItem({
    required int? levelIndex,
    required int? itemIndex,
    required bool fromTop,
  }) {
    return manageDraggingFromLevelIndex == levelIndex &&
        manageDraggingFromItemIndex == itemIndex &&
        isManageDraggingFromTop == fromTop;
  }

  void moveManageModuleToTop(ModuleResponseEntity item, int insertIndex) {
    if (isManageDraggingFromTop) {
      if (manageDraggingFromItemIndex == null ||
          manageDraggingFromItemIndex! >= manageTopModuleList.length) {
        clearManageDragState();
        return;
      }
      final int sourceIndex = manageDraggingFromItemIndex!;
      final ModuleResponseEntity movingItem = manageTopModuleList.removeAt(sourceIndex);
      final int safeIndex = insertIndex.clamp(0, manageTopModuleList.length);
      final int targetIndex = sourceIndex < safeIndex ? safeIndex - 1 : safeIndex;
      manageTopModuleList.insert(targetIndex.clamp(0, manageTopModuleList.length), movingItem);
      manageTopModuleList.refresh();
      clearManageDragState();
      return;
    }

    if (manageDraggingFromLevelIndex == null ||
        manageDraggingFromItemIndex == null ||
        manageDraggingFromLevelIndex! >= levelTabList.length) {
      clearManageDragState();
      return;
    }
    final int sourceLevelIndex = manageDraggingFromLevelIndex!;
    final int sourceItemIndex = manageDraggingFromItemIndex!;
    final List<ModuleResponseEntity> sourceModules = getLevelModules(levelTabList[sourceLevelIndex]);
    if (sourceItemIndex >= sourceModules.length) {
      clearManageDragState();
      return;
    }
    final ModuleResponseEntity movingItem = sourceModules.removeAt(sourceItemIndex);
    _replaceLevelModules(sourceLevelIndex, sourceModules);
    _manageTopSourceLevelIdMap[movingItem.uid] = levelTabList[sourceLevelIndex].uid;
    final int safeIndex = insertIndex.clamp(0, manageTopModuleList.length);
    manageTopModuleList.insert(safeIndex, movingItem);
    manageTopModuleList.refresh();
    _hasPendingManageModuleChanges = true;
    clearManageDragState();
  }

  void moveManageModuleToLevel({
    required ModuleResponseEntity item,
    required int targetLevelIndex,
    required int targetIndex,
  }) {
    if (targetLevelIndex < 0 || targetLevelIndex >= levelTabList.length) {
      clearManageDragState();
      return;
    }
    final List<ModuleResponseEntity> targetModules = getLevelModules(levelTabList[targetLevelIndex]);
    final int safeInsertIndex = targetIndex.clamp(0, targetModules.length);

    if (isManageDraggingFromTop) {
      if (manageDraggingFromItemIndex == null ||
          manageDraggingFromItemIndex! >= manageTopModuleList.length) {
        clearManageDragState();
        return;
      }
      final int sourceIndex = manageDraggingFromItemIndex!;
      final ModuleResponseEntity movingItem = manageTopModuleList.removeAt(sourceIndex);
      targetModules.insert(safeInsertIndex, movingItem);
      _replaceLevelModules(targetLevelIndex, targetModules);
      _manageTopSourceLevelIdMap.remove(movingItem.uid);
      manageTopModuleList.refresh();
      _hasPendingManageModuleChanges = true;
      clearManageDragState();
      return;
    }

    if (manageDraggingFromLevelIndex == null ||
        manageDraggingFromItemIndex == null ||
        manageDraggingFromLevelIndex! >= levelTabList.length) {
      clearManageDragState();
      return;
    }

    final int sourceLevelIndex = manageDraggingFromLevelIndex!;
    final int sourceItemIndex = manageDraggingFromItemIndex!;
    final List<ModuleResponseEntity> sourceModules = getLevelModules(levelTabList[sourceLevelIndex]);
    if (sourceItemIndex >= sourceModules.length) {
      clearManageDragState();
      return;
    }
    final ModuleResponseEntity movingItem = sourceModules.removeAt(sourceItemIndex);
    if (sourceLevelIndex == targetLevelIndex) {
      final int adjustedIndex = sourceItemIndex < safeInsertIndex ? safeInsertIndex - 1 : safeInsertIndex;
      sourceModules.insert(adjustedIndex.clamp(0, sourceModules.length), movingItem);
      _replaceLevelModules(sourceLevelIndex, sourceModules);
    } else {
      targetModules.insert(safeInsertIndex, movingItem);
      _replaceLevelModules(sourceLevelIndex, sourceModules);
      _replaceLevelModules(targetLevelIndex, targetModules);
    }
    _hasPendingManageModuleChanges = true;
    clearManageDragState();
  }

  void _replaceLevelModules(int levelIndex, List<ModuleResponseEntity> modules) {
    final LevelResponseEntity currentLevel = levelTabList[levelIndex];
    levelTabList[levelIndex] = currentLevel.copyWith(
      moduleDTOList: modules,
      moduleIds: modules.map((e) => e.uid).toList(),
    );
    levelTabList.refresh();
  }

  // 课程等级及模块查询
  void onFetchLevelModules() async {
    if (_courseOrLevelUid == null) {
      ToastUtils.showManageToast(text: "uid为空");
      return;
    }

    try {
      ToastUtils.showLoading();
      final response = await CourseUtil.levelModules(
        uid: _courseOrLevelUid.toString(),
        config: RequestConfig(requireToken: true),
      );
      ToastUtils.hideLoading();
      levelTabList.value = response.data?.courseLevelList ?? [];
      _syncLevelTabKeys();
      courseInfo = response.data?.courseInfo;
      if (levelTabList.isNotEmpty) {
        tabController = TabController(vsync: this, length: levelTabList.length, initialIndex: tabCurrentIndex.value);
        addTabListener();
      }
    } catch (e) {
      ToastUtils.hideLoading();
      ToastUtils.showManageToast(text: "查询课程等级及模块失败");
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  // 等级模块列表
  void _onFetchModuleList({bool isRefresh = false}) async {
    if (_courseOrLevelUid == null) {
      ToastUtils.showManageToast(text: "levelUid为空");
      return;
    }

    try {
      ToastUtils.showLoading();
      final response = await LevelUtil.moduleList(
        levelId: _courseOrLevelUid,
        config: RequestConfig(requireToken: true),
      );
      ToastUtils.hideLoading();
      if (response.data != null) {
        levelTabList.value = [response.data!];
        _syncLevelTabKeys();
        if (levelTabList.isNotEmpty) {
          tabController?.dispose();
          tabController = TabController(
            initialIndex: tabCurrentIndex.value,
            vsync: this,
            length: levelTabList.length,
          );
          addTabListener();
        }
      } else {
        ToastUtils.showManageToast(text: response.message ?? "等级模块列表失败");
      }
    } catch (e) {
      ToastUtils.hideLoading();
      ToastUtils.showManageToast(text: "等级模块列表失败");
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  void addTabListener() {
    tabController?.addListener(() {
      tabCurrentIndex.value = tabController?.index ?? 0;
    });
  }

  void onLevelTabTap(int index) {
    scrollToLevel(index);
  }

  void scrollToLevel(int index) {
    if (index < 0 || index >= levelTabList.length) return;
    tabCurrentIndex.value = index;
    _ensureLevelTabVisibleByIndex(index);

    final ctx = levelTabList[index].globalKey.currentContext;
    if (ctx == null) return;
    final renderObject = ctx.findRenderObject();
    if (renderObject == null) return;

    final viewport = RenderAbstractViewport.of(renderObject);
    final offset = viewport.getOffsetToReveal(renderObject, 0).offset;
    _isAnimatingToLevel = true;
    levelScrollController
        .animateTo(
          offset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        )
        .whenComplete(() {
          _isAnimatingToLevel = false;
        });
  }

  void _handleLevelScroll() {
    if (_isAnimatingToLevel) return;
    if (levelTabList.isEmpty) return;
    if (!levelScrollController.hasClients) return;

    final currentOffset = levelScrollController.position.pixels;
    int activeIndex = 0;
    for (int i = 0; i < levelTabList.length; i++) {
      final ctx = levelTabList[i].globalKey.currentContext;
      if (ctx == null) continue;
      final renderObject = ctx.findRenderObject();
      if (renderObject == null) continue;
      final viewport = RenderAbstractViewport.of(renderObject);

      final offset = viewport.getOffsetToReveal(renderObject, 0).offset;
      if (currentOffset + 1 >= offset) {
        activeIndex = i;
      } else {
        break;
      }
    }

    if (activeIndex != tabCurrentIndex.value) {
      tabCurrentIndex.value = activeIndex;
      _ensureLevelTabVisibleByIndex(activeIndex);
    }
  }

  GlobalKey getLevelTabKey(int index) {
    if (index < 0) return GlobalKey();
    while (_levelTabKeys.length <= index) {
      _levelTabKeys.add(GlobalKey(debugLabel: 'manage_level_tab_$index'));
    }
    return _levelTabKeys[index];
  }

  void _syncLevelTabKeys() {
    final int targetLen = levelTabList.length;
    if (_levelTabKeys.length > targetLen) {
      _levelTabKeys.removeRange(targetLen, _levelTabKeys.length);
      return;
    }
    while (_levelTabKeys.length < targetLen) {
      _levelTabKeys.add(GlobalKey());
    }
  }

  void _ensureLevelTabVisibleByIndex(int index) {
    final ctx = getLevelTabKey(index).currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      alignment: 0.5,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
    );
  }

  // 添加级别
  Future<void> toAddLevel(BuildContext context) async {
    if (_courseOrLevelUid == null) {
      ToastUtils.showManageToast(text: "uid为空");
      return;
    }

    ManageCreateRelevanceLevelManager.show(
      context: context,
      courseId: _courseOrLevelUid!,
      language: _language,
      disableAssociationLevel: courseInfo?.specialty == SpecialtyEnum.EN_PHONICS,
      disableCopyLevel: courseInfo?.specialty == SpecialtyEnum.EN_PHONICS,
      initCreateWay: courseInfo?.specialty == SpecialtyEnum.EN_PHONICS ? 2 : 0,
      dataDisableCallback: (LevelResponseEntity targetLevelEntity) {
        bool isDisable = false;
        for (final LevelResponseEntity responseEntity in levelTabList) {
          if (responseEntity.hashCode == targetLevelEntity.hashCode) {
            isDisable = true;
            break;
          }
        }
        return isDisable;
      },
    )?.then((List<LevelResponseEntity?>? value) {
      if (value != null) {
        final validLevels = value.whereType<LevelResponseEntity>();
        if (validLevels.isNotEmpty) {
          for (var level in validLevels) {
            final jsonData = level.toJson();
            final convertedLevel = LevelResponseEntity<ModuleResponseEntity<dynamic>>.fromJson(
              jsonData,
              fromJson: (json) => ModuleResponseEntity.fromJson(json),
            );
            levelTabList.add(convertedLevel);
          }
          updateLevelList(isAddLevel: true);
        }
      }
    });
  }

  // 默认当前下标
  void updateLevelList({bool isAddLevel = false}) {
    if (levelTabList.isEmpty) return;
    while (tabCurrentIndex.value > levelTabList.length - 1) {
      tabCurrentIndex.value--;
    }

    if (isAddLevel) {
      tabCurrentIndex.value = levelTabList.length - 1;
    }
    _syncLevelTabKeys();
    tabController?.dispose();
    tabController = TabController(
      vsync: this,
      length: levelTabList.length,
      initialIndex: tabCurrentIndex.value,
    );
    addTabListener();
  }

  /// 显示排序弹窗
  Future<void> showSort(BuildContext context) async {
    if (levelTabList.isEmpty) return;
    await ManageAllCoursesLevelSortDialog.show(
      context,
      initialLevelList: [...levelTabList],
      onSave: (List<LevelResponseEntity> sortedLevelList) async {
        final bool success = await onSortLevel(sortedLevelList: sortedLevelList);
        if (!success) return false;
        levelTabList.value = sortedLevelList;
        updateLevelList();
        return true;
      },
    );
  }

  /// 跳转到模块详情
  Future<void> toModuleDetils(
    int? moduleId,
    String? moduleName, {
    required LevelResponseEntity levelEntity,
    int? unitUid,
    String? unitName,
  }) async {
    if(!ManageAuthUtils.isAuth(ManageAuthCode.courseModuleUnitLessonList)) return;
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_MODULE_DETILS,
      arguments: {
        "moduleId": moduleId,
        "moduleName": moduleName,
        "levelUid": levelEntity.uid,
        "language": _language,
        "unitUid": unitUid,
        "unitId": unitUid?.toString(),
        "unitName": unitName,
      },
    );
    // 返回后刷新数据
    _onFetchData(isRefresh: true);
  }

  /// 添加模块
  Future<void> toAddModule(BuildContext context, List moduleDTOList, {required LevelResponseEntity levelEntity}) async {
    if (courseInfo?.specialty == SpecialtyEnum.EN_PHONICS) {

      // 创建自然拼读课程的模块
      List<ModuleResponseEntity<dynamic>?>? res = await ManagePhonicsCreateModuleDialog.show(
        context: context,
        language: _language,
        levelUid: levelEntity.uid,
      );
      if (res == null) return;
      if (res.isEmpty) return;
      final validModules = res.whereType<ModuleResponseEntity>();
      if (validModules.isEmpty) return;
      levelEntity.moduleDTOList?.addAll(validModules);
      levelTabList.refresh();
      return;
    }

    // 创建普通课程的模块
    ManageCreateRelevanceModuleManager.show(
      context: context,
      levelUid: levelEntity.uid,
      language: _language,
      dataDisableCallback: (ModuleResponseEntity targetModuleEntity) {
        bool isDisable = false;
        for (final ModuleResponseEntity responseEntity in moduleDTOList) {
          if (responseEntity.hashCode == targetModuleEntity.hashCode) {
            isDisable = true;
            break;
          }
        }
        return isDisable;
      },
    )?.then((List<ModuleResponseEntity?>? value) {
      if (value != null) {
        final validModules = value.whereType<ModuleResponseEntity>();
        if (validModules.isNotEmpty) {
          levelEntity.moduleDTOList?.addAll(validModules);
          levelTabList.refresh();
        }
      }
    });
  }

  // 编辑模块
  Future<void> onEditModule(BuildContext context, int index, ModuleResponseEntity module, {required LevelResponseEntity levelEntity}) async {
    if (courseInfo?.specialty == SpecialtyEnum.EN_PHONICS) {
      List<ModuleResponseEntity<dynamic>?>? res = await ManagePhonicsCreateModuleDialog.show(
        context: context,
        language: _language,
        levelUid: levelEntity.uid,
        module: module,
      );
      if (res == null) return;
      if (res.isEmpty) return;
      final validModules = res.whereType<ModuleResponseEntity>();
      if (validModules.isEmpty) return;
      levelEntity.moduleDTOList?[index] = validModules.first;
      levelTabList.refresh();
      return;
    }
    ManageEditModule.show(context: context, moduleEntity: module)?.then((value) {
      if (value != null) {
        levelEntity.moduleDTOList?[index] = value;
        levelTabList.refresh();
      }
    });
  }

  // 编辑等级
  void onEditLevel(int index, LevelResponseEntity levelEntity) {
    ManageEditLevel.show(context: Get.context!, levelEntity: levelEntity)?.then((value) {
      if (value != null) {
        levelTabList[index] = levelEntity.copyWith(
          name: value.name,
          description: value.description,
          access: value.access,
        );
        levelTabList.refresh();
        updateLevelList();
      }
    });
  }

  // 删除等级
  Future<bool> onDeleteLevel(int index) async {
    bool isDel = false;
    if (_courseOrLevelUid == null) {
      ToastUtils.showManageToast(text: "uid为空");
      return isDel;
    }

    final List<LevelResponseEntity> oldLevels = [...levelTabList];
    oldLevels.removeAt(index);
    final List<int> ids = oldLevels.map((element) => element.uid).toList();
    if (ids.isEmpty) {
      ToastUtils.showManageToast(text: "等级不能为空");
      return isDel;
    }

    try {
      final response = await CourseUtil.edit(
        uid: _courseOrLevelUid.toString(),
        config: RequestConfig(
          requireToken: true,
          data: {"levelIds": ids},
        ),
      );
      if (response.data != null) {
        levelTabList.removeAt(index);
        updateLevelList();
        ToastUtils.showManageToast(text: "删除等级成功");
        isDel = true;
      } else {
        ToastUtils.showManageToast(text: response.message ?? "删除等级失败");
        isDel = false;
      }
    } catch (e) {
      ToastUtils.showManageToast(text: "删除等级失败");
      if (kDebugMode) {
        print(e.toString());
      }
      isDel = false;
    }

    return isDel;
  }

  // 删除等级下的模块
  void onDeleteModule(BuildContext context, int index, ModuleResponseEntity moduleEntity, {required LevelResponseEntity levelEntity}) async {
    final bool ask = await AskDialog.show(
      context: context,
      showLastCountdown: true,
      title: "温馨提示",
      content: "确定要删除${moduleEntity.name}吗？",
    );
    if (!ask) return;

    final List<ModuleResponseEntity> oldModules = [...levelEntity.moduleDTOList ?? []];
    oldModules.removeAt(index);

    final List<int> ids = oldModules.map((element) => element.uid).toList();
    if (ids.isEmpty) {
      ToastUtils.showManageToast(text: "模块不能为空");
      return;
    }

    try {
      final response = await LevelUtil.edit(
        uid: levelEntity.uid.toString(),
        config: RequestConfig(
          requireToken: true,
          data: {"moduleIds": ids},
        ),
      );
      if (response.data != null) {
        levelEntity.moduleDTOList?.removeAt(index);
        levelTabList.refresh();
        ToastUtils.showManageToast(text: "删除模块成功");
      } else {
        ToastUtils.showManageToast(text: response.message ?? "删模块失败");
      }
    } catch (e) {
      ToastUtils.showManageToast(text: "删除模块失败");
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  /// 展开unit
  Future<void> onExpandUnit(ModuleResponseEntity moduleEntity) async {
    final int? courseUid = courseInfo?.uid;
    final int moduleUid = moduleEntity.uid;
    if (courseUid == null) {
      ToastUtils.showManageToast(text: "课程uid为空");
      return;
    }
    if (_isModuleExpandTapThrottled(moduleUid)) {
      return;
    }

    if (expandedModuleId.value == moduleUid) {
      expandedModuleId.value = null;
      return;
    }

    if (moduleSimpleUnitMap.containsKey(moduleUid)) {
      expandedModuleId.value = moduleUid;
      return;
    }
    if (moduleSimpleUnitLoadingMap[moduleUid] == true) {
      return;
    }

    try {
      moduleSimpleUnitLoadingMap[moduleUid] = true;
      final dynamic response = await ModuleUtil.courseSimpleUnits(
        courseId: courseUid.toString(),
        moduleId: moduleUid.toString(),
        config: RequestConfig(requireToken: true),
      );
      final List<dynamic> rawList = _extractSimpleUnitList(response);
      moduleSimpleUnitMap[moduleUid] = rawList
          .whereType<Map>()
          .map((item) => ManageCourseSimpleUnitInfo.fromJson(Map<String, dynamic>.from(item)))
          .toList(growable: false);
      expandedModuleId.value = moduleUid;
    } catch (e) {
      ToastUtils.showManageToast(text: "展开unit失败");
      if (kDebugMode) {
        print(e.toString());
      }
    } finally {
      moduleSimpleUnitLoadingMap.remove(moduleUid);
    }
  }

  List<dynamic> _extractSimpleUnitList(dynamic response) {
    if (response is Map<String, dynamic>) {
      final dynamic data = response['data'];
      if (data is List) {
        return data;
      }
    }
    if (response is List) {
      return response;
    }
    return const <dynamic>[];
  }

  bool _isModuleExpandTapThrottled(int moduleUid) {
    final int now = DateTime.now().millisecondsSinceEpoch;
    final int? lastTapAt = _moduleExpandTapAtMap[moduleUid];
    if (lastTapAt != null && now - lastTapAt < 500) {
      return true;
    }
    _moduleExpandTapAtMap[moduleUid] = now;
    return false;
  }

  bool isModuleExpanded(int? moduleId) {
    if (moduleId == null) return false;
    return expandedModuleId.value == moduleId;
  }

  bool isModuleUnitLoading(int? moduleId) {
    if (moduleId == null) return false;
    return moduleSimpleUnitLoadingMap[moduleId] == true;
  }

  List<ManageCourseSimpleUnitInfo> getModuleSimpleUnits(int? moduleId) {
    if (moduleId == null) return const <ManageCourseSimpleUnitInfo>[];
    return moduleSimpleUnitMap[moduleId] ?? const <ManageCourseSimpleUnitInfo>[];
  }

  Future<void> onUnitTap(
    ModuleResponseEntity moduleEntity,
    LevelResponseEntity levelEntity,
    ManageCourseSimpleUnitInfo unitEntity,
  ) async {
    await toModuleDetils(
      moduleEntity.uid,
      moduleEntity.name,
      levelEntity: levelEntity,
      unitUid: unitEntity.uid,
      unitName: unitEntity.name,
    );
  }

  // 等级排序
  Future<bool> onSortLevel({List<LevelResponseEntity>? sortedLevelList}) async {
    if (_courseOrLevelUid == null) {
      ToastUtils.showManageToast(text: "uid为空");
      return false;
    }

    final List<LevelResponseEntity> targetList = sortedLevelList ?? [...levelTabList];
    final List<int> ids = targetList.map((element) => element.uid).toList();
    if (ids.isEmpty) {
      ToastUtils.showManageToast(text: "等级不能为空");
      return false;
    }

    try {
      final response = await CourseUtil.edit(
        uid: _courseOrLevelUid.toString(),
        config: RequestConfig(
          requireToken: true,
          data: {"levelIds": ids},
        ),
      );
      if (response.data != null) {
        ToastUtils.showManageToast(text: "等级排序成功");
        return true;
      } else {
        ToastUtils.showManageToast(text: "等级排序失败");
        return false;
      }
    } catch (e) {
      ToastUtils.showManageToast(text: "等级排序失败");
      if (kDebugMode) {
        print(e.toString());
      }
      return false;
    }
  }

  @override
  void onClose() {
    levelTabList.clear();
    tabController?.dispose();
    levelScrollController.dispose();
    manageStorageScrollController.dispose();
    _moduleUpdateWorker?.dispose();
    moduleIdSearchController.dispose();
    bookIdSearchController.dispose();
    moduleNameSearchController.dispose();
    moduleDescSearchController.dispose();
    moduleKeywordSearchController.dispose();
    _courseOrLevelUid = null;
    super.onClose();
  }
}

class ManageCourseSimpleUnitInfo {
  final int? uid;
  final String? name;
  final String? description;
  final ManageCourseSimpleUnitImageInfo? image;

  const ManageCourseSimpleUnitInfo({
    this.uid,
    this.name,
    this.description,
    this.image,
  });

  factory ManageCourseSimpleUnitInfo.fromJson(Map<String, dynamic> json) {
    return ManageCourseSimpleUnitInfo(
      uid: _parseJsonInt(json['uid']),
      name: json['name']?.toString(),
      description: json['description']?.toString(),
      image: json['image'] is Map<String, dynamic>
          ? ManageCourseSimpleUnitImageInfo.fromJson(json['image'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ManageCourseSimpleUnitImageInfo {
  final String? imageUrl;

  const ManageCourseSimpleUnitImageInfo({this.imageUrl});

  factory ManageCourseSimpleUnitImageInfo.fromJson(Map<String, dynamic> json) {
    return ManageCourseSimpleUnitImageInfo(
      imageUrl: json['imageUrl']?.toString(),
    );
  }
}

int? _parseJsonInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}
