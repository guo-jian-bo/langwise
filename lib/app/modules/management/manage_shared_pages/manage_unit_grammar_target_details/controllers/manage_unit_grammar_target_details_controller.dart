import 'dart:async';

import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/common/enum/enum.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/common/mixins/mixins.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/mqtt_utils/mqtt_message_services_code.dart';
import 'package:langwise/utils/utils.dart';

import '../../../../elements/utils/elements_page_utils.dart';
import '../../../../../routes/routes.dart';
import '../../../../../routes/tag_routes.dart';
import '../../../utils/manage_page_registry.dart';
import '../views/manage_unit_grammar_target_details_dialogs.dart';

class ManageUnitGrammarTargetDetailsController extends GetxController with DualBreadcrumbMixin {
  final String tag;
  ManageUnitGrammarTargetDetailsController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_UNIT_GRAMMAR_TARGET_DETAILS;

  @override
  String get breadcrumbTitle => 'Target详情';

  int? unitId;
  int? targetUid;
  bool isManagement = true;
  bool reviewQueue = false;
  final RxList<int> reviewQueueUids = <int>[].obs;
  final RxMap<int, String> reviewQueueStatuses = <int, String>{}.obs;

  final RxBool isLoading = true.obs;
  final RxBool isSentenceAnalyseRunning = false.obs;

  /// 详情原始返回，便于后续扩展直接追源。
  final Rxn<ManageUnitGrammarTargetDetailEntity> detailData = Rxn<ManageUnitGrammarTargetDetailEntity>();
  final Rxn<PatternBlueprintEntity> patternBlueprint = Rxn<PatternBlueprintEntity>();
  final Rxn<SentencePatternCompareEntity> paradigmCompareData = Rxn<SentencePatternCompareEntity>();
  final Rxn<SentencePairEntity> pairData = Rxn<SentencePairEntity>();
  final Rxn<SentenceForkEntity> pairForkData = Rxn<SentenceForkEntity>();
  final Rxn<ManageGrammarPanoramaEntity> grammarPanoramaData = Rxn<ManageGrammarPanoramaEntity>();
  final RxMap<String, dynamic> grammarStructPayload = <String, dynamic>{}.obs;
  final RxBool isSentenceSetLoadingMore = false.obs;
  final ScrollController scrollController = ScrollController();
  final RxList<ManageUnitGrammarTargetSentenceSetPageEntity> sentenceSetPages = <ManageUnitGrammarTargetSentenceSetPageEntity>[].obs;
  final RxInt sentenceSetPageTotal = 0.obs;
  final RxList<int> selectedUngroupedSentenceIds = <int>[].obs;
  final RxnString selectedUngroupedPatternGroupKey = RxnString();
  final RxnInt selectedUngroupedPyramidSentenceId = RxnInt();
  final RxnInt selectedUngroupedPairSentenceId = RxnInt();
  final RxnInt selectedUngroupedPairForkSentenceId = RxnInt();
  final RxMap<String, int> selectedUngroupedParadigmSentenceIdMap = <String, int>{}.obs;
  int sentenceSetPageOffset = 0;
  static const int _sentenceSetPageLimit = 30;

