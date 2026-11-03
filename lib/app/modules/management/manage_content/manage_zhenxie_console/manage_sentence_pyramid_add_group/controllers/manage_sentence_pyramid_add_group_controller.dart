import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/enum/enum.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../../utils/utils.dart';
import '../../../../../../routes/routes.dart';
import '../../../../utils/utils.dart';
import '../../common/manage_sentence_add_select_dialog.dart';
import '../../common/manage_sentence_add_widgets.dart';
import '../../manage_sentence_blueprint_add_group/views/manage_sentence_blueprint_add_group_slot_map_widget.dart';

class ManageSentencePyramidAddGroupController extends GetxController with ManageBreadcrumbMixin {
  /// 当前页面实例 tag。
  final String tag;

  ManageSentencePyramidAddGroupController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_SENTENCE_PYRAMID_ADD_GROUP;

  @override
  String get breadcrumbTitle => '添加一组';

  /// 页面入口传入的句型蓝图。
  PatternBlueprintEntity? patternBlueprint;

  /// 单元 Target 入口传入的 Target 详情。
  ManageUnitGrammarTargetDetailEntity? target;

  /// 单元 Target 入口传入的单元 id，只用于候选句接口。
  int? unitId;

  /// 上级页面预先指定的基句 uid，进入页面后默认按这句锁基句。
  int? presetSentenceId;

  /// 当前页面对应的 Target 形态锁数据。
  ManageSentenceBlueprintAddGroupShapeLockData shapeLockData = const ManageSentenceBlueprintAddGroupShapeLockData();

  /// 当前已选择的增长槽，顺序决定金字塔层级顺序。
  final RxList<String> growthSlotKeys = <String>[].obs;

  /// 当前已锁定的基句。
  final Rxn<PatternBlueprintSentenceBriefEntity> baseSentence = Rxn<PatternBlueprintSentenceBriefEntity>();

  /// 当前基句实际占用的槽。
  final RxList<String> baseOccupancySlotKeys = <String>[].obs;

  /// 当前每个增长槽已绑定的层句，key 为 slotKey。
  final RxMap<String, PatternBlueprintSentenceBriefEntity> boundSentenceMap = <String, PatternBlueprintSentenceBriefEntity>{}.obs;

  /// 基句 uid 输入框控制器。
  final TextEditingController pyramidBaseIdController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    final dynamic arguments = Get.arguments;
    if (arguments is! Map) {
      return;
    }

