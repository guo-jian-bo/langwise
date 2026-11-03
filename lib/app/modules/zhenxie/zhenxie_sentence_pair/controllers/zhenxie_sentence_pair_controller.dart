import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../../common/mixins/mixins.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../routes/tag_routes.dart';

class ZhenxieSentencePairController extends GetxController with DualBreadcrumbMixin {
  final String tagText;
  ZhenxieSentencePairController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.ZHENXIE_SENTENCE_PAIR;

  @override
  String get breadcrumbTitle => '句间配链';

  /// 是否是管理端入口打开
  bool isManagement = false;
  /// 筛选 - 配对类型(pairType) 默认选择的 nid 列表
  List<String?>? filterPairTypeNids;

  /// 配对列表排序项
  final RxMap<String, FilterSortsData> pairFilterSorts = <String, FilterSortsData>{}.obs;
  /// 分叉列表排序项
  final RxMap<String, FilterSortsData> forkFilterSorts = <String, FilterSortsData>{}.obs;

  /// 配对列表筛选项
  final RxMap<String, FilterConditionsData> pairFilterConditions = <String, FilterConditionsData>{}.obs;
  /// 分叉列表筛选项
  final RxMap<String, FilterConditionsData> forkFilterConditions = <String, FilterConditionsData>{}.obs;

  /// 配对列表搜索项
  final Map<String, FilterSearchsData> pairFilterSearchs = {
    "content": FilterSearchsData(
      title: "搜索",
      hintText: "名称",
      controller: TextEditingController(),
    ),
  };
  /// 分叉列表搜索项
  final Map<String, FilterSearchsData> forkFilterSearchs = {
    "content": FilterSearchsData(
      title: "搜索",
      hintText: "名称",
      controller: TextEditingController(),
    ),
  };

  /// tab 配对/分叉
  final RxInt tab = 0.obs;
  
  /// 配对列表
  final RxList<SentencePairEntity> sentencePairList = <SentencePairEntity>[].obs;
  /// 分叉列表
  final RxList<SentenceForkEntity> sentenceForkList = <SentenceForkEntity>[].obs;
  
  /// 配对列表滚动控制器
  final ScrollController pairScrollController = ScrollController();
  /// 配对列表滚动位置
  double pairScrollPosition = 0.0;
  /// 分叉列表滚动控制器
  final ScrollController forkScrollController = ScrollController();
  /// 分叉列表滚动位置
  double forkScrollPosition = 0.0;

  /// 配对列表总条数
  final RxInt pairTotal = 0.obs;
  /// 分叉列表总条数
  final RxInt forkTotal = 0.obs;

  /// 配对列表 offset
  int pairOffset = 0;
  /// 分叉列表 offset
  int forkOffset = 0;

  /// 配对列表 limit
  int pairLimit = 20;
  /// 分叉列表 limit
  int forkLimit = 20;

