import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/utils/utils.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/app/routes/routes_breadcrumb_utils.dart';

class ZhenduTheaterListController extends GetxController
    with RoutesBreadcrumbMixin {
  static const int pageLimit = 30;

  final String tagText;
  final ZhenduTheaterEntity theater;

  ZhenduTheaterListController({
    required this.tagText,
    required this.theater,
  });

  @override
  String get breadcrumbRoute => Routes.ZHENDU_THEATER_LIST;

  @override
  String get breadcrumbTitle => getHeroTitle();

  final RxBool isLoading = true.obs;
  final RxBool isNotData = false.obs;

  final TextEditingController searchController = TextEditingController();
  final RxString draftQuery = ''.obs;
  final RxString committedQuery = ''.obs;
  final Rx<LockEntity> pageRights = LockEntity().obs;
  final Rxn<ZhenduScriptQueryMetaGroupListEntity> metaGroupList =
      Rxn<ZhenduScriptQueryMetaGroupListEntity>();
  final RxMap<String, List<String>> selectedFilters =
      <String, List<String>>{}.obs;
  final RxString selectedOrderGroupCode = ''.obs;
  final RxString selectedOrderValue = ''.obs;
  final SearchHintRotator searchHintRotator = SearchHintRotator();

  final RxList<KnowledgeCommonEntityList> items =
      <KnowledgeCommonEntityList>[].obs;
  final RxInt totalCount = 0.obs;
  int offset = 0;
  final int limit = pageLimit;
  bool loadingMore = false;
  int _loadingCount = 0;

  bool get hasMore => items.length < totalCount.value;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText, title: getHeroTitle());
    draftQuery.listen((value) {
      if (searchController.text != value) {
        searchController.text = value;
        searchController.selection = TextSelection.fromPosition(
            TextPosition(offset: searchController.text.length));
      }
    });
    initPage(showLoading: true);
  }

  @override
  void onClose() {
    searchHintRotator.dispose();
    scrollController.dispose();
    searchController.dispose();
    super.onClose();
  }

  final ScrollController scrollController = ScrollController();

  String get currentSearchHintText {
    final String hint = searchHintRotator.currentHint.value.trim();
    if (hint.isNotEmpty) return hint;
    return '搜索标题、关键字';
  }

  Future<void> initPage({
    bool showLoading = false,
    bool reloadMeta = false,
  }) async {
    await _runWithLoading(() async {
      await _ensureMetaLoaded(forceReload: reloadMeta);
      await refreshItems(showLoading: false);
    }, enabled: showLoading);
  }

  Future<void> refreshItems({bool showLoading = true}) async {
    await loadItems(reset: true, showLoading: showLoading);
  }

  Future<void> loadItems({
    bool reset = false,
    bool showLoading = false,
  }) async {
    if (!reset && loadingMore) return;
    try {
      if (reset) {
        offset = 0;
        loadingMore = false;
        totalCount.value = 0;
        items.clear();
        isNotData.value = false;
      }
      if (!reset && !hasMore) return;
      if (!reset) {
        loadingMore = true;
      }
      if (offset == 0) {
        isLoading.value = showLoading;
      }

      final String category = theater.category ?? '';
      final ZhenduCategoryContentV2PagesEntity? resp =
          await _runWithLoading<ZhenduCategoryContentV2PagesEntity?>(
        () => ZhenduRequest.getCategoryContentPages(
          category: category,
          offset: offset,
          limit: limit,
          query:
              committedQuery.value.trim().isEmpty ? null : committedQuery.value,
          filters: _buildRequestFilters(),
          order: _buildRequestOrder(),
        ),
        enabled: showLoading,
      );
      if (resp == null) {
        if (items.isEmpty) isNotData.value = true;
        return;
      }

      pageRights.value = resp.rights ?? LockEntity();
      totalCount.value = resp.count ?? 0;
      items.addAll(resp.list);
      offset = items.length;
      isNotData.value = items.isEmpty;
    } finally {
      if (offset == 0) {
        isLoading.value = false;
      }
      loadingMore = false;
    }
  }

  String _resolveSubmittedSearchKeyword() {
    final String keyword = searchController.text.trim();
    if (keyword.isNotEmpty) return keyword;
    return currentSearchHintText.trim();
  }

  Future<void> submitSearch() async {
    final String keyword = _resolveSubmittedSearchKeyword();
    if (searchController.text != keyword) {
      searchController.text = keyword;
      searchController.selection = TextSelection.fromPosition(
        TextPosition(offset: keyword.length),
      );
    }
    draftQuery.value = keyword;
    committedQuery.value = keyword;
    await refreshItems(showLoading: true);
  }

  void resetFilters() {
    searchController.clear();
    draftQuery.value = '';
    committedQuery.value = '';
    selectedFilters.clear();
    selectedOrderGroupCode.value = '';
    selectedOrderValue.value = '';
    _applyDefaultSelections();
    refreshItems(showLoading: true);
  }

  Future<void> applyConditionSelections(
    Map<String, List<String>> selections,
  ) async {
    selectedFilters
      ..clear()
      ..addAll(selections);
    await refreshItems(showLoading: true);
  }

  Future<void> applySortSelection({
    required String groupCode,
    required String value,
  }) async {
    if (selectedOrderGroupCode.value == groupCode &&
        selectedOrderValue.value == value) {
      return;
    }
    selectedOrderGroupCode.value = groupCode;
    selectedOrderValue.value = value;
    await refreshItems(showLoading: true);
  }

  Future<void> loadMore() async {
    if (isLoading.value || loadingMore || !hasMore) return;
    await loadItems();
  }

  Future<void> _ensureMetaLoaded({bool forceReload = false}) async {
    if (!forceReload && metaGroupList.value != null) {
      if (selectedOrderValue.value.isEmpty && selectedFilters.isEmpty) {
        _applyDefaultSelections();
      }
      return;
    }
    Map<String, dynamic> params = {
      "category": theater.category ?? '',
    };
    final resp = await ZhenduRequest.getScriptQueryMetaGroupList(parameters: params);
    if (resp == null) {
      return;
    }
    metaGroupList.value = resp;
    searchHintRotator.updateHints(resp.searchHints);
    _applyDefaultSelections();
  }

  void _applyDefaultSelections() {
    if (selectedOrderValue.value.isNotEmpty || selectedFilters.isNotEmpty) {
      return;
    }
    _applyDefaultFilterSelections();
    _applyDefaultOrderSelection();
  }

  void _applyDefaultFilterSelections() {
    final Map<String, List<String>> defaults = <String, List<String>>{};
    final Map<String, String> linkedGroupSelections = <String, String>{};
    for (final ZhenduScriptQueryMetaGroupEntity group in filterGroups) {
      final String groupCode = (group.groupCode ?? '').trim();
      if (groupCode.isEmpty || group.items.isEmpty) continue;
      final List<String> values = group.items
          .where((e) => e.defaultValue ?? false)
          .map((e) => (e.value ?? '').trim())
          .where((e) => e.isNotEmpty)
          .toList();
      if (values.isEmpty) continue;

      final String filterGroup = (group.filterGroup ?? '').trim();
      final bool isLinkedRadioGroup = filterGroup.isNotEmpty &&
          (group.radioGroup ?? false) &&
          values.isNotEmpty;
      if (isLinkedRadioGroup) {
        final String? previousGroupCode = linkedGroupSelections[filterGroup];
        if (previousGroupCode != null) {
          defaults.remove(previousGroupCode);
        }
        linkedGroupSelections[filterGroup] = groupCode;
        defaults[groupCode] = <String>[values.first];
        continue;
      }

      final bool isSingle = (group.component ?? '').trim() == 'radio';
      defaults[groupCode] = isSingle ? <String>[values.first] : values;
    }
    if (defaults.isNotEmpty) {
      selectedFilters.addAll(defaults);
    }
  }

  void _applyDefaultOrderSelection() {
    for (final ZhenduScriptQueryMetaGroupEntity group in orderGroups) {
      ZhenduScriptQueryMetaItemEntity? selected;
      for (final ZhenduScriptQueryMetaItemEntity item in group.items) {
        if (item.defaultValue ?? false) {
          selected = item;
          break;
        }
      }
      if (selected == null) continue;
      selectedOrderGroupCode.value = (group.groupCode ?? '').trim();
      selectedOrderValue.value = selected.value ?? '';
      break;
    }
  }

  List<Map<String, dynamic>>? _buildRequestFilters() {
    if (selectedFilters.isEmpty) return null;
    final resp = <Map<String, dynamic>>[];
    selectedFilters.forEach((key, values) {
      final k = key.trim();
      final selectedValues =
          values.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      if (k.isEmpty || selectedValues.isEmpty) return;
      resp.add(<String, dynamic>{
        'code': k,
        'values': selectedValues,
      });
    });
    return resp.isEmpty ? null : resp;
  }

  String? _buildRequestOrder() {
    final value = selectedOrderValue.value.trim();
    if (value.isEmpty) return null;
    return value;
  }

  List<ZhenduScriptQueryMetaGroupEntity> get filterGroups =>
      metaGroupList.value?.filters ??
      const <ZhenduScriptQueryMetaGroupEntity>[];

  List<ZhenduScriptQueryMetaGroupEntity> get orderGroups =>
      metaGroupList.value?.orders ?? const <ZhenduScriptQueryMetaGroupEntity>[];

  bool get hasFilterMeta => filterGroups.isNotEmpty || orderGroups.isNotEmpty;

  bool isFilterSelected(String groupCode, String value) {
    final values = selectedFilters[groupCode];
    if (values == null || values.isEmpty) return false;
    return values.contains(value);
  }

  bool isSortSelected(String groupCode, String value) {
    return selectedOrderGroupCode.value == groupCode &&
        selectedOrderValue.value == value;
  }

  String sortItemValueByName(String groupCode, String itemName) {
    final group = orderGroups.firstWhereOrNull(
      (e) => (e.groupCode ?? '') == groupCode,
    );
    if (group == null) return '';
    final item =
        group.items.firstWhereOrNull((e) => (e.name ?? '') == itemName);
    return item?.value ?? '';
  }

  String get currentSortLabel {
    final groupCode = selectedOrderGroupCode.value;
    final value = selectedOrderValue.value;
    for (final group in orderGroups) {
      if ((group.groupCode ?? '') != groupCode) continue;
      final item =
          group.items.firstWhereOrNull((e) => (e.value ?? '') == value);
      if (item == null) continue;
      return '${group.groupName ?? ''} · ${item.name ?? ''}';
    }
    return '';
  }

  List<String> get activeFilterSummaries {
    final resp = <String>[];
    for (final group in filterGroups) {
      final key = group.groupCode ?? '';
      final values = selectedFilters[key];
      if (values == null || values.isEmpty) continue;
      for (final value in values) {
        final item =
            group.items.firstWhereOrNull((e) => (e.value ?? '') == value);
        if (item == null) continue;
        resp.add('${group.groupName ?? key} · ${item.name ?? value}');
      }
    }
    return resp;
  }

  bool get hasActiveState {
    final queryActive = committedQuery.value.trim().isNotEmpty;
    final filterActive = selectedFilters.isNotEmpty;
    final sortActive = selectedOrderGroupCode.value.trim().isNotEmpty &&
        selectedOrderValue.value.trim().isNotEmpty;
    return queryActive || filterActive || sortActive;
  }

  Future<T> _runWithLoading<T>(
    Future<T> Function() task, {
    required bool enabled,
  }) async {
    if (!enabled) return task();
    _loadingCount++;
    if (_loadingCount == 1) {
      ToastUtils.showLoading();
    }
    try {
      return await task();
    } finally {
      _loadingCount--;
      if (_loadingCount <= 0) {
        _loadingCount = 0;
        ToastUtils.hideLoading();
      }
    }
  }

  String getHeroTitle() {
    return LearningLangUtils.getLocalLang(theater.title)?.text ??
        LearningLangUtils.getLearningLang(theater.title)?.text ??
        '甄读剧场';
  }

  String getHeroDescription() {
    return LearningLangUtils.getLocalLang(theater.description)?.text ??
        LearningLangUtils.getLearningLang(theater.description)?.text ??
        '';
  }

  String getHeroMarquee() {
    return (theater.label ?? '').toUpperCase();
  }

  String getHeroHallNote() {
    return LearningLangUtils.getLocalLang(theater.tip)?.text ??
        LearningLangUtils.getLearningLang(theater.tip)?.text ??
        '';
  }
}
