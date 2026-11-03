import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/utils/utils.dart';

class ZhenduTheaterListController extends GetxController {
  static const int pageLimit = 20;

  final ZhenduTheaterEntity theater;

  ZhenduTheaterListController({required this.theater});

  final RxBool isLoading = false.obs;
  final RxInt loadStatus = (-1).obs;

  final TextEditingController searchController = TextEditingController();
  final RxString draftQuery = ''.obs;
  final RxString committedQuery = ''.obs;
  final Rxn<LockEntity> pageRights = Rxn<LockEntity>();
  final Rxn<ZhenduScriptQueryMetaGroupListEntity> metaGroupList =
      Rxn<ZhenduScriptQueryMetaGroupListEntity>();
  final RxMap<String, List<String>> selectedFilters =
      <String, List<String>>{}.obs;
  final RxString selectedOrderGroupCode = ''.obs;
  final RxString selectedOrderValue = ''.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;
  final EasyRefreshController refreshController = EasyRefreshController(
    controlFinishLoad: true,
  );

  final RxList<ZhenduScriptEntity> items = <ZhenduScriptEntity>[].obs;
  final List<ZhenduScriptEntity> _allItems = [];
  int _nextOffset = 0;

  @override
  void onInit() {
    super.onInit();
    draftQuery.listen((value) {
      if (searchController.text != value) {
        searchController.text = value;
        searchController.selection = TextSelection.fromPosition(TextPosition(offset: searchController.text.length));
      }
    });
    initPage();
  }

  @override
  void onClose() {
    refreshController.dispose();
    scrollController.dispose();
    searchController.dispose();
    super.onClose();
  }

  final ScrollController scrollController = ScrollController();

  Future<void> initPage({bool reloadMeta = false}) async {
    _ensureMetaLoaded(forceReload: reloadMeta);
    _resetPagingCursor();
    await _fetchPage(showPageLoading: true, reloadMeta: reloadMeta);
  }

  Future<void> onResetQuery() async {
    searchController.clear();
    draftQuery.value = '';
    committedQuery.value = '';
    selectedFilters.clear();
    selectedOrderGroupCode.value = '';
    selectedOrderValue.value = '';
    _resetPagingCursor();
    await _fetchPage();
  }

  Future<void> commitQuery() async {
    final keyword = searchController.text.trim();
    draftQuery.value = keyword;
    committedQuery.value = keyword;
    _resetPagingCursor();
    await _fetchPage();
  }

  Future<void> refreshFilters() async {
    _resetPagingCursor();
    await _fetchPage();
  }

  Future<void> clearCommittedQuery() async {
    searchController.clear();
    draftQuery.value = '';
    committedQuery.value = '';
    _resetPagingCursor();
    await _fetchPage();
  }

  Future<void> applyConditionSelections(
    Map<String, List<String>> selections,
  ) async {
    selectedFilters
      ..clear()
      ..addAll(selections);
    _resetPagingCursor();
    await _fetchPage();
  }

  Future<void> applySortSelection({
    required String groupCode,
    required String value,
  }) async {
    selectedOrderGroupCode.value = groupCode;
    selectedOrderValue.value = value;
    _resetPagingCursor();
    await _fetchPage();
  }

  Future<void> loadMore() async {
    if (isLoading.value || isLoadingMore.value || !hasMore.value) {
      refreshController.finishLoad(
        hasMore.value ? IndicatorResult.none : IndicatorResult.noMore,
      );
      return;
    }
    await _fetchPage(append: true);
  }

  Future<void> _fetchPage({
    bool showPageLoading = false,
    bool reloadMeta = false,
    bool append = false,
  }) async {
    if (append) {
      isLoadingMore.value = true;
    } else {
      isLoading.value = true;
    }
    if (!append && showPageLoading) {
      loadStatus.value = -1;
    }
    ToastUtils.showLoading();
    try {
      final category = theater.category ?? '';
      if (!append) {
        pageRights.value = null;
      }

      final resp = await ZhenduRequest.getCategoryContentPages(
        category: category,
        offset: _nextOffset,
        limit: pageLimit,
        query:
            committedQuery.value.trim().isEmpty ? null : committedQuery.value,
        filters: _buildRequestFilters(),
        order: _buildRequestOrder(),
      );
      if (resp == null) {
        if (!append && (showPageLoading || items.isEmpty)) {
          loadStatus.value = 1;
        }
        return;
      }

      final fetchedItems = resp.items;
      final count = resp.count ?? 0;
      pageRights.value = resp.rights;
      _nextOffset += pageLimit;
      hasMore.value = count > 0 && fetchedItems.length >= 3;

      if (append) {
        if (fetchedItems.isNotEmpty) {
          _allItems.addAll(fetchedItems);
          items.addAll(fetchedItems);
        }
      } else {
        _allItems
          ..clear()
          ..addAll(fetchedItems);
        items.assignAll(fetchedItems);
      }

      if (!append) {
        loadStatus.value = items.isEmpty ? 4 : 0;
      } else if (items.isEmpty) {
        loadStatus.value = 4;
      } else {
        loadStatus.value = 0;
      }

      if (append) {
        refreshController.finishLoad(
          hasMore.value ? IndicatorResult.success : IndicatorResult.noMore,
        );
      }
    } catch (_) {
      if (!append && (showPageLoading || items.isEmpty)) {
        loadStatus.value = 1;
      }
      if (append) {
        refreshController.finishLoad(
          hasMore.value ? IndicatorResult.fail : IndicatorResult.noMore,
        );
      }
    } finally {
      if (append) {
        isLoadingMore.value = false;
      } else {
        isLoading.value = false;
      }
      if (!append) {
        refreshController.finishLoad();
      }
      ToastUtils.hideLoading();
    }
  }

