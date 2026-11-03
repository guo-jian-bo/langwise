import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/app_pages.dart';
import 'package:langwise/app/routes/routes_breadcrumb_utils.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/https/music.dart';
import '../../../../common/https/subscribe.dart';
import '../../../../utils/utils.dart';

class NewMusicController extends GetxController with RoutesBreadcrumbMixin {
  final String tagText;
  NewMusicController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.MUSIC;

  @override
  String get breadcrumbTitle => '音乐';

  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();

  final RxBool isLoading = true.obs;
  final RxBool isNotData = false.obs;
  final RxList<SongDetailsItem> songList = <SongDetailsItem>[].obs;
  final Rx<LockEntity> rights = LockEntity().obs;
  final Rxn<ZhenduScriptQueryMetaGroupListEntity> metaGroupList =
      Rxn<ZhenduScriptQueryMetaGroupListEntity>();

  final RxMap<String, List<String>> selectedFilters =
      <String, List<String>>{}.obs;
  final RxString selectedOrderGroupCode = ''.obs;
  final RxString selectedOrderValue = ''.obs;
  final RxString draftQuery = ''.obs;
  final RxString committedQuery = ''.obs;
  final RxInt totalCount = 0.obs;
  final RxInt userDifficulty = 0.obs;
  final RxInt settingDifficulty = 0.obs;
  final SearchHintRotator searchHintRotator = SearchHintRotator();
  final List<String> difficultyList = <String>[
    'Pre A1',
    'A1',
    'A2',
    'B1',
    'B2',
    'C1',
    'C2',
  ];

  int offset = 0;
  final int limit = 30;
  bool loadingMore = false;
  int _loadingCount = 0;

  bool get hasMore => songList.length < totalCount.value;

  List<ZhenduScriptQueryMetaGroupEntity> get filterGroups =>
      metaGroupList.value?.filters ??
      const <ZhenduScriptQueryMetaGroupEntity>[];

  List<ZhenduScriptQueryMetaGroupEntity> get orderGroups =>
      metaGroupList.value?.orders ?? const <ZhenduScriptQueryMetaGroupEntity>[];

  String get currentSearchHintText {
    final String hint = searchHintRotator.currentHint.value.trim();
    if (hint.isNotEmpty) return hint;
    return '搜索标题、关键字';
  }

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    draftQuery.listen((value) {
      if (searchController.text != value) {
        searchController.text = value;
        searchController.selection = TextSelection.fromPosition(
          TextPosition(offset: searchController.text.length),
        );
      }
    });
    initPage(showLoading: true);
  }

  Future<void> initPage({bool showLoading = false}) async {
    if (LockUtils.checkExperienceAppStorage()) return;
    await _runWithLoading(() async {
      await _loadMemberDifficulty();
      await _ensureMetaLoaded();
      await refreshSongs(showLoading: false);
    }, enabled: showLoading);
  }

  Future<void> refreshSongs({bool showLoading = true}) async {
    await loadSong(reset: true, showLoading: showLoading);
  }

  Future<void> loadSong({
    bool reset = false,
    bool showLoading = false,
  }) async {
    if (!reset && loadingMore) return;
    try {
      if (reset) {
        offset = 0;
        loadingMore = false;
        totalCount.value = 0;
        songList.clear();
        isNotData.value = false;
      }
      if (!reset && !hasMore) return;
      if (!reset) {
        loadingMore = true;
      }
      if (offset == 0) {
        isLoading.value = showLoading;
      }
      final SongDetailsPageData? page = await _runWithLoading(
        () => MusicRequest.getSongDetailsPageByQuery(
          offset: offset,
          limit: limit,
          order: selectedOrderValue.value.trim().isEmpty
              ? null
              : selectedOrderValue.value.trim(),
          reqData: _buildRequestData(),
        ),
        enabled: showLoading,
      );
      if (page == null) {
        if (songList.isEmpty) isNotData.value = true;
        return;
      }

      rights.value = page.rights ?? LockEntity();
      totalCount.value = page.count ?? 0;
      final List<SongDetailsItem> items = (page.datas ?? <SongDetailsItem?>[])
          .whereType<SongDetailsItem>()
          .toList();
      songList.addAll(items);
      offset = songList.length;
      isNotData.value = songList.isEmpty;
    } finally {
      if (offset == 0) {
        isLoading.value = false;
      }
      loadingMore = false;
    }
  }

  Map<String, dynamic> _buildRequestData() {
    final Map<String, dynamic> reqData = <String, dynamic>{};
    reqData['difficulty'] = settingDifficulty.value;
    final String keyword = committedQuery.value.trim();
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
    await refreshSongs(showLoading: true);
  }

  Future<void> applyConditionSelections(
    Map<String, List<String>> selections,
  ) async {
    selectedFilters
      ..clear()
      ..addAll(selections);
    await refreshSongs(showLoading: true);
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
    await refreshSongs(showLoading: true);
  }

  String _resolveSubmittedSearchKeyword() {
    final String keyword = searchController.text.trim();
    if (keyword.isNotEmpty) return keyword;
    return currentSearchHintText.trim();
  }

  void resetFilters() {
    searchController.clear();
    draftQuery.value = '';
    committedQuery.value = '';
    selectedFilters.clear();
    selectedOrderGroupCode.value = '';
    selectedOrderValue.value = '';
    _applyDefaultSelections();
    refreshSongs(showLoading: true);
  }

  Future<void> _ensureMetaLoaded({bool forceReload = false}) async {
    if (!forceReload && metaGroupList.value != null) {
      if (selectedOrderValue.value.isEmpty && selectedFilters.isEmpty) {
        _applyDefaultSelections();
      }
      return;
    }
    final ZhenduScriptQueryMetaGroupListEntity? data = await _runWithLoading(
      () => MusicRequest.getSongQueryMetaGroupList(),
      enabled: false,
    );
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

  void freshSingleSong(SongDetailsItem item) {
    item.favourite = !(item.favourite ?? false);
    songList.refresh();
  }

  Future<void> _loadMemberDifficulty() async {
    final dynamic res = await SubscribeRequest.memberDifficulty();
    if (res == null || res.data == null) return;
    final dynamic data = res.data;
    if (data is! int) return;
    userDifficulty.value = data;
    settingDifficulty.value = data;
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

  @override
  void onClose() {
    searchHintRotator.dispose();
    scrollController.dispose();
    searchController.dispose();
    super.onClose();
  }
}
