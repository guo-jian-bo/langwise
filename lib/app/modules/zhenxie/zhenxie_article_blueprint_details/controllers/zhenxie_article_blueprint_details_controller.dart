import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/mixins/mixins.dart';
import '../../../../../utils/utils.dart';

class ZhenxieArticleBlueprintDetailsController extends GetxController with DualBreadcrumbMixin {
  final String tagText;
  ZhenxieArticleBlueprintDetailsController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.ZHENXIE_ARTICLE_BLUEPRINT_DETAILS;

  @override
  String get breadcrumbTitle => "文章蓝图详情";

  // 传进来的参数
  /// nid
  String? nid;
  /// 蓝图 nid
  String? blueprintNid;
  /// 是否是管理端
  bool isManagement = false;

  /// 段落/文章的步骤
  final RxList<ParagraphRhetoricalEntityList> paragraphRhetoricalList = <ParagraphRhetoricalEntityList>[].obs;
  /// 详情数据
  final Rx<ArticleBlueprintEntity> detailData = ArticleBlueprintEntity().obs;
  /// 是否加载中
  final RxBool isLoading = false.obs;

  /// 滚动视图控制器
  final ScrollController scrollController = ScrollController();

  /// 滚动视图显示控制器
  late final ListObserverController scrollObserverController;

  /// 当前触发到的索引
  final RxInt currentTabIndex = 0.obs;

  /// 是否正在执行底部 tab 触发的程序化滚动
  bool isBottomTabScrolling = false;

  /// 程序化滚动要命中的目标 tab 下标
  int? bottomTabTargetIndex;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    if(Get.arguments != null){
      isManagement = Get.arguments["isManagement"]??false;
      nid = Get.arguments["nid"];
      blueprintNid = Get.arguments["blueprintNid"];
    }
    scrollObserverController = ListObserverController(controller: scrollController);
    scrollController.addListener(_syncLastTabWhenReachBottom);
    initData(init: true);
  }

  Future<void> initData({bool init = false}) async{
    try {
      isLoading.value = true;
      ToastUtils.showLoading();
      await getParagraphRhetoricalList();
      await getDataDetail();
      if(init){
        initScrollToBlueprintNid();
      }
    } finally{
      isLoading.value = false;
      ToastUtils.hideLoading();
    }
  }

  /// 段落/文章的步骤
  Future<void> getParagraphRhetoricalList() async{
    try {
      ParagraphRhetoricalEntity? entity = await LanguageUtil.getParagraphRhetoricalList();
      if(entity == null) return;
      List<ParagraphRhetoricalEntityList?> list = entity.list??[];
      paragraphRhetoricalList.clear();
      for(ParagraphRhetoricalEntityList? item in list){
        if(item == null) continue;
        paragraphRhetoricalList.add(item);
      }
    } catch (_) {}
  }

  Future<void> getDataDetail() async{
    if(nid == null && blueprintNid == null) return;
    try {
      Map<String, dynamic> parameters = {
        "familyNid": nid,
        "blueprintNid": blueprintNid,
      };
      ArticleBlueprintEntity? entity;
      if (isManagement) {
        entity = await LanguageConsoleRequest.getArticleBlueprintDetail(
          parameters: parameters,
        );
      } else {
        entity = await LanguageUtil.getArticleBlueprintDetail(
          parameters: parameters,
        );
      }
      if(entity == null) return;
      detailData.value = entity;

    } catch (_) {}
  }

  /// 初始化滚动到对应的blueprintNid
  void initScrollToBlueprintNid(){
    if(blueprintNid == null) return;
    List<ArticleBlueprintEntityBlueprints?> list = detailData.value.blueprints??[];
    if(list.isEmpty) return;
    int index = list.indexWhere((element) => element?.nid == blueprintNid);
    if(index == -1) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      switchBottomTab(index);
    });
  }




  /// 切换tab
  void switchTab(int index){
    List<ArticleBlueprintEntityBlueprints?> list = detailData.value.blueprints??[];
    if (list.isEmpty) return;
    if (isBottomTabScrolling) {
      if (bottomTabTargetIndex == list.length - 1) {
        if (_isAtListBottom()) {
          currentTabIndex.value = list.length - 1;
          _clearBottomTabScrollingState();
        }
        return;
      }
      if (index == bottomTabTargetIndex) {
        currentTabIndex.value = index;
        _clearBottomTabScrollingState();
      }
      return;
    }
    if (_isAtListBottom()) {
      currentTabIndex.value = list.length - 1;
      return;
    }
    currentTabIndex.value = index;
  }

  /// 底部tab切换
  void switchBottomTab(int index){
    isBottomTabScrolling = true;
    bottomTabTargetIndex = index;
    currentTabIndex.value = index;
    List<ArticleBlueprintEntityBlueprints?> list = detailData.value.blueprints??[];
    if(index == list.length - 1){
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      ).whenComplete(() {
        _clearBottomTabScrollingState();
      });
      return;
    }
    scrollObserverController.animateTo(
      index: index, 
      duration: Duration(milliseconds: 200), 
      curve: Curves.easeInOut,
      alignment: 0,
    ).whenComplete(() {
      _clearBottomTabScrollingState();
    });

  }

  /// 滚动到底部时，强制同步到底部 tab，避免被首个可见项回写成倒数第二个
  void _syncLastTabWhenReachBottom() {
    List<ArticleBlueprintEntityBlueprints?> list = detailData.value.blueprints??[];
    if (list.isEmpty) return;
    if (!_isAtListBottom()) return;
    currentTabIndex.value = list.length - 1;
    _clearBottomTabScrollingState();
  }

  /// 判断当前列表是否已经滚动到底部
  bool _isAtListBottom() {
    if (!scrollController.hasClients) return false;
    return scrollController.position.pixels >= scrollController.position.maxScrollExtent - 1;
  }

  /// 清空底部 tab 程序化滚动状态
  void _clearBottomTabScrollingState() {
    isBottomTabScrolling = false;
    bottomTabTargetIndex = null;
  }

  @override
  void onClose() {
    scrollController.removeListener(_syncLastTabWhenReachBottom);
    scrollController.dispose();
    super.onClose();
  }
}
