import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/subscribe.dart';
import 'package:langwise/common/stores/user.dart';
import 'package:langwise/utils/utils.dart';

import '../../routes/routes.dart';
import '../../routes/routes_breadcrumb_utils.dart';
import '../../routes/tag_routes.dart';
import '../../../utils/play_record_utils/play_record_utils.dart';

class SubListenDetailsController extends GetxController with RoutesBreadcrumbMixin {
  final String tagText;
  SubListenDetailsController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.APP_SUBSCRIBE_LISTENING_DETAILS;

  @override
  String get breadcrumbTitle => "详情";

  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();

  final RxList<UserRevealDetailItemEntity> items =
      <UserRevealDetailItemEntity>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isNotData = false.obs;
  final RxInt total = 0.obs;
  final Rxn<ZhenduScriptQueryMetaGroupListEntity> metaGroupList =
      Rxn<ZhenduScriptQueryMetaGroupListEntity>();
  final RxMap<String, List<String>> selectedFilters =
      <String, List<String>>{}.obs;
  final RxString selectedOrderGroupCode = ''.obs;
  final RxString selectedOrderValue = ''.obs;
  final RxString title = ''.obs;
  final RxString description = ''.obs;
  final RxInt userDifficulty = 0.obs;
  final RxInt settingDifficulty = 0.obs;
  final SearchHintRotator searchHintRotator = SearchHintRotator();

  late final int collectionId;
  String _initialThemeTitle = '';
  int offset = 0;
  final int limit = 30;
  bool loadingMore = false;

