import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/mixins/mixins.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../utils/utils.dart';
import '../../../../routes/tag_routes.dart';

class ZhenxiePhraseStructureController extends GetxController with DualBreadcrumbMixin {
  final String tagText;
  ZhenxiePhraseStructureController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.ZHENXIE_PHRASE_STRUCTURE;

  @override
  String get breadcrumbTitle => "短语结构";

  // 传进来的参数
  /// 是否是管理端
  bool isManagement = false;

  final RxMap<String, FilterSortsData> filterSorts = <String, FilterSortsData>{}.obs;

  final RxMap<String, FilterConditionsData> filterConditions = <String, FilterConditionsData>{}.obs;

  final Map<String, FilterSearchsData> filterSearchs = {
    "content": FilterSearchsData(
      title: "搜索",
      hintText: "短语 / 角色 / 结构说明",
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
  final RxList<PhraseStructureEntity> dataList = <PhraseStructureEntity>[].obs;

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
      FiltersGroupEntity? filtersGroup = await LanguageConsoleRequest.getWriteFilterData("structure");
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
      
      ListResponseEntity<PhraseStructureEntity>? res = await LanguageConsoleRequest.getWritePhraseStructurePage(data: reqData, parameters: params);
      if(res == null) return;
      total = res.count??0;
      dataList.addAll(res.datas ?? []);
    } finally{
      isLoading.value = false;
      if(showLoading) ToastUtils.hideLoading();
    }
  }

  /// 跳转至详情页面
  Future<void> toDetails(PhraseStructureEntity data) async {
    TagRoutes.toNamed(
      Routes.ZHENXIE_PHRASE_STRUCTURE_DETAILS,
      arguments: {
        "phraseId": data.phraseId,
        "isManagement": isManagement,
      },
    );
  }

  @override
  void onClose() {
    super.onClose();
  }
}
