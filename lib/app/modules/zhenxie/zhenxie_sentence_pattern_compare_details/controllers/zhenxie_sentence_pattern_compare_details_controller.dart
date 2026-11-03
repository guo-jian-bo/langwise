import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../../common/mixins/mixins.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../common/enum/enum.dart';
import '../../../../../theme/theme.dart';
import '../../../management/utils/utils.dart';
import '../views/zhenxie_edit_compare_group_dialog.dart';

class ZhenxieSentencePatternCompareDetailsController extends GetxController with DualBreadcrumbMixin {
  final String tagText;
  ZhenxieSentencePatternCompareDetailsController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.ZHENXIE_SENTENCE_PATTERN_COMPARE_DETAILS;

  @override
  String get breadcrumbTitle => '句型对照详情';

  // 传进来的参数

  /// nid
  String? nid;
  /// 详情参数 例句列表 realizationSetId
  int? realizationSetId;
  /// 单元语境透传的 unitId，用于后续“添加一组”继续限制候选范围。
  int? unitId;

  
  /// 句型对照详情
  final Rx<SentencePatternCompareEntity> detailData = SentencePatternCompareEntity().obs;

  /// 详情页展示用的对照组例句列表。
  final RxList<SentencePatternCompareSentenceRealizationSetEntity> exampleList = <SentencePatternCompareSentenceRealizationSetEntity>[].obs;