    final dynamic rawPatternBlueprint = arguments['patternBlueprint'];
    final dynamic rawTarget = arguments['target'];
    if (rawPatternBlueprint is PatternBlueprintEntity) {
      patternBlueprint = rawPatternBlueprint;
    }
    if (rawTarget is ManageUnitGrammarTargetDetailEntity) {
      target = rawTarget;
    }
    unitId = arguments['unitId'];
    presetSentenceId = _parsePresetSentenceId(arguments['presetSentenceId']);
    initData();
  }

  /// 首次进入页面时重置本地草稿态。
  Future<void> initData() async {
    shapeLockData = ManageSentenceBlueprintAddGroupSlotMapHelper.buildShapeLockData(
      patternBlueprint: patternBlueprint,
      target: target,
    );
    growthSlotKeys.assignAll(_sortGrowthSlotKeys(
      shapeLockData.type == ZhenxieEnSentenceType.EN_SENTENCE_PYRAMID.rawValue ? shapeLockData.activatedOptionalSlotKeys : const <String>[],
    ));
    baseSentence.value = null;
    baseOccupancySlotKeys.clear();
    boundSentenceMap.clear();
    pyramidBaseIdController.clear();
    if (presetSentenceId != null) {
      pyramidBaseIdController.text = "$presetSentenceId";
      await lockBaseSentence();
    }
  }

  /// 当前是否已经锁定基句。
  bool get hasLockedBaseSentence => baseSentence.value?.sentenceId != null;

  /// 当前增长槽和基句是否存在 Target 锁冲突。
  List<String> get pyramidLockConflictSlotKeys {
    if (!hasLockedBaseSentence || shapeLockData.type != ZhenxieEnSentenceType.EN_SENTENCE_PYRAMID.rawValue) {
      return const <String>[];
    }
    return _resolveLockedGrowthConflictSlotKeys(baseOccupancySlotKeys);
  }

  /// 当前页面是否已经锁定完整的金字塔形态。
  bool isShapeLocked() {
    return hasLockedBaseSentence && growthSlotKeys.isNotEmpty && pyramidLockConflictSlotKeys.isEmpty;
  }

  /// 当前骨架里要高亮显示的槽。
  List<String> get checkedSlotKeys {
    final List<String> resp = <String>[];
    final Set<String> seen = <String>{};
    for (final String raw in <String>[
      ...baseOccupancySlotKeys,
      ...growthSlotKeys,
    ]) {
      final String key = raw.trim();
      if (key.isEmpty || seen.contains(key)) {
        continue;
      }
      seen.add(key);
      resp.add(key);
    }
    return resp;
  }

  /// 当前增长态下可以继续点击选择的开放槽。
  List<String> get pyramidGrowableSlotKeys {
    if (!hasLockedBaseSentence) {
      return const <String>[];
    }
    return _availableGrowthSlotKeys.where((key) => !baseOccupancySlotKeys.contains(key)).toList();
  }

  /// 当前要按 unused 态显示的开放槽。
  List<String> get disabledOptionalSlotKeys {
    final Set<String> resp = <String>{
      ...ManageSentenceBlueprintAddGroupSlotMapHelper.getDisabledOptionalSlotKeys(
        patternBlueprint,
        shapeLockData: shapeLockData,
      ),
    };
    if (hasLockedBaseSentence) {
      for (final String key in _availableGrowthSlotKeys) {
        if (!pyramidGrowableSlotKeys.contains(key) && !growthSlotKeys.contains(key)) {
          resp.add(key);
        }
      }
    }
    return resp.toList();
  }

  /// 当前卡片列表展示态。
  List<ManageSentenceAddBindingCardModel> buildBindingCardList() {
    if (!isShapeLocked()) {
      return const <ManageSentenceAddBindingCardModel>[];
    }
    final List<ManageSentenceAddBindingCardModel> resp = <ManageSentenceAddBindingCardModel>[
      ManageSentenceAddBindingCardModel(
        index: 0,
        title: "基句",
        cellKey: 'layer_0',
        sentence: baseSentence.value,
        highlightSlotKeys: growthSlotKeys.toList(),
        patternBlueprint: patternBlueprint,
      ),
    ];
    for (int index = 0; index < growthSlotKeys.length; index++) {
      final String slotKey = growthSlotKeys[index];
      resp.add(
        ManageSentenceAddBindingCardModel(
          index: index + 1,
          title: _resolveGrowthTitle(slotKey, index + 1),
          cellKey: slotKey,
          sentence: boundSentenceMap[slotKey],
          exampleSentence: _resolveExampleSentence(slotKey),
          highlightSlotKeys: growthSlotKeys.toList(),
          patternBlueprint: patternBlueprint,
        ),
      );
    }
    return resp;
  }

  /// 当前已绑句数，包含基句。
  int get bindCount {
    int resp = hasLockedBaseSentence ? 1 : 0;
    for (final String slotKey in growthSlotKeys) {
      if (boundSentenceMap[slotKey]?.sentenceId != null) {
        resp += 1;
      }
    }
    return resp;
  }

  /// 当前总句位数，包含基句。
  int get totalCount {
    if (!hasLockedBaseSentence) {
      return 0;
    }
    return growthSlotKeys.length + 1;
  }

  /// 是否允许执行补句落库。
  bool get isAddSentenceEnabled => isShapeLocked() && bindCount > 0;

  /// 是否允许执行满句落库。
  bool get isFullSentenceEnabled => isShapeLocked() && totalCount > 0 && bindCount == totalCount;

  /// 当前基础开放槽里的可选增长槽。
  List<String> get _availableGrowthSlotKeys {
    return ManageSentenceBlueprintAddGroupSlotMapHelper.getOptionalOpenSlotKeys(
      patternBlueprint,
      shapeLockData: shapeLockData,
    );
  }

  /// 当前 Target 锁定的金字塔增长槽，顺序由 Target 形态锁决定。
  List<String> get _lockedPyramidGrowthSlotKeys {
    if (shapeLockData.type != ZhenxieEnSentenceType.EN_SENTENCE_PYRAMID.rawValue) {
      return const <String>[];
    }
    return _sortGrowthSlotKeys(shapeLockData.activatedOptionalSlotKeys);
  }

  /// 计算当前基句已经连续长到金字塔的前缀层数。
  int _resolveLockedGrowthPrefixLength(List<String> occupancySlotKeys) {
    int prefixLength = 0;
    for (final String key in _lockedPyramidGrowthSlotKeys) {
      if (!occupancySlotKeys.contains(key)) {
        break;
      }
      prefixLength += 1;
    }
    return prefixLength;
  }

  /// 计算当前基句在锁定增长槽上的非法跳占部分。
  List<String> _resolveLockedGrowthConflictSlotKeys(List<String> occupancySlotKeys) {
    final List<String> lockedGrowthSlotKeys = _lockedPyramidGrowthSlotKeys;
    if (lockedGrowthSlotKeys.isEmpty) {
      return const <String>[];
    }
    final int prefixLength = _resolveLockedGrowthPrefixLength(occupancySlotKeys);
    final List<String> resp = <String>[];
    for (int index = prefixLength; index < lockedGrowthSlotKeys.length; index++) {
      final String key = lockedGrowthSlotKeys[index];
      if (occupancySlotKeys.contains(key)) {
        resp.add(key);
      }
    }
    return resp;
  }

  /// 计算锁定基句后，金字塔剩余还能继续增长的层。
  List<String> _resolveRemainingLockedGrowthSlotKeys(List<String> occupancySlotKeys) {
    final List<String> lockedGrowthSlotKeys = _lockedPyramidGrowthSlotKeys;
    if (lockedGrowthSlotKeys.isEmpty) {
      return const <String>[];
    }
    final int prefixLength = _resolveLockedGrowthPrefixLength(occupancySlotKeys);
    return lockedGrowthSlotKeys.skip(prefixLength).toList();
  }

  /// 基句校验时挑一条合法且非空的增长链，避免把基句自己已占用的槽再次传给后端。
  List<String> _resolveBaseCheckGrowthSlotKeys({required List<String> baseOccupancySlotKeys}) {
    if (shapeLockData.type == ZhenxieEnSentenceType.EN_SENTENCE_PYRAMID.rawValue) {
      final List<String> lockedGrowthConflictSlotKeys = _resolveLockedGrowthConflictSlotKeys(baseOccupancySlotKeys);
      if (lockedGrowthConflictSlotKeys.isNotEmpty) {
        return _lockedPyramidGrowthSlotKeys;
      }
      return _resolveRemainingLockedGrowthSlotKeys(baseOccupancySlotKeys);
    }
    final List<List<String>> candidateGroups = <List<String>>[
      growthSlotKeys.toList(),
      _sortGrowthSlotKeys(_availableGrowthSlotKeys),
    ];
    for (final List<String> candidateKeys in candidateGroups) {
      final List<String> legalGrowthSlotKeys = _sortGrowthSlotKeys(
        candidateKeys.where((key) => !baseOccupancySlotKeys.contains(key)).toList(),
      );
      if (legalGrowthSlotKeys.isNotEmpty) {
        return legalGrowthSlotKeys;
      }
    }
    return const <String>[];
  }

  /// 锁定基句，并基于返回的 occupancy 重算当前增长态。
  Future<void> lockBaseSentence() async {
    final PatternBlueprintEntity? pattern = patternBlueprint;
    final String? nid = pattern?.nid;
    if (nid == null || nid.isEmpty) {
      ToastUtils.showToast(text: '当前蓝图缺少 nid');
      return;
    }

    final int? sentenceId = int.tryParse(pyramidBaseIdController.text.trim());
    if (sentenceId == null) {
      ToastUtils.showToast(text: '请输入正确的基句 uid');
      return;
    }
    final PatternBlueprintSentenceBriefEntity fetchedBaseSentence = await _fetchSentenceStructForBinding(
      PatternBlueprintSentenceBriefEntity(
        sentenceId: sentenceId,
        contentType: "EN_SENTENCE",
      ),
    );
    if (isClosed) {
      return;
    }
    final List<String> fetchedBaseOccupancySlotKeys = _resolveBaseOccupancySlotKeys(
      occupancy: const <dynamic>[],
      sentence: fetchedBaseSentence,
    );
    baseOccupancySlotKeys.assignAll(fetchedBaseOccupancySlotKeys);
    final List<String> bindGrowthSlotKeys = _resolveBaseCheckGrowthSlotKeys(
      baseOccupancySlotKeys: fetchedBaseOccupancySlotKeys,
    );
    // if (bindGrowthSlotKeys.isEmpty) {
    //   ToastUtils.showToast(text: '这句已经占用了全部可增长槽，换一句更短的基句试试');
    //   return;
    // }

    ToastUtils.showLoading();
    PatternRealizationSetPatternBindCheckEntity? response;
    try {
      response = await LanguageConsoleRequest.checkPatternRealizationSetPyramidBind(
        nid: nid,
        data: <String, dynamic>{
          "sentenceId": sentenceId,
          "layerIndex": 0,
          "growthSlotKeys": bindGrowthSlotKeys,
          "boundSentenceIds": const <int>[],
        },
      );
    } finally {
      ToastUtils.hideLoading();
    }
    if (response == null) return;

    if (response.ok != true) {
      ToastUtils.showToast(text: response.reason ?? '这句不能作为当前金字塔基句');
      return;
    }

    final PatternBlueprintSentenceBriefEntity nextBaseSentence = response.sentenceStruct ??
        PatternBlueprintSentenceBriefEntity(
          sentenceId: response.sentenceId ?? sentenceId,
          content: response.text?.isNotEmpty == true ? response.text : "句子 $sentenceId",
          contentType: response.contentType,
          access: "INTERNAL",
        );
    final PatternBlueprintSentenceBriefEntity mergedBaseSentence = _mergeSentenceStruct(
      base: nextBaseSentence,
      struct: fetchedBaseSentence,
    );
    baseSentence.value = mergedBaseSentence;
    final List<String> nextBaseOccupancySlotKeys = _resolveBaseOccupancySlotKeys(
      occupancy: response.occupancy,
      sentence: mergedBaseSentence,
    );
    baseOccupancySlotKeys.assignAll(nextBaseOccupancySlotKeys);

    if (shapeLockData.type == ZhenxieEnSentenceType.EN_SENTENCE_PYRAMID.rawValue) {
      growthSlotKeys.assignAll(_resolveRemainingLockedGrowthSlotKeys(nextBaseOccupancySlotKeys));
    } else {
      growthSlotKeys.assignAll(
        _sortGrowthSlotKeys(
          growthSlotKeys.where((key) => !nextBaseOccupancySlotKeys.contains(key)).toList(),
        ),
      );
    }

    // 基句变化后，已有层句都需要重新绑，避免旧盘面残留。
    boundSentenceMap.clear();
  }

  /// 清空当前基句，并回到初始草稿态。
  void clearBaseSentence() {
    baseSentence.value = null;
    baseOccupancySlotKeys.clear();
    boundSentenceMap.clear();
    pyramidBaseIdController.clear();
    growthSlotKeys.assignAll(_sortGrowthSlotKeys(
      shapeLockData.type == ZhenxieEnSentenceType.EN_SENTENCE_PYRAMID.rawValue ? shapeLockData.activatedOptionalSlotKeys : const <String>[],
    ));
  }

  /// 点击增长槽时切换当前金字塔增长链。
  void onGrowthSlotTap(SentenceSlotMapItemEntity item) {
    if (!hasLockedBaseSentence ||
        shapeLockData.type == ZhenxieEnSentenceType.EN_SENTENCE_PYRAMID.rawValue ||
        item.isLiteral ||
        item.unused) {
      return;
    }

    final String key = item.slotKey;
    final bool isSelected = growthSlotKeys.contains(key);
    if (!isSelected && !pyramidGrowableSlotKeys.contains(key)) {
      return;
    }

    if (isSelected) {
      if (_hasSelectedDependent(key)) {
        return;
      }
      growthSlotKeys.remove(key);
    } else {
      final List<String> deps = _resolveSelectableDependsOn(key);
      growthSlotKeys.assignAll(_sortGrowthSlotKeys(<String>[
        ...growthSlotKeys,
        ...deps,
        key,
      ]));
    }

    // 增长链变化后，已绑层句可能不再对应新的层级结构。
    boundSentenceMap.clear();
  }

  /// 打开候选句弹窗，并在用户选中后写回当前层位。
  Future<void> pickSentence(BuildContext context, String slotKey) async {
    if (!isShapeLocked()) {
      ToastUtils.showToast(text: '先锁定基句并选好增长槽，再开始绑句');
      return;
    }

    final PatternBlueprintEntity? pattern = patternBlueprint;
    final String? nid = pattern?.nid;
    final int layerIndex = growthSlotKeys.indexOf(slotKey) + 1;
    if (nid == null || nid.isEmpty || layerIndex <= 0) {
      ToastUtils.showToast(text: '当前层位信息不完整');
      return;
    }

    final PatternBlueprintSentenceBriefEntity? selected = await ManageSentenceAddSelectDialog.show(
      context: context,
      model: ManageSentenceAddSelectDialogModel(
        pageType: ZhenxieEnSentenceType.EN_SENTENCE_PYRAMID,
        title: _resolveGrowthTitle(slotKey, layerIndex),
        nid: nid,
        baseSlotKeys: const <String>[],
        dialSlotKeys: const <String>[],
        boundSentenceIds: _activeBoundSentenceIdsExcluding(slotKey),
        unitId: unitId,
        layerIndex: layerIndex,
        baseSentenceId: baseSentence.value?.sentenceId,
        growthSlotKeys: growthSlotKeys.toList(),
        patternName: _resolveGrowthTitle(slotKey, layerIndex),
        exampleSentence: _resolveExampleSentence(slotKey),
      ),
    );
    if (selected == null) {
      return;
    }
    await _bindLayerSentenceWithStructure(slotKey: slotKey, sentence: selected);
  }

  /// 手动输入 uid，并校验当前句子是否能绑到当前层位。
  Future<void> manualInputUid(BuildContext context, String slotKey) async {
    if (!isShapeLocked()) {
      ToastUtils.showToast(text: '先锁定基句并选好增长槽，再开始绑句');
      return;
    }

    final PatternBlueprintEntity? pattern = patternBlueprint;
    final String? nid = pattern?.nid;
    final int layerIndex = growthSlotKeys.indexOf(slotKey) + 1;
    if (nid == null || nid.isEmpty || layerIndex <= 0) {
      ToastUtils.showToast(text: '当前层位信息不完整');
      return;
    }

    final String? raw = await InputDialog.show(
      context: context,
      title: "句子 uid",
      inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
      confirmText: "核对",
    );
    if (raw == null) return;

    final int? sentenceId = int.tryParse(raw);
    if (sentenceId == null) {
      ToastUtils.showToast(text: '请输入正确的句子 uid');
      return;
    }

    ToastUtils.showLoading();
    PatternRealizationSetPatternBindCheckEntity? response;
    try {
      response = await LanguageConsoleRequest.checkPatternRealizationSetPyramidBind(
        nid: nid,
        data: <String, dynamic>{
          "sentenceId": sentenceId,
          "layerIndex": layerIndex,
          "baseSentenceId": baseSentence.value?.sentenceId,
          "growthSlotKeys": growthSlotKeys,
          "boundSentenceIds": _activeBoundSentenceIdsExcluding(slotKey),
        },
      );
    } finally {
      ToastUtils.hideLoading();
    }
    if (response == null) return;

    if (response.ok != true) {
      ToastUtils.showToast(text: response.reason ?? '这句不能绑到当前层位');
      return;
    }

    final PatternBlueprintSentenceBriefEntity boundSentence = response.sentenceStruct ??
        PatternBlueprintSentenceBriefEntity(
          sentenceId: response.sentenceId ?? sentenceId,
          content: response.text?.isNotEmpty == true ? response.text : "句子 $sentenceId",
          contentType: response.contentType,
          access: "INTERNAL",
        );
    await _bindLayerSentenceWithStructure(slotKey: slotKey, sentence: boundSentence);
  }

  /// 提交“补句落库”，允许只带部分人工钉句。
  Future<void> addSentence() async {
    if (!isAddSentenceEnabled) {
      _showSubmitHint(requireFull: false);
      return;
    }
    await _submitPyramidSet(matchFirst: false);
  }

  /// 提交“满句落库”，要求所有层位都已经绑满。
  Future<void> fullSentence() async {
    if (!isFullSentenceEnabled) {
      _showSubmitHint(requireFull: true);
      return;
    }
    await _submitPyramidSet(matchFirst: true);
  }

  /// 当前已绑定的 sentenceId，包含基句。
  List<int> get _activeBoundSentenceIds {
    final List<int> resp = <int>[];
    final int? baseSentenceId = baseSentence.value?.sentenceId;
    if (baseSentenceId != null) {
      resp.add(baseSentenceId);
    }
    for (final String slotKey in growthSlotKeys) {
      final int? sentenceId = boundSentenceMap[slotKey]?.sentenceId;
      if (sentenceId != null) {
        resp.add(sentenceId);
      }
    }
    return resp;
  }

  /// 返回排除当前层位后的已绑定 sentenceId 列表。
  List<int> _activeBoundSentenceIdsExcluding(String currentSlotKey) {
    final List<int> resp = <int>[];
    final int? baseSentenceId = baseSentence.value?.sentenceId;
    if (baseSentenceId != null) {
      resp.add(baseSentenceId);
    }
    for (final String slotKey in growthSlotKeys) {
      if (slotKey == currentSlotKey) {
        continue;
      }
      final int? sentenceId = boundSentenceMap[slotKey]?.sentenceId;
      if (sentenceId != null) {
        resp.add(sentenceId);
      }
    }
    return resp;
  }

  /// 当前提交使用的层句 id 集合，包含基句。
  List<int> _buildLayerSentenceIds() {
    return _activeBoundSentenceIds.toSet().toList();
  }

  /// 解析入口透传的预设基句 uid。
  int? _parsePresetSentenceId(dynamic rawValue) {
    if (rawValue is int && rawValue > 0) {
      return rawValue;
    }
    return int.tryParse(rawValue?.toString() ?? '');
  }

  /// 先回填层句，再补查完整结构，保证层句句面能按增长槽高亮。
  Future<void> _bindLayerSentenceWithStructure({
    required String slotKey,
    required PatternBlueprintSentenceBriefEntity sentence,
  }) async {
    boundSentenceMap[slotKey] = sentence;
    final PatternBlueprintSentenceBriefEntity nextSentence = await _fetchSentenceStructForBinding(sentence);
    if (isClosed) {
      return;
    }
    boundSentenceMap[slotKey] = nextSentence;
  }

  /// 按当前句子的 type + uid 拉完整结构，并从 sentenceRealizationList 中匹配回同一句。
  Future<PatternBlueprintSentenceBriefEntity> _fetchSentenceStructForBinding(
    PatternBlueprintSentenceBriefEntity sentence,
  ) async {
    final int? sentenceId = sentence.sentenceId;
    final String? contentType = sentence.contentType;
    if (sentenceId == null) {
      return sentence;
    }

    ToastUtils.showLoading();
    try {
      final Map<String, dynamic> reqData = {
        "contents": [
          {
            "type": contentType ?? "EN_SENTENCE",
            "uid": sentenceId,
          },
        ],
      };
      final PatternBlueprintEntity? sentenceStruct = await LanguageConsoleRequest.querySentenceStructure(data: reqData);
      if (sentenceStruct == null) {
        return sentence;
      }
      final List<PatternBlueprintSentenceBriefEntity?> sentenceRealizations = sentenceStruct.sentenceRealizationList ?? [];
      final PatternBlueprintSentenceBriefEntity? matchedSentence = _matchSentenceStruct(
        sentenceRealizations: sentenceRealizations,
        sentence: sentence,
      );
      if (matchedSentence == null) {
        return sentence;
      }
      return _mergeSentenceStruct(base: sentence, struct: matchedSentence);
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 从统一结构接口返回的 realization 列表里，按 sentenceId + type 找回当前句子。
  PatternBlueprintSentenceBriefEntity? _matchSentenceStruct({
    required List<PatternBlueprintSentenceBriefEntity?> sentenceRealizations,
    required PatternBlueprintSentenceBriefEntity sentence,
  }) {
    for (final PatternBlueprintSentenceBriefEntity? item in sentenceRealizations) {
      if (item == null) {
        continue;
      }
      if (item.sentenceId == sentence.sentenceId && item.contentType == sentence.contentType) {
        return item;
      }
    }
    for (final PatternBlueprintSentenceBriefEntity? item in sentenceRealizations) {
      if (item == null) {
        continue;
      }
      if (item.sentenceId == sentence.sentenceId) {
        return item;
      }
    }
    return sentenceRealizations.length == 1 ? sentenceRealizations.first : null;
  }

  /// 把可能挂在 sentenceStruct 里的真实句子结构上提到当前句子，保证 segment 等字段可直接消费。
  PatternBlueprintSentenceBriefEntity _resolveEffectiveSentenceStruct(PatternBlueprintSentenceBriefEntity sentence) {
    final PatternBlueprintSentenceBriefEntity? nestedSentence = sentence.sentenceStruct;
    if (nestedSentence == null) {
      return sentence;
    }
    final bool hasTopLevelSegmentList = sentence.segmentList?.isNotEmpty == true;
    if (hasTopLevelSegmentList) {
      return sentence;
    }
    return PatternBlueprintSentenceBriefEntity(
      sentenceId: sentence.sentenceId ?? nestedSentence.sentenceId,
      semanticId: sentence.semanticId ?? nestedSentence.semanticId,
      content: sentence.content ?? nestedSentence.content,
      definition: sentence.definition ?? nestedSentence.definition,
      contentType: sentence.contentType ?? nestedSentence.contentType,
      patternNid: sentence.patternNid ?? nestedSentence.patternNid,
      patternTemplate: sentence.patternTemplate ?? nestedSentence.patternTemplate,
      blueprintScope: sentence.blueprintScope ?? nestedSentence.blueprintScope,
      segmentList: sentence.segmentList ?? nestedSentence.segmentList,
      order: sentence.order ?? nestedSentence.order,
      realizationSetId: sentence.realizationSetId ?? nestedSentence.realizationSetId,
      access: sentence.access ?? nestedSentence.access,
    );
  }

  /// 用结构接口返回的 segment 等字段补全当前句子，同时保留原句已有的展示字段。
  PatternBlueprintSentenceBriefEntity _mergeSentenceStruct({
    required PatternBlueprintSentenceBriefEntity base,
    required PatternBlueprintSentenceBriefEntity struct,
  }) {
    final PatternBlueprintSentenceBriefEntity resolvedBase = _resolveEffectiveSentenceStruct(base);
    final PatternBlueprintSentenceBriefEntity resolvedStruct = _resolveEffectiveSentenceStruct(struct);
    return PatternBlueprintSentenceBriefEntity(
      sentenceId: resolvedStruct.sentenceId ?? resolvedBase.sentenceId,
      semanticId: resolvedStruct.semanticId ?? resolvedBase.semanticId,
      content: resolvedStruct.content ?? resolvedBase.content,
      definition: resolvedStruct.definition ?? resolvedBase.definition,
      contentType: resolvedStruct.contentType ?? resolvedBase.contentType,
      patternNid: resolvedStruct.patternNid ?? resolvedBase.patternNid,
      patternTemplate: resolvedStruct.patternTemplate ?? resolvedBase.patternTemplate,
      blueprintScope: resolvedStruct.blueprintScope ?? resolvedBase.blueprintScope,
      segmentList: resolvedStruct.segmentList ?? resolvedBase.segmentList,
      order: resolvedStruct.order ?? resolvedBase.order,
      realizationSetId: resolvedStruct.realizationSetId ?? resolvedBase.realizationSetId,
      access: resolvedStruct.access ?? resolvedBase.access,
    );
  }

  /// 执行 Pyramid add-set 提交流程。
  Future<void> _submitPyramidSet({required bool matchFirst}) async {
    final PatternBlueprintEntity? pattern = patternBlueprint;
    final String? nid = pattern?.nid;
    final int? baseSentenceId = baseSentence.value?.sentenceId;
    if (nid == null || nid.isEmpty) {
      ToastUtils.showToast(text: '当前蓝图缺少 nid');
      return;
    }
    if (baseSentenceId == null || growthSlotKeys.isEmpty) {
      ToastUtils.showToast(text: '先锁定基句并选好增长槽');
      return;
    }

    final List<int> layerSentenceIds = _buildLayerSentenceIds();
    ToastUtils.showLoading();
    try {
      final PatternRealizationSetPatternMatchCheckEntity? matchResp = await LanguageConsoleRequest.checkPatternRealizationSetPyramidMatch(
        nid: nid,
        data: <String, dynamic>{
          "growthSlotKeys": growthSlotKeys,
          "layerSentenceIds": layerSentenceIds,
        },
      );
      if (matchResp?.ok != true) {
        final String failureText = (matchResp?.failures ?? const <PatternRealizationSetPatternMatchFailureEntity>[])
            .map((item) => item.code ?? '')
            .where((item) => item.isNotEmpty)
            .join('、');
        ToastUtils.showToast(text: failureText.isNotEmpty ? failureText : '当前金字塔未通过整塔门禁');
        return;
      }

      final Map<String, dynamic> createReqData = <String, dynamic>{
        "baseSentenceId": baseSentenceId,
        "growthSlotKeys": growthSlotKeys,
        "layerSentenceIds": layerSentenceIds,
        "match_first": matchFirst,
      };
      final Map<String, dynamic> parameter = <String, dynamic>{};
      if (unitId != null) {
        parameter['unitId'] = unitId;
      }
      if (target?.uid != null) {
        parameter['targetId'] = target?.uid;
      }

      final bool createResp = await LanguageConsoleRequest.createPatternRealizationSetPyramid(
        nid: nid,
        data: createReqData,
        parameter: parameter,
      );
      if (!createResp) {
        return;
      }

      ToastUtils.showToast(text: '已发起创建任务', type: ToastType.success);
      Get.back(result: true);
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 根据提交目标给出统一提示。
  void _showSubmitHint({required bool requireFull}) {
    if (!hasLockedBaseSentence) {
      ToastUtils.showToast(text: '先锁定基句');
      return;
    }
    if (growthSlotKeys.isEmpty) {
      ToastUtils.showToast(text: '先选至少 1 个增长槽');
      return;
    }
    if (pyramidLockConflictSlotKeys.isNotEmpty) {
      ToastUtils.showToast(text: '当前基句占用了锁定增长槽，先换一句基句');
      return;
    }
    ToastUtils.showToast(text: requireFull ? '先把所有层位都绑满，再满句落库' : '至少先锁好基句，再补句落库');
  }

  /// 当前增长槽是否被其他已选槽依赖。
  bool _hasSelectedDependent(String slotKey) {
    final Map<String, PatternBlueprintOpenSlotEntity?> openSlotMap = _openSlotMap;
    for (final String selectedKey in growthSlotKeys) {
      final List<String> dependsOn = _normalizeSlotKeys(openSlotMap[selectedKey]?.dependsOn);
      if (selectedKey != slotKey && dependsOn.contains(slotKey)) {
        return true;
      }
    }
    return false;
  }

  /// 当前增长槽补齐所需的前置依赖。
  List<String> _resolveSelectableDependsOn(String slotKey) {
    final Map<String, PatternBlueprintOpenSlotEntity?> openSlotMap = _openSlotMap;
    return _normalizeSlotKeys(openSlotMap[slotKey]?.dependsOn).where((key) {
      return !growthSlotKeys.contains(key) && pyramidGrowableSlotKeys.contains(key);
    }).toList();
  }

  /// 当前蓝图开放槽映射。
  Map<String, PatternBlueprintOpenSlotEntity?> get _openSlotMap {
    return <String, PatternBlueprintOpenSlotEntity?>{
      for (final PatternBlueprintOpenSlotEntity? slot in patternBlueprint?.openSlots ?? const <PatternBlueprintOpenSlotEntity?>[])
        if ((slot?.slotKey ?? '').trim().isNotEmpty) (slot!.slotKey!).trim(): slot,
    };
  }

  /// 按 growthPriority 排序增长槽，保持层级顺序稳定。
  List<String> _sortGrowthSlotKeys(Iterable<String> keys) {
    final List<String> resp = _normalizeSlotKeys(keys);
    final Map<String, int> priorityMap = <String, int>{
      for (final PatternBlueprintOpenSlotEntity? slot in patternBlueprint?.openSlots ?? const <PatternBlueprintOpenSlotEntity?>[])
        if ((slot?.slotKey ?? '').trim().isNotEmpty) (slot!.slotKey!).trim(): slot.growthPriority ?? 999,
    };
    resp.sort((a, b) => (priorityMap[a] ?? 999).compareTo(priorityMap[b] ?? 999));
    return resp;
  }

  /// 统一收口 slotKey 列表，过滤空值并去重。
  List<String> _normalizeSlotKeys(Iterable<dynamic>? keys) {
    final List<String> resp = <String>[];
    final Set<String> seen = <String>{};
    for (final dynamic raw in keys ?? const <dynamic>[]) {
      final String key = raw?.toString().trim() ?? '';
      if (key.isEmpty || seen.contains(key)) {
        continue;
      }
      seen.add(key);
      resp.add(key);
    }
    return resp;
  }

  /// 基句锁定后，合并接口 occupancy 和补查详情里的真实占槽。
  List<String> _resolveBaseOccupancySlotKeys({
    required Iterable<dynamic>? occupancy,
    required PatternBlueprintSentenceBriefEntity? sentence,
  }) {
    final List<String> resp = _normalizeSlotKeys(occupancy);
    final PatternBlueprintSentenceBriefEntity? effectiveSentence = sentence == null ? null : _resolveEffectiveSentenceStruct(sentence);
    final List<String> sentenceSlotKeys = ManageSentenceBlueprintAddGroupSlotMapHelper.collectOccupiedSlotKeys(
      patternBlueprint: patternBlueprint,
      sentences: <PatternBlueprintSentenceBriefEntity?>[effectiveSentence],
    );
    for (final String key in sentenceSlotKeys) {
      if (!resp.contains(key)) {
        resp.add(key);
      }
    }
    return resp;
  }

  /// 当前层位的展示标题。
  String _resolveGrowthTitle(String slotKey, int layerIndex) {
    for (final PatternBlueprintOpenSlotListItemEntity? item
        in patternBlueprint?.openSlotList ?? const <PatternBlueprintOpenSlotListItemEntity?>[]) {
      if (item?.slotKey != slotKey) {
        continue;
      }
      final String? slotName = LearningLangUtils.getLocalLang(item?.slot?.name)?.text;
      if (slotName?.isNotEmpty == true) {
        return "+ $slotName";
      }
    }
    return "+ 第 $layerIndex 层";
  }

  /// 取当前层位顶部展示用的样句，优先展示上一层已绑句，其次回退基句。
  ZhenxieSentenceMemberSentenceEntity? _resolveExampleSentence(String slotKey) {
    final int layerIndex = growthSlotKeys.indexOf(slotKey);
    if (layerIndex > 0) {
      final String previousKey = growthSlotKeys[layerIndex - 1];
      final PatternBlueprintSentenceBriefEntity? previousSentence = boundSentenceMap[previousKey];
      if (previousSentence != null) {
        return _buildSentenceStruct(previousSentence);
      }
    }
    return _buildSentenceStruct(baseSentence.value);
  }

  /// 将页面里沿用的句子摘要整理成样句组件统一使用的句子结构。
  ZhenxieSentenceMemberSentenceEntity? _buildSentenceStruct(PatternBlueprintSentenceBriefEntity? sentence) {
    if (sentence == null) {
      return null;
    }
    return ZhenxieSentenceMemberSentenceEntity(
      sentenceId: sentence.actualSentenceId ?? sentence.sentenceId,
      semanticId: sentence.semanticId,
      contentType: sentence.contentType,
      content: sentence.actualContent ?? sentence.content,
      definition: sentence.actualDefinition ?? sentence.definition,
      patternNid: sentence.actualPatternNid ?? sentence.patternNid,
      patternName: sentence.actualPatternName ?? sentence.patternName,
      patternTemplate: sentence.patternTemplate,
      blueprintScope: sentence.blueprintScope,
      segmentList: sentence.segmentList,
      access: sentence.actualAccess ?? sentence.access,
    );
  }

  @override
  void onClose() {
    pyramidBaseIdController.dispose();
    super.onClose();
  }
}
