import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/elements/elements_enums/elements_card_mode.dart';
import 'package:langwise/app/modules/elements/model/elements_detils_data_model.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/app/routes/routes_breadcrumb_utils.dart';
import 'package:langwise/app/routes/tag_routes.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/enum/enum.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/public_controller/config_controller.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../utils/utils.dart';
import '../../dialog/elements_delete_card_dialog.dart';

class DictionaryController extends GetxController with RoutesBreadcrumbMixin {
  static const String _learnedFilterValue = 'LEARNED';
  static const List<String> _studyTimeGroupNames = <String>[
    '上次学习时间',
    '首次学习时间',
  ];

  final String tagText;
  DictionaryController({required this.tagText});

  static DictionaryController? get registered {
    if (!Get.isRegistered<DictionaryController>(tag: Routes.DICTIONARY)) {
      return null;
    }
    return Get.find<DictionaryController>(tag: Routes.DICTIONARY);
  }

  @override
  String get breadcrumbRoute => Routes.DICTIONARY;

  @override
  String get breadcrumbTitle => '词典';

  final ConfigController configController = Get.find<ConfigController>();
  Worker? _styleWatcher;
  int _loadingCount = 0;

  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();

  final RxBool isLoading = true.obs;
  final RxBool isNotData = false.obs;
  final RxList<ElementsDetilsDataModel> datas = <ElementsDetilsDataModel>[].obs;
  final Rx<LockEntity> rights = LockEntity().obs;
  final RxList<CardDictModeEntityList> dictModeList =
      <CardDictModeEntityList>[].obs;
  final Rxn<ZhenduScriptQueryMetaGroupListEntity> metaGroupList =
      Rxn<ZhenduScriptQueryMetaGroupListEntity>();

  final RxMap<String, List<String>> selectedFilters =
      <String, List<String>>{}.obs;
  final RxString selectedOrderGroupCode = ''.obs;
  final RxString selectedOrderValue = ''.obs;
  final SearchHintRotator searchHintRotator = SearchHintRotator();

  final RxInt total = 0.obs;
  final RxInt count = 0.obs;

  int offset = 0;
  final int limit = 40;
  bool loadingMore = false;

  bool get hasMore => datas.length < count.value;

  List<ZhenduScriptQueryMetaGroupEntity> get filterGroups =>
      metaGroupList.value?.filters ??
      const <ZhenduScriptQueryMetaGroupEntity>[];

  List<ZhenduScriptQueryMetaGroupEntity> get visibleFilterGroups =>
      filterGroups.where(_isFilterGroupVisible).toList();

  List<ZhenduScriptQueryMetaGroupEntity> get orderGroups =>
      metaGroupList.value?.orders ?? const <ZhenduScriptQueryMetaGroupEntity>[];

  String get currentSearchHintText {
    final String hint = searchHintRotator.currentHint.value.trim();
    if (hint.isNotEmpty) return hint;
    return '搜索知识点卡片';
  }

