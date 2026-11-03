import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/public_controller/config_controller.dart';
import '../../elements_morpheme_detils/bindings/elements_morpheme_detils_binding.dart';
import '../../elements_morpheme_detils/views/elements_morpheme_detils_view.dart';
import '../../model/elements_card_detils_tab_model.dart';

class ElementsWordDetilsController extends GetxController with GetTickerProviderStateMixin{
  // 传进来的参数
  int? contentId;
  /// * 外部传进来的参数，用来定位滚动视图
  /// * [ElementsJumpModuleType]
  String? jumpType;
  /// 传进来的御医id
  List<int?>? semanticIds;

  final ConfigController configController = Get.find<ConfigController>();

  /// 详情的全部数据
  final Rx<CardWordDetilsEntity> cardWordDetils = CardWordDetilsEntity().obs;
  /// 每个tab的数据
  final RxList<CardWordDetilsEntityPosList> cardPosList = <CardWordDetilsEntityPosList>[].obs;

  /// 左边卡片图片
  final RxString leftCardImage = "".obs;

  /// tab信息
  final RxList<ElementsCardDetilsTabModel> tabListData = <ElementsCardDetilsTabModel>[].obs;
  

  late final TabController tabController;
  final RxInt currentTabIndex = 0.obs;

  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    if(Get.arguments != null){
      contentId = Get.arguments['contentId'];
      jumpType = Get.arguments['jumpType'];
      semanticIds = Get.arguments['semanticIds'];
      // contentId = 103249;
      initData();
    }
  }

  Future<void> initData() async{
    try {
      ToastUtils.showLoading();
      await getRightCount();
      await getDetils();
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


  /// 获取单词详细信息
  Future<void> getDetils() async{
    if(contentId == null) return;
    CardWordDetilsEntity? detils = await ElementsRequest.getWordDetils(contentId!, module: jumpType, semanticIds: semanticIds);
    if(detils == null) return;
    cardWordDetils.value = detils;
    cardPosList.clear();
    for(int i = 0; i < detils.posList!.length; i++){
      if(detils.posList![i] == null) continue;
      cardPosList.add(detils.posList![i]!);
    }
    initTabController();
    
  }

  /// 设置tab信息
  void initTabController(){
    int initTabIndex = 0;
    
    for(int i = 0; i < cardPosList.length; i++){
      ScrollController scrollController = ScrollController();
      if(cardWordDetils.value.contentId == cardPosList[i].contentId){
        currentTabIndex.value = i;
        initTabIndex = i;
      }
      LanguageConfigColorModel? indicatorColor = StatusUtils.getConfigColor(configController.colorConfigs.value.pos, cardPosList[i].pos);

      tabListData.add(
        ElementsCardDetilsTabModel(
          potTitle: cardPosList[i].potTitle??[],
          pos: cardPosList[i].pos??"",
          contentId: cardPosList[i].contentId,
          contentType: cardPosList[i].contentType,
          scrollController: scrollController,
          observerController: ListObserverController(controller: scrollController),
          tagTabbarIndex: 0.obs,
          indicatorColor: indicatorColor?.color?.borderColor??AppTheme.cBgBrand,
        ),
      );
    }
    

    tabController = TabController(length: tabListData.length, vsync: this, initialIndex: initTabIndex);
    tabController.addListener(() {
      currentTabIndex.value = tabController.index;
      tabListData[currentTabIndex.value].observerController.jumpTo(index: 0);
      tabListData[currentTabIndex.value].tagTabbarIndex.value = 0;
      if(tabController.indexIsChanging){
        changeLeftImage(currentTabIndex.value, 0);
      }
      
    });

    changeLeftImage(initTabIndex, 0);
    isLoading.value = false;
    
  }


  void changeTagTabbarIndex(int tabIndex, int index){
    
    tabListData[tabIndex].observerController.animateTo(
      index: index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.ease,
    );
    

  }

  /// 根据语义切换左边的图片
  void changeLeftImage(int tabIndex, int semanticsIndex){
    if(tabIndex != currentTabIndex.value) return;
    List<CardWordDetilsEntityPosListSemantics?> semantics = cardPosList[tabIndex].semantics??[];
    if(semanticsIndex >= semantics.length) return;
    String imageUrl = semantics[semanticsIndex]?.imageUrl??"";
    if(leftCardImage.value == imageUrl) return;
    leftCardImage.value = imageUrl;
  }
  
  /// 根据语法特性切换左边的图片
  void setLeftImageForGrammaticale(int tabIndex){
    if(tabIndex != currentTabIndex.value) return;
    String? imageUrl = cardPosList[tabIndex].grammatical?.first?.inflections?.pluralInfo?.imageUrl;
    if(imageUrl == null) return;
    if(leftCardImage.value == imageUrl) return;
    leftCardImage.value = imageUrl;
  }

  /// 去词素详情
  Future<void> toMorphemeDetils(BuildContext context, CardWordDetilsEntityPosListMorphologyMorphemes? data, String pos) async{
    if(data == null) return;
    if(data.disable == true) return;
    Get.to(
      ElementsMorphemeDetilsView(tagText: "${data.content}+${data.type}"),
      preventDuplicates: false,
      binding: ElementsMorphemeDetilsBinding(tagText: "${data.content}+${data.type}"),
      arguments: {
        "content": data.content,
        "type": data.type,
        "pos": pos,
      },
    );
  }


  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    if(!isLoading.value){
      tabController.dispose();
    }
    super.onClose();
  }
}
