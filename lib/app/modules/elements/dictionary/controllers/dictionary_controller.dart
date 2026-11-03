import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/app/routes/routes_breadcrumb_utils.dart';
import 'package:langwise/app/routes/tag_routes.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/mixins/mixins.dart';
import '../../../../../common/public_controller/config_controller.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../utils/utils.dart';
import '../dialog/dictionary_reset_card_dialog.dart';

class DictionaryController extends GetxController
    with RoutesBreadcrumbMixin, PageRefreshAwareMixin {
  static const String _learnedFilterValue = 'LEARNED';
  static const List<String> _studyTimeGroupNames = <String>[
    '上次学习时间',
    '首次学习时间',
  ];

  final String tagText;
  DictionaryController({required this.tagText});

  static DictionaryController? get registered {
    return TagRoutes.findLast<DictionaryController>(Routes.DICTIONARY);
  }

  @override
  String get breadcrumbRoute => Routes.DICTIONARY;

  @override
  String get breadcrumbTitle => '语境词典';

  final ConfigController configController = Get.find<ConfigController>();
  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();
  final SearchHintRotator searchHintRotator = SearchHintRotator();

  /// 页面加载态，只用于首屏和刷新过程中的展示控制。
  final RxBool isLoading = true.obs;

  /// 列表是否为空，用于切换空态占位。
  final RxBool isNotData = false.obs;

  /// 当前词典卡片数据，直接使用 v2 接口返回的通用卡片结构。
  final RxList<KnowledgeCommonEntityList> items = <KnowledgeCommonEntityList>[].obs;

  /// 当前页面权限信息，继续沿用锁态遮罩。
  final Rx<LockEntity> rights = LockEntity().obs;

  /// 顶部提示组件使用的帮助视频地址。
  final RxString helpVideoUrl = ''.obs;

  /// 词典筛选和排序元数据。
  final Rxn<ZhenduScriptQueryMetaGroupListEntity> metaGroupList =
      Rxn<ZhenduScriptQueryMetaGroupListEntity>();

  final RxMap<String, List<String>> selectedFilters = <String, List<String>>{}.obs;
  final RxString selectedOrderGroupCode = ''.obs;
  final RxString selectedOrderValue = ''.obs;
  final RxInt total = 0.obs;
  final RxInt count = 0.obs;

  int offset = 0;
  final int limit = 30;
  int _loadingCount = 0;
  bool loadingMore = false;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    initPage(showLoading: true);
  }

  @override
  Future<void> onReturnPageRefresh(String? key) async {
    await refreshList(showLoading: true);
  }

  Future<void> initPage({bool showLoading = false}) async {
    if (LockUtils.checkExperienceAppStorage()) return;
    await _runWithLoading(() async {
      await Future.wait([
        _loadHelpVideoUrl(),
        _ensureMetaLoaded(),
      ]);
      await refreshList(showLoading: false);
    }, enabled: showLoading);
  }

  /// 外部联动刷新时，回到默认筛选并重拉列表。
  Future<void> externalRefresh() async {
    _resetQueryState();
    searchController.clear();
    await initPage(showLoading: true);
  }

  Future<void> clearSearch() async {
    if (searchController.text.trim().isEmpty) return;
    searchController.clear();
    await refreshList(showLoading: true);
  }

  Future<void> refreshList({bool showLoading = true}) async {
    offset = 0;
    loadingMore = false;
    total.value = 0;
    count.value = 0;
    items.clear();
    isNotData.value = false;
    isLoading.value = true;
    await _loadListData(showLoading: showLoading);
  }

  Future<void> loadMore() async {
    if (loadingMore || !_hasMoreData()) return;
    loadingMore = true;
    offset = items.length;
    await _loadListData(showLoading: false);
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
    await refreshList(showLoading: true);
  }

  Future<void> applyConditionSelections(
    Map<String, List<String>> selections,
  ) async {
    final Map<String, List<String>> sanitizedSelections =
        _sanitizeConditionSelections(selections);
    if (_containsLearnedSelection(sanitizedSelections) &&
        searchController.text.trim().isNotEmpty) {
      searchController.clear();
    }
    selectedFilters
      ..clear()
      ..addAll(sanitizedSelections);
    await refreshList(showLoading: true);
  }

  void resetFilters() {
    _resetQueryState();
    refreshList(showLoading: true);
  }

  Future<void> submitSearch() async {
    final String keyword = _resolveSubmittedSearchKeyword();
    if (searchController.text != keyword) {
      searchController.text = keyword;
      searchController.selection = TextSelection.fromPosition(
        TextPosition(offset: keyword.length),
      );
    }
    selectedFilters.clear();
    await refreshList(showLoading: true);
  }

  Future<void> goDictate() async {
    final List<UnitKnowledgePointsEntityKnowledgeList> knowledgeList =
        <UnitKnowledgePointsEntityKnowledgeList>[];
    for (final KnowledgeCommonEntityList item in items) {
      if ((item.contentType ?? '').isEmpty) continue;
      knowledgeList.add(UnitKnowledgePointsEntityKnowledgeList(
        contentId: item.contentId,
        contentType: item.contentType,
        content: item.title,
        semanticId: item.content?.semanticId,
        definition: item.subTitle,
        audioUrl: _resolveAudioUrl(item),
        imageUrl: item.coverImage?.url,
        pronunciations: _resolveDictationPronunciations(item),
        gloss: item.subTitles,
      ));
    }
    if (knowledgeList.isEmpty) return;
    TagRoutes.toNamed(Routes.OFFICIAL_COURSE_DETAILS_DICTATION, arguments: {
      'knowledgeList': knowledgeList,
    });
  }

  Future<void> showResetLearnMask(
    BuildContext context,
    KnowledgeCommonEntityList item,
    GlobalKey cardKey,
  ) async {
    if (!hasLearnedFilterSelected()) return;
    if (cardKey.currentContext == null) return;
    await DictionaryResetCardDialog.show(
      context: context,
      data: item,
      cardKey: cardKey,
      onTap: () {
        resetLearnRecord(context, item);
      },
    );
  }

  /// 长按已学卡片时，允许重置当前知识点的学习记录。
  Future<void> resetLearnRecord(
    BuildContext context,
    KnowledgeCommonEntityList item,
  ) async {
    final bool isPwdRight = await ParentPasswordialog.show(context: context);
    if (!isPwdRight) return;
    if (!context.mounted) return;
    final bool deleteRes = await DeleteDialog.show(
      context: context,
      title: '重置学习计划',
      subTitle:
          '你确定要重置 ${item.title ?? ""} 这个知识点吗？\n重置后，该知识点将恢复为“未学习”状态，并不会再出现在复习中。',
      content: '提示：此操作不可逆！',
      subContent: '此操作仅建议在误学高年级知识点时使用。',
      confirmText: '确认重置',
    );
    if (!deleteRes) return;
    try {
      ToastUtils.showLoading();
      final Map<String, dynamic> reqData = <String, dynamic>{
        'uid': item.contentId,
        'type': item.contentType,
      };
      final bool res = await ElementsRequest.deleteCard(reqData);
      if (!res) return;
      await refreshList(showLoading: false);
      ToastUtils.showToast(text: '重置成功', type: ToastType.success);
      Get.back();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  List<ZhenduScriptQueryMetaGroupEntity> buildFilterGroups() {
    return metaGroupList.value?.filters ?? const <ZhenduScriptQueryMetaGroupEntity>[];
  }

  List<ZhenduScriptQueryMetaGroupEntity> buildOrderGroups() {
    return metaGroupList.value?.orders ?? const <ZhenduScriptQueryMetaGroupEntity>[];
  }

  String buildCurrentSearchHintText() {
    final String hint = searchHintRotator.currentHint.value.trim();
    if (hint.isNotEmpty) return hint;
    return '搜索知识点卡片';
  }

  bool hasLearnedFilterSelected() {
    return _hasSelectedFilterValue(_learnedFilterValue);
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

  String findSortItemValueByName(String groupCode, String itemName) {
    final ZhenduScriptQueryMetaGroupEntity? group =
        buildOrderGroups().firstWhereOrNull(
      (e) => (e.groupCode ?? '') == groupCode,
    );
    if (group == null) return '';
    final ZhenduScriptQueryMetaItemEntity? item = group.items.firstWhereOrNull(
      (e) => (e.name ?? '') == itemName,
    );
    return item?.value ?? '';
  }

  Future<void> _loadListData({bool showLoading = true}) async {
    await configController.ensureStyleReady();
    try {
      final Map<String, dynamic>? pageData = await _runWithLoading(
        () => _getCardListPage(offset, limit),
        enabled: showLoading,
      );
      if (pageData == null) {
        isNotData.value = items.isEmpty;
        return;
      }

      rights.value = _resolvePageRights(pageData);
      count.value = _resolvePageInt(pageData, 'count');
      total.value = _resolvePageInt(pageData, 'total');

      final List<KnowledgeCommonEntityList> pageItems =
          _resolvePageItems(pageData);
      if (pageItems.isEmpty) {
        if (items.isEmpty) {
          isNotData.value = true;
        } else if (count.value < items.length) {
          count.value = items.length;
        }
        return;
      }

      items.addAll(pageItems);
      if (count.value < items.length) {
        count.value = items.length;
      }
      isNotData.value = items.isEmpty;
    } finally {
      isLoading.value = false;
      loadingMore = false;
    }
  }

  Future<Map<String, dynamic>?> _getCardListPage(
    int currentOffset,
    int currentLimit,
  ) async {
    final Map<String, dynamic> parameters = <String, dynamic>{
      'offset': currentOffset,
      'limit': currentLimit,
      'style': configController.currentStyleForRequest,
      'mediaMode': configController.currentMediaMode,
    };
    if (selectedOrderValue.value.trim().isNotEmpty) {
      parameters['order'] = selectedOrderValue.value.trim();
    }

    final Map<String, dynamic> reqData = <String, dynamic>{};
    if (searchController.text.trim().isNotEmpty) {
      reqData['content'] = searchController.text.trim();
    }
    final List<Map<String, dynamic>>? filters = _buildRequestFilters();
    if (filters != null && filters.isNotEmpty) {
      reqData['filters'] = filters;
    }

    return ElementsRequest.getCardListV2(parameters, reqData);
  }

  Future<void> _loadHelpVideoUrl() async {
    final CardDictModeEntity? data = await _runWithLoading(
      () => ElementsRequest.getDictMode(),
      enabled: false,
    );
    final List<CardDictModeEntityList?> list = data?.list ?? const <CardDictModeEntityList?>[];
    for (final CardDictModeEntityList item in list.whereType<CardDictModeEntityList>()) {
      final String url = (item.helpVideoUrl ?? '').trim();
      if (url.isEmpty) continue;
      helpVideoUrl.value = url;
      return;
    }
    helpVideoUrl.value = '';
  }

  Future<void> _ensureMetaLoaded({bool forceReload = false}) async {
    if (!forceReload && metaGroupList.value != null) {
      if (selectedOrderValue.value.isEmpty && selectedFilters.isEmpty) {
        _applyDefaultSelections();
      }
      return;
    }
    final ZhenduScriptQueryMetaGroupListEntity? data = await _runWithLoading(
      () => ElementsRequest.getCardQueryMetaGroupList(),
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
    for (final ZhenduScriptQueryMetaGroupEntity group in buildFilterGroups()) {
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
    if (defaults.isEmpty) return;
    selectedFilters.addAll(defaults);
    _removeHiddenFilterSelections();
  }

  void _applyDefaultOrderSelection() {
    for (final ZhenduScriptQueryMetaGroupEntity group in buildOrderGroups()) {
      final ZhenduScriptQueryMetaItemEntity? item = group.items.firstWhereOrNull(
        (e) => e.defaultValue ?? false,
      );
      if (item == null) continue;
      selectedOrderGroupCode.value = (group.groupCode ?? '').trim();
      selectedOrderValue.value = item.value ?? '';
      break;
    }
  }

  void _resetQueryState() {
    selectedFilters.clear();
    selectedOrderGroupCode.value = '';
    selectedOrderValue.value = '';
    _applyDefaultSelections();
  }

  List<KnowledgeCommonEntityList> _resolvePageItems(
    Map<String, dynamic> pageData,
  ) {
    final dynamic source = (pageData['list'] is List && (pageData['list'] as List).isNotEmpty)
        ? pageData['list']
        : pageData['datas'];
    if (source is! List) return const <KnowledgeCommonEntityList>[];
    return source
        .whereType<Map>()
        .map((item) => KnowledgeCommonEntityList.fromJson(
              Map<String, dynamic>.from(item),
            ))
        .toList();
  }

  int _resolvePageInt(Map<String, dynamic> pageData, String key) {
    final dynamic value = pageData[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }

  LockEntity _resolvePageRights(Map<String, dynamic> pageData) {
    final dynamic value = pageData['rights'];
    if (value is Map<String, dynamic>) {
      return LockEntity.fromJson(value);
    }
    if (value is Map) {
      return LockEntity.fromJson(Map<String, dynamic>.from(value));
    }
    return LockEntity();
  }

  String _resolveSubmittedSearchKeyword() {
    final String keyword = searchController.text.trim();
    if (keyword.isNotEmpty) return keyword;
    return buildCurrentSearchHintText().trim();
  }

  String _resolveAudioUrl(KnowledgeCommonEntityList item) {
    final List<Pronunciations?> list =
        item.params?.data?.pronunciations ?? const <Pronunciations?>[];
    for (final Pronunciations pronunciation in list.whereType<Pronunciations>()) {
      final String url = (pronunciation.audioUrl ?? '').trim();
      if (url.isNotEmpty) return url;
    }
    return '';
  }

  List<PronunciationsEntity>? _resolveDictationPronunciations(
    KnowledgeCommonEntityList item,
  ) {
    final List<Pronunciations?> list =
        item.params?.data?.pronunciations ?? const <Pronunciations?>[];
    if (list.isEmpty) return null;
    final List<PronunciationsEntity> pronunciations = <PronunciationsEntity>[];
    for (final Pronunciations pronunciation in list.whereType<Pronunciations>()) {
      pronunciations.add(
        PronunciationsEntity.fromJson(pronunciation.toJson()),
      );
    }
    return pronunciations.isEmpty ? null : pronunciations;
  }

  bool _hasMoreData() {
    return items.length < count.value;
  }

  List<Map<String, dynamic>>? _buildRequestFilters() {
    if (selectedFilters.isEmpty) return null;
    final List<Map<String, dynamic>> resp = <Map<String, dynamic>>[];
    final Map<String, List<String>> sanitizedSelections =
        _sanitizeConditionSelections(Map<String, List<String>>.from(selectedFilters));
    sanitizedSelections.forEach((key, values) {
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

  bool _hasSelectedFilterValue(String value) {
    final String target = value.trim();
    if (target.isEmpty) return false;
    for (final List<String> values in selectedFilters.values) {
      if (values.any((e) => e.trim() == target)) {
        return true;
      }
    }
    return false;
  }

  bool _isStudyTimeGroup(ZhenduScriptQueryMetaGroupEntity group) {
    final String groupName = (group.groupName ?? '').trim();
    return _studyTimeGroupNames.contains(groupName);
  }

  bool _containsLearnedSelection(Map<String, List<String>> selections) {
    for (final List<String> values in selections.values) {
      if (values.any((e) => e.trim() == _learnedFilterValue)) {
        return true;
      }
    }
    return false;
  }

  Map<String, List<String>> _sanitizeConditionSelections(
    Map<String, List<String>> selections,
  ) {
    if (_containsLearnedSelection(selections)) {
      return selections;
    }
    final Set<String> hiddenGroupCodes = buildFilterGroups()
        .where(_isStudyTimeGroup)
        .map((e) => (e.groupCode ?? '').trim())
        .where((e) => e.isNotEmpty)
        .toSet();
    if (hiddenGroupCodes.isEmpty) {
      return selections;
    }
    final Map<String, List<String>> sanitized = <String, List<String>>{};
    selections.forEach((key, values) {
      if (hiddenGroupCodes.contains(key.trim())) return;
      sanitized[key] = values;
    });
    return sanitized;
  }

  void _removeHiddenFilterSelections() {
    final Map<String, List<String>> sanitizedSelections =
        _sanitizeConditionSelections(Map<String, List<String>>.from(selectedFilters));
    if (sanitizedSelections.length == selectedFilters.length) {
      return;
    }
    selectedFilters
      ..clear()
      ..addAll(sanitizedSelections);
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
