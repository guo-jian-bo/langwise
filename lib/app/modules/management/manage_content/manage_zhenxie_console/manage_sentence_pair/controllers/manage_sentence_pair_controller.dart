import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    "pair": FilterConditionsData(
      title: "句对",
      conditions: [
        FilterConditionsItem(name: "已挑句", value: true),
        FilterConditionsItem(name: "未挑句", value: false),
      ],
    ),
    "practiceMethod": FilterConditionsData(
      title: "练习方式",
      conditions: [
        FilterConditionsItem(name: "只能配对", value: "pair"),
        FilterConditionsItem(name: "必须走分叉", value: "fork"),
        FilterConditionsItem(name: "可配队也可分叉", value: "both"),
      ],
    ),
    // 配对类型
  }.obs;

  final Map<String, FilterSearchsData> filterSearchs = {
    "keyWord": FilterSearchsData(
      title: "搜索",
      hintText: "name / nid / pattern / 教例",
      controller: TextEditingController(),
    ),
  };

  /// tab 配对/分叉
  final RxInt tab = 0.obs;

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

  /// 切换tab
  void switchTab(int value){
    if(tab.value == value) return;
    scrollController.jumpTo(0);
    tab.value = value;
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
  Future<void> jumpToPairDetailPage() async{
    ManagePageRegistry.jumpTo(Routes.MANAGE_SENTENCE_PAIR_DETAILS);
  }

  /// 跳转至分叉详情页面
  Future<void> toForkDetails() async{
    ManagePageRegistry.jumpTo(Routes.MANAGE_SENTENCE_PAIR_FORK_DETAILS);
  } 

  @override
  void onClose() {
    // TODO: 清理逻辑
    super.onClose();
  }
}