  /// 配对列表是否加载中
  final RxBool pairIsLoading = false.obs;
  /// 分叉列表是否加载中
  final RxBool forkIsLoading = false.obs;


  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      isManagement = Get.arguments['isManagement'] ?? false;
      filterPairTypeNids = Get.arguments["filterPairTypeNids"]?.cast<String?>();
    }
    initBreadcrumb(tagText);
    listenScroll();
    initData();
  }

  Future<void> initData() async{
    try {
      pairIsLoading.value = true;
      ToastUtils.showLoading();
      await getPairFiltersGroup();
      await getPairListData(showLoading: false);

      getForkFiltersGroup().then((value){
        getForkListData(showLoading: false);
      });

    } finally{
      pairIsLoading.value = false;
      ToastUtils.hideLoading();
    }
  }

  /// 监听列表滚动进行分页加载
  void listenScroll(){
    pairScrollController.addListener(() {
      pairScrollPosition = pairScrollController.position.pixels;
      if(pairScrollPosition >= pairScrollController.position.maxScrollExtent - 200 && !pairScrollController.position.outOfRange){
        if(!pairIsLoading.value && sentencePairList.length < pairTotal.value){
          pairOffset += pairLimit;
          getPairListData();
        }
      }
    });
    forkScrollController.addListener(() {
      forkScrollPosition = forkScrollController.position.pixels;
      if(forkScrollPosition >= forkScrollController.position.maxScrollExtent - 200 && !forkScrollController.position.outOfRange){
        if(!forkIsLoading.value && sentenceForkList.length < forkTotal.value){
          forkOffset += forkLimit;
          getForkListData();
        }
      }
    });
  }

  /// 获取配链筛选数据
  Future<void> getPairFiltersGroup() async{
    try {
      FiltersGroupEntity? filtersGroup;
      if (isManagement) {
        filtersGroup = await LanguageConsoleRequest.getPairFiltersGroup();
      } else {
        filtersGroup = await LanguageUtil.getSentencePairFiltersGroup();
      }
      if(filtersGroup == null) return;
      pairFilterConditions.value = FilterStripUtils.getConditionDataFrom(filtersGroup);
      pairFilterSorts.value = FilterStripUtils.getSortDataFrom(filtersGroup);

      if(filterPairTypeNids == null) return;
      pairFilterConditions["pairType"]?.conditions.forEach((element) {
        if(filterPairTypeNids?.contains(element.value) == true){
          element.selected = true;
        } 
      });

    } catch (_) {}
  }

  /// 获取分叉筛选数据
  Future<void> getForkFiltersGroup() async{
    try {
      FiltersGroupEntity? filtersGroup;
      if (isManagement) {
        filtersGroup = await LanguageConsoleRequest.getForkFiltersGroup();
      } else {
        filtersGroup = await LanguageUtil.getSentenceForkFiltersGroup();
      }
      if(filtersGroup == null) return;
      forkFilterConditions.value = FilterStripUtils.getConditionDataFrom(filtersGroup);
      forkFilterSorts.value = FilterStripUtils.getSortDataFrom(filtersGroup);
    } catch (_) {}
  }



  /// 切换tab
  void switchTab(int value){
    if(tab.value == value) return;
    tab.value = value;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(tab.value == 0){
        if(!pairScrollController.hasClients) return;
        pairScrollController.jumpTo(pairScrollPosition);
      }else{
        if(!forkScrollController.hasClients) return;
        forkScrollController.jumpTo(forkScrollPosition);
      }
    });
  }

  /// 刷新列表
  Future<void> refreshList() async{
    if(tab.value == 0){
      sentencePairList.clear();
      pairOffset = 0;
      pairTotal.value = 0;
      await getPairListData();
    }else{
      sentenceForkList.clear();
      forkOffset = 0;
      forkTotal.value = 0;
      await getForkListData();
    }
  }

  /// 获取配对列表
  Future<void> getPairListData({bool showLoading = true}) async {
    try {
      pairIsLoading.value = true;
      if(showLoading) ToastUtils.showLoading();
      ListResponseEntity<SentencePairEntity>? list;
      if (isManagement) {
        list = await LanguageConsoleRequest.querySentencePairList(
          parameters: _buildPairListParameters(),
          data: _buildPairListRequestData(),
        );
      } else {
        list = await LanguageUtil.querySentencePairList(
          parameters: _buildPairListParameters(),
          data: _buildPairListRequestData(),
        );
      }
      if(list == null) return;
      pairTotal.value = list.count??0;
      sentencePairList.addAll(list.datas??[]);
    }finally{
      pairIsLoading.value = false;
      if(showLoading) ToastUtils.hideLoading();
    }
  }

  /// 刷新单个配对数据
  Future<void> refreshPairDetail(SentencePairEntity pair) async{
    if(pair.nid == null) return;
    try {
      Map<String, dynamic> reqData = {
        "nid": pair.nid,
      };
      ListResponseEntity<SentencePairEntity>? list;
      if (isManagement) {
        list = await LanguageConsoleRequest.querySentencePairList(
          data: reqData,
        );
      } else {
        list = await LanguageUtil.querySentencePairList(
          data: reqData,
        );
      }
      if(list == null) return;
      List<SentencePairEntity> pairs = list.datas??[];
      for (var i = 0; i < sentencePairList.length; i++) {
        for (var j = 0; j < pairs.length; j++) {
          if(sentencePairList[i].nid == pairs[j].nid){
            sentencePairList[i] = pairs[j];
            sentencePairList.refresh();
            break;
          }
        }
      }

    } catch (_) {}
  }


  /// 获取分叉列表
  Future<void> getForkListData({bool showLoading = true}) async {
    try {
      forkIsLoading.value = true;
      if(showLoading) ToastUtils.showLoading();
      
      ListResponseEntity<SentenceForkEntity>? list;
      if (isManagement) {
        list = await LanguageConsoleRequest.querySentenceForkList(
          parameters: _buildForkListParameters(),
          data: _buildForkListRequestData(),
        );
      } else {
        list = await LanguageUtil.querySentenceForkList(
          parameters: _buildForkListParameters(),
          data: _buildForkListRequestData(),
        );
      }
      if(list == null) return;
      forkTotal.value = list.count??0;
      sentenceForkList.addAll(list.datas??[]);
    }finally{
      forkIsLoading.value = false;
      if(showLoading) ToastUtils.hideLoading();
    }
  }

  /// 刷新单个分叉数据
  Future<void> refreshForkDetail(SentenceForkEntity pair) async{
    if(pair.nid == null) return;
    try {
      Map<String, dynamic> reqData = {
        "nid": pair.nid,
      };
      ListResponseEntity<SentenceForkEntity>? list;
      if (isManagement) {
        list = await LanguageConsoleRequest.querySentenceForkList(
          data: reqData,
        );
      } else {
        list = await LanguageUtil.querySentenceForkList(
          data: reqData,
        );
      }
      if(list == null) return;
      List<SentenceForkEntity> pairs = list.datas??[];  
      for (var i = 0; i < sentenceForkList.length; i++) {
        for (var j = 0; j < pairs.length; j++) {
          if(sentenceForkList[i].nid == pairs[j].nid){
            sentenceForkList[i] = pairs[j];
            sentenceForkList.refresh();
            break;
          }
        }
      }

    } catch (_) {}
  }

  /// 组装配对列表分页与排序参数
  Map<String, dynamic> _buildPairListParameters(){
    Map<String, dynamic> params = {
      "offset": pairOffset,
      "limit": pairLimit,
    };
    Map<String, dynamic> sortParams = FilterStripUtils.getSortOrderParameter(sorts: pairFilterSorts);
    if(sortParams.isNotEmpty){
      params.addAll(sortParams);
    }
    return params;
  }

  /// 组装配对列表筛选与搜索参数
  Map<String, dynamic> _buildPairListRequestData(){
    Map<String, dynamic> reqData = {};
    Map<String, dynamic> conditionParams = FilterStripUtils.getConditionParameter(
      conditions: pairFilterConditions,
      singleToList: true,
    );
    List<Map<String, dynamic>> filters = [];
    conditionParams.forEach((key, value) {
      filters.add({
        "code": key,
        "values": value,
      });
    });
    if(filters.isNotEmpty){
      reqData["filters"] = filters;
    }

    Map<String, dynamic> searchParams = FilterStripUtils.getSearchParameter(searchs: pairFilterSearchs);
    if(searchParams.isNotEmpty){
      reqData.addAll(searchParams);
    }
    return reqData;
  }

  /// 组装分叉列表分页与排序参数
  Map<String, dynamic> _buildForkListParameters(){
    Map<String, dynamic> params = {
      "offset": forkOffset,
      "limit": forkLimit,
    };
    Map<String, dynamic> sortParams = FilterStripUtils.getSortOrderParameter(sorts: forkFilterSorts);
    if(sortParams.isNotEmpty){
      params.addAll(sortParams);
    }
    return params;
  }

  /// 组装分叉列表筛选与搜索参数
  Map<String, dynamic> _buildForkListRequestData(){
    Map<String, dynamic> reqData = {};
    Map<String, dynamic> conditionParams = FilterStripUtils.getConditionParameter(
      conditions: forkFilterConditions,
      singleToList: true,
    );
    List<Map<String, dynamic>> filters = [];
    conditionParams.forEach((key, value) {
      filters.add({
        "code": key,
        "values": value,
      });
    });
    if(filters.isNotEmpty){
      reqData["filters"] = filters;
    }

    Map<String, dynamic> searchParams = FilterStripUtils.getSearchParameter(searchs: forkFilterSearchs);
    if(searchParams.isNotEmpty){
      reqData.addAll(searchParams);
    }
    return reqData;
  }


  /// 跳转至配对详情页面
  Future<void> jumpToPairDetailPage(SentencePairEntity pair) async{
    if(pair.nid == null) return;
    await TagRoutes.toNamed(
      Routes.ZHENXIE_SENTENCE_PAIR_DETAILS,
      arguments: {
        "nid": pair.nid,
        "isManagement": isManagement,
      },
    );
    await refreshPairDetail(pair);
  }

  /// 跳转至分叉详情页面
  Future<void> toForkDetails(SentenceForkEntity fork) async{
    if(fork.nid == null) return;
    await TagRoutes.toNamed(
      Routes.ZHENXIE_SENTENCE_PAIR_FORK_DETAILS,
      arguments: {
        "nid": fork.nid,
        "isManagement": isManagement,
      },
    );
    await refreshForkDetail(fork);
  } 

  @override
  void onClose() {
    pairScrollController.dispose();
    forkScrollController.dispose();
    for(final item in pairFilterSearchs.values){
      item.controller.dispose();
    }
    for(final item in forkFilterSearchs.values){
      item.controller.dispose();
    }
    super.onClose();
  }
}
