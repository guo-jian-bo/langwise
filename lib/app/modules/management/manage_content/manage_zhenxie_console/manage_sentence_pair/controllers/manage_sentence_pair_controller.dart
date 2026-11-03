import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../routes/routes.dart';
import '../../../../utils/utils.dart';

class ManageSentencePairController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageSentencePairController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_SENTENCE_PAIR;

  @override
  String get breadcrumbTitle => '句间配链';

  final RxMap<String, FilterSortsData> filterSorts = <String, FilterSortsData>{}.obs;

  final RxMap<String, FilterConditionsData> filterConditions = <String, FilterConditionsData>{}.obs;

  final Map<String, FilterSearchsData> filterSearchs = {
    "content": FilterSearchsData(
      title: "搜索",
      hintText: "name / nid / pattern / 教例",
      controller: TextEditingController(),
    ),
  };

  /// tab 配对/分叉
  final RxInt tab = 0.obs;
  
  /// 配对列表
  final RxList<SentencePairEntity> sentencePairList = <SentencePairEntity>[].obs;
  /// 分叉列表
  final RxList<SentenceForkEntity> sentenceForkList = <SentenceForkEntity>[].obs;

  /// 滚动控制器
  final ScrollController scrollController = ScrollController();
  /// 总条数
  int total = 0;
  /// offset
  int offset = 0;
  /// limit
  int limit = 20;
  /// 是否加载中
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    listenScroll();
    refreshList();
    getPairFiltersGroup();
  }

  /// 监听列表滚动进行分页加载
  void listenScroll(){
    scrollController.addListener(() {
      if(scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200 && !scrollController.position.outOfRange){
        int length = tab.value == 0 ? sentencePairList.length : sentenceForkList.length;
        if(!isLoading.value && length < total){
          offset += limit;
          if(tab.value == 0){
            getPairListData();
          }else{
            getForkListData();
          }
        }
      }
    });
  }

  /// 获取配链筛选数据
  Future<void> getPairFiltersGroup() async{
    try {
      FiltersGroupEntity? filtersGroup = await LanguageConsoleRequest.getPatternBlueprintFilters();
      if(filtersGroup == null) return;
      filterConditions.value = FilterStripUtils.getConditionDataFrom(filtersGroup);
      filterSorts.value = FilterStripUtils.getSortDataFrom(filtersGroup);
    } catch (_) {}
  }

  /// 获取分叉筛选数据
  Future<void> getForkFiltersGroup() async{
    try {
      FiltersGroupEntity? filtersGroup = await LanguageConsoleRequest.getPatternBlueprintFilters();
      if(filtersGroup == null) return;
      filterConditions.value = FilterStripUtils.getConditionDataFrom(filtersGroup);
      filterSorts.value = FilterStripUtils.getSortDataFrom(filtersGroup);
    } catch (_) {}
  }



  /// 切换tab
  void switchTab(int value){
    if(tab.value == value) return;
    if(scrollController.hasClients){
      scrollController.jumpTo(0);
    }
    tab.value = value;
    filterSearchs["content"]?.controller.clear();
    if(tab.value == 0){
      getPairFiltersGroup();
    }else{
      getForkFiltersGroup();
    }
    refreshList();
  }

  /// 刷新列表
  Future<void> refreshList() async{
    sentencePairList.clear();
    sentenceForkList.clear();
    offset = 0;
    total = 0;
    if(tab.value == 0){
      await getPairListData();
    }else{
      await getForkListData();
    }
  }

  /// 获取配对列表
  Future<void> getPairListData() async {
    try {
      isLoading.value = true;
      ToastUtils.showLoading();
      ListResponseEntity<SentencePairEntity>? list = await LanguageConsoleRequest.querySentencePairList(
        parameters: _buildListParameters(),
        data: _buildListRequestData(),
      );
      if(list == null) return;
      total = list.count??0;
      sentencePairList.addAll(list.datas??[]);
    }finally{
      isLoading.value = false;
      ToastUtils.hideLoading();
    }
  }

  /// 刷新单个配对数据
  Future<void> refreshPairDetail(SentencePairEntity pair) async{
    if(pair.nid == null) return;
    try {
      Map<String, dynamic> reqData = {
        "nid": pair.nid,
      };
      ListResponseEntity<SentencePairEntity>? list = await LanguageConsoleRequest.querySentencePairList(
        data: reqData,
      );
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
  Future<void> getForkListData() async {
    try {
      isLoading.value = true;
      ToastUtils.showLoading();
      
      ListResponseEntity<SentenceForkEntity>? list = await LanguageConsoleRequest.querySentenceForkList(
        parameters: _buildListParameters(),
        data: _buildListRequestData(),
      );
      if(list == null) return;
      total = list.count??0;
      sentenceForkList.addAll(list.datas??[]);
    }finally{
      isLoading.value = false;
      ToastUtils.hideLoading();
    }
  }

  /// 刷新单个分叉数据
  Future<void> refreshForkDetail(SentenceForkEntity pair) async{
    if(pair.nid == null) return;
    try {
      Map<String, dynamic> reqData = {
        "nid": pair.nid,
      };
      ListResponseEntity<SentenceForkEntity>? list = await LanguageConsoleRequest.querySentenceForkList(
        data: reqData,
      );
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

  /// 组装列表分页与排序参数
  Map<String, dynamic> _buildListParameters(){
    Map<String, dynamic> params = {
      "offset": offset,
      "limit": limit,
    };
    Map<String, dynamic> sortParams = FilterStripUtils.getSortOrderParameter(sorts: filterSorts);
    if(sortParams.isNotEmpty){
      params.addAll(sortParams);
    }
    return params;
  }

  /// 组装列表筛选与搜索参数
  Map<String, dynamic> _buildListRequestData(){
    Map<String, dynamic> reqData = {};
    Map<String, dynamic> conditionParams = FilterStripUtils.getConditionParameter(conditions: filterConditions);
    if(conditionParams.isNotEmpty){
      reqData.addAll(conditionParams);
    }

    Map<String, dynamic> searchParams = FilterStripUtils.getSearchParameter(searchs: filterSearchs);
    if(searchParams.isNotEmpty){
      reqData.addAll(searchParams);
    }
    return reqData;
  }


  /// 跳转至配对详情页面
  Future<void> jumpToPairDetailPage(SentencePairEntity pair) async{
    if(pair.nid == null) return;
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_SENTENCE_PAIR_DETAILS,
      arguments: {
        "nid": pair.nid,
      },
    );
    await refreshPairDetail(pair);
  }

  /// 跳转至分叉详情页面
  Future<void> toForkDetails(SentenceForkEntity fork) async{
    if(fork.nid == null) return;
    await ManagePageRegistry.jumpTo(
      Routes.MANAGE_SENTENCE_PAIR_FORK_DETAILS,
      arguments: {
        "nid": fork.nid,
      },
    );
    await refreshForkDetail(fork);
  } 

  @override
  void onClose() {
    scrollController.dispose();
    for(final item in filterSearchs.values){
      item.controller.dispose();
    }
    super.onClose();
  }
}
