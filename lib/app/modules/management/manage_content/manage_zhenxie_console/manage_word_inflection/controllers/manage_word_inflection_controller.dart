import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../routes/routes.dart';
import '../../../../utils/utils.dart';

class ManageWordInflectionController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageWordInflectionController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_WORD_INFLECTION;

  @override
  String get breadcrumbTitle => '曲折变化';

  final RxMap<String, FilterSortsData> filterSorts = <String, FilterSortsData>{}.obs;

  final RxMap<String, FilterConditionsData> filterConditions = <String, FilterConditionsData>{}.obs;

  final Map<String, FilterSearchsData> filterSearchs = {
    "content": FilterSearchsData(
      title: "搜索",
      hintText: "lemma / familyKey / 词形",
      controller: TextEditingController(),
    ),
  };

  final RxList<WordInflectionListItemEntity> wordInflectionList = <WordInflectionListItemEntity>[].obs;

  final ScrollController scrollController = ScrollController();

  final Map<String, String> posNameMap = <String, String>{};

  final Map<String, String> grammaticalTypeNameMap = <String, String>{};

  final Map<String, String> orderValueMap = <String, String>{};

  int total = 0;

  int offset = 0;

  int limit = 30;

  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    listenScroll();
    initData();
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

  void listenScroll() {
    scrollController.addListener(() {
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200 &&
          !scrollController.position.outOfRange) {
        if (!isLoading.value && wordInflectionList.length < total) {
          offset += limit;
          getListData();
        }
      }
    });
  }

  Future<void> getFiltersGroup() async {
    try {
      FiltersGroupEntity? filtersGroup = await LanguageConsoleRequest.getWordInflectionFilters();
      if (filtersGroup == null) return;
      filterConditions.value = FilterStripUtils.getConditionDataFrom(filtersGroup);
      filterSorts.value = _getSortDataFrom(filtersGroup);
      _cacheFilterValueNames(filtersGroup);
    } catch (_) {}
  }

  Future<void> refreshList() async {
    wordInflectionList.clear();
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
      String? selectedOrderValue = getSelectedOrderValue();
      if (selectedOrderValue != null && selectedOrderValue.isNotEmpty) {
        params["order"] = selectedOrderValue;
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
      if (filters.isNotEmpty) {
        reqData["filters"] = filters;
      }
      Map<String, dynamic> searchParams = FilterStripUtils.getSearchParameter(searchs: filterSearchs);
      if (searchParams.isNotEmpty) {
        reqData.addAll(searchParams);
      }

      ListResponseEntity<WordInflectionListItemEntity>? list = await LanguageConsoleRequest.queryWordInflectionList(
        parameters: params,
        data: reqData,
      );
      if (list == null) return;
      total = list.count ?? 0;
      wordInflectionList.addAll(list.datas ?? []);
    } finally {
      isLoading.value = false;
      if (showLoading) ToastUtils.hideLoading();
    }
  }

  Map<String, FilterSortsData> _getSortDataFrom(FiltersGroupEntity filtersGroup) {
    Map<String, FilterSortsData> filterData = <String, FilterSortsData>{};
    List<FiltersGroupEntityFilters?> orders = filtersGroup.orders ?? [];

    for (var group in orders) {
      String? groupCode = group?.code;
      String? groupName = group?.name;
      if (groupCode == null || groupName == null) continue;
      List<FilterSortsItem> sortItems = [];
      bool hasSelected = false;
      List<FiltersGroupEntityValues?> values = group?.values ?? [];
      for (int i = 0; i < values.length; i++) {
        String? itemName = values[i]?.name;
        String? itemValue = values[i]?.value;
        if (itemName == null || itemValue == null) continue;
        bool selected = values[i]?.defaultValue ?? false;
        if (selected) {
          hasSelected = true;
        }
        orderValueMap[_sortItemKey(groupCode, itemName)] = itemValue;
        sortItems.add(FilterSortsItem(
          name: itemName,
          selected: selected,
          isDefault: selected,
          direction: itemValue.endsWith('_desc') ? FilterSortDirection.down : FilterSortDirection.up,
        ));
      }
      if (sortItems.isNotEmpty && !hasSelected) {
        sortItems.first.selected = true;
        sortItems.first.isDefault = true;
      }
      if (sortItems.isEmpty) continue;
      filterData[groupCode] = FilterSortsData(
        title: groupName,
        sorts: sortItems,
      );
    }
    return filterData;
  }

  void _cacheFilterValueNames(FiltersGroupEntity filtersGroup) {
    posNameMap.clear();
    grammaticalTypeNameMap.clear();

    List<FiltersGroupEntityFilters?> filters = filtersGroup.filters ?? [];
    for (int i = 0; i < filters.length; i++) {
      String? code = filters[i]?.code;
      List<FiltersGroupEntityValues?> values = filters[i]?.values ?? [];
      for (int j = 0; j < values.length; j++) {
        String? value = values[j]?.value;
        String? name = values[j]?.name;
        if (value == null || name == null) continue;
        if (code == "pos") {
          posNameMap[value] = name;
        }
        if (code == "grammaticalType") {
          grammaticalTypeNameMap[value] = name;
        }
      }
    }
  }

  String? getSelectedOrderValue() {
    for (final entry in filterSorts.entries) {
      FilterSortsItem? selectedItem = entry.value.sorts.firstWhereOrNull((item) => item.selected);
      if (selectedItem == null) continue;
      return orderValueMap[_sortItemKey(entry.key, selectedItem.name)];
    }
    return null;
  }

  String getPosName(String? pos) {
    if (pos == null || pos.isEmpty) return '';
    return posNameMap[pos] ?? pos;
  }

  List<String> getGrammaticalTypeNames(List<String?>? nids) {
    if (nids == null || nids.isEmpty) return [];
    return nids
        .whereType<String>()
        .map((nid) => grammaticalTypeNameMap[nid] ?? nid)
        .toList();
  }

  String _sortItemKey(String groupCode, String itemName) {
    return "$groupCode::$itemName";
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