  StreamSubscription<PushMessageServiceEnitiy>? _messageSubscription;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);

    final arguments = Get.arguments;
    final Map args = arguments is Map ? arguments : const {};
    unitId = _parseInt(args['unitId']);
    targetUid = _parseInt(args['targetUid']);
    final dynamic isManagementValue = args['isManagement'];
    if (isManagementValue != null) {
      isManagement = isManagementValue == true || isManagementValue.toString() == 'true';
    }
    reviewQueue = args['reviewQueue'] == true;
    reviewQueueUids.assignAll(_parseIntList(args['reviewQueueUids']));
    if (reviewQueueUids.isEmpty) {
      reviewQueue = false;
    }

    _listenScroll();
    fetchData(showLoading: true);
    _messageSubscription = MqttNotificationMessage.instance.listenByCode(
      codes: [MqttMessageServicesCode.write_sentence_realization_create],
      onData: (value) {
        fetchData(showLoading: false);
      },
    );
  }

  @override
  void onClose() {
    _messageSubscription?.cancel();
    scrollController.dispose();
    super.onClose();
  }

  /// 统一解析页面入参里的数字字段。
  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  List<int> _parseIntList(dynamic value) {
    if (value is! List) return const [];
    return value.map(_parseInt).whereType<int>().toList();
  }

  void _listenScroll() {
    scrollController.addListener(() {
      if (!scrollController.hasClients) return;
      if (scrollController.position.outOfRange) return;
      if (scrollController.position.pixels < scrollController.position.maxScrollExtent - 200) return;
      if (!canLoadMoreSentenceSetPages()) return;
      if (isSentenceSetLoadingMore.value) return;
      loadMoreSentenceSetPages();
    });
  }

  /// 拉取当前 Target 详情，并把页面直用字段显式落到本地状态。
  Future<void> fetchData({bool showLoading = false}) async {
    if (unitId == null || targetUid == null) {
      ToastUtils.showManageToast(text: 'Target详情参数为空');
      return;
    }

    if (showLoading) {
      ToastUtils.showLoading();
    }

    try {
      isLoading.value = true;
      final ResponseEntity<ManageUnitGrammarTargetDetailEntity?>? response = await _requestTargetDetail();

      if (response?.data == null) {
        ToastUtils.showManageToast(
          text: response?.message ?? 'Target详情加载失败',
        );
        return;
      }

      _applyDetailData(response!.data);
      if (isApprovedTarget()) {
        final ResponseEntity<ListResponseEntity<ManageUnitGrammarTargetSentenceSetPageEntity>?>? sentenceSetResponse =
            await _requestSentenceSetPages(offset: 0, limit: _sentenceSetPageLimit);
        _applySentenceSetPageResponse(sentenceSetResponse, reset: true);
      } else {
        _resetSentenceSetPages();
      }
      if (reviewQueue && targetUid != null && response.data?.status != null) {
        reviewQueueStatuses[targetUid!] = response.data!.status!;
      }
    } catch (e) {
      ToastUtils.showManageToast(text: 'Target详情加载失败');
    } finally {
      isLoading.value = false;
      if (showLoading) {
        ToastUtils.hideLoading();
      }
    }
  }

  Future<ResponseEntity<ManageUnitGrammarTargetDetailEntity?>?> _requestTargetDetail() {
    return UnitUtil.unitGrammarTargetDetail(
      unitId: unitId.toString(),
      config: RequestConfig(
        requireToken: true,
        parameters: {
          'targetUid': targetUid,
          'isManagement': isManagement,
        },
      ),
    );
  }

  Future<ResponseEntity<ListResponseEntity<ManageUnitGrammarTargetSentenceSetPageEntity>?>?> _requestSentenceSetPages({
    required int offset,
    required int limit,
  }) {
    return UnitUtil.unitGrammarTargetSentenceSetPages(
      unitId: unitId.toString(),
      config: RequestConfig(
        requireToken: true,
        parameters: {
          'targetUid': targetUid,
          'limit': limit,
          'offset': offset,
          'isManagement': isManagement,
        },
      ),
    );
  }

  void _applyDetailData(ManageUnitGrammarTargetDetailEntity? data) {
    detailData.value = data;
    grammarStructPayload.assignAll(
      data?.grammarUnifiedInfo?.payload ?? const {},
    );
    final String? type = data?.grammarUnifiedInfo?.type;
    patternBlueprint.value =
        (type == ZhenxieEnSentenceType.EN_SENTENCE_PATTERN.rawValue || type == ZhenxieEnSentenceType.EN_SENTENCE_PYRAMID.rawValue) &&
                grammarStructPayload.isNotEmpty
            ? PatternBlueprintEntity.fromJson(grammarStructPayload)
            : null;
    pairData.value = type == ZhenxieEnSentenceType.EN_SENTENCE_PATTERN_PAIR.rawValue && grammarStructPayload.isNotEmpty
        ? SentencePairEntity.fromJson(grammarStructPayload)
        : null;
    pairForkData.value = type == ZhenxieEnSentenceType.EN_SENTENCE_PATTERN_PAIR_FORK.rawValue && grammarStructPayload.isNotEmpty
        ? SentenceForkEntity.fromJson(grammarStructPayload)
        : null;
    grammarPanoramaData.value = type == ZhenxieEnSentenceType.EN_SENTENCE_GRAMMAR_GRID.rawValue && grammarStructPayload.isNotEmpty
        ? ManageGrammarPanoramaEntity.fromJson(grammarStructPayload)
        : null;
    paradigmCompareData.value = type == ZhenxieEnSentenceType.EN_SENTENCE_PARADIGM.rawValue && grammarStructPayload.isNotEmpty
        ? SentencePatternCompareEntity.fromJson(grammarStructPayload)
        : null;
  }

  void _resetSentenceSetPages() {
    sentenceSetPageOffset = 0;
    sentenceSetPages.clear();
    sentenceSetPageTotal.value = 0;
    selectedUngroupedSentenceIds.clear();
    selectedUngroupedPatternGroupKey.value = null;
    selectedUngroupedPyramidSentenceId.value = null;
    selectedUngroupedPairSentenceId.value = null;
    selectedUngroupedPairForkSentenceId.value = null;
    selectedUngroupedParadigmSentenceIdMap.clear();
  }

  void _applySentenceSetPageResponse(
    ResponseEntity<ListResponseEntity<ManageUnitGrammarTargetSentenceSetPageEntity>?>? response, {
    required bool reset,
  }) {
    final List<ManageUnitGrammarTargetSentenceSetPageEntity> datas = response?.data?.datas ?? const [];
    final List<ManageUnitGrammarTargetSentenceSetPageEntity> ungroupedDatas = datas.where((item) => item.isSet != true).toList();
    final List<ManageUnitGrammarTargetSentenceSetPageEntity> groupedDatas = datas.where((item) => item.isSet == true).toList();
    if (reset) {
      sentenceSetPages.assignAll([
        ...ungroupedDatas,
        ...groupedDatas,
      ]);
      _resetSelectedUngroupedSentenceIds();
    } else {
      final Set<int> existingGroupedIds = groupedSentenceSetPages.map((item) => item.uid ?? -1).toSet();
      final List<ManageUnitGrammarTargetSentenceSetPageEntity> appendGroups =
          groupedDatas.where((item) => item.uid == null || !existingGroupedIds.contains(item.uid)).toList();
      sentenceSetPages.addAll(appendGroups);
    }
    sentenceSetPageTotal.value = response?.data?.count ?? groupedSentenceSetPages.length;
    sentenceSetPageOffset = groupedSentenceSetPages.length;
  }

  Future<void> fetchSentenceSetPages({bool reset = false}) async {
    if (unitId == null || targetUid == null) {
      _resetSentenceSetPages();
      return;
    }

    if (!isApprovedTarget()) {
      _resetSentenceSetPages();
      return;
    }

    if (isSentenceSetLoadingMore.value) return;
    if (!reset && sentenceSetPageTotal.value > 0 && groupedSentenceSetPages.length >= sentenceSetPageTotal.value) {
      return;
    }

    final int requestOffset = reset ? 0 : sentenceSetPageOffset;
    isSentenceSetLoadingMore.value = true;
    try {
      final ResponseEntity<ListResponseEntity<ManageUnitGrammarTargetSentenceSetPageEntity>?>? response = await _requestSentenceSetPages(
        offset: requestOffset,
        limit: _sentenceSetPageLimit,
      );
      _applySentenceSetPageResponse(response, reset: reset);
    } finally {
      isSentenceSetLoadingMore.value = false;
    }
  }

  List<ManageUnitGrammarTargetSentenceSetPageEntity> get groupedSentenceSetPages {
    return sentenceSetPages.where((item) => item.isSet == true).toList();
  }

  List<ManageUnitGrammarTargetSentenceSetPageEntity> get ungroupedSentenceSetPages {
    return sentenceSetPages.where((item) => item.isSet != true).toList();
  }

  bool canLoadMoreSentenceSetPages() {
    return sentenceSetPageTotal.value > groupedSentenceSetPages.length;
  }

  Future<void> loadMoreSentenceSetPages() async {
    await fetchSentenceSetPages();
  }

  bool isQaPairTarget() {
    return detailData.value?.grammarUnifiedInfo?.type == ZhenxieEnSentenceType.EN_SENTENCE_PATTERN_PAIR.rawValue &&
        pairData.value?.pairTypeNid == 'qa_pair';
  }

  bool isPairTarget() {
    return detailData.value?.grammarUnifiedInfo?.type == ZhenxieEnSentenceType.EN_SENTENCE_PATTERN_PAIR.rawValue;
  }

  bool isApprovedTarget() {
    return detailData.value?.status == 'approved';
  }

  /// 右上角“搜索库里已有句子 / 生成句子”按钮的可用条件。
  bool canOperatePatternActions() {
    return detailData.value?.status == 'approved' &&
        detailData.value?.grammarUnifiedInfo?.type == ZhenxieEnSentenceType.EN_SENTENCE_PATTERN.rawValue;
  }

  bool canOperateAdvancedPractice() {
    final String? type = detailData.value?.grammarUnifiedInfo?.type;
    return detailData.value?.status == 'approved' &&
        (type == ZhenxieEnSentenceType.EN_SENTENCE_PATTERN_PAIR.rawValue ||
            type == ZhenxieEnSentenceType.EN_SENTENCE_PATTERN_PAIR_FORK.rawValue ||
            type == ZhenxieEnSentenceType.EN_SENTENCE_PARADIGM.rawValue ||
            type == ZhenxieEnSentenceType.EN_SENTENCE_PYRAMID.rawValue ||
            type == ZhenxieEnSentenceType.EN_SENTENCE_GRAMMAR_GRID.rawValue);
  }

  bool canAddRealizationSet() {
    return isApprovedTarget();
  }

  bool isPatternTarget() {
    return detailData.value?.grammarUnifiedInfo?.type == ZhenxieEnSentenceType.EN_SENTENCE_PATTERN.rawValue;
  }

  bool isPyramidTarget() {
    return detailData.value?.grammarUnifiedInfo?.type == ZhenxieEnSentenceType.EN_SENTENCE_PYRAMID.rawValue;
  }

  bool isPairForkTarget() {
    return detailData.value?.grammarUnifiedInfo?.type == ZhenxieEnSentenceType.EN_SENTENCE_PATTERN_PAIR_FORK.rawValue;
  }

  bool isParadigmTarget() {
    return detailData.value?.grammarUnifiedInfo?.type == ZhenxieEnSentenceType.EN_SENTENCE_PARADIGM.rawValue;
  }

  bool hasSelectedUngroupedSentences() {
    return selectedUngroupedSentenceIds.isNotEmpty;
  }

  bool hasSelectedUngroupedPyramidSentence() {
    final int? sentenceId = selectedUngroupedPyramidSentenceId.value;
    return sentenceId != null && sentenceId > 0;
  }

  bool hasSelectedUngroupedPairSentence() {
    final int? sentenceId = selectedUngroupedPairSentenceId.value;
    return sentenceId != null && sentenceId > 0;
  }

  bool hasSelectedUngroupedPairForkSentence() {
    final int? sentenceId = selectedUngroupedPairForkSentenceId.value;
    return sentenceId != null && sentenceId > 0;
  }

  bool hasSelectedUngroupedParadigmSentence() {
    return selectedUngroupedParadigmSentenceIdMap.values.any((sentenceId) => sentenceId > 0);
  }

  bool shouldDisableAddGroupButton() {
    if (isPatternTarget()) {
      return !hasSelectedUngroupedSentences();
    }
    if (isPyramidTarget()) {
      return !hasSelectedUngroupedPyramidSentence();
    }
    if (isPairTarget()) {
      return !hasSelectedUngroupedPairSentence();
    }
    if (isPairForkTarget()) {
      return !hasSelectedUngroupedPairForkSentence();
    }
    if (isParadigmTarget()) {
      return !hasSelectedUngroupedParadigmSentence();
    }
    return false;
  }

  bool isUngroupedSentenceSelected(int? sentenceId) {
    if (sentenceId == null || sentenceId <= 0) return false;
    if (isPyramidTarget()) {
      return selectedUngroupedPyramidSentenceId.value == sentenceId;
    }
    if (isPairTarget()) {
      return selectedUngroupedPairSentenceId.value == sentenceId;
    }
    if (isPairForkTarget()) {
      return selectedUngroupedPairForkSentenceId.value == sentenceId;
    }
    return selectedUngroupedSentenceIds.contains(sentenceId);
  }

  bool isUngroupedParadigmSentenceSelected({
    required String groupKey,
    required int? sentenceId,
  }) {
    if (!isParadigmTarget() || sentenceId == null || sentenceId <= 0) return false;
    return selectedUngroupedParadigmSentenceIdMap[groupKey] == sentenceId;
  }

  void toggleUngroupedSentence(int? sentenceId, {String? groupKey}) {
    if (sentenceId == null || sentenceId <= 0) return;
    if (isPyramidTarget()) {
      if (selectedUngroupedPyramidSentenceId.value == sentenceId) {
        selectedUngroupedPyramidSentenceId.value = null;
        return;
      }
      selectedUngroupedPyramidSentenceId.value = sentenceId;
      return;
    }
    if (isPairTarget()) {
      if (selectedUngroupedPairSentenceId.value == sentenceId) {
        selectedUngroupedPairSentenceId.value = null;
        return;
      }
      selectedUngroupedPairSentenceId.value = sentenceId;
      return;
    }
    if (isPairForkTarget()) {
      selectedUngroupedPairForkSentenceId.value = sentenceId;
      return;
    }
    final String normalizedGroupKey = groupKey?.trim() ?? '';
    if (isPatternTarget() && normalizedGroupKey.isNotEmpty) {
      final String currentGroupKey = selectedUngroupedPatternGroupKey.value?.trim() ?? '';
      if (currentGroupKey.isNotEmpty && currentGroupKey != normalizedGroupKey) {
        selectedUngroupedSentenceIds.assignAll([sentenceId]);
        selectedUngroupedPatternGroupKey.value = normalizedGroupKey;
        return;
      }
      if (selectedUngroupedSentenceIds.contains(sentenceId)) {
        selectedUngroupedSentenceIds.remove(sentenceId);
        if (selectedUngroupedSentenceIds.isEmpty) {
          selectedUngroupedPatternGroupKey.value = null;
        }
        return;
      }
      selectedUngroupedPatternGroupKey.value = normalizedGroupKey;
      selectedUngroupedSentenceIds.add(sentenceId);
      return;
    }
    if (selectedUngroupedSentenceIds.contains(sentenceId)) {
      selectedUngroupedSentenceIds.remove(sentenceId);
      return;
    }
    selectedUngroupedSentenceIds.add(sentenceId);
  }

  bool isUngroupedPatternGroupAllSelected(List<int> sentenceIds, {required String groupKey}) {
    if (!isPatternTarget() || sentenceIds.isEmpty) return false;
    if (selectedUngroupedPatternGroupKey.value != groupKey) return false;
    return sentenceIds.every(selectedUngroupedSentenceIds.contains);
  }

  void toggleUngroupedPatternGroupSelection(List<int> sentenceIds, {required String groupKey}) {
    if (!isPatternTarget() || sentenceIds.isEmpty || groupKey.isEmpty) return;
    if (isUngroupedPatternGroupAllSelected(sentenceIds, groupKey: groupKey)) {
      selectedUngroupedSentenceIds.clear();
      selectedUngroupedPatternGroupKey.value = null;
      return;
    }
    selectedUngroupedSentenceIds.assignAll(sentenceIds);
    selectedUngroupedPatternGroupKey.value = groupKey;
  }

  void toggleUngroupedParadigmSentence({
    required String groupKey,
    required int? sentenceId,
  }) {
    if (!isParadigmTarget() || groupKey.isEmpty || sentenceId == null || sentenceId <= 0) return;
    if (selectedUngroupedParadigmSentenceIdMap[groupKey] == sentenceId) {
      selectedUngroupedParadigmSentenceIdMap.remove(groupKey);
      return;
    }
    selectedUngroupedParadigmSentenceIdMap[groupKey] = sentenceId;
  }

  bool isUngroupedPyramidSentenceDisabled(
    ManageUnitGrammarTargetSentenceSetPageEntity page,
    PatternBlueprintSentenceBriefEntity? sentence,
  ) {
    if (!isPyramidTarget()) return false;
    final Set<String> growthSlotKeySet = _buildPyramidGrowthSlotKeySet(page);
    if (growthSlotKeySet.isEmpty || sentence == null) return false;
    final Set<String> sentenceSlotKeySet = _buildSentenceSlotKeySet(sentence.segmentList);
    if (sentenceSlotKeySet.isEmpty) return false;
    final Set<String> optionalSlotKeySet = _buildPyramidOptionalSlotKeySet();
    if (optionalSlotKeySet.isEmpty) return false;
    for (final String slotKey in sentenceSlotKeySet) {
      if (!optionalSlotKeySet.contains(slotKey)) continue;
      if (!growthSlotKeySet.contains(slotKey)) {
        return true;
      }
    }
    return false;
  }

  void _resetSelectedUngroupedSentenceIds() {
    selectedUngroupedSentenceIds.clear();
    selectedUngroupedPatternGroupKey.value = null;
  }

  List<PatternBlueprintSentenceBriefEntity> buildPresetSentences() {
    final List<PatternBlueprintSentenceBriefEntity> resp = <PatternBlueprintSentenceBriefEntity>[];
    final Set<int> seen = <int>{};
    for (final ManageUnitGrammarTargetSentenceSetPageEntity page in ungroupedSentenceSetPages) {
      for (final PatternBlueprintSentenceBriefEntity? sentence in page.contents ?? const <PatternBlueprintSentenceBriefEntity?>[]) {
        final int? sentenceId = sentence?.actualSentenceId;
        if (sentence == null ||
            sentenceId == null ||
            sentenceId <= 0 ||
            !selectedUngroupedSentenceIds.contains(sentenceId) ||
            !seen.add(sentenceId)) {
          continue;
        }
        resp.add(sentence);
      }
    }
    return resp;
  }

  int? buildPresetSentenceId() {
    final int? sentenceId = isPairTarget()
        ? selectedUngroupedPairSentenceId.value
        : isPairForkTarget()
            ? selectedUngroupedPairForkSentenceId.value
            : selectedUngroupedPyramidSentenceId.value;
    if (sentenceId == null || sentenceId <= 0) {
      return null;
    }
    return sentenceId;
  }

  List<int> buildPresetSentenceIds() {
    final Set<int> selectedIds = selectedUngroupedParadigmSentenceIdMap.values.where((sentenceId) => sentenceId > 0).toSet();
    final List<int> resp = <int>[];
    final Set<int> seen = <int>{};
    for (final ManageUnitGrammarTargetSentenceSetPageEntity page in ungroupedSentenceSetPages) {
      for (final PatternBlueprintSentenceBriefEntity? sentence in page.contents ?? const <PatternBlueprintSentenceBriefEntity?>[]) {
        final int? sentenceId = sentence?.actualSentenceId;
        if (sentenceId == null || sentenceId <= 0 || !selectedIds.contains(sentenceId) || !seen.add(sentenceId)) continue;
        resp.add(sentenceId);
      }
    }
    return resp;
  }

  Set<String> _buildPyramidGrowthSlotKeySet(ManageUnitGrammarTargetSentenceSetPageEntity page) {
    final Set<String> pageGrowthSlotKeySet =
        page.growthSlotKeys?.map((item) => item.trim()).where((item) => item.isNotEmpty).toSet() ?? <String>{};
    if (pageGrowthSlotKeySet.isNotEmpty) {
      return pageGrowthSlotKeySet;
    }

    final Set<String> detailGrowthSlotKeySet = <String>{};
    for (final PatternBlueprintEditSlotEntity? editSlot in patternBlueprint.value?.editSlots ?? const <PatternBlueprintEditSlotEntity?>[]) {
      for (final PatternBlueprintEditOptionSlotEntity? optionSlot
          in editSlot?.optionSlots ?? const <PatternBlueprintEditOptionSlotEntity?>[]) {
        final String slotKey = optionSlot?.slotKey?.trim() ?? '';
        if (slotKey.isEmpty || optionSlot?.growthOrder == null) continue;
        detailGrowthSlotKeySet.add(slotKey);
      }
    }
    return detailGrowthSlotKeySet;
  }

  Set<String> _buildPyramidOptionalSlotKeySet() {
    final Set<String> resp = <String>{};
    for (final PatternBlueprintEditSlotEntity? editSlot in patternBlueprint.value?.editSlots ?? const <PatternBlueprintEditSlotEntity?>[]) {
      for (final PatternBlueprintEditOptionSlotEntity? optionSlot
          in editSlot?.optionSlots ?? const <PatternBlueprintEditOptionSlotEntity?>[]) {
        final String slotKey = optionSlot?.slotKey?.trim() ?? '';
        if (slotKey.isEmpty || optionSlot?.required == true) continue;
        resp.add(slotKey);
      }
    }
    return resp;
  }

  Set<String> _buildSentenceSlotKeySet(
    List<PatternBlueprintSentenceBriefSegmentEntity?>? segmentList,
  ) {
    final Set<String> resp = <String>{};
    for (final PatternBlueprintSentenceBriefSegmentEntity? segment
        in segmentList ?? const <PatternBlueprintSentenceBriefSegmentEntity?>[]) {
      if (segment == null) continue;
      final List<String> candidateSlotKeys = <String>[
        segment.slotKey ?? '',
        segment.renderSlotKey ?? '',
        segment.sourceSlotKey ?? '',
      ];
      for (final String raw in candidateSlotKeys) {
        final String slotKey = raw.trim();
        if (slotKey.isEmpty) continue;
        resp.add(slotKey);
      }
      resp.addAll(_buildSentenceSlotKeySet(segment.childStruct?.segmentList));
    }
    return resp;
  }

  Future<void> onOpenPairForkDetails(String? nid) async {
    if (nid?.isEmpty ?? true) {
      ToastUtils.showManageToast(text: '分叉详情参数为空');
      return;
    }
    await TagRoutes.toNamed(
      Routes.ZHENXIE_SENTENCE_PAIR_FORK_DETAILS,
      arguments: {
        'nid': nid,
        'isManagement': isManagement,
      },
    );
  }

  Future<void> onOpenGrammarPanoramaDetails(String? nid) async {
    if (nid?.isEmpty ?? true) {
      ToastUtils.showManageToast(text: '语法全景详情参数为空');
      return;
    }
    await TagRoutes.toNamed(
      Routes.ZHENXIE_GRAMMAR_PANORAMA_DETAILS,
      arguments: {
        'nid': nid,
        'isManagement': isManagement,
      },
    );
  }

  bool hasReviewQueue() {
    return reviewQueue && reviewQueueUids.isNotEmpty;
  }

  int currentReviewQueueIndex() {
    if (!hasReviewQueue() || targetUid == null) return -1;
    return reviewQueueUids.indexOf(targetUid!);
  }

  int currentReviewQueueOrder() {
    final int index = currentReviewQueueIndex();
    if (index < 0) return 0;
    return index + 1;
  }

  int reviewQueueTotalCount() {
    return reviewQueueUids.length;
  }

  int remainingReviewQueueCandidateCount() {
    if (!hasReviewQueue()) return 0;
    return reviewQueueUids.where((uid) {
      final String? status = reviewQueueStatuses[uid];
      return status == null || status == 'candidate';
    }).length;
  }

  int? getPreviousReviewTargetUid() {
    final int index = currentReviewQueueIndex();
    if (index <= 0) return null;
    return reviewQueueUids[index - 1];
  }

  int? getNextReviewTargetUid() {
    final int index = currentReviewQueueIndex();
    if (index < 0 || index >= reviewQueueUids.length - 1) return null;
    return reviewQueueUids[index + 1];
  }

  int? findNextCandidateTargetUid() {
    if (!hasReviewQueue()) return null;
    final int currentIndex = currentReviewQueueIndex();
    final int takeCount = (currentIndex + 1).clamp(0, reviewQueueUids.length).toInt();
    final List<int> orderedUids = <int>[
      ...reviewQueueUids.skip(currentIndex + 1),
      ...reviewQueueUids.take(takeCount),
    ];
    for (final uid in orderedUids) {
      final String? status = reviewQueueStatuses[uid];
      if (status == null || status == 'candidate') {
        return uid;
      }
    }
    return null;
  }

  Future<void> onTapSearchLibrary() async {
    if (!canOperatePatternActions()) {
      ToastUtils.showManageToast(text: '先把本 Target 标成通过，才能匹配或生成');
      return;
    }

    ToastUtils.showLoading();
    try {
      final ResponseEntity<ManageUnitGrammarMatchPreviewEntity?>? response = await UnitUtil.previewUnitGrammarTargetMatch(
        unitId: unitId.toString(),
        config: RequestConfig(
          requireToken: true,
          data: {
            'targetUid': targetUid,
          },
        ),
      );

      ToastUtils.hideLoading();
      if (response == null) {
        ToastUtils.showManageToast(text: '搜索库句失败');
        return;
      }

      final List<ManageUnitGrammarMatchCandidateEntity> matches = response.data?.matches ?? const [];
      final List<int>? selectedIds = await ManageUnitGrammarTargetDetailsDialogs.showMatchPreviewDialog(
        matches: matches,
      );

      if (selectedIds == null || selectedIds.isEmpty) return;

      ToastUtils.showLoading();
      final ResponseEntity<ManageUnitGrammarAppendSelectedEntity?>? saveResponse = await UnitUtil.appendUnitGrammarTargetSelectedSentences(
        unitId: unitId.toString(),
        config: RequestConfig(
          requireToken: true,
          data: {
            'targetUid': targetUid,
            'contentIds': selectedIds,
          },
        ),
      );

      ToastUtils.showManageToast(
        text: saveResponse?.message ?? '保存选中成功',
      );
      await fetchData();
    } catch (e) {
      ToastUtils.showManageToast(text: '搜索库句失败');
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<void> onTapGenerateSentence() async {
    if (!canOperatePatternActions()) {
      ToastUtils.showManageToast(text: '先把本 Target 标成通过，才能匹配或生成');
      return;
    }

    ManagePageRegistry.jumpTo(
      Routes.MANAGE_SENTENCE_BLUEPRINT_GENERATE,
      arguments: {
        'unitId': unitId,
        'targetUid': targetUid,
      },
    );

    // final int? count = await ManageUnitGrammarTargetDetailsDialogs.showCreateCountDialog(
    //   title: '生成几句？',
    //   description: '只给当前这条 Target 加句，范围 1-6。',
    //   min: 1,
    //   max: 6,
    //   confirmText: '生成',
    // );
    // if (count == null) return;

    // ToastUtils.showLoading();
    // try {
    //   final ResponseEntity<String>? response = await UnitUtil.createUnitGrammarSentenceByPattern(
    //     unitId: unitId.toString(),
    //     config: RequestConfig(
    //       requireToken: true,
    //       data: {
    //         'targetUid': targetUid,
    //         'count': count,
    //       },
    //     ),
    //   );

    //   ToastUtils.showManageToast(text: response?.message ?? '已发起生成');
    //   await ManageUnitGrammarTargetDetailsDialogs.showGeneratingHintDialog();
    //   await fetchData();
    // } catch (e) {
    //   ToastUtils.showManageToast(text: '生成句子失败');
    // } finally {
    //   ToastUtils.hideLoading();
    // }
  }

  Future<void> onTapAdvancedPractice() async {
    if (!canOperateAdvancedPractice()) {
      ToastUtils.showManageToast(text: '先把本 Target 标成通过，才能高阶加练');
      return;
    }

    final int? count = await ManageUnitGrammarTargetDetailsDialogs.showCreateCountDialog(
      title: '生成几组？',
      description: '只给当前这条高阶 Target 加练，范围 1-3 组。',
      min: 1,
      max: 3,
      confirmText: '生成',
    );
    if (count == null) return;

    ToastUtils.showLoading();
    try {
      final ResponseEntity<String>? response = await UnitUtil.createUnitGrammarSentenceByRelation(
        unitId: unitId.toString(),
        config: RequestConfig(
          requireToken: true,
          data: {
            'targetUid': targetUid,
            'count': count,
          },
        ),
      );
      if (response == null || response.code != 200) return;

      ToastUtils.showManageToast(text: response.message ?? '已发起高阶加练');
      await ManageUnitGrammarTargetDetailsDialogs.showGeneratingHintDialog();
      await fetchData();
    } catch (e) {
      ToastUtils.showManageToast(text: '高阶加练失败');
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<void> onTapAddGroup() async {
    if (!canAddRealizationSet()) {
      ToastUtils.showManageToast(text: '先把本 Target 标成通过，才能添加一组');
      return;
    }
    if (shouldDisableAddGroupButton()) {
      ToastUtils.showManageToast(
        text: isPyramidTarget()
            ? '请先选一句作为基句'
            : isPairTarget()
                ? '请先选一句作为上一句'
                : isPairForkTarget()
                    ? '请先选一句作为上一句'
                    : isParadigmTarget()
                        ? '请先按组选择句子'
                        : '请先勾选未归组句',
      );
      return;
    }

    final ZhenxieEnSentenceType? typeEnum = ZhenxieEnSentenceType.fromRawValue(
      detailData.value?.grammarUnifiedInfo?.type,
    );
    String? routeName;
    Map<String, dynamic>? arguments;
    switch (typeEnum) {
      case ZhenxieEnSentenceType.EN_SENTENCE_PATTERN:
        routeName = Routes.MANAGE_SENTENCE_BLUEPRINT_ADD_GROUP;
        arguments = {
          'unitId': unitId,
          'target': detailData.value,
          'patternBlueprint': patternBlueprint.value,
          'presetSentences': buildPresetSentences(),
        };
        break;
      case ZhenxieEnSentenceType.EN_SENTENCE_PYRAMID:
        routeName = Routes.MANAGE_SENTENCE_PYRAMID_ADD_GROUP;
        arguments = {
          'unitId': unitId,
          'target': detailData.value,
          'patternBlueprint': patternBlueprint.value,
          'presetSentenceId': buildPresetSentenceId(),
        };
        break;
      case ZhenxieEnSentenceType.EN_SENTENCE_PARADIGM:
        routeName = Routes.MANAGE_SENTENCE_PARADIGM_ADD_GROUP;
        arguments = {
          'unitId': unitId,
          'targetId': detailData.value?.uid,
          'detailData': paradigmCompareData.value,
          'presetSentenceIds': buildPresetSentenceIds(),
        };
        break;
      case ZhenxieEnSentenceType.EN_SENTENCE_PATTERN_PAIR:
        routeName = Routes.MANAGE_SENTENCE_PAIR_ADD_GROUP;
        arguments = {
          'unitId': unitId,
          'targetId': detailData.value?.uid,
          'pairDetail': pairData.value,
          'presetSentenceId': buildPresetSentenceId(),
        };
        break;
      case ZhenxieEnSentenceType.EN_SENTENCE_PATTERN_PAIR_FORK:
        routeName = Routes.MANAGE_SENTENCE_FORK_ADD_GROUP;
        arguments = {
          'unitId': unitId,
          'targetId': detailData.value?.uid,
          'forkDetail': pairForkData.value,
          'presetSentenceId': buildPresetSentenceId(),
        };
        break;
      case ZhenxieEnSentenceType.EN_SENTENCE_GRAMMAR_GRID:
        routeName = Routes.MANAGE_SENTENCE_GRAMMAR_ADD_GROUP;
        arguments = {
          'unitId': unitId,
          'targetId': detailData.value?.uid,
          'grammarDetail': grammarPanoramaData.value,
        };
        break;
      case null:
        break;
    }
    if (routeName == null || arguments == null) {
      ToastUtils.showManageToast(text: '当前语法类型暂不支持添加一组');
      return;
    }

    final dynamic result = await ManagePageRegistry.jumpTo(
      routeName,
      arguments: arguments,
    );
    if (result != true) return;
    print('成功');
    await fetchData();
  }

  void onTapSlotDetails() {
    ToastUtils.showManageToast(text: '槽位详情待接入');
  }

  Future<void> onTapExpandStudy(
    PatternBlueprintSentenceBriefEntity sentence,
  ) async {
    if (sentence.actualSentenceId == null) {
      ToastUtils.showManageToast(text: '当前句子缺少 sentenceId');
      return;
    }

    await ElementsPageUtils.jumpElementsPage(
      contentId: sentence.actualSentenceId,
      contentType: KnowledgeTypeEnum.EN_SENTENCE.value,
      semanticId: sentence.semanticId,
      content: sentence.actualContent,
      styleId: null,
      dialect: null,
    );
  }

  Future<void> onTapPatternSentenceExample(
    BuildContext context,
    PatternBlueprintSentenceBriefSegmentEntity segment,
    PatternBlueprintSentenceBriefEntity? sentence,
  ) async {
    await SlotSentenceExampleDialog.show(
      context: context,
      segment: segment,
      nid: detailData.value?.grammarUnifiedInfo?.nid ?? '',
      sentenceId: sentence?.actualSentenceId,
      isManagement: isManagement,
    );
  }

  Future<void> onShelfPatternSentenceSet(
    ManageUnitGrammarTargetSentenceSetPageEntity page,
  ) async {
    if (!isManagement || page.uid == null || page.isSet != true) return;
    ToastUtils.showLoading();
    try {
      final bool resp = await LanguageConsoleRequest.zhenxieExampleAccess(
        uid: page.uid!,
        data: {
          'access': page.access == AccessEnum.NORMAL.value ? AccessEnum.INTERNAL.value : AccessEnum.NORMAL.value,
        },
      );
      if (!resp) return;
      ToastUtils.showManageToast(text: page.access == AccessEnum.NORMAL.value ? '下架成功' : '上架成功');
      await fetchSentenceSetPages(reset: true);
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<void> onDeletePatternSentenceSet(
    BuildContext context,
    int index,
    ManageUnitGrammarTargetSentenceSetPageEntity page,
  ) async {
    if (!isManagement || page.uid == null || page.isSet != true) return;
    final bool ask = await AskDialog.showUserAsk(
      context: context,
      title: '温馨提示',
      content: '确认删除 ${_buildSentenceSetTypeLabel(page)} ${index + 1} 吗？',
    );
    if (!ask) return;
    ToastUtils.showLoading();
    try {
      final bool resp = await LanguageConsoleRequest.zhenxieExampleAccess(
        uid: page.uid!,
        data: {
          'access': AccessEnum.DELETED.value,
        },
      );
      if (!resp) return;
      ToastUtils.showManageToast(text: '删除成功');
      await fetchSentenceSetPages(reset: true);
    } finally {
      ToastUtils.hideLoading();
    }
  }

  String _buildSentenceSetTypeLabel(
    ManageUnitGrammarTargetSentenceSetPageEntity page,
  ) {
    if (page.assetType == 'pyramid') return '金字塔';
    if (page.assetType == 'paradigm') return '对照';
    if (page.assetType == 'pair') return '配对';
    if (page.assetType == 'pair_fork') return '分叉';
    return '蓝图';
  }

  Future<void> onShelfPatternSentence(
    PatternBlueprintSentenceBriefEntity? sentence,
  ) async {
    if (!isManagement || sentence?.actualSentenceId == null) return;
    final bool wasNormal = sentence!.isNormal;
    ToastUtils.showLoading();
    try {
      final bool resp = await LanguageConsoleRequest.zhenxieExampleSingleAccess(
        sentenceId: sentence.actualSentenceId!,
        data: {
          'access': wasNormal ? AccessEnum.INTERNAL.value : AccessEnum.NORMAL.value,
        },
      );
      if (!resp) return;
      sentence.access = wasNormal ? AccessEnum.INTERNAL.value : AccessEnum.NORMAL.value;
      sentenceSetPages.refresh();
      ToastUtils.showManageToast(text: wasNormal ? '下架成功' : '上架成功');
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<void> onShelfPairSentence(
    SentencePairSentenceBriefEntity? sentence,
  ) async {
    if (!isManagement || sentence?.sentenceId == null) return;
    final bool wasNormal = sentence!.isNormal;
    ToastUtils.showLoading();
    try {
      final bool resp = await LanguageConsoleRequest.zhenxieExampleSingleAccess(
        sentenceId: sentence.sentenceId!,
        data: {
          'access': wasNormal ? AccessEnum.INTERNAL.value : AccessEnum.NORMAL.value,
        },
      );
      if (!resp) return;
      sentence.access = wasNormal ? AccessEnum.INTERNAL.value : AccessEnum.NORMAL.value;
      sentenceSetPages.refresh();
      ToastUtils.showManageToast(text: wasNormal ? '下架成功' : '上架成功');
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<void> onShelfPairForkSentence(
    SentenceForkSentenceBriefEntity? sentence,
  ) async {
    if (!isManagement || sentence?.sentenceId == null) return;
    final bool wasNormal = sentence!.isNormal;
    ToastUtils.showLoading();
    try {
      final bool resp = await LanguageConsoleRequest.zhenxieExampleSingleAccess(
        sentenceId: sentence.sentenceId!,
        data: {
          'access': wasNormal ? AccessEnum.INTERNAL.value : AccessEnum.NORMAL.value,
        },
      );
      if (!resp) return;
      sentence.access = wasNormal ? AccessEnum.INTERNAL.value : AccessEnum.NORMAL.value;
      sentenceSetPages.refresh();
      ToastUtils.showManageToast(text: wasNormal ? '下架成功' : '上架成功');
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<void> onAnalyseSentence() async {
    if (unitId == null || targetUid == null || isSentenceAnalyseRunning.value) {
      return;
    }

    ToastUtils.showLoading();
    isSentenceAnalyseRunning.value = true;
    try {
      final ResponseEntity<String>? response = await UnitUtil.analyseUnitGrammarSentence(
        config: RequestConfig(
          requireToken: true,
          data: {
            'unit_id': unitId,
            'target_ids': [targetUid],
          },
        ),
      );
      if (response == null || response.code != 200) {
        isSentenceAnalyseRunning.value = false;
        return;
      }
      ToastUtils.showManageToast(text: response.message ?? '已发起分析');
      await fetchData();
    } catch (e) {
      isSentenceAnalyseRunning.value = false;
      ToastUtils.showManageToast(text: '分析语法失败');
    } finally {
      ToastUtils.hideLoading();
    }
  }

  PatternBlueprintSentenceBriefEntity? findSentenceRealizationByContentId(
    int? contentId,
  ) {
    if (contentId == null) return null;
    for (final item in sentenceSetPages) {
      final List<PatternBlueprintSentenceBriefEntity?> contents = item.contents ?? const [];
      for (final content in contents) {
        if (content?.actualSentenceId == contentId) return content;
      }
    }
    return null;
  }

  Future<void> onOpenSentenceSetAssetDetails(ManageUnitGrammarTargetSentenceSetPageEntity page) async {
    final String? assetType = page.assetType;
    final String? assetNid = page.assetNid;
    if (assetType?.isEmpty != false || assetNid?.isEmpty != false) {
      ToastUtils.showManageToast(text: '句组资产参数为空');
      return;
    }
    final int? realizationSetId = page.isSet == true ? page.uid : null;

    if (assetType == 'pattern') {
      final bool supportsPyramid = detailData.value?.grammarUnifiedInfo?.type == ZhenxieEnSentenceType.EN_SENTENCE_PYRAMID.rawValue;
      await TagRoutes.toNamed(
        Routes.ZHENXIE_PATTERN_BLUEPRINT_DETAILS,
        arguments: {
          'nid': assetNid,
          'supportsPyramid': supportsPyramid,
          'isManagement': isManagement,
          'realizationSetId': realizationSetId,
        },
      );
      return;
    }

    if (assetType == 'pair') {
      await TagRoutes.toNamed(
        Routes.ZHENXIE_SENTENCE_PAIR_DETAILS,
        arguments: {
          'nid': assetNid,
          'isManagement': isManagement,
          'realizationSetId': realizationSetId,
        },
      );
      return;
    }

    if (assetType == 'pair_fork') {
      await TagRoutes.toNamed(
        Routes.ZHENXIE_SENTENCE_PAIR_FORK_DETAILS,
        arguments: {
          'nid': assetNid,
          'isManagement': isManagement,
          'realizationSetId': realizationSetId,
        },
      );
      return;
    }

    if (assetType == 'paradigm') {
      await TagRoutes.toNamed(
        Routes.ZHENXIE_SENTENCE_PATTERN_COMPARE_DETAILS,
        arguments: {
          'nid': assetNid,
          'isManagement': isManagement,
          'realizationSetId': realizationSetId,
        },
      );
      return;
    }

    if (assetType == 'grid') {
      await TagRoutes.toNamed(
        Routes.ZHENXIE_GRAMMAR_PANORAMA_DETAILS,
        arguments: {
          'nid': assetNid,
          'isManagement': isManagement,
          'realizationSetId': realizationSetId,
        },
      );
      return;
    }

    ToastUtils.showManageToast(text: '当前类型暂不支持打开句组详情');
  }

  Future<void> onRemoveFromGrammar(int? contentUid) async {
    if (unitId == null || targetUid == null || contentUid == null) return;
    // final bool askRes = await AskDialog.showUserAsk(
    //   context: Get.context!,
    //   content: '确认将这句从当前语法 Target 移除吗？',
    //   cancel: '取消',
    //   define: '确认',
    // );
    // if (!askRes) return;

    ToastUtils.showLoading();
    try {
      final ResponseEntity<String?>? response = await UnitUtil.removeUnitKnowledgeContents(
        unitId: unitId.toString(),
        config: RequestConfig(
          requireToken: true,
          parameters: {
            'flag': 2,
            'targetId': targetUid,
          },
          data: {
            'contents': [
              {
                'type': KnowledgeTypeEnum.EN_SENTENCE.value,
                'uid': contentUid.toString(),
              },
            ],
          },
        ),
      );
      if (response == null || response.code != 200) return;
      ToastUtils.showManageToast(text: response.message ?? '已从语法移除');
      await fetchData();
    } catch (e) {
      ToastUtils.showManageToast(text: '从语法移除失败');
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<void> onTapSentenceDelete(int? contentUid) async {
    if (contentUid == null) return;
    final ManageUnitGrammarSentenceDeleteAction? action = await ManageUnitGrammarTargetDetailsDialogs.showSentenceDeleteDialog();
    if (action == null) return;
    if (action == ManageUnitGrammarSentenceDeleteAction.removeFromUnit) {
      await onRemoveFromUnit(contentUid);
      return;
    }
    await onRemoveFromGrammar(contentUid);
  }

  Future<void> onRemoveFromUnit(int? contentUid) async {
    if (unitId == null || contentUid == null) return;
    // final bool askRes = await AskDialog.showUserAsk(
    //   context: Get.context!,
    //   content: '确认将这句从当前单元移除吗？',
    //   cancel: '取消',
    //   define: '确认',
    // );
    // if (!askRes) return;

    ToastUtils.showLoading();
    try {
      final ResponseEntity<String?>? response = await UnitUtil.removeUnitKnowledgeContents(
        unitId: unitId.toString(),
        config: RequestConfig(
          requireToken: true,
          parameters: {
            'flag': 0,
          },
          data: {
            'contents': [
              {
                'type': KnowledgeTypeEnum.EN_SENTENCE.value,
                'uid': contentUid.toString(),
              },
            ],
          },
        ),
      );
      if (response == null || response.code != 200) return;
      ToastUtils.showManageToast(text: response.message ?? '已从单元移除');
      await fetchData();
    } catch (e) {
      ToastUtils.showManageToast(text: '从单元移除失败');
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<void> onReviewStatus(String status) async {
    if (unitId == null || targetUid == null) return;
    final int currentUid = targetUid!;

    ToastUtils.showLoading();
    try {
      final ResponseEntity<ManageUnitGrammarTargetStatusUpdateEntity?>? response = await UnitUtil.updateUnitGrammarTargetStatus(
        unitId: unitId.toString(),
        config: RequestConfig(
          requireToken: true,
          data: {
            'targetUid': targetUid,
            'status': status,
          },
        ),
      );

      if (response == null || response.code != 200) return;

      reviewQueueStatuses[currentUid] = status;
      ToastUtils.showManageToast(text: response.message ?? '审核状态更新成功');

      if (hasReviewQueue()) {
        if (status == 'candidate') {
          await fetchData();
          return;
        }
        if (response.data?.reviewCompleted == true || remainingReviewQueueCandidateCount() <= 0) {
          Get.back();
          return;
        }
        final int? nextTargetUid = findNextCandidateTargetUid();
        if (nextTargetUid != null) {
          targetUid = nextTargetUid;
          await fetchData();
          return;
        }
        Get.back();
        return;
      }

      await fetchData();
    } catch (e) {
      ToastUtils.showManageToast(text: '审核状态更新失败');
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<void> onOpenReviewQueueTarget(int? nextTargetUid) async {
    if (!hasReviewQueue() || nextTargetUid == null) return;
    targetUid = nextTargetUid;
    await fetchData(showLoading: true);
  }
}
