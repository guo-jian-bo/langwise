import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/utils/utils.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/mixins/mixins.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../routes/tag_routes.dart';


class ZhenxiePhraseContrastController extends GetxController with DualBreadcrumbMixin {
  final String tagText;
  ZhenxiePhraseContrastController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.ZHENXIE_PHRASE_CONTRAST;

  @override
  String get breadcrumbTitle => "短语对照";

  // 传进来的参数
  /// 是否是管理端
  bool isManagement = false;

  final RxMap<String, FilterSortsData> filterSorts = <String, FilterSortsData>{}.obs;

  final RxMap<String, FilterConditionsData> filterConditions = <String, FilterConditionsData>{}.obs;

  final Map<String, FilterSearchsData> filterSearchs = {
    "content": FilterSearchsData(
      title: "搜索",
      hintText: "名称",
      controller: TextEditingController(),
    ),
  };

  /// 滚动控制器
  final ScrollController scrollController = ScrollController();
  /// 总条数
  int total = 0;
  /// offset
  int offset = 0;
  /// limit
  int limit = 40;
  /// 是否加载中
  final RxBool isLoading = false.obs;
  final RxList<PhraseParadigmEntity> dataList = <PhraseParadigmEntity>[].obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    if(Get.arguments != null){
      isManagement = Get.arguments["isManagement"]??false;
    }
    initData();
    listenScroll();
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
        if(!isLoading.value && dataList.length < total){
          offset += limit;
          getListData();
        }
      }
    });
  }

  /// 获取筛选数据
  Future<void> getFiltersGroup() async{
    try {
      FiltersGroupEntity? filtersGroup;
      if (isManagement) {
        filtersGroup = await LanguageConsoleRequest.getWriteFilterData("paradigm");
      } else {
        filtersGroup = await LanguageUtil.getWritePhraseParadigmFilters();
      }
      if(filtersGroup == null) return;
      filterConditions.value = FilterStripUtils.getConditionDataFrom(filtersGroup);
      filterSorts.value = FilterStripUtils.getSortDataFrom(filtersGroup);
    } catch (_) {}
  }

  /// 刷新列表
  Future<void> refreshList() async{
    dataList.clear();
    offset = 0;
    total = 0;
    getListData();
  }


  Future<void> getListData({bool showLoading = true}) async{
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
        filters.add({"code": key, "values": value});
      });
      if(filters.isNotEmpty){
        reqData["filters"] = filters;
      }

      Map<String, dynamic> searchParams = FilterStripUtils.getSearchParameter(searchs: filterSearchs);
      if(searchParams.isNotEmpty){
        reqData.addAll(searchParams);
      }
      
      ListResponseEntity<PhraseParadigmEntity>? res;
      if (isManagement) {
        res = await LanguageConsoleRequest.getWritePhraseParadigmPage(data: reqData, parameters: params);
      } else {
        res = await LanguageUtil.getWritePhraseParadigmPage(data: reqData, parameters: params);
      }
      if(res == null) return;
      total = res.count??0;
      dataList.addAll(res.datas ?? []);
    } finally{
      isLoading.value = false;
      if(showLoading) ToastUtils.hideLoading();
    }
  }

  /// 单独刷新制定数据
  Future<void> refreshSingleData(PhraseParadigmEntity data) async{
    if(data.nid == null) return;
    try {
      Map<String, dynamic> reqData = {
        "nid": data.nid,
      };
      ListResponseEntity<PhraseParadigmEntity>? list;
      if (isManagement) {
        list = await LanguageConsoleRequest.getWritePhraseParadigmPage(data: reqData);
      } else {
        list = await LanguageUtil.getWritePhraseParadigmPage(data: reqData);
      }
      if(list == null) return;
      if(list.datas == null) return;
      List<PhraseParadigmEntity> datas = list.datas??[];
      for (var i = 0; i < dataList.length; i++) {
        for (var j = 0; j < datas.length; j++) {
          if(dataList[i].nid == datas[j].nid){
            dataList[i] = datas[j];
            dataList.refresh();
            break;
          }
        }
      }
    } catch (_) {}
  }

  /// 跳转至详情页面
  Future<void> toDetails(PhraseParadigmEntity data) async {
    await TagRoutes.toNamed(
      Routes.ZHENXIE_PHRASE_CONTRAST_DETAILS,
      arguments: {
        "nid": data.nid,
        "isManagement": isManagement,
      },
    );
    // refreshSingleData(data);
  }


  @override
  void onClose() {
    super.onClose();
  }
}