  String? get currentHelpVideoUrl {
    for (final CardDictModeEntityList item in dictModeList) {
      final String url = item.helpVideoUrl ?? '';
      if (url.isNotEmpty) return url;
    }
    return null;
  }

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    _styleWatcher = debounce(configController.styleModeVersion, (_) {
      Future.microtask(() async {
        await refreshList(showLoading: true);
      });
    }, time: const Duration(milliseconds: 80));
    initPage(showLoading: true);
  }

  Future<void> initPage({bool showLoading = false}) async {
    if (LockUtils.checkExperienceAppStorage()) return;
    await _runWithLoading(() async {
      await Future.wait([
        getDictMode(),
        _ensureMetaLoaded(),
      ]);
      await refreshList(showLoading: false);
    }, enabled: showLoading);
  }

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
    count.value = 0;
    datas.clear();
    isNotData.value = false;
    await initListData(showLoading: showLoading);
  }

  Future<void> initListData({bool showLoading = true}) async {
    await configController.ensureStyleReady();
    final ElementsCardEntity? cards = await _runWithLoading(
      () => getCardList(offset, limit),
      enabled: showLoading,
    );
    if (cards == null) {
      if (datas.isEmpty) isNotData.value = true;
      loadingMore = false;
      return;
    }
    rights.value = cards.rights ?? LockEntity();
    count.value = cards.count ?? 0;
    total.value = cards.total ?? 0;

    final List<ElementsDetilsDataModel> list = <ElementsDetilsDataModel>[];
    for (int i = 0; i < (cards.datas?.length ?? 0); i++) {
      final ElementsCardEntityDatas? data = cards.datas?[i];
      if (data == null) continue;
      if ((data.contentType ?? '').isEmpty) continue;
      list.add(ElementsDetilsDataModel(
        type: ElementsCardType.fromRawValue(data.contentType ?? ''),
        data: data,
      ));
    }
    datas.addAll(list);
    isNotData.value = datas.isEmpty;
    loadingMore = false;
  }

  Future<void> loadMore() async {
    if (loadingMore || !hasMore) return;
    loadingMore = true;
    offset += limit;
    await initListData(showLoading: false);
  }

  Future<ElementsCardEntity?> getCardList(
      int currentOffset, int currentLimit) async {
    final Map<String, dynamic> parameters = {
      'offset': currentOffset,
      'limit': currentLimit,
      'style': configController.currentStyleForRequest,
      'mediaMode': configController.currentMediaMode,
    };
    if (selectedOrderValue.value.trim().isNotEmpty) {
      parameters['order'] = selectedOrderValue.value.trim();
    }

    final Map<String, dynamic> reqData = {};
    if (searchController.text.trim().isNotEmpty) {
      reqData['content'] = searchController.text.trim();
    }
    final List<Map<String, dynamic>>? filters = _buildRequestFilters();
    if (filters != null && filters.isNotEmpty) {
      reqData['filters'] = filters;
    }

    return ElementsRequest.getCardList(parameters, reqData);
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
    refreshList(showLoading: true);
  }

  Future<void> applyConditionSelections(
    Map<String, List<String>> selections,
  ) async {
    final Map<String, List<String>> sanitizedSelections =
        _sanitizeConditionSelections(selections);
    selectedFilters
      ..clear()
      ..addAll(sanitizedSelections);
    refreshList(showLoading: true);
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
    await refreshList(showLoading: true);
  }

  String _resolveSubmittedSearchKeyword() {
    final String keyword = searchController.text.trim();
    if (keyword.isNotEmpty) return keyword;
    return currentSearchHintText.trim();
  }

  Future<void> getDictMode() async {
    final CardDictModeEntity? data = await _runWithLoading(
      () => ElementsRequest.getDictMode(),
      enabled: false,
    );
    if (data == null) return;
    final List<CardDictModeEntityList?>? list = data.list;
    if (list == null) return;
    dictModeList.value = list.whereType<CardDictModeEntityList>().toList();
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
      _removeHiddenFilterSelections();
    }
  }

  void _applyDefaultOrderSelection() {
    for (final ZhenduScriptQueryMetaGroupEntity group in orderGroups) {
      final ZhenduScriptQueryMetaItemEntity? item =
          group.items.firstWhereOrNull(
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
    final ZhenduScriptQueryMetaGroupEntity? group =
        orderGroups.firstWhereOrNull(
      (e) => (e.groupCode ?? '') == groupCode,
    );
    if (group == null) return '';
    final ZhenduScriptQueryMetaItemEntity? item = group.items.firstWhereOrNull(
      (e) => (e.name ?? '') == itemName,
    );
    return item?.value ?? '';
  }

  Future<void> goDictate() async {
    final List<UnitKnowledgePointsEntityKnowledgeList> knowledgeList = [];
    for (final ElementsDetilsDataModel cardModel in datas) {
      final ElementsCardEntityDatas? data = cardModel.data;
      if (data == null) continue;
      knowledgeList.add(UnitKnowledgePointsEntityKnowledgeList(
        contentId: data.contentId,
        contentType: data.contentType,
        content: data.content,
        semanticId: data.semanticId,
        difficulty: data.difficulty,
        definition: data.definition,
        audioUrl: data.audioUrl,
        imageUrl: data.imageUrl,
        gloss: data.gloss,
        pronunciations: data.pronunciations,
      ));
    }
    if (knowledgeList.isEmpty) return;
    TagRoutes.toNamed(Routes.OFFICIAL_COURSE_DETAILS_DICTATION, arguments: {
      'knowledgeList': knowledgeList,
    });
  }

  Future<void> showDeleteMask(
      BuildContext context, ElementsDetilsDataModel? data) async {
    if (data == null) return;
    if (currentMode != ElementsCardMode.studyCard) return;
    ElementsDeleteCardDialog.show(
      context: context,
      data: data,
      onTap: (type) {
        if (type == 1) {
          deleteCard(context, data);
        }
      },
    );
  }

  Future<void> deleteCard(
      BuildContext context, ElementsDetilsDataModel data) async {
    final bool isPwdRight = await ParentPasswordialog.show(context: context);
    if (!isPwdRight) return;
    final bool deleteRes = await DeleteDialog.show(
      context: context,
      title: '重置学习计划',
      subTitle:
          "你确定要重置 ${data.data?.content ?? ""} 这个知识点吗？\n重置后，该知识点将恢复为“未学习”状态，并不会再出现在复习中。",
      content: '提示：此操作不可逆！',
      subContent: '此操作仅建议在误学高年级知识点时使用。',
      confirmText: '确认重置',
    );
    if (!deleteRes) return;
    try {
      ToastUtils.showLoading();
      final Map<String, dynamic> reqData = {
        'uid': data.data?.contentId,
        'type': data.data?.contentType,
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

  String get currentMode {
    if (_hasSelectedFilterValue('LEARNED')) {
      return ElementsCardMode.studyCard;
    }
    return '';
  }

  bool get hasLearnedFilterSelected => _hasSelectedFilterValue(_learnedFilterValue);

  List<Map<String, dynamic>>? _buildRequestFilters() {
    if (selectedFilters.isEmpty) return null;
    final List<Map<String, dynamic>> resp = <Map<String, dynamic>>[];
    final Map<String, List<String>> sanitizedSelections =
        _sanitizeConditionSelections(Map<String, List<String>>.from(
      selectedFilters,
    ));
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

  bool _isFilterGroupVisible(ZhenduScriptQueryMetaGroupEntity group) {
    if (!_isStudyTimeGroup(group)) return true;
    return _containsLearnedSelection(selectedFilters);
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
    final Set<String> hiddenGroupCodes = filterGroups
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
        _sanitizeConditionSelections(Map<String, List<String>>.from(
      selectedFilters,
    ));
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
    _styleWatcher?.dispose();
    searchHintRotator.dispose();
    scrollController.dispose();
    searchController.dispose();
    super.onClose();
  }
}
