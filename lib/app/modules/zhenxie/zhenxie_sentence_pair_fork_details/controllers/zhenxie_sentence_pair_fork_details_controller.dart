import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../../common/mixins/mixins.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../common/enum/enum.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../theme/theme.dart';
import '../../../management/utils/utils.dart';

class ZhenxieSentencePairForkDetailsController extends GetxController with DualBreadcrumbMixin {
  final String tagText;
  ZhenxieSentencePairForkDetailsController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.ZHENXIE_SENTENCE_PAIR_FORK_DETAILS;

  @override
  String get breadcrumbTitle => '分叉详情';

  // 传进来的参数
  String? nid;
  /// 详情参数 例句列表 realizationSetId
  int? realizationSetId;
  /// 单元语境透传的 unitId，用于后续“添加一组”继续限制候选范围。
  int? unitId;

  /// 是否是管理端入口打开
  bool isManagement = false;

  final Rx<SentenceForkEntity> forkDetail = SentenceForkEntity().obs;

  /// 详情页展示用的分叉例句列表。
  final RxList<SentencePairForkExampleEntity> exampleList = <SentencePairForkExampleEntity>[].obs;

  /// 滚动控制器
  final ScrollController scrollController = ScrollController();

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
      isManagement = Get.arguments['isManagement'] ?? false;
      nid = Get.arguments['nid'];
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

  /// 初始化详情页数据
  Future<void> initData() async {
    try {
      isLoading.value = true;
      ToastUtils.showLoading();
      await getFiltersGroup();
      await getForkDetail(showLoading: false);
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
        filtersGroup = await LanguageConsoleRequest.getSentencePairForkExampleFiltersGroup();
      } else {
        // filtersGroup = await LanguageUtil.getSentencePairForkExampleFiltersGroup();
      }
      if (filtersGroup == null) return;
      filterConditions.value = FilterStripUtils.getConditionDataFrom(filtersGroup);
      filterSorts.value = FilterStripUtils.getSortDataFrom(filtersGroup);
    } catch (_) {}
  }

  /// 获取详情数据
  Future<void> getForkDetail({bool showLoading = true}) async {
    if (nid == null) return;
    try {
      if (showLoading) ToastUtils.showLoading();
      Map<String, dynamic> params = {};
      if(realizationSetId != null){
        params['realizationSetId'] = realizationSetId;
        params['optionSlot'] = true; // | realizationSetId > 0 | sentenceId > 0 | 处理 |
      }
      SentenceForkEntity? list;
      if (isManagement) {
        list = await LanguageConsoleRequest.getSentenceForkDetails(nid!, parameters: params);
      } else {
        list = await LanguageUtil.getSentenceForkDetails(nid!, parameters: params);
      }
      if (list == null) return;
      forkDetail.value = list;
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

      ListResponseEntity<SentencePairForkExampleEntity>? list;
      if (isManagement) {
        list = await LanguageConsoleRequest.querySentencePairForkExample(
          data: reqData,
          parameters: params,
        );
      } else {
        list = await LanguageUtil.querySentencePairForkExample(
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

  /// 例句句子组上下架
  Future<void> exampleSentenceGroupShelf(SentenceForkSentenceRealizationEntity? example) async {
    if (example == null) return;
    if (example.uid == null) return;
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
      forkDetail.refresh();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 删除句组
  Future<void> exampleSentenceGroupDelete(BuildContext context, SentenceForkSentenceRealizationEntity? example) async {
    if (example == null) return;
    if (example.uid == null) return;
    bool ask = await AskDialog.showUserAsk(
      context: context,
      title: "温馨提示",
      content: "确认删除句子吗？",
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
      getForkDetail();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 句子上下架
  Future<void> exampleSentenceShelf(SentenceForkSentenceBriefEntity? sentence) async {
    if (sentence == null) return;
    if (sentence.sentenceId == null) return;
    bool isNormal = sentence.isNormal == true;
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "access": sentence.isNormal ? AccessEnum.INTERNAL.value : AccessEnum.NORMAL.value,
      };
      bool resp = await LanguageConsoleRequest.zhenxieExampleSingleAccess(
        sentenceId: sentence.sentenceId!,
        data: reqData,
      );
      if (!resp) return;
      ToastUtils.showToast(text: "${isNormal ? "下架" : "上架"}成功", type: ToastType.success);
      sentence.access = isNormal ? AccessEnum.INTERNAL.value : AccessEnum.NORMAL.value;
      exampleList.refresh();
      forkDetail.refresh();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 添加一组
  Future<void> addGroup() async{
    dynamic res = await ManagePageRegistry.jumpTo(
      Routes.MANAGE_SENTENCE_FORK_ADD_GROUP,
      arguments: {
        "unitId": unitId,
        "forkDetail": forkDetail.value,
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
