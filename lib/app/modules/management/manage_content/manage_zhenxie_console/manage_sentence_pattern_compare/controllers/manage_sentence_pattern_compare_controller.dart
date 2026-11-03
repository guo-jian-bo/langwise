import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../routes/routes.dart';
import '../../../../utils/utils.dart';

class ManageSentencePatternCompareController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageSentencePatternCompareController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_SENTENCE_PATTERN_COMPARE;

  @override
  String get breadcrumbTitle => '句型对照';

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
    "shellCount": FilterSortsData(
      title: "壳数",
      sorts: [
        FilterSortsItem(name: "少到多", direction: FilterSortDirection.up),
        FilterSortsItem(name: "多到少", direction: FilterSortDirection.down),
      ],
    ),
  }.obs;

  final RxMap<String, FilterConditionsData> filterConditions = {
    "shellCount": FilterConditionsData(
      title: "壳数",
      conditions: [
        FilterConditionsItem(name: "2壳", value: 2),
        FilterConditionsItem(name: "3壳+", value: 3),
      ],
    ),
    "compareGroup": FilterConditionsData(
      title: "对照组",
      conditions: [
        FilterConditionsItem(name: "已挑句", value: true),
        FilterConditionsItem(name: "未挑句", value: false),
      ],
    ),
    "transformType": FilterConditionsData(
      title: "变形种类",
      conditions: [
        FilterConditionsItem(name: "同一条主线可以换哪些说法", value: "same"),
        FilterConditionsItem(name: "肯定和否定怎么切换", value: "negate"),
        FilterConditionsItem(name: "去向状态怎么切换", value: "direction"),
      ],
    ),
    // 维度
  }.obs;

  final Map<String, FilterSearchsData> filterSearchs = {
    "keyWord": FilterSearchsData(
      title: "搜索",
      hintText: "name / nid / patternNid / 教例",
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

  /// 跳转至详情页面
  Future<void> jumpToDetailPage() async{
    ManagePageRegistry.jumpTo(Routes.MANAGE_SENTENCE_PATTERN_COMPARE_DETAILS);
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
