import 'package:api/entities/entities.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/common/stores/stores.dart';
import 'package:langwise/utils/toast_utils.dart';

import '../../../../../../common/entities/entities.dart';
import '../../../../../../common/enum/enum.dart';
import '../../../../../../common/widgets/widgets.dart';
import '../../../../../routes/routes.dart';
import '../../../dialog/manage_edit_unit/view.dart';
import '../../../dialog/manage_edit_lesson/view.dart';
import '../../../utils/manage_breadcrumb_utils.dart';
import '../../../utils/manage_page_registry.dart';
import '../../../utils/utils.dart';

class ManageModuleDetilsController extends GetxController with GetTickerProviderStateMixin, ManageBreadcrumbMixin {
  final String tag;
  ManageModuleDetilsController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_MODULE_DETILS;

  @override
  String get breadcrumbTitle => _moduleName ?? '模块详情';

  TabController? tabController;
  final RxList<NewUnitResponseEntity> unitTabList = <NewUnitResponseEntity>[].obs;

  int tabCurrentIndex = 0;

  final GlobalKey sortGlobalKey = GlobalKey();

  int? _moduleId, _unitUid;
  String? _unitId;
  String? _moduleName, _language;

  // 从单元列表过来, 隐藏新增单元控件
  bool isFromUnit = false;
  bool get isHideHeader => isFromUnit;

