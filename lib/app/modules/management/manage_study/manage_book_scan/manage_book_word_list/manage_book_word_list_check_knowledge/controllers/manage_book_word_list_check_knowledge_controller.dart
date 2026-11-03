import 'package:api/api.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

class ManageBookWordListCheckKnowledgeController extends GetxController with ManageBreadcrumbMixin{
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
  int? draggingFromUnitIndex;
  int? draggingFromItemIndex;
  bool isDraggingFromTop = false;

  final ScrollController topScrollController = ScrollController();
  List<ScrollController> unitScrollControllerList = <ScrollController>[];

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    moduleId = Get.arguments['moduleId'];

    initServiceData();
  }

  @override
  void onClose() {
    super.onClose();
    topScrollController.dispose();
    for (var controller in unitScrollControllerList) {
      controller.dispose();
    }
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
      List<Knowledge> newList = (response?.data?.stagingList?.knowledgeList ?? <Knowledge>[]).cast<Knowledge>();
      topList.addAll(newList);
      update();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  //修改单元名称
  void modifyUnitName(int unitIndex) async {
    final String? name = await InputDialog.show(context: Get.context!, title: "单元名称", hintText: "请输入单元名称", realName: unitNameList[unitIndex]!);
    if (name == null) {
      return;
    }

    try {
      ToastUtils.showLoading();

      await UnitUtil.edit(
          uid: responseEntity?.unitList?[unitIndex].unitId?.toString() ?? '', config: RequestConfig(requireToken: true, data: {"name": name, "moduleId": moduleId}));
      unitNameList[unitIndex] = name;
      update();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  //获取自定义课程知识点
  void initServiceData() async {
    try {
      ToastUtils.showLoading();

      final response = await UnitUtil.allKnowledgeInfo(moduleId: moduleId, config: RequestConfig(requireToken: true));
      responseEntity = response.data;
      unitsList.value = response.data?.unitList?.map((e) => (e.knowledgeList ?? <Knowledge>[]).cast<Knowledge>()).toList() ?? [];
      topList.value = (response.data?.stagingList?.knowledgeList ?? <Knowledge>[]).cast<Knowledge>();

      unitScrollControllerList = [];
      List<String?> nameList = [];
      for (int i = 0; i < unitsList.length; i++) {
        unitScrollControllerList.add(ScrollController());
        nameList.add(responseEntity?.unitList?[i].unitName ?? '');
      }
      unitNameList.value = nameList;
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

      if(item.unitId != null){
        reqData['oldUnitId'] = item.unitId;
      }

      if(unitId != null){
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

  //拖拽结束，被移动到top区域
  void moveToTop(Knowledge item, int moveToIndex) async {
    bool isContains = topList.contains(item);
    if(isContains) return;

    bool isSuccess = await moveKnowledge(
      unitId: null,
      item: item,
      index: moveToIndex + 1,
    );
    if (isSuccess == false) return;

    item.unitId = null;

    List<List<Knowledge>> oldUnitsList = unitsList.map((list) => List<Knowledge>.from(list)).toList();
    List<Knowledge> oldTopList = List<Knowledge>.from(topList);

    //从原本的数组删除
    if (isDraggingFromTop) {
      oldTopList.removeAt(draggingFromItemIndex!);
    } else {
      oldUnitsList[draggingFromUnitIndex!].removeAt(draggingFromItemIndex!);
    }

    //添加到top数组
    if (moveToIndex >= topList.length) {
      oldTopList.add(item);
    } else {
      oldTopList.insert(moveToIndex, item);
    }

    unitsList.value = oldUnitsList;
    topList.value = oldTopList;

    // 重置拖拽相关的状态
    draggingFromUnitIndex = null;
    draggingFromItemIndex = null;
    isDraggingFromTop = false;
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

    List<List<Knowledge>> oldUnitsList = unitsList.map((list) => List<Knowledge>.from(list)).toList();
    List<Knowledge> oldTopList = List<Knowledge>.from(topList);

    // 从原本的数组删除
    if (isDraggingFromTop) {
      oldTopList.remove(item);
    } else {
      oldUnitsList[draggingFromUnitIndex!].removeAt(draggingFromItemIndex!);
    }

    // 添加到unit数组
    if (moveToIndex >= unitsList[moveToUnitIndex].length) {
      oldUnitsList[moveToUnitIndex].add(item);
    } else {
      oldUnitsList[moveToUnitIndex].insert(moveToIndex, item);
    }

    unitsList.value = oldUnitsList;
    topList.value = oldTopList;

    // 重置拖拽相关的状态
    draggingFromUnitIndex = null;
    draggingFromItemIndex = null;
    isDraggingFromTop = false;
  }
}
