import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/https/zhenxie.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/mixins/mixins.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../utils/utils.dart';
import '../../../../routes/tag_routes.dart';

class ZhenxieEtymologyForestController extends GetxController with DualBreadcrumbMixin {
  final String tagText;
  ZhenxieEtymologyForestController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.ZHENXIE_ETYMOLOGY_FOREST;

  @override
  String get breadcrumbTitle => "词源记忆";

  /// 是否是管理端
  bool isManagement = false;

  /// 底部筛选元数据原始结构，用于解析排序参数
  ZhenduScriptQueryMetaGroupListEntity? metaGroupList;

  final RxMap<String, FilterSortsData> filterSorts = <String, FilterSortsData>{}.obs;

  final RxMap<String, FilterConditionsData> filterConditions = <String, FilterConditionsData>{}.obs;

  final Map<String, FilterSearchsData> filterSearchs = {
    "content": FilterSearchsData(
      title: "搜索",
      hintText: "单词 / 短语",
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
  int limit = 30;
  /// 是否加载中
  final RxBool isLoading = false.obs;
  final RxList<ZhenxieEtymologyForestEntity> dataList = <ZhenxieEtymologyForestEntity>[].obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    if (Get.arguments != null) {
      isManagement = Get.arguments["isManagement"] ?? false;
    }
    initData();
    listenScroll();
  }

  Future<void> initData() async {
    try {
      isLoading.value = true;
      ToastUtils.showLoading();
      await getFiltersGroup();
      await getListData(showLoading: false);
    } finally {
      isLoading.value = false;
      ToastUtils.hideLoading();
    }
  }

  /// 监听列表滚动进行分页加载
  void listenScroll() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200 && !scrollController.position.outOfRange) {
        if (!isLoading.value && dataList.length < total) {
          offset += limit;
          getListData();
        }
      }
    });
  }

  /// 获取底部筛选与排序元数据
  Future<void> getFiltersGroup() async {
    final ZhenduScriptQueryMetaGroupListEntity? meta = await ZhenxieRequest.getEtymologyQueryMetaGroupList();
    if (meta == null) return;
    metaGroupList = meta;
    filterConditions.value = _buildFilterConditions();
    filterSorts.value = _buildFilterSorts();
  }

  /// 刷新列表
  Future<void> refreshList() async {
    dataList.clear();
    offset = 0;
    total = 0;
    getListData();
  }

  Future<void> getListData({bool showLoading = true}) async {
    try {
      isLoading.value = true;
      if (showLoading) ToastUtils.showLoading();
      Map<String, dynamic> params = {
        "offset": offset,
        "limit": limit,
      };
      String orderValue = _resolveOrderValue();
      if (orderValue.isNotEmpty) {
        params["order"] = orderValue;
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
      if (filters.isNotEmpty) {
        reqData["filters"] = filters;
      }

      Map<String, dynamic> searchParams = FilterStripUtils.getSearchParameter(searchs: filterSearchs);
      if (searchParams.isNotEmpty) {
        reqData.addAll(searchParams);
      }

      ListResponseEntity<ZhenxieEtymologyForestEntity>? res = await ZhenxieRequest.getEtymologyForestPage(data: reqData, parameters: params);
      if (res == null) return;
      total = res.count ?? 0;
      dataList.addAll(res.datas ?? []);
    } finally {
      isLoading.value = false;
      if (showLoading) ToastUtils.hideLoading();
    }
  }

  /// 跳转至词源画布页
  void toDetails(ZhenxieEtymologyForestEntity data) {
    if (data.contentId == null) return;
    TagRoutes.toNamed(
      Routes.ETYMOLOGY_MEMORY,
      arguments: {
        "contentType": data.contentType,
        "contentId": data.contentId,
        "isManagement": isManagement,
      },
    );
  }

  /// 用筛选元数据构建底部筛选条件
  Map<String, FilterConditionsData> _buildFilterConditions() {
    final Map<String, FilterConditionsData> resp = <String, FilterConditionsData>{};
    for (final ZhenduScriptQueryMetaGroupEntity group in metaGroupList?.filters ?? const <ZhenduScriptQueryMetaGroupEntity>[]) {
      final String groupCode = (group.groupCode ?? '').trim();
      if (groupCode.isEmpty || group.items.isEmpty) continue;
      resp[groupCode] = FilterConditionsData(
        title: group.groupName ?? groupCode,
        isSingle: (group.component ?? '').trim() == 'radio',
        component: group.component,
        filterGroup: group.filterGroup,
        radioGroup: group.radioGroup ?? false,
        conditions: group.items.map((item) => FilterConditionsItem(
          name: item.name ?? (item.value ?? ''),
          value: item.value ?? '',
          selected: item.defaultValue ?? false,
        )).toList(),
      );
    }
    return resp;
  }

  /// 用排序元数据构建底部排序项
  Map<String, FilterSortsData> _buildFilterSorts() {
    final Map<String, FilterSortsData> resp = <String, FilterSortsData>{};
    for (final ZhenduScriptQueryMetaGroupEntity group in metaGroupList?.orders ?? const <ZhenduScriptQueryMetaGroupEntity>[]) {
      final String groupCode = (group.groupCode ?? '').trim();
      if (groupCode.isEmpty || group.items.isEmpty) continue;
      resp[groupCode] = FilterSortsData(
        title: group.groupName ?? groupCode,
        sorts: group.items.map((item) => FilterSortsItem(
          name: item.name ?? (item.value ?? ''),
          selected: item.defaultValue ?? false,
          isDefault: item.defaultValue ?? false,
          direction: (item.value ?? '').startsWith('-') ? FilterSortDirection.down : FilterSortDirection.up,
        )).toList(),
      );
    }
    return resp;
  }

  /// 解析当前选中排序项的 order 值，取不到时退回分组 code
  String _resolveOrderValue() {
    for (final MapEntry<String, FilterSortsData> entry in filterSorts.entries) {
      for (final FilterSortsItem item in entry.value.sorts) {
        if (!item.selected) continue;
        return _metaOrderValue(entry.key, item.name);
      }
    }
    return "";
  }

  /// 按展示名从排序元数据里找回对应的 order 值
  String _metaOrderValue(String groupCode, String itemName) {
    for (final ZhenduScriptQueryMetaGroupEntity group in metaGroupList?.orders ?? const <ZhenduScriptQueryMetaGroupEntity>[]) {
      if ((group.groupCode ?? '') != groupCode) continue;
      for (final ZhenduScriptQueryMetaItemEntity item in group.items) {
        if ((item.name ?? (item.value ?? '')) != itemName) continue;
        return item.value ?? groupCode;
      }
    }
    return groupCode;
  }

  @override
  void onClose() {
    scrollController.dispose();
    filterSearchs["content"]?.controller.dispose();
    super.onClose();
  }
}
