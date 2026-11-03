
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/enum/enum.dart';
import 'package:langwise/app/routes/routes.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../../common/mixins/mixins.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../theme/theme.dart';
import '../../../elements/utils/elements_page_utils.dart';
import '../../../management/utils/utils.dart';

class ZhenxiePatternBlueprintDetailsController extends GetxController with DualBreadcrumbMixin {
  final String tagText;
  ZhenxiePatternBlueprintDetailsController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.ZHENXIE_PATTERN_BLUEPRINT_DETAILS;

  @override
  String get breadcrumbTitle => '句型蓝图详情';

  /// 传进来的参数
  String? nid;
  /// 详情参数 例句列表 realizationSetId
  int? realizationSetId;
  /// 单元语境透传的 unitId，用于后续“添加一组”继续限制候选范围。
  int? unitId;


  /// 是否是金字塔
  bool supportsPyramid = false;
  /// 是否是管理端入口打开
  bool isManagement = false;


  final RxMap<String, FilterSortsData> filterSorts = <String, FilterSortsData>{}.obs;

  final RxMap<String, FilterConditionsData> filterConditions = <String, FilterConditionsData>{}.obs;

  final Map<String, FilterSearchsData> filterSearchs = {
    "content": FilterSearchsData(
      title: "搜索",
      hintText: "例句",
      controller: TextEditingController(),
    ),
  };

  final Rx<PatternBlueprintEntity> patternBlueprint = PatternBlueprintEntity().obs;

