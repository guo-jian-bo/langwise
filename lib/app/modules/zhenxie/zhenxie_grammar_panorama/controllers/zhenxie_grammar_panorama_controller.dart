import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../../common/mixins/mixins.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../routes/tag_routes.dart';


class ZhenxieGrammarPanoramaController extends GetxController with DualBreadcrumbMixin {
  final String tagText;
  ZhenxieGrammarPanoramaController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.ZHENXIE_GRAMMAR_PANORAMA;

  @override
  String get breadcrumbTitle => '语法全景';

  /// 是否是管理端入口打开
  bool isManagement = false;

  final RxMap<String, FilterSortsData> filterSorts = <String, FilterSortsData>{}.obs;

  final RxMap<String, FilterConditionsData> filterConditions = <String, FilterConditionsData>{}.obs;

  final Map<String, FilterSearchsData> filterSearchs = {
    "content": FilterSearchsData(
      title: "搜索",
      hintText: "name / nid / 轴值",
      controller: TextEditingController(),
    ),
  };

  final RxList<ManageGrammarPanoramaEntity> grammarPanoramaList = <ManageGrammarPanoramaEntity>[].obs;
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
    initBreadcrumb(tagText);
    if (Get.arguments != null) {
      isManagement = Get.arguments['isManagement'] ?? false;
    }
    listenScroll();
    initData();
  }

  Future<void> initData() async{
    try {
      isLoading.value = true;
      ToastUtils.showLoading();
      await getFiltersGroup();
      await getListData(showLoading: false);
    } finally{
      isLoading.value = false;
      ToastUtils.hideLoading();
    }
  }

  /// 监听列表滚动进行分页加载
  void listenScroll(){
    scrollController.addListener(() {
      if(scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200 && !scrollController.position.outOfRange){
        if(!isLoading.value && grammarPanoramaList.length < total){
          offset += limit;
          getListData();
        }
      }
    });
  }

  /// 获取筛选数据
  Future<void> getFiltersGroup() async{
    try {
      FiltersGroupEntity? filtersGroup = await LanguageConsoleRequest.getGrammarPanoramaFiltersGroup();
      if(filtersGroup == null) return;
      filterConditions.value = FilterStripUtils.getConditionDataFrom(filtersGroup);
      filterSorts.value = FilterStripUtils.getSortDataFrom(filtersGroup);
    } catch (_) {}
  }

  /// 刷新列表
  Future<void> refreshList() async{
    grammarPanoramaList.clear();
    offset = 0;
    total = 0;
    getListData();
  }

  Future<void> getListData({bool showLoading = true}) async {
    try {
      isLoading.value = true;
      if(showLoading) ToastUtils.showLoading();
      Map<String, dynamic> params = {
        "offset": offset,
        "limit": limit,
      };
      Map<String, dynamic> sortParams = FilterStripUtils.getSortOrderParameter(sorts: filterSorts);
      if(sortParams.isNotEmpty){
        params.addAll(sortParams);
      }

      Map<String, dynamic> reqData = {};
      Map<String, dynamic> conditionParams = FilterStripUtils.getConditionParameter(
        conditions: filterConditions, 
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

      Map<String, dynamic> searchParams = FilterStripUtils.getSearchParameter(searchs: filterSearchs);
      if(searchParams.isNotEmpty){
        reqData.addAll(searchParams);
      }

      ListResponseEntity<ManageGrammarPanoramaEntity>? list = await LanguageConsoleRequest.getManageGrammarPanoramaList(
        parameters: params, 
        data: reqData,
      );
      if(list == null) return;
      total = list.count??0;
      grammarPanoramaList.addAll(list.datas??[]);
    }finally{
      isLoading.value = false;
      if(showLoading) ToastUtils.hideLoading();
    }
  }

  /// 单独刷新制定数据
  Future<void> refreshSingleData(ManageGrammarPanoramaEntity data) async{
    if(data.nid == null) return;
    try {
      Map<String, dynamic> reqData = {
        "nid": data.nid,
      };
      ListResponseEntity<ManageGrammarPanoramaEntity>? list = await LanguageConsoleRequest.getManageGrammarPanoramaList(
        data: reqData,
      );
      if(list == null) return;
      if(list.datas == null) return;
      List<ManageGrammarPanoramaEntity> datas = list.datas??[];

      for (var i = 0; i < grammarPanoramaList.length; i++) {
        for (var j = 0; j < datas.length; j++) {
          if(grammarPanoramaList[i].nid == datas[j].nid){
            grammarPanoramaList[i] = datas[j];
            grammarPanoramaList.refresh();
            break;
          }
        }
      }
    } catch (_) {}
  }

  /// 跳转至配对详情页面
  Future<void> jumpToDetailPage(ManageGrammarPanoramaEntity data) async{
    if(data.nid == null) return;
    await TagRoutes.toNamed(
      Routes.ZHENXIE_GRAMMAR_PANORAMA_DETAILS,
      arguments: {
        "nid": data.nid,
        "isManagement": isManagement,
      },
    );
    refreshSingleData(data);

  }
}
