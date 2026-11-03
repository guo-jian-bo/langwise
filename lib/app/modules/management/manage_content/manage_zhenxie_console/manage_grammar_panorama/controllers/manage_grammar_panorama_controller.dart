import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../routes/routes.dart';
import '../../../../utils/utils.dart';


class ManageGrammarPanoramaController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageGrammarPanoramaController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_GRAMMAR_PANORAMA;

  @override
  String get breadcrumbTitle => '语法全景';

  final RxMap<String, FilterSortsData> filterSorts = <String, FilterSortsData>{
    "updated": FilterSortsData(
      title: "推荐排序",
      sorts: [
        FilterSortsItem(name: "从低到高", direction: FilterSortDirection.up),
        FilterSortsItem(name: "从高到低", direction: FilterSortDirection.down, selected: true, isDefault: true),
      ],
    ),
    "name": FilterSortsData(
      title: "名称",
      sorts: [
        FilterSortsItem(name: "A-Z", direction: FilterSortDirection.up),
        FilterSortsItem(name: "Z-A", direction: FilterSortDirection.down),
      ],
    ),
    "type": FilterSortsData(
      title: "类型",
      sorts: [
        FilterSortsItem(name: "A-Z", direction: FilterSortDirection.up),
        FilterSortsItem(name: "Z-A", direction: FilterSortDirection.down),
      ],
    ),
  }.obs;

  final RxMap<String, FilterConditionsData> filterConditions = {
    "type": FilterConditionsData(
      title: "宫格类型",
      conditions: [
        FilterConditionsItem(name: "时x体", value: "time_aspect"),
        FilterConditionsItem(name: "极性×问句", value: "polarity"),
        FilterConditionsItem(name: "语态×时", value: "aspect"),
        FilterConditionsItem(name: "时×极性", value: "time_polarity"),
      ],
    ),
  }.obs;

  final Map<String, FilterSearchsData> filterSearchs = {
    "keyWord": FilterSearchsData(
      title: "搜索",
      hintText: "name / nid / 轴值",
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
  int limit = 20;
  /// 是否加载中
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    listenScroll();
    refreshList();
  }

  /// 监听列表滚动进行分页加载
  void listenScroll(){
    scrollController.addListener(() {
      // if(scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200 && !scrollController.position.outOfRange){
      //   if(!isLoading.value && ticketTempList.length < total){
      //     offset += limit;
      //     getTicketTempList();
      //   }
      // }
    });
  }

  /// 刷新列表
  Future<void> refreshList() async{
    // ticketTempList.clear();
    offset = 0;
    total = 0;
    getListData();
  }

  /// 获取工单模版列表
  Future<void> getListData() async {
    try {
      isLoading.value = true;
      ToastUtils.showLoading();
      Map<String, dynamic> params = {
        "offset": offset,
        "limit": limit,
      };
      Map<String, dynamic> sortParams = FilterStripUtils.getSortOrderParameter(sorts: filterSorts);
      if(sortParams.isNotEmpty){
        params.addAll(sortParams);
      }

      Map<String, dynamic> reqData = {};
      Map<String, dynamic> conditionParams = FilterStripUtils.getConditionParameter(conditions: filterConditions);
      if(conditionParams.isNotEmpty){
        reqData.addAll(conditionParams);
      }

      Map<String, dynamic> searchParams = FilterStripUtils.getSearchParameter(searchs: filterSearchs);
      if(searchParams.isNotEmpty){
        reqData.addAll(searchParams);
      }

      // ListResponseEntity<ManageTicketTempEntity>? list = await AccountConsoleRequest.getManageTicketTempList(params: params, data: reqData);
      // if(list == null) return;
      // total = list.count??0;
      // ticketTempList.addAll(list.datas??[]);
    }finally{
      isLoading.value = false;
      ToastUtils.hideLoading();
    }
  }

  /// 跳转至配对详情页面
  Future<void> jumpToDetailPage() async{
    ManagePageRegistry.jumpTo(Routes.MANAGE_GRAMMAR_PANORAMA_DETAILS);
  }

  @override
  void onClose() {
    // TODO: 清理逻辑
    super.onClose();
  }
}
