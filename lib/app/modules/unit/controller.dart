import 'package:animated_reorderable_list/animated_reorderable_list.dart';
import 'package:api/entities/entities.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/utils.dart';
import 'package:quiz_play/utils/utils.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class UnitController extends GetxController {
  int? _courseUid, _bookUid, _moduleUid;

  AppModuleResponseEntity? _moduleResponseEntity;

  // 单元列表
  List get unitList => _moduleResponseEntity?.unitList ?? <AppUnitResponseEntity>[];

  bool get hasAppUnitList => unitList.isNotEmpty;

  // 锁定的单元
  AppUnitResponseEntity? get lockUnit => unitList.firstWhereOrNull((element) => element.isAddUnit);

  // 锁定的单元列表
  List get lockUnitList => lockUnit != null ? [lockUnit!] : [];

  // 知识点暂存区
  List get unGrouped => _moduleResponseEntity?.unGrouped ?? <Knowledge>[];

  bool get hasUnGroupedList => unGrouped.isNotEmpty;

  // 锁定的知识点
  Knowledge? get lockKnowledge => unGrouped.firstWhereOrNull((element) => element.isAddKnowledge);

  // 锁定的单元列表
  List get lockKnowledgeList => lockKnowledge != null ? [lockKnowledge!] : [];

  late AutoScrollController unitScrollController;

  @override
  void onInit() {
    super.onInit();

    final arguments = Get.arguments;
    if (arguments != null && arguments.containsKey("courseUid")) {
      _courseUid = arguments["courseUid"];
    }

    if (arguments != null && arguments.containsKey("bookUid")) {
      _bookUid = arguments["bookUid"];
    }

    if (arguments != null && arguments.containsKey("moduleUid")) {
      _moduleUid = arguments["moduleUid"];
    }

    debugPrint("[$runtimeType], arguments: $arguments");
    SchedulerBinding.instance.addPostFrameCallback((_) {
      unitScrollController = AutoScrollController(
          viewportBoundaryGetter: () => Rect.fromLTRB(0, 0, 0, MediaQuery.of(Get.context!).padding.bottom),
          axis: Axis.horizontal);
    });

    onFetchUnitKnowledgeList();
  }

  // 课程单元知识点列表
  void onFetchUnitKnowledgeList() async {
    if (ObjectUtil.isEmpty(_courseUid)) {
      ToastUtils.showToast(text: "请先创建课程");
      return;
    }

    if (ObjectUtil.isEmpty(_bookUid)) {
      ToastUtils.showToast(text: "请先添加书籍");
      return;
    }

    if (ObjectUtil.isEmpty(_moduleUid)) {
      ToastUtils.showToast(text: "请先添加书籍");
      return;
    }

    try {
      ToastUtils.showLoading();
      final response =
          await ModuleAppUtil.knowledge(moduleId: _moduleUid.toString(), config: RequestConfig(requireToken: true));
      _moduleResponseEntity = response.data;
      // 无论是否异常，都添加新单元
      _moduleResponseEntity?.unitList?.add(AppUnitResponseEntity<Knowledge>(uid: -1));
      if (!(_moduleResponseEntity?.unGrouped?.isEmpty ?? true)) {
        // 知识点暂存区有数据时, 加上指引
        _moduleResponseEntity?.unGrouped?.insert(0, Knowledge(uid: -1));
      }
    } on FormatException catch (error) {
      if (kDebugMode) {
        print(error.toString());
      }
      ToastUtils.showManageToast(text: error.source?.message ?? '获取单元列表失败');
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    } finally {
      _initData();
      ToastUtils.hideLoading();
    }
  }

  // 重新排序
  void onReorderKnowledge({required AppUnitResponseEntity unitEntity, required int oldIndex, required int newIndex}) {
    try {
      final Knowledge row = unitEntity.knowledgeList?.removeAt(oldIndex);
      unitEntity.knowledgeList?.insert(newIndex, row);
      onOrderKnowledgeList(unitUid: unitEntity.uid, knowledgeUid: row.uid, index: newIndex + 1);
    } catch (e) {
      print("移除同一容器数据异常e: $e");
    } finally {
      print("本容器内重新排序");
      _initData();
    }
  }

  // 从知识点暂存区列表源容器中移除拖拽的数据
  void onRemoveStorageContainerItem(
      {required CrossContainerData containerData, required unitUid, required int oldIndex, required int newIndex}) {
    try {
      if (!hasAppUnitList) {
        return;
      }

      if (!hasUnGroupedList) {
        return;
      }

      // 目标单元
      AppUnitResponseEntity<Knowledge>? oldAppUnitEntity;

      int oldUnitIndex = 0;

      for (int i = 0; i < unitList.length; i++) {
        final AppUnitResponseEntity<Knowledge> tempAppUnitEntity = unitList[i];
        if (tempAppUnitEntity.uid == unitUid) {
          oldAppUnitEntity = tempAppUnitEntity;
          oldUnitIndex = i;
          break;
        }
      }

      if (oldAppUnitEntity != null) {
        final List<Knowledge> oldKnowledgeList = unGrouped.map<Knowledge>((element) => element).toList();
        // 移除拖拽的单词
        oldKnowledgeList.removeAt(oldIndex);
        // 先清空单词列表
        _moduleResponseEntity?.unGrouped?.clear();
        unGrouped.clear();
        // _initData();
        // 重新赋值单词列表
        _moduleResponseEntity = _moduleResponseEntity?.copyWith(unGrouped: oldKnowledgeList);

        // 检查 oldKnowledgeList 中是否已经有 uid 为 -1 的 Knowledge 对象
        bool hasPlaceholder = oldKnowledgeList.any((element) => element.uid == -1);

        // 必须再加个临时数据占位,否则UI报错
        if (oldKnowledgeList.isNotEmpty && !hasPlaceholder) {
          // 知识点暂存区有数据时, 加上指引
          _moduleResponseEntity?.unGrouped?.insert(0, Knowledge(uid: -1));
        }

        for (int i = 0; i < unGrouped.length; i++) {
          final Knowledge tempKnowledge = unGrouped[i];
          print(tempKnowledge);
        }

        // 刷新UI
        _initData();
        /*************将拖拽单词添加到新单元列表****************/
        oldAppUnitEntity.knowledgeList?.insert(0, containerData.dragInfo.draggedItemData);
        unitList[oldUnitIndex] = oldAppUnitEntity;

        onOrderKnowledgeList(
            unitUid: oldAppUnitEntity.uid, knowledgeUid: containerData.dragInfo.draggedItemData!.uid, index: 0);
      }
    } catch (e) {
      print("移除同一容器数据异常e: $e");
    } finally {
      print("---finally,onRemoveOriginalContainerItem更新数据---");
      _initData();
    }
  }

  // 从单元列表源容器中移除拖拽的数据
  void onRemoveUnitContainerItem(
      {required CrossContainerData containerData, required unitUid, required int oldIndex, required int newIndex}) {
    try {
      if (!hasAppUnitList) {
        return;
      }

      // 检查单元列表
      if (unitList.length < 2) return;

      AppUnitResponseEntity<Knowledge>? oldAppUnitEntity;

      int oldUnitIndex = 0;

      for (int i = 0; i < unitList.length; i++) {
        final AppUnitResponseEntity<Knowledge> tempAppUnitEntity = unitList[i];
        if (tempAppUnitEntity.uid == unitUid) {
          oldAppUnitEntity = tempAppUnitEntity;
          oldUnitIndex = i;
          break;
        }
      }

      if (oldAppUnitEntity != null) {
        print("---更新单元数据: ${oldAppUnitEntity.knowledgeList?.length}---");
        final List<Knowledge> oldKnowledgeList =
            oldAppUnitEntity.knowledgeList?.map((element) => element).toList() ?? [];
        // 移除拖拽的单词
        oldKnowledgeList.removeAt(oldIndex);
        // 先清空单词列表
        oldAppUnitEntity.knowledgeList?.clear();
        // 重新赋值单词列表
        oldAppUnitEntity = oldAppUnitEntity.copyWith(knowledgeList: oldKnowledgeList);

        // 刷新UI
        _initData();
        print("---再次更新单元数据: ${oldAppUnitEntity.knowledgeList?.length}---");
        // 旧单元数据
        unitList[oldUnitIndex] = oldAppUnitEntity;

        /*************将拖拽单词添加到新单元列表****************/
        // 变量用来记录当前可见的单元索引
        final int currentVisibleIndex = findHoveredCellIndex(dragPosition: containerData.dragInfo.dragPosition);

        // 如果没有找到可见单元，直接返回
        if (currentVisibleIndex == -1) return;
        // 将拖拽单词添加到目标单元
        final AppUnitResponseEntity<Knowledge> targetAppUnitEntity = unitList[currentVisibleIndex];
        targetAppUnitEntity.knowledgeList?.insert(0, containerData.dragInfo.draggedItemData);
        unitList[currentVisibleIndex] = targetAppUnitEntity;

        onOrderKnowledgeList(
            unitUid: targetAppUnitEntity.uid, knowledgeUid: containerData.dragInfo.draggedItemData!.uid, index: 0);
      }
    } catch (e) {
      print("移除同一容器数据异常e: $e");
    } finally {
      print("---finally,onRemoveOriginalContainerItem更新数据---");
      _initData();
    }
  }

  // 课程单元知识点列表
  void onOrderKnowledgeList({required int unitUid, required int knowledgeUid, required int index}) async {
    try {
      final response = await UnitAppUtil.orderKnowledge(
          config: RequestConfig(
              requireToken: true, data: {"unitId": unitUid, "unitKnowledgeId": knowledgeUid, "index": index}));
      if (response.data != null) {
        onFetchUnitKnowledgeList();
      }
    } on FormatException catch (error) {
      if (kDebugMode) {
        print(error.toString());
      }
      ToastUtils.showManageToast(text: error.source?.message ?? '排序单词失败');
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    } finally {
      _initData();
    }
  }

  // 新建单元
  void onCreateUnit(BuildContext context, {required String name}) async {
    if (ObjectUtil.isEmpty(_moduleUid)) {
      ToastUtils.showToast(text: "请先添加书籍");
      return;
    }

    final String? name =
        await InputDialog.show(context: context, title: "新建单元", content: "请输入单元名称：", hintText: "单元名称", realName: "");
    if (ObjectUtil.isNotEmpty(name)) {
      _onCreateUnit(name: name!);
    }
  }

  // 新建单元
  void _onCreateUnit({required String name}) async {
    if (ObjectUtil.isEmpty(_moduleUid)) {
      ToastUtils.showToast(text: "请先添加书籍");
      return;
    }

    try {
      final response = await UnitAppUtil.create(
          config: RequestConfig(requireToken: true, data: {"moduleId": _moduleUid, "name": name}));
      if (response.data != null) {
        onFetchUnitKnowledgeList();
      }
    } on FormatException catch (error) {
      if (kDebugMode) {
        print(error.toString());
      }
      ToastUtils.showManageToast(text: error.source?.message ?? '新建单元失败');
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    } finally {
      _initData();
    }
  }

  // 编辑单元
  void onEditUnit(BuildContext context, {required AppUnitResponseEntity unitEntity}) async {
    if (ObjectUtil.isEmpty(_moduleUid)) {
      ToastUtils.showToast(text: "请先添加书籍");
      return;
    }

    final String? name = await InputDialog.show(
        context: context, title: "编辑单元", content: "请输入单元名称：", hintText: "单元名称", realName: unitEntity.name ?? '');
    if (ObjectUtil.isNotEmpty(name)) {
      _onEditUnit(uid: unitEntity.uid, name: name!);
    }
  }

  // 编辑单元
  void _onEditUnit({required int uid, required String name}) async {
    if (ObjectUtil.isEmpty(_moduleUid)) {
      ToastUtils.showToast(text: "请先添加书籍");
      return;
    }

    try {
      final response = await UnitAppUtil.edit(
          uid: uid, config: RequestConfig(requireToken: true, data: {"moduleId": _moduleUid, "name": name}));
      if (response.data != null) {
        onFetchUnitKnowledgeList();
      }
    } on FormatException catch (error) {
      if (kDebugMode) {
        print(error.toString());
      }
      ToastUtils.showManageToast(text: error.source?.message ?? '编辑单元失败');
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    } finally {
      _initData();
    }
  }

  /// 生成课程
  void emergentCurriculum() {
    Get.back();
    // Get.toNamed(Routes.COURSE_OUTLINE);
  }

  @override
  void onReady() {
    super.onReady();
    _initData();
  }

  void _initData() {
    update(["unit"]);
  }

  /// 检测拖拽浮层是否位于单元上方并返回目标索引
  ///
  /// [dragPosition] 当前拖拽位置
  /// [unitBounds] 候选单元边界列表
  int findHoveredCellIndex({required Offset dragPosition}) {
    // 检查单元列表
    if (!hasAppUnitList) {
      return -1;
    }

    // 获取拖拽的水平位置
    final double dragX = dragPosition.dx;

    // 变量用来记录当前可见的单元索引
    int currentVisibleIndex = -1;

    // 遍历所有单元，只判断哪个单元当前可见
    for (int i = 0; i < unitList.length; i++) {
      final unit = unitList[i];
      var record = CommonUtils.getSizeAndPosition(unit.globalKey);
      // 跳过无效的容器
      if (record.size == Size.zero) continue;

      final Offset globalPosition = record.globalPosition;
      final Size size = record.size;
      // print("---当前单元: $i, 单元全局坐标: $globalPosition, 单元尺寸: $size, 拖拽位置: $dragX");
      final double unitLeftDx = globalPosition.dx, unitRightDx = globalPosition.dx + size.width;

      if (dragX > unitLeftDx && dragX < unitRightDx) {
        // 找到一个可见的单元，记录其索引并退出循环
        currentVisibleIndex = i;
        // print("---找到单元: $i, 单元全局坐标: $globalPosition, 单元尺寸: $size, 拖拽位置: $dragX");
        break;
      }
    }

    return currentVisibleIndex;
  }
}
