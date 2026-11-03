import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/public_controller/config_controller.dart';
import '../../../../../theme/theme.dart';
import '../../../../../utils/utils.dart';
import '../../../../routes/routes.dart';
import '../../common/elements_bottom_menu_widget.dart';
import '../../model/elements_card_detils_tab_model.dart';

class ElementsPhraseDetilsController extends GetxController with GetTickerProviderStateMixin{

  // 传进来的参数
  int? contentId;
  /// * 外部传进来的参数，用来定位滚动视图
  /// * [ElementsJumpModuleType]
  String? jumpType;
  /// 传进来的semanticIds
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


  /// 获取短语详细信息
  Future<void> getDetils() async{
    if(contentId == null) return;
    CardWordDetilsEntity? detils = await ElementsRequest.getPhraseDetils(contentId!, module: jumpType, semanticIds: semanticIds);
    if(detils == null) return;
    // detils.semanticId = 758183;
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
      if(contentId == cardPosList[i].contentId){
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

  void changeLeftImage(int tabIndex, int semanticsIndex){
    if(tabIndex != currentTabIndex.value) return;
    List<CardWordDetilsEntityPosListSemantics?> semantics = cardPosList[tabIndex].semantics??[];
    if(semanticsIndex >= semantics.length) return;
    String imageUrl = semantics[semanticsIndex]?.imageUrl??"";
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

  Future<void> bottomMenuTypeFun(ElementsBottomMenuType type, BuildContext context) async{
    if(type == ElementsBottomMenuType.upgradeCard){
      await showUpgradeCardDialog(context);
    }else if(type == ElementsBottomMenuType.collectCard){
      await collectCard(context);
    }
  }

  Future<void> showUpgradeCardDialog(BuildContext context) async{
    dynamic updateRes = await Get.toNamed(
      Routes.ELEMENTS_UPGRADE_CARD,
      arguments: {
        "knowledge": "a boy",
      },
    );
    if(updateRes == null) return;
    // TODO: 升卡
    dynamic pageRes = await Get.toNamed(Routes.PRACTICE_QUESTIONS);
    if(pageRes == null) return;
    // ElementsStartUpgradeDialog.show(context: context);

  }

  /// 集卡
  Future<void> collectCard(BuildContext context) async{
    // dynamic collectRes = await Get.toNamed(
    //   Routes.ELEMENTS_COLLECT_CARD,
    //   arguments: {
    //     "knowledge": "see",
    //   },
    // );
    // if(collectRes == null) return;
    // dynamic pageRes = await Get.toNamed(Routes.PRACTICE_QUESTIONS);
    // if(pageRes == null) return;
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