  void _resetPagingCursor() {
    _nextOffset = 0;
    hasMore.value = true;
  }

  Future<void> _ensureMetaLoaded({bool forceReload = false}) async {
    if (!forceReload && metaGroupList.value != null) {
      return;
    }
    final resp = await ZhenduRequest.getScriptQueryMetaGroupList();
    if (resp == null) {
      return;
    }
    metaGroupList.value = resp;
  }

  List<Map<String, dynamic>>? _buildRequestFilters() {
    if (selectedFilters.isEmpty) return null;
    final resp = <Map<String, dynamic>>[];
    selectedFilters.forEach((key, values) {
      final k = key.trim();
      final selectedValues = values
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
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
      metaGroupList.value?.filters ?? const <ZhenduScriptQueryMetaGroupEntity>[];

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
    final item = group.items.firstWhereOrNull((e) => (e.name ?? '') == itemName);
    return item?.value ?? '';
  }

  String get currentSortLabel {
    final groupCode = selectedOrderGroupCode.value;
    final value = selectedOrderValue.value;
    for (final group in orderGroups) {
      if ((group.groupCode ?? '') != groupCode) continue;
      final item = group.items.firstWhereOrNull((e) => (e.value ?? '') == value);
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

  String getHeroTitle() {
    return LearningLangUtils.getLocalLang(theater.title)?.text ?? LearningLangUtils.getLearningLang(theater.title)?.text ?? '甄读剧场';
  }

  String getHeroDescription() {
    return LearningLangUtils.getLocalLang(theater.description)?.text ?? LearningLangUtils.getLearningLang(theater.description)?.text ?? '';
  }

  String getHeroMarquee() {
    return (theater.label ?? '').toUpperCase();
  }

  String getHeroHallNote() {
    return LearningLangUtils.getLocalLang(theater.tip)?.text ?? LearningLangUtils.getLearningLang(theater.tip)?.text ?? '';
  }

  String getDisplayTitle(ZhenduScriptEntity item) {
    final learning = LearningLangUtils.getLearningLang(item.title)?.text;
    if (learning != null && learning.trim().isNotEmpty) return learning.trim();
    final local = LearningLangUtils.getLocalLang(item.title)?.text;
    if (local != null && local.trim().isNotEmpty) return local.trim();
    return '';
  }

  String getDisplaySubtitle(ZhenduScriptEntity item) {
    final local = LearningLangUtils.getLocalLang(item.title)?.text;
    final learning = LearningLangUtils.getLearningLang(item.title)?.text;
    if (local != null && local.trim().isNotEmpty && local.trim() != learning?.trim()) return local.trim();
    final semanticContent = getSemanticContent(item);
    if (semanticContent.isNotEmpty) return semanticContent;
    return item.source?.name ?? '';
  }

  String getLevelLabel(ZhenduScriptEntity item) {
    final max = item.difficulty?.max ?? item.difficulty?.min;
    switch (max) {
      case 0:
        return 'Pre-A1';
      case 1:
        return 'A1';
      case 2:
        return 'A2';
      case 3:
        return 'B1';
      case 4:
        return 'B2';
      default:
        return 'A1';
    }
  }

  String getDurationLabel(ZhenduScriptEntity item) {
    final seconds = _durationWeight(item);
    final minutes = seconds ~/ 60;
    final remain = seconds % 60;
    return '$minutes:${remain.toString().padLeft(2, '0')}';
  }

  String getStyleLabel(ZhenduScriptEntity item) {
    if ((theater.category ?? '') == 'context') return '3D动画';
    if ((theater.category ?? '') == 'semantic') return '教育插画';
    return '绘本插画';
  }

  String getLocaleLabel(ZhenduScriptEntity item) {
    if ((theater.category ?? '') == 'semantic') return '英美';
    return '中国';
  }

  String getThemeLabel(ZhenduScriptEntity item) {
    return _getTagText(item, 0, fallback: '课堂主题');
  }

  String getGenreLabel(ZhenduScriptEntity item) {
    return _getTagText(item, 1, fallback: (theater.category ?? '') == 'semantic' ? '语义演绎' : '剧情故事');
  }

  String getSourceLine(ZhenduScriptEntity item) {
    final semanticContent = getSemanticContent(item);
    if (semanticContent.isNotEmpty) return semanticContent;
    final source = item.source?.name?.trim() ?? '';
    if (source.isNotEmpty) return source;
    return 'LangWise Official Course';
  }

  String getSemanticContent(ZhenduScriptEntity item) {
    final data = _sourceData(item);
    final content = data['content']?.toString().trim() ?? '';
    if (content.isNotEmpty) return content;
    return item.source?.name?.trim() ?? '';
  }

  String getSemanticPronunciations(ZhenduScriptEntity item) {
    final value = _sourceData(item)['pronunciations'];
    return _normalizeSourceValue(value);
  }

  String getSemanticTranslate(ZhenduScriptEntity item) {
    final value = _sourceData(item)['translate'];
    return _normalizeSourceValue(value);
  }

  String getResolvedCoverUrl(ZhenduScriptEntity item) {
    final coverUrl = item.coverUrl?.trim() ?? '';
    if (coverUrl.isNotEmpty) return coverUrl;
    final fallbackImages = _fallbackCoverImages;
    if (fallbackImages.isEmpty) return theater.backgroundImage?.trim() ?? '';
    final seed = _allItems.indexOf(item);
    final index = seed < 0 ? 0 : seed % fallbackImages.length;
    return fallbackImages[index];
  }

  bool isWatched(ZhenduScriptEntity item) {
    return item.isRead ?? false;
  }

  String _getTagText(ZhenduScriptEntity item, int index, {required String fallback}) {
    final tags = item.tags;
    if (tags == null || tags.length <= index) return fallback;
    final tag = tags[index];
    final local = LearningLangUtils.getLocalLang(tag.gloss)?.text;
    if (local != null && local.trim().isNotEmpty) return local.trim();
    final learning = LearningLangUtils.getLearningLang(tag.gloss)?.text;
    if (learning != null && learning.trim().isNotEmpty) return learning.trim();
    return fallback;
  }

  int _durationWeight(ZhenduScriptEntity item) {
    if (item.duration != null && item.duration! > 0) {
      return item.duration!.round();
    }
    final sceneCount = item.sceneCount ?? 1;
    return sceneCount * 35;
  }

  Map<String, dynamic> _sourceData(ZhenduScriptEntity item) {
    final data = item.source?.data;
    if (data == null) return const <String, dynamic>{};
    return data;
  }

  String _normalizeSourceValue(dynamic value) {
    if (value == null) return '';
    if (value is String) return value.trim();
    if (value is List) {
      final parts = value.map((e) => e?.toString().trim() ?? '').where((e) => e.isNotEmpty).toList();
      return parts.join(' / ');
    }
    if (value is Map<String, dynamic>) {
      final parts = value.values.map((e) => e?.toString().trim() ?? '').where((e) => e.isNotEmpty).toList();
      return parts.join(' / ');
    }
    return value.toString().trim();
  }

  List<String> get _fallbackCoverImages {
    final category = (theater.category ?? '').trim();
    if (category == 'context') {
      return const [
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=1280&h=720&q=80',
        'https://images.unsplash.com/photo-1476842634003-7dcca8f832de?auto=format&fit=crop&w=1280&h=720&q=80',
        'https://images.unsplash.com/photo-1416879595882-3373a0480b5b?auto=format&fit=crop&w=1280&h=720&q=80',
        'https://images.unsplash.com/photo-1488459716781-31db52582fe9?auto=format&fit=crop&w=1280&h=720&q=80',
        'https://images.unsplash.com/photo-1504851149312-7a075b496cc7?auto=format&fit=crop&w=1280&h=720&q=80',
        'https://images.unsplash.com/photo-1587300003388-59208cc962cb?auto=format&fit=crop&w=1280&h=720&q=80',
      ];
    }
    if (category == 'semantic') {
      return const [
        'https://images.unsplash.com/photo-1552674605-db6ffd4facb5?auto=format&fit=crop&w=1280&h=720&q=80',
        'https://images.unsplash.com/photo-1507400492013-162706c8c05e?auto=format&fit=crop&w=1280&h=720&q=80',
        'https://images.unsplash.com/photo-1504639725590-34d0984388bd?auto=format&fit=crop&w=1280&h=720&q=80',
        'https://images.unsplash.com/photo-1494253109108-2e30c049369b?auto=format&fit=crop&w=1280&h=720&q=80',
        'https://images.unsplash.com/photo-1521791136064-7986c2920216?auto=format&fit=crop&w=1280&h=720&q=80',
      ];
    }
    return const [
      'https://images.unsplash.com/photo-1516979187457-637abb4f9353?auto=format&fit=crop&w=1280&h=720&q=80',
      'https://images.unsplash.com/photo-1472214103451-9374bd1c798e?auto=format&fit=crop&w=1280&h=720&q=80',
      'https://images.unsplash.com/photo-1532693322450-2cb5c511067d?auto=format&fit=crop&w=1280&h=720&q=80',
      'https://images.unsplash.com/photo-1525382455947-f319bc05fb35?auto=format&fit=crop&w=1280&h=720&q=80',
    ];
  }
}
