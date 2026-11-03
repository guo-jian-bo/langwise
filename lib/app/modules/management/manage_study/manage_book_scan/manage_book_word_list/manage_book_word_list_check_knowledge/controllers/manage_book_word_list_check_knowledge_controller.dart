import 'package:api/api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/management/common/manage_select_knowledge_table/view.dart';
import '../../../../../../../routes/routes.dart';
import '../../../../../utils/utils.dart';
import '../models/manage_book_word_list_check_knowledge_response_entity.dart';
import 'package:langwise/common/entities/en_phrase_entity.dart';
import 'package:langwise/common/entities/en_sentence_entity.dart';
import 'package:langwise/common/entities/en_text_entity.dart';
import 'package:langwise/common/entities/en_word_entity.dart';
import 'package:langwise/common/entities/knowledge.dart';
import 'package:langwise/common/https/unit.dart';
import 'package:langwise/common/widgets/input_dialog.dart';
import 'package:langwise/utils/toast_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

class ManageBookWordListCheckKnowledgeController extends GetxController
    with ManageBreadcrumbMixin {
  final String tag;
  ManageBookWordListCheckKnowledgeController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_WORD_LIST_CHECK_KNOWLEDGE;

  @override
  String get breadcrumbTitle => '单元管理';

  String? moduleId;

  ManageBookWordListCheckKnowledgeResponseEntity? responseEntity;
  final RxList<List<Knowledge>> unitsList = <List<Knowledge>>[].obs;
  final RxList<Knowledge> topList = <Knowledge>[].obs;
  final RxList<String?> unitNameList = <String?>[].obs;
  final RxInt activeUnitId = (-1).obs;
  int currentUnitIndex = 0;
  int? draggingFromUnitIndex;
  int? draggingFromItemIndex;
  bool isDraggingFromTop = false;
  bool _programmaticScrolling = false;

  final ScrollController topScrollController = ScrollController();
  final ScrollController unitWorkspaceScrollController = ScrollController();
  final ScrollController unitTabScrollController = ScrollController();
  final GlobalKey unitTabViewportKey = GlobalKey();
  List<ScrollController> unitScrollControllerList = <ScrollController>[];
  final Map<int, GlobalKey> unitSectionKeys = <int, GlobalKey>{};
  final Map<int, GlobalKey> unitHeaderKeys = <int, GlobalKey>{};
  final Map<int, GlobalKey> unitTabKeys = <int, GlobalKey>{};

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    moduleId = Get.arguments['moduleId'];
    unitWorkspaceScrollController.addListener(_syncActiveUnitByScroll);

    initServiceData();
  }

  @override
  void onClose() {
    super.onClose();
    unitWorkspaceScrollController.removeListener(_syncActiveUnitByScroll);
    topScrollController.dispose();
    unitWorkspaceScrollController.dispose();
    unitTabScrollController.dispose();
    for (var controller in unitScrollControllerList) {
      controller.dispose();
    }
  }

  List<Knowledge> get currentUnitList {
    if (unitsList.isEmpty) {
      return <Knowledge>[];
    }
    final int safeIndex =
        currentUnitIndex.clamp(0, unitsList.length - 1).toInt();
    return unitsList[safeIndex];
  }

  String get currentUnitName {
    if (unitNameList.isEmpty) {
      return '';
    }
    final int safeIndex =
        currentUnitIndex.clamp(0, unitNameList.length - 1).toInt();
    return unitNameList[safeIndex] ?? '';
  }

  int? get currentUnitId {
    if ((responseEntity?.unitList ?? []).isEmpty) {
      return null;
    }
    final int safeIndex =
        currentUnitIndex.clamp(0, responseEntity!.unitList!.length - 1).toInt();
    return responseEntity?.unitList?[safeIndex].unitId;
  }

  ScrollController? get currentUnitScrollController {
    if (unitScrollControllerList.isEmpty) {
      return null;
    }
    final int safeIndex =
        currentUnitIndex.clamp(0, unitScrollControllerList.length - 1).toInt();
    return unitScrollControllerList[safeIndex];
  }

  // 管理知识点列表
  Future<dynamic> onAddKnowledge(BuildContext context) async {
    var value = await ManageSelectKnowledgeTableManager.show(
      context: context,
      // unitId: 111,
      defaultDessert: [],
      language: 'en',
      showSelectKnowledgeAddButton: true,
    );
    final List<Knowledge> newLs = <Knowledge>[];
    if (value != null && value.isNotEmpty) {
      for (int i = 0; i < value.length; i++) {
        final entity = value[i];
        if (entity is EnWordEntity) {
          newLs.add(Knowledge(
              uid: entity.uid,
              contentType: entity.contentType,
              content: entity.content,
              contentId: entity.uid,
              definition: entity.definition,
              semanticId: entity.selectedSemantics?.uid,
              imageUrl: entity.imageUrl,
              audioUrl: entity.audioUrl,
              language: entity.language));
        } else if (entity is EnPhraseEntity) {
          newLs.add(Knowledge(
              uid: entity.uid,
              contentType: entity.contentType,
              content: entity.content,
              contentId: entity.uid,
              definition: entity.definition,
              semanticId: entity.selectedSemantics?.uid,
              imageUrl: entity.imageUrl,
              audioUrl: entity.audioUrl,
              language: entity.language));
        } else if (entity is EnSentenceEntity) {
          newLs.add(Knowledge(
              uid: entity.uid,
              contentType: entity.contentType,
              content: entity.content,
              contentId: entity.uid,
              definition: entity.definition,
              semanticId: entity.selectedSemantics?.uid,
              imageUrl: entity.imageUrl,
              audioUrl: entity.audioUrl,
              language: entity.language));
        } else if (entity is EnTextEntity) {
          newLs.add(Knowledge(
              uid: entity.uid,
              contentType: entity.contentType,
              content: entity.content,
              contentId: entity.uid,
              definition: entity.title,
              imageUrl: entity.imageUrl,
              audioUrl: entity.audioUrl,
              language: entity.language));
        }
      }
      _onAdd(list: newLs);
    }
    debugPrint('value: $value');
  }

  // 添加知识点到缓存区
  void _onAdd({required List<Knowledge> list}) async {
    try {
      ToastUtils.showLoading();

      final response = await UnitUtil.addKnowledge(
        moduleId: moduleId,
        config: RequestConfig(
          requireToken: true,
          data: list.map((element) => element.toJson()).toList(),
        ),
      );
      List<Knowledge> newList =
          (response?.data?.stagingList?.knowledgeList ?? <Knowledge>[])
              .cast<Knowledge>();
      topList.addAll(newList);
      update(['bottomBar']);
      update();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  void selectUnit(int index) {
    if (index < 0 || index >= unitsList.length) {
      return;
    }
    final int? unitId = responseEntity?.unitList?[index].unitId;
    if (unitId == null) {
      currentUnitIndex = index;
      update(['bottomBar']);
      update();
      return;
    }
    scrollToUnit(unitId);
  }

  void onComplete() {
    Get.back(result: true);
  }

  //修改单元名称
  void modifyUnitName(int unitIndex) async {
    final String? name = await InputDialog.show(
        context: Get.context!,
        title: "单元名称",
        hintText: "请输入单元名称",
        realName: unitNameList[unitIndex]!);
    if (name == null) {
      return;
    }

    try {
      ToastUtils.showLoading();

      await UnitUtil.edit(
          uid: responseEntity?.unitList?[unitIndex].unitId?.toString() ?? '',
          config: RequestConfig(
              requireToken: true, data: {"name": name, "moduleId": moduleId}));
      unitNameList[unitIndex] = name;
      update(['bottomBar']);
      update();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  //获取自定义课程知识点
  void initServiceData() async {
    try {
      ToastUtils.showLoading();

      final response = await UnitUtil.allKnowledgeInfo(
          moduleId: moduleId, config: RequestConfig(requireToken: true));
      responseEntity = response.data;
      unitsList.value = response.data?.unitList
              ?.map((e) => (e.knowledgeList ?? <Knowledge>[]).cast<Knowledge>())
              .toList() ??
          [];
      topList.value =
          (response.data?.stagingList?.knowledgeList ?? <Knowledge>[])
              .cast<Knowledge>();

      unitScrollControllerList = [];
      List<String?> nameList = [];
      for (int i = 0; i < unitsList.length; i++) {
        unitScrollControllerList.add(ScrollController());
        nameList.add(responseEntity?.unitList?[i].unitName ?? '');
        final int? unitId = responseEntity?.unitList?[i].unitId;
        if (unitId != null) {
          unitSectionKeys.putIfAbsent(unitId, GlobalKey.new);
          unitHeaderKeys.putIfAbsent(unitId, GlobalKey.new);
          unitTabKeys.putIfAbsent(unitId, GlobalKey.new);
        }
      }
      unitNameList.value = nameList;
      if (unitsList.isEmpty) {
        currentUnitIndex = 0;
        activeUnitId.value = -1;
      } else if (currentUnitIndex >= unitsList.length) {
        currentUnitIndex = unitsList.length - 1;
      }
      _syncActiveUnitFromSelection();
      update(['bottomBar']);
      update();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  //移动知识点接口
  Future<bool> moveKnowledge({
    int? unitId,
    required Knowledge item,
    required int index,
  }) async {
    try {
      ToastUtils.showLoading();

      Map<String, dynamic> reqData = {
        "index": index,
      };

      if (item.unitId != null) {
        reqData['oldUnitId'] = item.unitId;
      }

      if (unitId != null) {
        reqData['newUnitId'] = unitId;
      }

      final response = await UnitUtil.refreshKnowledge(
        unitId: 123,
        knowledgeId: item.uid,
        config: RequestConfig(
          requireToken: true,
          data: reqData,
        ),
      );
      update();
      if (response == null) {
        return false;
      }
      return true;
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

  void clearDragState() {
    draggingFromUnitIndex = null;
    draggingFromItemIndex = null;
    isDraggingFromTop = false;
  }

  void _syncActiveUnitFromSelection() {
    final int? unitId = responseEntity?.unitList?[currentUnitIndex].unitId;
    if (unitId == null) {
      return;
    }
    _setActiveUnit(unitId);
  }

  int? _findUnitIndexById(int? unitId) {
    if (unitId == null) {
      return null;
    }
    final units = responseEntity?.unitList ?? <KnowledgeInfo>[];
    for (int index = 0; index < units.length; index++) {
      if (units[index].unitId == unitId) {
        return index;
      }
    }
    return null;
  }

  GlobalKey getUnitHeaderKey(int unitId) {
    return unitHeaderKeys.putIfAbsent(unitId, GlobalKey.new);
  }

  GlobalKey getUnitTabKey(int unitId) {
    return unitTabKeys.putIfAbsent(unitId, GlobalKey.new);
  }

  void _setActiveUnit(int? unitId) {
    if (unitId == null) {
      return;
    }
    if (activeUnitId.value != unitId) {
      activeUnitId.value = unitId;
    }
    final int? index = _findUnitIndexById(unitId);
    if (index != null) {
      currentUnitIndex = index;
    }
    update(['bottomBar']);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _centerActiveUnitTabIfNeeded(unitId);
    });
  }

  void scrollToUnit(int unitId) {
    _programmaticScrolling = true;
    _setActiveUnit(unitId);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToUnitHeader(unitId);
    });
  }

  void _scrollToUnitHeader(int unitId, {int retry = 0}) {
    if (isClosed) {
      return;
    }
    if (!unitWorkspaceScrollController.hasClients) {
      if (retry >= 8) {
        _finishProgrammaticScroll();
        return;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToUnitHeader(unitId, retry: retry + 1);
      });
      return;
    }
    final double? targetOffset = _getHeaderScrollOffset(unitId);
    if (targetOffset != null) {
      final double maxOffset =
          unitWorkspaceScrollController.position.maxScrollExtent;
      unitWorkspaceScrollController
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
      _scrollToUnitHeader(unitId, retry: retry + 1);
    });
  }

  double? _getHeaderScrollOffset(int unitId) {
    final BuildContext? ctx = unitHeaderKeys[unitId]?.currentContext;
    if (ctx == null ||
        !ctx.mounted ||
        !unitWorkspaceScrollController.hasClients) {
      return null;
    }
    final RenderObject? renderObject = ctx.findRenderObject();
    if (renderObject == null || !renderObject.attached) {
      return null;
    }
    final RenderAbstractViewport viewport =
        RenderAbstractViewport.of(renderObject);
    return viewport.getOffsetToReveal(renderObject, 0).offset;
  }

  void _finishProgrammaticScroll() {
    Future.delayed(const Duration(milliseconds: 80), () {
      _programmaticScrolling = false;
      _syncActiveUnitByScroll();
    });
  }

  void _syncActiveUnitByScroll() {
    if (_programmaticScrolling) {
      return;
    }
    final units = responseEntity?.unitList ?? <KnowledgeInfo>[];
    if (units.isEmpty || !unitWorkspaceScrollController.hasClients) {
      return;
    }

    final double probeOffset =
        unitWorkspaceScrollController.offset + (60.wMin * 0.6);
    int? nextUnitId;
    for (final unit in units) {
      final int? currentUnitId = unit.unitId;
      if (currentUnitId == null) {
        continue;
      }
      final double? headerOffset = _getHeaderScrollOffset(currentUnitId);
      if (headerOffset == null) {
        continue;
      }
      if (headerOffset <= probeOffset) {
        nextUnitId = currentUnitId;
        continue;
      }
      break;
    }
    nextUnitId ??= units.first.unitId;
    if (nextUnitId != null && nextUnitId != activeUnitId.value) {
      _setActiveUnit(nextUnitId);
    }
  }

  void _centerActiveUnitTabIfNeeded(int unitId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isClosed || !unitTabScrollController.hasClients) {
        return;
      }
      final BuildContext? itemContext = getUnitTabKey(unitId).currentContext;
      final BuildContext? viewportContext = unitTabViewportKey.currentContext;
      if (itemContext == null || viewportContext == null) {
        return;
      }

      final RenderObject? itemRenderObject = itemContext.findRenderObject();
      final RenderObject? viewportRenderObject =
          viewportContext.findRenderObject();
      if (itemRenderObject is! RenderBox ||
          viewportRenderObject is! RenderBox) {
        return;
      }
      if (!itemRenderObject.attached || !viewportRenderObject.attached) {
        return;
      }

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
      if (!isOutOfView) {
        return;
      }

      final double targetOffset = unitTabScrollController.offset +
          itemLeft -
          ((viewportWidth - itemRenderObject.size.width) / 2);
      final double maxOffset = unitTabScrollController.position.maxScrollExtent;
      unitTabScrollController.animateTo(
        targetOffset.clamp(0.0, maxOffset),
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    });
  }

  int? _findKnowledgeIndex(List<Knowledge> list, Knowledge item) {
    final int index = list.indexWhere((element) => element.uid == item.uid);
    return index == -1 ? null : index;
  }

  int? _findUnitIndexContainingKnowledge(Knowledge item) {
    for (int unitIndex = 0; unitIndex < unitsList.length; unitIndex++) {
      final int? itemIndex = _findKnowledgeIndex(unitsList[unitIndex], item);
      if (itemIndex != null) {
        return unitIndex;
      }
    }
    return null;
  }

  //拖拽结束，被移动到top区域
  void moveToTop(Knowledge item, int moveToIndex) async {
    bool isSuccess = await moveKnowledge(
      unitId: null,
      item: item,
      index: moveToIndex + 1,
    );
    if (isSuccess == false) return;

    List<List<Knowledge>> oldUnitsList =
        unitsList.map((list) => List<Knowledge>.from(list)).toList();
    List<Knowledge> oldTopList = List<Knowledge>.from(topList);
    final int? sourceTopIndex = _findKnowledgeIndex(oldTopList, item);
    final bool sourceFromTop = isDraggingFromTop || sourceTopIndex != null;
    final bool moveInsideTop = sourceFromTop;
    final int? sourceUnitIndex =
        sourceFromTop ? null : _findUnitIndexContainingKnowledge(item);
    final int? sourceUnitItemIndex = moveInsideTop || sourceUnitIndex == null
        ? null
        : _findKnowledgeIndex(oldUnitsList[sourceUnitIndex], item);

    //从原本的数组删除
    if (sourceFromTop) {
      final int? removeIndex = draggingFromItemIndex ?? sourceTopIndex;
      if (removeIndex == null || removeIndex >= oldTopList.length) {
        clearDragState();
        return;
      }
      oldTopList.removeAt(removeIndex);
    } else {
      final int? removeUnitIndex = draggingFromUnitIndex ?? sourceUnitIndex;
      final int? removeItemIndex = draggingFromItemIndex ?? sourceUnitItemIndex;
      if (removeUnitIndex == null ||
          removeItemIndex == null ||
          removeUnitIndex >= oldUnitsList.length ||
          removeItemIndex >= oldUnitsList[removeUnitIndex].length) {
        clearDragState();
        return;
      }
      oldUnitsList[removeUnitIndex].removeAt(removeItemIndex);
    }

    item.unitId = null;

    //添加到top数组
    int targetIndex = moveToIndex;
    if (moveInsideTop &&
        draggingFromItemIndex != null &&
        targetIndex > draggingFromItemIndex!) {
      targetIndex -= 1;
    }

    if (targetIndex >= oldTopList.length) {
      oldTopList.add(item);
    } else {
      oldTopList.insert(targetIndex, item);
    }

    unitsList.value = oldUnitsList;
    topList.value = oldTopList;
    _syncActiveUnitFromSelection();
    clearDragState();
    update();
  }

  //拖拽结束，被移动到unit区域
  void moveToUnit(Knowledge item, int moveToUnitIndex, int moveToIndex) async {
    bool isSuccess = await moveKnowledge(
      unitId: responseEntity!.unitList![moveToUnitIndex].unitId,
      item: item,
      index: moveToIndex + 1,
    );
    if (isSuccess == false) return;

    item.unitId = responseEntity!.unitList![moveToUnitIndex].unitId;

    List<List<Knowledge>> oldUnitsList =
        unitsList.map((list) => List<Knowledge>.from(list)).toList();
    List<Knowledge> oldTopList = List<Knowledge>.from(topList);
    final int? sourceTopIndex = _findKnowledgeIndex(oldTopList, item);
    final bool sourceFromTop = isDraggingFromTop || sourceTopIndex != null;
    final int? sourceUnitIndex = sourceFromTop
        ? null
        : (draggingFromUnitIndex ?? _findUnitIndexContainingKnowledge(item));
    final int? sourceUnitItemIndex = sourceFromTop || sourceUnitIndex == null
        ? null
        : _findKnowledgeIndex(oldUnitsList[sourceUnitIndex], item);
    final bool moveInsideSameUnit =
        !sourceFromTop && sourceUnitIndex == moveToUnitIndex;

    // 从原本的数组删除
    if (sourceFromTop) {
      final int? removeIndex = draggingFromItemIndex ?? sourceTopIndex;
      if (removeIndex == null || removeIndex >= oldTopList.length) {
        clearDragState();
        return;
      }
      oldTopList.removeAt(removeIndex);
    } else {
      final int? removeUnitIndex = sourceUnitIndex;
      final int? removeItemIndex = draggingFromItemIndex ?? sourceUnitItemIndex;
      if (removeUnitIndex == null ||
          removeItemIndex == null ||
          removeUnitIndex >= oldUnitsList.length ||
          removeItemIndex >= oldUnitsList[removeUnitIndex].length) {
        clearDragState();
        return;
      }
      oldUnitsList[removeUnitIndex].removeAt(removeItemIndex);
    }

    // 添加到unit数组
    int targetIndex = moveToIndex;
    if (moveInsideSameUnit &&
        (draggingFromItemIndex ?? sourceUnitItemIndex) != null &&
        targetIndex > (draggingFromItemIndex ?? sourceUnitItemIndex)!) {
      targetIndex -= 1;
    }

    if (targetIndex >= oldUnitsList[moveToUnitIndex].length) {
      oldUnitsList[moveToUnitIndex].add(item);
    } else {
      oldUnitsList[moveToUnitIndex].insert(targetIndex, item);
    }

    unitsList.value = oldUnitsList;
    topList.value = oldTopList;
    currentUnitIndex = moveToUnitIndex;
    _syncActiveUnitFromSelection();
    clearDragState();
    update();
  }
}