  /// 滚动控制器
  final ScrollController scrollController = ScrollController();


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
      isManagement = Get.arguments["isManagement"] ?? false;
      nid = Get.arguments["nid"];
      realizationSetId = Get.arguments["realizationSetId"];
      unitId = Get.arguments["unitId"];
    }
    initData();
    listenScroll();
  }

  /// 监听列表滚动进行分页加载
  void listenScroll() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200 && !scrollController.position.outOfRange) {
        if (!isLoading.value && exampleList.length < total) {
          offset += limit;
          getExampleList(showLoading: true);
        }
      }
    });
  }

  /// 获取详情数据
  Future<void> initData() async {
    try {
      isLoading.value = true;
      ToastUtils.showLoading();
      await getFiltersGroup();
      await getDetailData(showLoading: false);
    } finally {
      isLoading.value = false;
      ToastUtils.hideLoading();
    }
  }

  /// 获取筛选数据
  Future<void> getFiltersGroup() async {
    try {
      FiltersGroupEntity? filtersGroup;
      if (isManagement) {
        filtersGroup = await LanguageConsoleRequest.getSentencePatternCompareExampleFilters();
      } else {
        // filtersGroup = await LanguageUtil.getSentencePatternCompareExampleFilters();
      }
      if (filtersGroup == null) return;
      filterConditions.value = FilterStripUtils.getConditionDataFrom(filtersGroup);
      filterSorts.value = FilterStripUtils.getSortDataFrom(filtersGroup);
    } catch (_) {}
  }

  /// 获取详情数据
  Future<void> getDetailData({bool showLoading = true}) async {
    if (nid == null) return;
    try {
      if (showLoading) ToastUtils.showLoading();
      Map<String, dynamic> params = {};
      if(realizationSetId != null){
        params['realizationSetId'] = realizationSetId;
        params['optionSlot'] = true; // | realizationSetId > 0 | sentenceId > 0 | 处理 |
      }

      SentencePatternCompareEntity? res;
      if (isManagement) {
        res = await LanguageConsoleRequest.getSentencePatternCompareDetails(nid!, parameters: params);
      } else {
        res = await LanguageUtil.getSentencePatternCompareDetails(nid!, parameters: params);
      }
      if (res == null) return;
      detailData.value = res;
      await refreshExampleList(showLoading: false);
    } finally {
      if (showLoading) ToastUtils.hideLoading();
    }
  }

  /// 刷新例句列表。
  Future<void> refreshExampleList({bool showLoading = true}) async {
    exampleList.clear();
    offset = 0;
    total = 0;
    await getExampleList(showLoading: showLoading);
  }

  /// 查询当前页例句列表。
  Future<void> getExampleList({bool showLoading = false}) async {
    if (nid == null && realizationSetId == null) return;
    try {
      isLoading.value = true;
      if (showLoading) ToastUtils.showLoading();

      final Map<String, dynamic> reqData = {
        "assetNid": nid,
      };
      if(realizationSetId != null){
        reqData['uids'] = [realizationSetId];
      }
      final Map<String, dynamic> params = {
        "offset": offset,
        "limit": limit,
      };
      final Map<String, dynamic> sortParams = FilterStripUtils.getSortOrderParameter(sorts: filterSorts);
      if (sortParams.isNotEmpty) {
        params.addAll(sortParams);
      }
      ListResponseEntity<SentencePatternCompareSentenceRealizationSetEntity>? list;
      final Map<String, dynamic> conditionParams = FilterStripUtils.getConditionParameter(
        conditions: filterConditions,
        singleToList: true,
      );
      final List<Map<String, dynamic>> filters = [];
      conditionParams.forEach((key, value) {
        filters.add({
          "code": key,
          "values": value,
        });
      });
      if (filters.isNotEmpty) {
        reqData["filters"] = filters;
      }
      final Map<String, dynamic> searchParams = FilterStripUtils.getSearchParameter(searchs: filterSearchs);
      if (searchParams.isNotEmpty) {
        reqData.addAll(searchParams);
      }

      if (isManagement) {
        list = await LanguageConsoleRequest.querySentencePatternCompareExample(
          data: reqData,
          parameters: params,
        );
      } else {
        list = await LanguageUtil.querySentencePatternCompareExample(
          data: reqData,
          parameters: params,
        );
      }
      if (list == null) return;
      total = list.count ?? 0;
      exampleList.addAll(list.datas ?? []);
    } finally {
      isLoading.value = false;
      if (showLoading) ToastUtils.hideLoading();
    }
  }

  /// 编辑名称说明
  Future<void> editNameDesc(BuildContext context) async {
    if (detailData.value.nid == null) return;

    EditNameDescDialogResult? res = await EditNameDescDialog.show(
      context: context,
      name: detailData.value.name,
      description: detailData.value.description,
    );
    if (res == null) return;
    try {
      ToastUtils.showLoading();
      List<Map<String, dynamic>> nameList = [];
      List<Map<String, dynamic>> descriptionList = [];
      res.name?.forEach((e) {
        nameList.add(e?.toJson() ?? {});
      });
      res.description?.forEach((e) {
        descriptionList.add(e?.toJson() ?? {});
      });

      Map<String, dynamic> reqData = {
        "name": nameList,
        "description": descriptionList,
      };

      SentencePatternCompareEntity? resp = await LanguageConsoleRequest.editSentencePatternCompare(
        nid: detailData.value.nid!,
        data: reqData,
      );
      if (resp == null) return;
      ToastUtils.showToast(text: "保存成功", type: ToastType.success);
      detailData.value = resp;
      detailData.refresh();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 编辑对照组
  Future<void> editCompareGroup(BuildContext context) async {
    await ZhenxieEditCompareGroupDialog.show(
      context: context,
      detailData: detailData.value,
    );
    await getDetailData();
  }

  /// 例句句子组上下架
  Future<void> exampleSentenceGroupShelf(SentencePatternCompareSentenceRealizationSetEntity? example) async {
    if (example == null) return ToastUtils.showToast(text: "对照信息为空");
    if (example.uid == null) return ToastUtils.showToast(text: "对照信息uid为空");
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "access": example.isNormal ? AccessEnum.INTERNAL.value : AccessEnum.NORMAL.value,
      };
      bool resp = await LanguageConsoleRequest.zhenxieExampleAccess(
        uid: example.uid!,
        data: reqData,
      );
      if (!resp) return;
      ToastUtils.showToast(text: "${example.isNormal ? "下架" : "上架"}成功", type: ToastType.success);
      example.access = example.isNormal ? AccessEnum.INTERNAL.value : AccessEnum.NORMAL.value;
      exampleList.refresh();
      detailData.refresh();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 删除句组
  Future<void> exampleSentenceGroupDelete(BuildContext context, SentencePatternCompareSentenceRealizationSetEntity? example) async {
    if (example == null) return ToastUtils.showToast(text: "对照信息为空");
    if (example.uid == null) return ToastUtils.showToast(text: "对照信息uid为空");
    bool ask = await AskDialog.showUserAsk(
      context: context,
      title: "温馨提示",
      content: "确认删除对照吗？",
      defineColor: AppTheme.cSurfaceError.color,
    );
    if (!ask) return;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "access": AccessEnum.DELETED.value,
      };
      bool resp = await LanguageConsoleRequest.zhenxieExampleAccess(
        uid: example.uid!,
        data: reqData,
      );
      if (!resp) return;
      ToastUtils.showToast(text: "删除成功", type: ToastType.success);
      getDetailData();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 句子上下架
  Future<void> exampleSentenceShelf(SentencePatternCompareSentenceBindingEntity? sentence) async {
    if (sentence == null) return ToastUtils.showToast(text: "句子为空");
    if (sentence.sentenceId == null) return ToastUtils.showToast(text: "句子uid为空");
    bool isNormal = sentence.sentenceStruct?.isNormal == true;
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "access": isNormal ? AccessEnum.INTERNAL.value : AccessEnum.NORMAL.value,
      };
      bool resp = await LanguageConsoleRequest.zhenxieExampleSingleAccess(
        sentenceId: sentence.sentenceId!,
        data: reqData,
      );
      if (!resp) return;
      ToastUtils.showToast(text: "${isNormal ? "下架" : "上架"}成功", type: ToastType.success);
      sentence.sentenceStruct?.access = isNormal ? AccessEnum.INTERNAL.value : AccessEnum.NORMAL.value;
      exampleList.refresh();
      detailData.refresh();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 添加一组
  Future<void> addGroup() async{
    dynamic res = await ManagePageRegistry.jumpTo(
      Routes.MANAGE_SENTENCE_PARADIGM_ADD_GROUP,
      arguments: {
        "unitId": unitId,
        "detailData": detailData.value,
      },
    );
    if(res != true) return;
    refreshExampleList(showLoading: false);
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
