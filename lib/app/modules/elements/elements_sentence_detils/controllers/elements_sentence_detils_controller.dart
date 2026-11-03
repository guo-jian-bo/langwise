
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/utils/utils.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/public_controller/config_controller.dart';
import '../../../../routes/routes.dart';
import '../../../../routes/routes_breadcrumb_utils.dart';
import '../../model/elements_jump_module_type.dart';
import '../../model/elements_tabview_tag_model.dart';

class ElementsSentenceDetilsController extends GetxController
    with GetSingleTickerProviderStateMixin, RoutesBreadcrumbMixin {
  final String tagText;
  ElementsSentenceDetilsController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.EN_SENTENCE_DETAIL;

  @override
  String get breadcrumbTitle => "语境词典详情";

  /// 传进来的参数
  int? contentId;
  /// * 外部传进来的参数，用来定位滚动视图
  /// * [ElementsJumpModuleType]
  String? jumpType;
  List<int?>? semanticIds;


  /// 句子详情
  final Rx<CardSentencesDetilsEntity> sentencesDetils = CardSentencesDetilsEntity().obs;


  final AutoScrollController autoScrollController = AutoScrollController();

  List<ElementsTabViewTagModel> tagList = [
    ElementsTabViewTagModel(index: 0, title: "句子发音", type: ElementsJumpModuleType.PRONUNCIATION, color: const Color(0xff38BDF8)),
    ElementsTabViewTagModel(index: 1, title: "句子释义", type: ElementsJumpModuleType.SEMANTICS, color: const Color(0xffEC4899)),
  ];
  final RxInt tagTabbarIndex = 0.obs;
  /// 发音tab 英音/美音
  final RxInt englishAmericanType = 0.obs;


  final hideTranslation = false.obs;

  /// 结构/句法分析tab
  final RxInt structuralSyntaxTabbarIndex = 0.obs;


  // -------- 结构分析模块 -----------
  /// 语块分析/成分分析 tab
  final RxInt structureTabControllerIndex = 0.obs;

  /// 网格视图/折叠视图tag
  final RxInt gridOrFoldTagIndex = 0.obs;

  /// 句子结构表网格视图序号选择下标 要根据下标改变 下面的 结构详情
  final RxInt sentenceStructureTableSelectIndex = 0.obs;

  /// 句子结构详情 选择模块的下标
  final RxInt sentenceStructureDetailSelectIndex = (-1).obs;

  // --------- 句法分析模块 -----------

  /// 标记鼠标是否在 GraphView 内
  final RxBool isHoveringGraph = false.obs; 

  /// 句法分析 分叉树 显示更多/隐藏详情
  final RxBool graphShowDetils = false.obs;

  /// 句法分析 分叉树 跳转时的index 
  final RxInt graphAutoToIndex = (-1).obs;

  final RxBool isLoading = true.obs;
  final RxBool isFavorited = false.obs;
  final RxBool isMemoryStatusLoading = false.obs;
  

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    
    if(Get.arguments != null){
      contentId = Get.arguments['contentId'];
      jumpType = Get.arguments['jumpType'];
      semanticIds = Get.arguments['semanticIds']?.cast<int?>();
      // contentId = 157106;
      initData();
    }
  }

  /// 通过旧语义列表接口获取当前句子的记忆状态
  Future<void> refreshFavoritedStatus() async {
    final CardSentencesDetilsEntity detils = sentencesDetils.value;
    final int? cId = detils.contentId;
    final String? cType = detils.contentType;
    final int semId = detils.semanticId ?? 0;
    if (cId == null || (cType ?? '').isEmpty || semId <= 0) {
      isFavorited.value = false;
      return;
    }
    try {
      isMemoryStatusLoading.value = true;
      final List<ElementsCardEntityDatas>? groups =
          await ListenAndReadRequest.getKnowledgeSemantics(<String, dynamic>{
        'contents': <Map<String, dynamic>>[
          <String, dynamic>{'uid': cId, 'type': cType},
        ],
      });
      if (groups == null || groups.isEmpty) {
        isFavorited.value = false;
        return;
      }
      // favorited 在 contentList 子列表（semantic 级别）中
      for (final ElementsCardEntityDatas group in groups) {
        final List<ElementsCardEntityDatas?> children = group.contentList ?? [];
        final ElementsCardEntityDatas? match = children.firstWhereOrNull(
          (ElementsCardEntityDatas? item) => item?.semanticId == semId,
        );
        if (match != null) {
          isFavorited.value = match.isFavorited;
          return;
        }
      }
      isFavorited.value = false;
    } finally {
      isMemoryStatusLoading.value = false;
    }
  }

  Future<void> initData() async{
    try {
      ToastUtils.showLoading();
      isLoading.value = true;
      await Get.find<ConfigController>().ensureStyleReady();
      await Future.wait([
        getRightCount(),
        getDetils(),
      ]);
    } finally{
      ToastUtils.hideLoading();
    }
  }

  /// 获取权益数量
  Future<void> getRightCount() async{
    RightCountDetailsEntity? rightCountDetailsEntity = await UserRequest.getCardRightCount();
    if(rightCountDetailsEntity == null) return;
    int extendCard = rightCountDetailsEntity.extendCard??0;
    if(extendCard == 0) return;
    ToastUtils.showToast(text: "您还有$extendCard次探索卡片", type: ToastType.warning);
  }


  Future<void> getDetils() async{
    if(contentId == null) return;
    final ConfigController configController = Get.find<ConfigController>();
    CardSentencesDetilsEntity? detils = await ElementsRequest.getSentencesDetils(
      contentId!,
      semanticIds: semanticIds,
      module: jumpType,
      style: configController.currentStyleForRequest,
      mediaMode: configController.currentMediaMode,
    );
    if(detils == null) {
      isLoading.value = false;
      return;
    }
    sentencesDetils.value = detils;
    _updateDetailBreadcrumbTitle(detils);
    refreshFavoritedStatus();
    isLoading.value = false;
    if(detils.module == ElementsJumpModuleType.SYNTACTIC_ANALYSIS){
      changeStructuralSyntaxTabbarIndex(1);
    }else if(detils.module == ElementsJumpModuleType.STRUCTURE_ANALYSIS){
       changeStructuralSyntaxTabbarIndex(0);
    }else if(detils.module == ElementsJumpModuleType.CHUNK_ANALYSIS){
      changeStructuralSyntaxTabbarIndex(0);
      changeStructureTabControllerIndex(0);
    }else if(detils.module == ElementsJumpModuleType.COMPONENT_ANALYSIS){
      changeStructuralSyntaxTabbarIndex(0);
      changeStructureTabControllerIndex(1);
    }else if(detils.module == ElementsJumpModuleType.GRID_VIEW){
      changeStructuralSyntaxTabbarIndex(0);
      changeStructureTabControllerIndex(0);
      changeGridOrFoldTagIndex(0);
    }else if(detils.module == ElementsJumpModuleType.COLLAPSE_VIEW){
      changeStructuralSyntaxTabbarIndex(0);
      changeStructureTabControllerIndex(0);
      changeGridOrFoldTagIndex(1);
    }
  }

  Future<void> reloadForStyleChange() async {
    try {
      ToastUtils.showLoading();
      isLoading.value = true;
      await getDetils();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  void _updateDetailBreadcrumbTitle(CardSentencesDetilsEntity detils) {
    final String title = (detils.content ?? '').trim();
    if (title.isEmpty) return;
    updateBreadcrumbTitle(title);
  }


  void changeHideTranslation(){
    hideTranslation.value = !hideTranslation.value;
  }

  /// 结构/句法分析tab
  void changeStructuralSyntaxTabbarIndex(int index){
    structuralSyntaxTabbarIndex.value = index;
  }

  /// 语块分析/成分分析 tab
  void changeStructureTabControllerIndex(int index){
    structureTabControllerIndex.value = index;
    sentenceStructureDetailSelectIndex.value = -1;
    if(index == 1){
      gridOrFoldTagIndex.value = 0;
    }
  }

  /// 网格视图/折叠视图tag
  void changeGridOrFoldTagIndex(int index){
    if(structureTabControllerIndex.value == 1) return;
    sentenceStructureDetailSelectIndex.value = -1;
    gridOrFoldTagIndex.value = index;
  }

  /// 句子结构表网格视图序号选择下标 要根据下标改变 下面的 结构详情
  void changeSentenceStructureTableSelectIndex(int index){
    sentenceStructureTableSelectIndex.value = index;
  }

  /// 句子结构详情 选择模块的下标 点击结构表网格视图中的单词
  Future<void> toSentenceStructureDetailSelectIndex(int index) async{
    await autoScrollController.scrollToIndex(index + 2, preferPosition: AutoScrollPosition.begin);
    await Future.delayed(const Duration(milliseconds: 300));
    sentenceStructureDetailSelectIndex.value = index;
  }

  /// 句法分析 分叉树 跳转
  Future<void> toSentenceGraphTableIndex(String word) async{
    List<CardSentencesDetilsEntityStructs?>? list = sentencesDetils.value.structs;
    if(list == null) return;
    int index = list.indexWhere((element) => element?.content == word);
    if(index == -1) return;


    isHoveringGraph.value = false;
    await autoScrollController.scrollToIndex(index + 2, preferPosition: AutoScrollPosition.begin);
    await Future.delayed(const Duration(milliseconds: 300));
    graphAutoToIndex.value = index;
    await Future.delayed(const Duration(seconds: 2));
    graphAutoToIndex.value = -1;
  }

  void changeTagTabbarIndex(int jumpIndex){
    
    if(jumpIndex == 0){
      autoScrollController.animateTo(0, duration: Durations.short4, curve: Curves.easeIn);
    }else{
      autoScrollController.scrollToIndex(jumpIndex, preferPosition: AutoScrollPosition.begin, duration: Durations.short4);
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