  /// 蓝图例句列表
  final RxList<PatternBlueprintExampleEntity> exampleList = <PatternBlueprintExampleEntity>[].obs;
  /// 滚动控制器
  final ScrollController scrollController = ScrollController();
  /// 总条数
  int total = 0;
  /// offset
  int offset = 0;
  /// limit
  int limit = 10;
  /// 是否加载中
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    
    if (Get.arguments != null) {
      isManagement = Get.arguments["isManagement"] ?? false;
      nid = Get.arguments["nid"];
      supportsPyramid = Get.arguments["supportsPyramid"]??false;
      realizationSetId = Get.arguments["realizationSetId"];
      unitId = Get.arguments["unitId"];

      // nid = "state_entity_seem_adj";
      // realizationSetId = 5688;
      // supportsPyramid = true;



    }
    initData();
    initBreadcrumb(tagText, title: supportsPyramid ? "生长金字塔详情" : "句型蓝图详情");
    listenScroll();
  }

  /// 监听列表滚动进行分页加载
  void listenScroll(){
    scrollController.addListener(() {
      if(scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200 && !scrollController.position.outOfRange){
        if(!isLoading.value && exampleList.length < total){
          offset += limit;
          getExampleList(showLoading: true);
        }
      }
    });
  }

  Future<void> initData() async{
    try {
      isLoading.value = true;
      ToastUtils.showLoading();
      await getFiltersGroup();
      await getDetatils(showLoading: false);
    } finally{
      isLoading.value = false;
      ToastUtils.hideLoading();
    }
  }

  /// 获取筛选数据
  Future<void> getFiltersGroup() async{
    try {
      FiltersGroupEntity? filtersGroup;
      Map<String, dynamic> parameters = {};
      if(supportsPyramid){
        parameters["supportsPyramid"] = true;
      }
      if (isManagement) {
        filtersGroup = await LanguageConsoleRequest.getPatternBlueprintExampleFilters(parameters: parameters);
      } else {
        // filtersGroup = await LanguageUtil.getSentencePatternBlueprintExampleFilters(parameters: parameters);
      }
      if(filtersGroup == null) return;
      filterConditions.value = FilterStripUtils.getConditionDataFrom(filtersGroup);
      filterSorts.value = FilterStripUtils.getSortDataFrom(filtersGroup);
    } catch (_) {}
  }

  /// 查询详情
  Future<void> getDetatils({bool showLoading = true}) async {
    if (nid == null) return;
    try {
      if(showLoading) ToastUtils.showLoading();
      Map<String, dynamic> parameters = {};
      if(supportsPyramid){
        parameters["supportsPyramid"] = true;
      }
      if(realizationSetId != null){
        parameters["realizationSetId"] = realizationSetId;
        parameters['optionSlot'] = true; // | realizationSetId > 0 | sentenceId > 0 | 处理 |
      }
      PatternBlueprintEntity? res;
      if (isManagement) {
        res = await LanguageConsoleRequest.queryPatternBlueprint(nid!, parameters: parameters);
      } else {
        res = await LanguageUtil.querySentencePatternBlueprint(nid!, parameters: parameters);
      }
      if (res == null) return;
      patternBlueprint.value = res;
      await refreshExampleList(showLoading: false);
    } finally {
      if(showLoading) ToastUtils.hideLoading();
    }
  }

  /// 刷新列表
  Future<void> refreshExampleList({bool showLoading = true}) async{
    exampleList.clear();
    offset = 0;
    total = 0;
    await getExampleList(showLoading: showLoading);
  }

  Future<void> getExampleList({bool showLoading = false}) async{
    if (nid == null && realizationSetId == null) return;
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

      Map<String, dynamic> reqData = {
        "assetNid": nid,
      };
      if(realizationSetId != null){
        reqData['uids'] = [realizationSetId];
      }
      if(supportsPyramid){
        reqData["supportsPyramid"] = supportsPyramid;
      }
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
      
      ListResponseEntity<PatternBlueprintExampleEntity>? list;
      if (isManagement) {
        list = await LanguageConsoleRequest.queryPatternBlueprintExample(
          parameters: params,
          data: reqData,
        );
      } else {
        list = await LanguageUtil.querySentencePatternBlueprintExample(
          parameters: params,
          data: reqData,
        );
      }
      if(list == null) return;
      total = list.count??0;
      exampleList.addAll(list.datas??[]);
    }finally{
      isLoading.value = false;
      if(showLoading) ToastUtils.hideLoading();
    }
  }

  /// 根据uid查询代表句
  Future<void> getExampleForUid(PatternBlueprintExampleEntity data) async{
    if(data.uid == null) return;
    try {
      Map<String, dynamic> reqData = {
        "assetNid": nid,
        "supportsPyramid": supportsPyramid,
        "uids": [data.uid],
      };
      if(realizationSetId != null){
        reqData['uids'] = [realizationSetId];
      }

      ListResponseEntity<PatternBlueprintExampleEntity>? list;
      if (isManagement) {
        list = await LanguageConsoleRequest.queryPatternBlueprintExample(
          data: reqData,
        );
      } else {
        list = await LanguageUtil.querySentencePatternBlueprintExample(
          data: reqData,
        );
      }
      if(list == null) return;
      List<PatternBlueprintExampleEntity> datas = list.datas??[];
      for (var element in exampleList) {
        for (var item in datas) {
          if(item.uid == element.uid){
            element = item;
          }
        }
      }
      exampleList.refresh();
    } catch (_) {}
  }

  /// 槽位详情
  Future<void> slotDetails(BuildContext context, SentenceSlotMapItemEntity item) async {
    await PatternSlotDetailsDialog.show(context: context, item: item, isManagement: isManagement);
  }

  /// 槽位例句说明
  Future<void> slotSentenceExample(
    BuildContext context,
    ZhenxieSentenceMemberSegmentEntity segment,
    ZhenxieSentenceMemberSentenceEntity? item,
  ) async {
    await SlotSentenceExampleDialog.show(
      context: context,
      segment: segment,
      nid: nid??"",
      sentenceId: item?.sentenceId,
      isManagement: isManagement,
    );
  }

  /// 编辑名称说明
  Future<void> editNameDesc(BuildContext context) async {
    if(nid == null) return;

    EditNameDescDialogResult? res = await EditNameDescDialog.show(
      context: context,
      name: patternBlueprint.value.name,
      description: patternBlueprint.value.description,
    );
    if(res == null) return;
    try {
      ToastUtils.showLoading();
      List<Map<String, dynamic>> nameList = [];
      List<Map<String, dynamic>> descriptionList = [];
      res.name?.forEach((e) {
        nameList.add(e?.toJson()??{});
      });
      res.description?.forEach((e) {
        descriptionList.add(e?.toJson()??{});
      });

      Map<String, dynamic> reqData = {
        "name": nameList,
        "description": descriptionList,
      };

      PatternBlueprintEntity? resp = await LanguageConsoleRequest.editPatternBlueprint(
        nid: nid!,
        data: reqData,
      );
      if(resp == null) return;
      ToastUtils.showToast(text: "保存成功", type: ToastType.success);
      patternBlueprint.value = resp;
    } finally {
      ToastUtils.hideLoading();
    }
  }
  


  /// 蓝图例句句子组上下架
  Future<void> exampleSentenceGroupShelf(PatternBlueprintExampleEntity example) async {
    if(example.uid == null) return;
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "access": example.isNormal ? AccessEnum.INTERNAL.value : AccessEnum.NORMAL.value,
      };
      bool resp = await LanguageConsoleRequest.zhenxieExampleAccess(
        uid: example.uid!,
        data: reqData,
      );
      if(!resp) return;
      ToastUtils.showToast(text: "${example.isNormal ? "下架" : "上架"}成功", type: ToastType.success);
      example.access = example.isNormal ? AccessEnum.INTERNAL.value : AccessEnum.NORMAL.value;
      exampleList.refresh();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 删除代表句组
  Future<void> exampleSentenceGroupDelete(BuildContext context, int index, PatternBlueprintExampleEntity example) async {
    if(example.uid == null) return;
    bool ask = await AskDialog.showUserAsk(
      context: context,
      title: "温馨提示",
      content: "确认删除 代表句${index + 1} 吗？",
      defineColor: AppTheme.cSurfaceError.color,
    );
    if(!ask) return;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "access": AccessEnum.DELETED.value,
      };
      bool resp = await LanguageConsoleRequest.zhenxieExampleAccess(
        uid: example.uid!,
        data: reqData,
      );
      if(!resp) return;
      ToastUtils.showToast(text: "删除成功", type: ToastType.success);
      exampleList.removeWhere((element) => element.uid == example.uid);
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 蓝图例句句子上下架
  Future<void> exampleSentenceShelf(ZhenxieSentenceMemberSentenceEntity? sentence) async{
    if(sentence == null) return;
    if(sentence.sentenceId == null) return;
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "access": sentence.isNormal ? AccessEnum.INTERNAL.value : AccessEnum.NORMAL.value,
      };
      bool resp = await LanguageConsoleRequest.zhenxieExampleSingleAccess(
        sentenceId: sentence.sentenceId!,
        data: reqData,
      );
      if(!resp) return;
      ToastUtils.showToast(text: "${sentence.isNormal ? "下架" : "上架"}成功", type: ToastType.success);
      sentence.access = sentence.isNormal ? AccessEnum.INTERNAL.value : AccessEnum.NORMAL.value;
      exampleList.refresh();
      
    }  finally{
      ToastUtils.hideLoading();
    }
  }

  /// 拓展学习
  Future<void> expandLearning(PatternBlueprintSentenceBriefEntity? item) async {
    ElementsPageUtils.jumpElementsPage(
      contentId: item?.sentenceId, 
      contentType: KnowledgeTypeEnum.EN_SENTENCE.value, 
      semanticId: null, 
      content: item?.content,
      styleId: null, 
      dialect: null,
      isManagement: isManagement,
    );
  }

  /// 添加一组
  Future<void> addGroup() async{
    dynamic res = await ManagePageRegistry.jumpTo(
      supportsPyramid ? Routes.MANAGE_SENTENCE_PYRAMID_ADD_GROUP : Routes.MANAGE_SENTENCE_BLUEPRINT_ADD_GROUP,
      arguments: {
        "supportsPyramid": supportsPyramid,
        "patternBlueprint": patternBlueprint.value,
        "unitId": unitId,
      },
    );
    if(res != true) return;
    refreshExampleList(showLoading: false);
  }

}