  List<String> difficultyList = ['Pre A1', 'A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
  Map<int, String> dif = {
    0: 'Pre A1',
    1: 'A1',
    2: 'A2',
    3: 'B1',
    4: 'B2',
    5: 'C1',
    6: 'C2',
  };

  bool get hasMore => offset < total.value;

  List<ZhenduScriptQueryMetaGroupEntity> get filterGroups =>
      metaGroupList.value?.filters ??
      const <ZhenduScriptQueryMetaGroupEntity>[];

  List<ZhenduScriptQueryMetaGroupEntity> get orderGroups =>
      metaGroupList.value?.orders ?? const <ZhenduScriptQueryMetaGroupEntity>[];

  String get currentSearchHintText {
    final String hint = searchHintRotator.currentHint.value.trim();
    if (hint.isNotEmpty) return hint;
    return '搜索时文标题';
  }

  @override
  void onInit() {
    super.onInit();
    final dynamic args = Get.arguments;
    collectionId = args['collectionId'];
    title.value = (args['title'] ?? '').toString();
    description.value = (args['description'] ?? '').toString();
    initBreadcrumb(tagText, title: title.value);
    _initialThemeTitle = title.value.trim();
    _initPage();
  }

  Future<void> _initPage() async {
    ToastUtils.showLoading();
    try {
      await _loadMemberDifficulty();
      await _ensureMetaLoaded();
      await refreshPage(showLoading: false);
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<void> readReveal(UserRevealDetailItemEntity item, int index) async {
    final LockEntity? mRights = item.cardRights;
    if (mRights == null) return;
    final bool lock = await LockUtils.checkLock(
      mRights,
      Get.context!,
      contentType: item.contentType,
    );
    if (lock) return;
    UserStore.to.getUserInfo();

    final List<Map<String, dynamic>> contents = <Map<String, dynamic>>[];
    for (int i = 0; i < items.length; i++) {
      contents.add({
        'contentId': items[i].contentId,
        'contentType': items[i].contentType,
        'styleId': items[i].styleId,
        'dialect': items[i].dialect,
      });
    }

    TagRoutes.toNamed(
      Routes.LISTEN_AND_READ,
      arguments: {
        'contentId': item.contentId,
        'contentType': item.contentType,
        'contents': contents,
        'type': PlayRecordPageType.collection.value,
        'typeId': collectionId,
      },
    )!
        .then((_) {
      refreshPage(showLoading: false);
    });
  }

  Future<void> _loadMemberDifficulty() async {
    final dynamic res = await SubscribeRequest.memberDifficulty();
    if (res == null || res.data == null) return;
    final dynamic data = res.data;
    if (data is int) {
      userDifficulty.value = data;
      settingDifficulty.value = data;
    }
  }

  Future<void> refreshPage({bool showLoading = true}) async {
    await loadPage(reset: true, showLoading: showLoading);
  }

  Future<void> loadPage({
    bool reset = false,
    bool showLoading = false,
  }) async {
    if (!reset && loadingMore) return;
    if (!reset && !hasMore) return;
    try {
      if (reset) {
        offset = 0;
        loadingMore = false;
        total.value = 0;
        items.clear();
        isNotData.value = false;
      } else {
        loadingMore = true;
      }
      if (offset == 0) {
        isLoading.value = showLoading;
      }

      if (showLoading) {
        ToastUtils.showLoading();
      }
      final UserRevealDetailsPageEntity? page =
          await SubscribeRequest.getRevealDetailsPageByQuery(
        collectionId: collectionId,
        offset: offset,
        limit: limit,
        order: selectedOrderValue.value.trim().isEmpty
            ? null
            : selectedOrderValue.value.trim(),
        reqData: _buildRequestData(),
      );
      if (page == null) {
        if (items.isEmpty) {
          isNotData.value = true;
        }
        return;
      }

      total.value = page.count ?? 0;
      final List<UserRevealDetailItemEntity> list = page.datas ?? [];
      items.addAll(list);
      offset += limit;
      isNotData.value = items.isEmpty;
    } finally {
      if (showLoading) {
        ToastUtils.hideLoading();
      }
      if (offset == 0) {
        isLoading.value = false;
      }
      loadingMore = false;
    }
  }

  Map<String, dynamic> _buildRequestData() {
    final Map<String, dynamic> reqData = <String, dynamic>{};
    final String keyword = searchController.text.trim();
    if (keyword.isNotEmpty) {
      reqData['content'] = keyword;
    }
    final List<Map<String, dynamic>>? filters = _buildRequestFilters();
    if (filters != null && filters.isNotEmpty) {
      reqData['filters'] = filters;
    }
    return reqData;
  }

  List<Map<String, dynamic>>? _buildRequestFilters() {
    if (selectedFilters.isEmpty) return null;
    final List<Map<String, dynamic>> resp = <Map<String, dynamic>>[];
    selectedFilters.forEach((key, values) {
      final String code = key.trim();
      final List<String> selectedValues =
          values.map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      if (code.isEmpty || selectedValues.isEmpty) return;
      resp.add(<String, dynamic>{
        'code': code,
        'values': selectedValues,
      });
    });
    return resp.isEmpty ? null : resp;
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
    await refreshPage(showLoading: true);
  }

  Future<void> applyConditionSelections(
    Map<String, List<String>> selections,
  ) async {
    selectedFilters
      ..clear()
      ..addAll(selections);
    _syncDifficultyFromSelections(selections);
    await refreshPage(showLoading: true);
  }

  Future<void> setDifficultySelection(int difficulty) async {
    settingDifficulty.value = difficulty;
    final Map<String, List<String>> nextSelections =
        Map<String, List<String>>.from(selectedFilters);
    nextSelections['difficulty'] = <String>[difficulty.toString()];
    selectedFilters
      ..clear()
      ..addAll(nextSelections);
    await refreshPage(showLoading: true);
  }

  Future<void> submitSearch() async {
    await refreshPage(showLoading: true);
  }

  void resetFilters() {
    selectedFilters.clear();
    selectedOrderGroupCode.value = '';
    selectedOrderValue.value = '';
    _applyDefaultSelections();
    refreshPage(showLoading: true);
  }

  Future<void> _ensureMetaLoaded({bool forceReload = false}) async {
    if (!forceReload && metaGroupList.value != null) {
      if (selectedOrderValue.value.isEmpty && selectedFilters.isEmpty) {
        _applyDefaultSelections();
      }
      return;
    }
    final ZhenduScriptQueryMetaGroupListEntity? data =
        await SubscribeRequest.getCollectionQueryMetaGroupList();
    if (data == null) return;
    metaGroupList.value = data;
    searchHintRotator.updateHints(data.searchHints);
    _applyDefaultSelections();
  }

  void _applyDefaultSelections() {
    if (selectedOrderValue.value.isNotEmpty || selectedFilters.isNotEmpty) {
      return;
    }
    _applyDefaultFilterSelections();
    _applyInitialFilterSelections();
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

  void _applyInitialFilterSelections() {
    final String? themeValue = _findThemeFilterValue();
    if (themeValue != null && themeValue.isNotEmpty) {
      selectedFilters['theme'] = <String>[themeValue];
    }
    if (_hasFilterGroup('difficulty')) {
      selectedFilters['difficulty'] = <String>[
        settingDifficulty.value.toString()
      ];
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

  void _syncDifficultyFromSelections(Map<String, List<String>> selections) {
    final List<String>? difficultyValues = selections['difficulty'];
    if (difficultyValues == null || difficultyValues.isEmpty) return;
    final int? value = int.tryParse(difficultyValues.first);
    if (value == null) return;
    settingDifficulty.value = value;
  }

  bool _hasFilterGroup(String groupCode) {
    for (final ZhenduScriptQueryMetaGroupEntity group in filterGroups) {
      if ((group.groupCode ?? '').trim() == groupCode) {
        return true;
      }
    }
    return false;
  }

  String? _findThemeFilterValue() {
    final String expected = _initialThemeTitle.trim();
    if (expected.isEmpty) return null;
    for (final ZhenduScriptQueryMetaGroupEntity group in filterGroups) {
      if ((group.groupCode ?? '').trim() != 'theme') continue;
      for (final ZhenduScriptQueryMetaItemEntity item in group.items) {
        final String name = (item.name ?? '').trim();
        if (name.isEmpty) continue;
        if (name == expected) {
          return (item.value ?? '').trim();
        }
      }
    }
    return null;
  }

  bool isFilterSelected(String groupCode, String value) {
    final List<String>? values = selectedFilters[groupCode];
    if (values == null || values.isEmpty) return false;
    return values.contains(value);
  }

  bool isSortSelected(String groupCode, String value) {
    return selectedOrderGroupCode.value == groupCode &&
        selectedOrderValue.value == value;
  }

  String sortItemValueByName(String groupCode, String itemName) {
    for (final ZhenduScriptQueryMetaGroupEntity group in orderGroups) {
      if ((group.groupCode ?? '') != groupCode) continue;
      for (final ZhenduScriptQueryMetaItemEntity item in group.items) {
        if ((item.name ?? '') == itemName) {
          return item.value ?? '';
        }
      }
    }
    return '';
  }

  @override
  void onClose() {
    searchHintRotator.dispose();
    scrollController.dispose();
    searchController.dispose();
    super.onClose();
  }
}
