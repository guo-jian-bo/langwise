import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/mixins/mixins.dart';
import '../../../../../utils/utils.dart';
import '../../../../routes/tag_routes.dart';

class ZhenxieArticleBlueprintController extends GetxController with DualBreadcrumbMixin {
  final String tagText;
  ZhenxieArticleBlueprintController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.ZHENXIE_ARTICLE_BLUEPRINT;

  @override
  String get breadcrumbTitle => "文章蓝图";

  // 传进来的参数
  /// 是否是管理端
  bool isManagement = false;

  /// 段落/文章的步骤
  final RxList<ParagraphRhetoricalEntityList> paragraphRhetoricalList = <ParagraphRhetoricalEntityList>[].obs;

  /// 列表数据
  final RxList<ArticleBlueprintEntity> dataList = <ArticleBlueprintEntity>[].obs;

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
    }
    scrollObserverController = ListObserverController(controller: scrollController);
    scrollController.addListener(_syncLastTabWhenReachBottom);
    initData();
  }

  Future<void> initData() async{
    try {
      isLoading.value = true;
      ToastUtils.showLoading();
      await getParagraphRhetoricalList();
      await getDataList();
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

  Future<void> getDataList() async{
    try {
      Map<String, dynamic> parameters = {
        "offset": 0,
        "limit": 100,
      };
      ListResponseEntity<ArticleBlueprintEntity>? entity;
      if (isManagement) {
        entity = await LanguageConsoleRequest.getArticleBlueprintList(
          parameters: parameters,
          data: {},
        );
      } else {
        entity = await LanguageUtil.getArticleBlueprintList(
          parameters: parameters,
          data: {},
        );
      }
      if(entity == null) return;
      List<ArticleBlueprintEntity?> list = entity.datas??[];
      dataList.clear();
      for(ArticleBlueprintEntity? item in list){
        if(item == null) continue;
        dataList.add(item);
      }
    } catch (_) {}
  }



  /// 切换tab
  void switchTab(int index){
    if (dataList.isEmpty) return;
    if (isBottomTabScrolling) {
      if (index == bottomTabTargetIndex) {
        currentTabIndex.value = index;
        _clearBottomTabScrollingState();
        return;
      }
      if (bottomTabTargetIndex == dataList.length - 1 && _isAtListBottom()) {
        currentTabIndex.value = dataList.length - 1;
        _clearBottomTabScrollingState();
      }
      return;
    }
    if (_isAtListBottom()) {
      currentTabIndex.value = dataList.length - 1;
      return;
    }
    currentTabIndex.value = index;
  }

  /// 底部tab切换
  void switchBottomTab(int index){
    isBottomTabScrolling = true;
    bottomTabTargetIndex = index;
    currentTabIndex.value = index;
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
    if (dataList.isEmpty) return;
    if (!_isAtListBottom()) return;
    currentTabIndex.value = dataList.length - 1;
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

  /// 跳转到详情
  Future<void> toDetails(ArticleBlueprintEntity data, {ArticleBlueprintEntityBlueprints? blueprint}) async{
    TagRoutes.toNamed(
      Routes.ZHENXIE_ARTICLE_BLUEPRINT_DETAILS,
      arguments: {
        "isManagement": isManagement,
        "nid": data.nid,
        "blueprintNid": blueprint?.nid,
      },
    );
  }

  @override
  void onClose() {
    scrollController.removeListener(_syncLastTabWhenReachBottom);
    scrollController.dispose();
    super.onClose();
  }
}
