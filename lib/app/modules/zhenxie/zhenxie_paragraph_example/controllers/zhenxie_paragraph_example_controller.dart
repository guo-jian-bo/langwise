import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/mixins/mixins.dart';
import '../../../../../utils/utils.dart';

class ZhenxieParagraphExampleController extends GetxController with DualBreadcrumbMixin {
  final String tagText;
  ZhenxieParagraphExampleController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.ZHENXIE_PARAGRAPH_EXAMPLE;

  @override
  String get breadcrumbTitle => "段落实例";

  // 传进来的参数
  /// 是否是管理端
  bool isManagement = false;
  

  final RxList<ParagraphExampleEntityList> dataList = <ParagraphExampleEntityList>[].obs;

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
    getDataList();
  }

  /// 查询段落例句列表
  Future<void> getDataList() async{
    try {
      isLoading.value = true;
      ToastUtils.showLoading();
      ParagraphExampleEntity? entity = await LanguageConsoleRequest.getParagraphExampleList();
      if(entity == null) return;
      List<ParagraphExampleEntityList?> list = entity.list??[];
      dataList.clear();
      for(ParagraphExampleEntityList? item in list){
        if(item == null) continue;
        dataList.add(item);
      }
    } finally{
      isLoading.value = false;
      ToastUtils.hideLoading();
    }
  }
  

  /// 切换tab
  void switchTab(int index){
    if (dataList.isEmpty) return;
    if (isBottomTabScrolling) {
      if (bottomTabTargetIndex == dataList.length - 1) {
        if (_isAtListBottom()) {
          currentTabIndex.value = dataList.length - 1;
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
    if(index == dataList.length - 1){
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




  @override
  void onClose() {
    scrollController.removeListener(_syncLastTabWhenReachBottom);
    super.onClose();
  }
}