  ModuleResponseEntity? moduleResponseEntity;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);

    final arguments = Get.arguments;
    _moduleId = arguments?["moduleId"];
    _moduleName = arguments?["moduleName"];
    _language = arguments?["language"];
    _unitUid = arguments?["unitUid"];
    _unitId = arguments?["unitId"] ?? '';
    isFromUnit = arguments?["isFromUnit"] ?? false;

    onFetchData();
  }

  // 获取数据
  void onFetchData({bool isRefresh = false}) {
    if (isFromUnit) {
      _onFetchLessonList(isRefresh: isRefresh);
    } else {
      _onFetchPages(isRefresh: isRefresh);
    }
  }

  void _onFetchPages({bool isRefresh = false}) async {
    if (_moduleId == null) {
      ToastUtils.showManageToast(text: "moduleId为空");
      return;
    }

    try {
      final response = await ModuleUtil.unitLessons(
        uid: _moduleId.toString(),
        config: RequestConfig(requireToken: true),
      );

      final List<NewUnitResponseEntity> unitEntities = response.data?.courseUnitList ?? [];
      moduleResponseEntity = response.data?.courseModuleInfo;

      for (var unit in unitEntities) {
        unit.lessonDTOList?.add(getAddLessonButton());
      }

      unitTabList.value = unitEntities;
      unitTabList.refresh();

      if (unitTabList.isNotEmpty) {
        final int? targetUnitUid = int.tryParse(_unitId ?? '');
        if (targetUnitUid != null) {
          final int idx = unitTabList.indexWhere((e) => e.uid == targetUnitUid);
          if (idx >= 0) {
            tabCurrentIndex = idx;
          }
        }

        if (tabCurrentIndex < 0) tabCurrentIndex = 0;
        if (tabCurrentIndex >= unitTabList.length) tabCurrentIndex = 0;
        tabController?.dispose();
        tabController = TabController(
          initialIndex: tabCurrentIndex,
          vsync: this,
          length: unitTabList.length,
        );
        addTabListener();
      }
    } catch (e) {
      ToastUtils.showManageToast(text: "查询单元课时列表失败");
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  void _onFetchLessonList({bool isRefresh = false}) async {
    if (_unitUid == null) {
      ToastUtils.showManageToast(text: "unitUid为空");
      return;
    }

    try {
      final response = await UnitUtil.lessonList(
        unitId: _unitUid,
        config: RequestConfig(requireToken: true),
      );
      if (response.data != null) {
        response.data!.lessonDTOList?.add(getAddLessonButton());
        unitTabList.value = [response.data!];
        unitTabList.refresh();
        if (unitTabList.isNotEmpty) {
          tabController?.dispose();
          tabController = TabController(
            initialIndex: tabCurrentIndex,
            vsync: this,
            length: unitTabList.length,
          );
          addTabListener();
        }
      } else {
        ToastUtils.showManageToast(text: response.message ?? "单元课时列表失败");
      }
    } catch (e) {
      ToastUtils.showManageToast(text: "单元课时列表失败");
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  void addTabListener() {
    tabController?.addListener(() {
      tabCurrentIndex = tabController?.index ?? 0;
    });
  }

  // 添加单元
  Future<void> toAddUnit(BuildContext context) async {
    final NewUnitResponseEntity<LessonResponseEntity>? value = await AddUnitDialog.show(
      context: context,
      moduleId: _moduleId,
      language: _language,
      hidsDifficulty: moduleResponseEntity?.specialty == SpecialtyEnum.EN_PHONICS,
    );
    if (value != null) {
      unitTabList.add(value);
      unitTabList.refresh();
      updateUnitList(isAddUnit: true);
      final know = await onAddKnowledge(context, value);
      if (know) {
        _onCreateLesson(context, value);
      }
    }
  }

  void updateUnitList({bool isAddUnit = false}) {
    if (unitTabList.isEmpty) return;
    while (tabCurrentIndex > unitTabList.length - 1) {
      tabCurrentIndex--;
    }

    if (isAddUnit) {
      tabCurrentIndex = unitTabList.length - 1;
    }
    tabController?.dispose();
    tabController = TabController(
      vsync: this,
      length: unitTabList.length,
      initialIndex: tabCurrentIndex,
    );
    addTabListener();
  }

  /// 显示排序弹窗
  void showSort(BuildContext context) {
    final List<SortPopupEntity> list = unitTabList.map((e) => SortPopupEntity(e.name ?? '')).toList();
    SortPopupWindow.show(
      context: context,
      globalKey: sortGlobalKey,
      list: list,
      onReorder: (oldIndex, newIndex) {
        final NewUnitResponseEntity row = unitTabList.removeAt(oldIndex);
        unitTabList.insert(newIndex, row);
        updateUnitList();
        onSortLevel();
      },
      onDel: (index) async {
        
        final NewUnitResponseEntity row = unitTabList[index];
        final bool ask = await AskDialog.show(
          context: context,
          showLastCountdown: true,
          title: "温馨提示",
          content: "确定要删除${row.name}吗？",
        );
        if (ask) {
          return await onDeleteLevel(index);
        } else {
          return false;
        }
      },
    );
  }

  // 管理知识点列表
  Future<bool> onAddKnowledge(BuildContext context, NewUnitResponseEntity unitEntity) async {
    dynamic res = await Get.toNamed(
      Routes.OFFICIAL_COURSE_DETAILS_TARGET,
      arguments: {
        "moduleId": _moduleId,
        "unitId": unitEntity.uid,
        "isAdminPage": true,
        "language": _language,
      },
    );
    if (res != true) return false;
    onFetchData(isRefresh: true);
    return true;
  }

  // 编辑单元
  void onEditUnit(int unitIndex, NewUnitResponseEntity unitEntity) {
    ManageEditUnitDialog.show(
      context: Get.context!,
      unitEntity: unitEntity,
      hidsDifficulty: moduleResponseEntity?.specialty == SpecialtyEnum.EN_PHONICS,
    )?.then((value) {
      if (value != null) {
        unitTabList[unitIndex] = unitEntity.copyWith(
          name: value.name,
          description: value.description,
          difficultyLevel: value.difficultyLevel,
          difficulty: value.difficulty,
          access: value.access,
        );
        unitTabList.refresh();
        updateUnitList();
        CourseUpdateStore.to.notifyUnitUpdated();
      }
    });
  }

  // 删除单元
  Future<bool> onDeleteLevel(int unitIndex) async {
    bool isDel = false;
    if (_moduleId == null) {
      ToastUtils.showManageToast(text: "_moduleId为空");
      return isDel;
    }

    final List<NewUnitResponseEntity> oldLevels = [...unitTabList];
    oldLevels.removeAt(unitIndex);
    final List<int> ids = oldLevels.map((element) => element.uid).toList();
    if (ids.isEmpty) {
      ToastUtils.showManageToast(text: "单元不能为空");
      return isDel;
    }

    try {
      final response = await ModuleUtil.edit(
        uid: _moduleId.toString(),
        config: RequestConfig(
          requireToken: true,
          data: {"unitIds": ids},
        ),
      );
      if (response.data != null) {
        unitTabList.removeAt(unitIndex);
        updateUnitList();
        ToastUtils.showManageToast(text: "删除单元成功");
        isDel = true;
      } else {
        ToastUtils.showManageToast(text: response.message ?? "删除单元失败");
        isDel = false;
      }
    } catch (e) {
      ToastUtils.showManageToast(text: "删除单元失败");
      if (kDebugMode) {
        print(e.toString());
      }
      isDel = false;
    }

    return isDel;
  }

  // 单元排序
  void onSortLevel() async {
    if (_moduleId == null) {
      ToastUtils.showManageToast(text: "moduleId为空");
      return;
    }

    final List<int> ids = [...unitTabList].map((element) => element.uid).toList();
    if (ids.isEmpty) {
      ToastUtils.showManageToast(text: "单元Id为空");
      return;
    }

    try {
      final response = await ModuleUtil.edit(
        uid: _moduleId.toString(),
        config: RequestConfig(
          requireToken: true,
          data: {"unitIds": ids},
        ),
      );
      if (response.data != null) {
        ToastUtils.showManageToast(text: "单元排序成功");
      } else {
        ToastUtils.showManageToast(text: "单元排序失败");
      }
    } catch (e) {
      ToastUtils.showManageToast(text: "等级排序失败");
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  /// 跳转至添加Lesson页面
  Future<void> createLesson(BuildContext context, NewUnitResponseEntity unitEntity) async {
    if (!unitEntity.hasKnowledgeCount) {
      final value = await onAddKnowledge(context, unitEntity);
      if (value) {
        _onCreateLesson(context, unitEntity);
      }
    } else {
      _onCreateLesson(context, unitEntity);
    }
  }

  void _onCreateLesson(BuildContext context, NewUnitResponseEntity unitEntity) async {
    final ManageLessonTemplateEntityDatas? res = await SelectLessonTemplateDialog.show(
      context: context,
      difficultyLevel: unitEntity.difficultyLevel,
      language: _language,
    );
    if (res == null) return;
    try {
      ToastUtils.showLoading();
      final LessonResponseEntity? lessonCreateRes = await ModuleUtil.createLesson(
        unitEntity.language,
        unitEntity.uid,
        res.uid,
        name: res.name,
        description: res.description,
      );
      ToastUtils.hideLoading();
      if (lessonCreateRes == null) {
        ToastUtils.showManageToast(text: "创建课时失败");
        return;
      }

      int testIndex = -1;
      if (unitEntity.lessonDTOList != null) {
        for (int i = 0; i < unitEntity.lessonDTOList!.length; i++) {
          if (unitEntity.lessonDTOList![i].isUnitTEST) {
            testIndex = i;
            break;
          }
        }
      }

      if (testIndex != -1) {
        unitEntity.lessonDTOList?.insert(testIndex, lessonCreateRes);
      } else {
        unitEntity.lessonDTOList?.add(lessonCreateRes);
      }

      unitTabList.refresh();
      pushToCreateQuizPage(unitEntity, lessonCreateRes);
    } finally {
      ToastUtils.hideLoading();
    }
  }

  // 编辑课时
  void toEditLesson(BuildContext context, int lessonIndex, LessonResponseEntity targetLessonEntity, {required NewUnitResponseEntity unitEntity}) {
    if (!targetLessonEntity.isAbleEdit) {
      ToastUtils.showManageToast(text: "禁止编辑");
      return;
    }
    ManageEditLesson.show(context: context, lessonEntity: targetLessonEntity)?.then((value) {
      if (value != null) {
        unitEntity.lessonDTOList?[lessonIndex] = targetLessonEntity.copyWith(
          name: value.name,
          description: value.description,
        );
        unitTabList.refresh();
      }
    });
  }

  // 删除课时
  void onDeleteLesson(BuildContext context, int lessonIndex, LessonResponseEntity targetLessonEntity, {required NewUnitResponseEntity unitEntity}) async {
    if (!targetLessonEntity.isAbleEdit) {
      ToastUtils.showManageToast(text: "禁止删除");
      return;
    }

    final bool ask = await AskDialog.show(
      context: context,
      showLastCountdown: true,
      title: "温馨提示",
      content: "确定要删除${targetLessonEntity.name}吗？",
    );
    if (!ask) return;

    final List oldLessons = [...unitEntity.lessonDTOList ?? []].where((element) => element != targetLessonEntity).toList();
    final List ids = oldLessons.map((element) => element.uid).toList();
    if (ids.isEmpty) {
      ToastUtils.showManageToast(text: "课时不能为空");
      return;
    }

    try {
      ToastUtils.showLoading();
      final response = await UnitUtil.edit(
        uid: unitEntity.uid.toString(),
        config: RequestConfig(
          requireToken: true,
          data: {"lessonIds": ids},
        ),
      );
      if (response?.data != null) {
        unitEntity.lessonDTOList?.removeAt(lessonIndex);
        unitTabList.refresh();
      }
    } finally {
      ToastUtils.hideLoading();
    }
  }

  void pushToCreateQuizPage(NewUnitResponseEntity? unitData, LessonResponseEntity? lessonData) async {
    if (unitData == null || lessonData == null) return;
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_SELECT_QUZI_KNOWLEDGE,
      arguments: {
        "lessonTemplateId": lessonData.lessonTemplateId,
        "unitId": unitData.uid,
        "difficultyMin": unitData.difficulty?.min,
        "difficultyMax": unitData.difficulty?.max,
        "language": unitData.language,
        "lessonId": lessonData.uid,
      },
    );
    onFetchData(isRefresh: true);
  }

  // 获取模块ID
  int? get moduleId => _moduleId;

  // 单元目标
  Future<void> toUnitTarget(NewUnitResponseEntity unitEntity, LessonResponseEntity lessonEntity) async {
    if (lessonEntity.isUnitTARGET) {
      if (!ManageAuthUtils.isAuth(ManageAuthCode.unitKnowledgeList)) {
        ToastUtils.showManageToast(text: "无权限");
        return;
      }
      await Get.toNamed(
        Routes.OFFICIAL_COURSE_DETAILS_TARGET,
        arguments: {
          "moduleId": _moduleId,
          "unitId": unitEntity.uid,
          "isAdminPage": true,
          "language": _language,
        },
      );
      onFetchData(isRefresh: true);
    } else if (lessonEntity.isUnitTEST) {
      // 单元测试暂不处理
    } else {
      if (!ManageAuthUtils.isAuth(ManageAuthCode.lessonExerciseList)) {
        ToastUtils.showManageToast(text: "无权限");
        return;
      }
      await ManagePageRegistry.jumpTo(
        Routes.MANAGE_QUIZ_LIST,
        arguments: {
          "lessonId": lessonEntity.uid,
        },
      );
      onFetchData(isRefresh: true);
    }
  }

  /// 处理课时排序
  Future<void> onReorderLesson(NewUnitResponseEntity unitEntity, int oldIndex, int newIndex) async {
    try {
      final List lessonDTOList = unitEntity.lessonDTOList ?? [];
      if (oldIndex < 0 || oldIndex >= lessonDTOList.length || newIndex < 0 || newIndex > lessonDTOList.length) {
        return;
      }

      final movedLesson = lessonDTOList[oldIndex];
      if (movedLesson.isUnitTARGET == true || movedLesson.isUnitTEST == true || movedLesson.isAddButton == true) {
        ToastUtils.showManageToast(text: "目标型和测试型课时不能调整顺序");
        return;
      }

      final row = lessonDTOList.removeAt(oldIndex);
      lessonDTOList.insert(newIndex, row);

      final response = await UnitUtil.edit(
        uid: unitEntity.uid.toString(),
        config: RequestConfig(
          requireToken: true,
          data: {
            "lessonIds": lessonDTOList
                .cast<LessonResponseEntity>()
                .map((element) => element.uid)
                .where((element) => element != -1)
                .toList()
          },
        ),
      );

      if (response?.data != null) {
        unitTabList.refresh();
        ToastUtils.showManageToast(text: "排序成功");
      } else {
        ToastUtils.showManageToast(text: response?.message ?? "排序失败");
      }
    } catch (e) {
      if (kDebugMode) {
        print("课时排序错误: $e");
      }
      ToastUtils.showManageToast(text: "排序失败");
    }
  }

  LessonResponseEntity getAddLessonButton() => LessonResponseEntity(uid: -1, ableEdit: false, type: "ADD_BUTTON");

  Future<void> generateAudio() async {
    try {
      ToastUtils.showLoading();
      final response = await UnitUtil.generateAudio(
        moduleId: _moduleId.toString(),
        config: RequestConfig(requireToken: true),
      );
      if (response?.data != null) {
        ToastUtils.showManageToast(text: response!.data!);
      }
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<void> generateUnitPlan(int unitId) async {
    final askRes = await AskDialog.showUserAsk(
      context: Get.context!,
      content: "您确定要生成单元计划？",
      cancel: '取消',
      define: "确认",
    );
    if (!askRes) return;

    try {
      ToastUtils.showLoading();
      final response = await UnitUtil.generateUnitPlan(
        unitId: unitId.toString(),
        config: RequestConfig(requireToken: true),
      );
      if (response?.data != null) {
        ToastUtils.showManageToast(text: response!.data!);
      }
      onFetchData(isRefresh: true);
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<void> generateSentence(int unitId) async {
    final askRes = await AskDialog.showUserAsk(
      context: Get.context!,
      content: "您确定要生成句子？",
      cancel: '取消',
      define: "确认",
    );
    if (!askRes) return;

    try {
      ToastUtils.showLoading();
      final response = await UnitUtil.generateSentence(
        unitId: unitId.toString(),
        config: RequestConfig(requireToken: true),
      );
      if (response?.data != null) {
        ToastUtils.showManageToast(text: response!.data!);
      }
      onFetchData(isRefresh: true);
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<void> generateLessonPlan(int unitId) async {
    final askRes = await AskDialog.showUserAsk(
      context: Get.context!,
      content: "您确定要生成课时计划？",
      cancel: '取消',
      define: "确认",
    );
    if (!askRes) return;

    try {
      ToastUtils.showLoading();
      final response = await UnitUtil.generateLessonPlan(
        unitId: unitId.toString(),
        config: RequestConfig(requireToken: true),
      );
      if (response?.data != null) {
        ToastUtils.showManageToast(text: response!.data!);
      }
      onFetchData(isRefresh: true);
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<void> generateLessonTitle(int unitId) async {
    final askRes = await AskDialog.showUserAsk(
      context: Get.context!,
      content: "您确定要生成课时题目？",
      cancel: '取消',
      define: "确认",
    );
    if (!askRes) return;

    try {
      ToastUtils.showLoading();
      List lessonIds = [];
      for (var uint in unitTabList) {
        if (uint.uid == unitId) {
          uint.lessonDTOList?.forEach((element) {
            if (element.type == "LEARN_PRACTICE") {
              lessonIds.add(element.uid);
            }
          });
          break;
        }
      }

      final response = await UnitUtil.generateLessonTitle(
        unitId: unitId.toString(),
        config: RequestConfig(
          requireToken: true,
          data: {"lessonIds": lessonIds},
        ),
      );
      if (response?.data != null) {
        ToastUtils.showManageToast(text: response!.data!);
      }
      onFetchData(isRefresh: true);
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<void> generateLessonArticle(int unitId) async {
    final result = await ManagePageRegistry.jumpTo(
      Routes.MANAGE_MODULE_DETILS_GENERATE_ARTICLE,
      arguments: {
        'moduleId': _moduleId,
        'unitId': unitId,
      },
    );
    if (result ?? false) {
      onFetchData(isRefresh: true);
    }
  }

  Future<void> generateLessonSong(int unitId) async {
    final result = await ManagePageRegistry.jumpTo(
      Routes.MANAGE_GENERAL_SONG_PAGE,
      arguments: {'unitId': unitId},
    );
    if (result ?? false) {
      onFetchData(isRefresh: true);
    }
  }

  Future<void> generateOneLessonTitle(int unitId, int lessonId) async {
    final askRes = await AskDialog.showUserAsk(
      context: Get.context!,
      content: "您确定要重新生成题目？",
      cancel: '取消',
      define: "确认",
    );
    if (!askRes) return;

    try {
      ToastUtils.showLoading();
      final response = await UnitUtil.generateLessonTitle(
        unitId: unitId.toString(),
        config: RequestConfig(
          requireToken: true,
          data: {
            "lessonIds": [lessonId.toString()]
          },
        ),
      );
      if (response?.data != null) {
        ToastUtils.showManageToast(text: response!.data!);
      }
      onFetchData(isRefresh: true);
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<void> refreshOneLessonPlan(int unitId, int lessonId) async {
    final askRes = await AskDialog.showUserAsk(
      context: Get.context!,
      content: "您确定要刷新课时计划？",
      cancel: '取消',
      define: "确认",
    );
    if (!askRes) return;

    try {
      ToastUtils.showLoading();
      final response = await UnitUtil.refreshLessonPlan(
        unitId: unitId.toString(),
        lessonId: lessonId.toString(),
        config: RequestConfig(requireToken: true),
      );
      if (response?.data != null) {
        ToastUtils.showManageToast(text: response!.data!);
      }
      onFetchData(isRefresh: true);
    } finally {
      ToastUtils.hideLoading();
    }
  }

  @override
  void onClose() {
    tabController?.dispose();
    tabController = null;
    unitTabList.clear();
    _moduleId = null;
    super.onClose();
  }
}
