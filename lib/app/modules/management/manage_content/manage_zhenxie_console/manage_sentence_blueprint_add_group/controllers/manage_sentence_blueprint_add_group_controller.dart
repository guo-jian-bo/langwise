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
import '../views/manage_sentence_blueprint_add_group_slot_map_widget.dart';

class ManageSentenceBlueprintAddGroupController extends GetxController with ManageBreadcrumbMixin {
  /// 当前页面实例 tag。
  final String tag;

  ManageSentenceBlueprintAddGroupController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_SENTENCE_BLUEPRINT_ADD_GROUP;

  @override
  String get breadcrumbTitle => '添加一组';

  /// 页面入口传入的句型蓝图。
  PatternBlueprintEntity? patternBlueprint;

  /// 单元 Target 入口传入的 Target 详情。
  ManageUnitGrammarTargetDetailEntity? target;

  /// 单元 Target 入口传入的单元 id，只用于候选句接口。
  int? unitId;

  /// 上级页面预先勾好的句子，按传入顺序默认回填到句位。
  List<PatternBlueprintSentenceBriefEntity> presetSentences = const [];

  /// 预设句实际占用到的骨架槽，多句按并集汇总。
  List<String> presetOccupiedSlotKeys = const [];

  /// 当前页面对应的 Target 形态锁数据。
  ManageSentenceBlueprintAddGroupShapeLockData shapeLockData = const ManageSentenceBlueprintAddGroupShapeLockData();

  /// 当前已纳入形态的可选开放槽。
  final RxList<String> optionalBaseSlotKeys = <String>[].obs;

  /// 当前要拧的槽。
  final RxList<String> dialSlotKeys = <String>[].obs;

  /// 当前各句位已绑定的句子，key 为句位下标。
  final RxMap<int, PatternBlueprintSentenceBriefEntity> boundSentenceMap = <int, PatternBlueprintSentenceBriefEntity>{}.obs;

  /// 要钉几句输入框控制器。
  final TextEditingController sentenceNumberController = TextEditingController(text: "2");

  /// 当前目标句数，直接驱动绑句列表刷新。
  final RxInt sentenceCountValue = 2.obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    if (Get.arguments == null) {
      return;
    }

    patternBlueprint = Get.arguments["patternBlueprint"];
    target = Get.arguments["target"];
    unitId = Get.arguments["unitId"];
    presetSentences = _parsePresetSentenceList(Get.arguments["presetSentences"]);
    presetOccupiedSlotKeys = ManageSentenceBlueprintAddGroupSlotMapHelper.collectOccupiedSlotKeys(
      patternBlueprint: patternBlueprint,
      sentences: presetSentences,
    );
    initData();
  }

  /// 首次进入页面时重置本地草稿态。
  Future<void> initData() async {
    optionalBaseSlotKeys.clear();
    dialSlotKeys.clear();
    boundSentenceMap.clear();
    shapeLockData = ManageSentenceBlueprintAddGroupSlotMapHelper.buildShapeLockData(
      patternBlueprint: patternBlueprint,
      target: target,
    );
    optionalBaseSlotKeys.assignAll(
      ManageSentenceBlueprintAddGroupSlotMapHelper.mergePresetOccupiedOptionalSlotKeys(
        patternBlueprint: patternBlueprint,
        selectedOptionalSlotKeys: shapeLockData.activatedOptionalSlotKeys,
        occupiedSlotKeys: presetOccupiedSlotKeys,
      ),
    );
    if (presetSentences.isNotEmpty) {
      final List<String> baseSlotKeys = ManageSentenceBlueprintAddGroupSlotMapHelper.getBaseSlotKeys(
        patternBlueprint: patternBlueprint,
        optionalBaseSlotKeys: optionalBaseSlotKeys,
        shapeLockData: shapeLockData,
      );
      final int presetCount = presetSentences.length < 2 ? 2 : (presetSentences.length > 8 ? 8 : presetSentences.length);
      sentenceNumberController.text = "$presetCount";
      sentenceCountValue.value = presetCount;
      dialSlotKeys.assignAll(baseSlotKeys);
      for (int index = 0; index < presetCount && index < presetSentences.length; index++) {
        boundSentenceMap[index] = presetSentences[index];
      }
      return;
    }
    sentenceNumberController.text = "2";
    sentenceCountValue.value = 2;
  }

  /// 当前 shape 是否已经锁定完成，可以开始绑句。
  bool isShapeLocked() {
    final List<String> baseSlotKeys = ManageSentenceBlueprintAddGroupSlotMapHelper.getBaseSlotKeys(
      patternBlueprint: patternBlueprint,
      optionalBaseSlotKeys: optionalBaseSlotKeys,
      shapeLockData: shapeLockData,
    );
    return baseSlotKeys.isNotEmpty && dialSlotKeys.isNotEmpty && sentenceCountValue.value >= 2;
  }

  /// 当前列表卡片的页面态。
  List<ManageSentenceAddBindingCardModel> buildBindingCardList() {
    if (!isShapeLocked()) {
      return const [];
    }
    return List<ManageSentenceAddBindingCardModel>.generate(sentenceCountValue.value, (index) {
      return ManageSentenceAddBindingCardModel(
        index: index,
        title: "第 ${index + 1} 句",
        sentence: boundSentenceMap[index],
        highlightSlotKeys: dialSlotKeys.toList(),
        patternBlueprint: patternBlueprint,
      );
    });
  }

  /// 要钉几句输入框改变事件。
  Future<void> onSentenceNumberChanged([String? value]) async {
    final int? nextCount = int.tryParse(value ?? sentenceNumberController.text);
    if (nextCount == null || nextCount == sentenceCountValue.value) {
      return;
    }
    sentenceCountValue.value = nextCount;
    final int maxIndex = sentenceCountValue.value - 1;
    boundSentenceMap.removeWhere((key, value) => key > maxIndex);
  }

  /// 句型骨架中槽点击事件：
  /// 未纳入 -> 纳入；已纳入未拧 -> 标成要拧；已拧 -> 取消并尝试移出可选槽。
  void onPatternSlotTap(SentenceSlotMapItemEntity item) {
    final PatternBlueprintEntity? pattern = patternBlueprint;
    if (pattern == null || item.isLiteral || item.unused) {
      return;
    }

    final String key = item.slotKey;
    final List<String> baseSlotKeys = ManageSentenceBlueprintAddGroupSlotMapHelper.getBaseSlotKeys(
      patternBlueprint: patternBlueprint,
      optionalBaseSlotKeys: optionalBaseSlotKeys,
      shapeLockData: shapeLockData,
    );
    final List<String> optionalOpenSlotKeys = ManageSentenceBlueprintAddGroupSlotMapHelper.getOptionalOpenSlotKeys(
      patternBlueprint,
      shapeLockData: shapeLockData,
    );
    final bool canSelectByPresetOccupancy = presetOccupiedSlotKeys.contains(key);
    final bool inForm = baseSlotKeys.contains(key);
    final bool isDial = dialSlotKeys.contains(key);
    if (!inForm) {
      if (!optionalOpenSlotKeys.contains(key) && !canSelectByPresetOccupancy) {
        return;
      }
      optionalBaseSlotKeys.assignAll(
        ManageSentenceBlueprintAddGroupSlotMapHelper.addOptionalWithDeps(
          pattern: pattern,
          selected: optionalBaseSlotKeys,
          key: key,
        ),
      );
      return;
    }

    if (!isDial) {
      if (!dialSlotKeys.contains(key)) {
        dialSlotKeys.add(key);
      }
      return;
    }

    dialSlotKeys.remove(key);
    final List<String> lockedFormSlotKeys = ManageSentenceBlueprintAddGroupSlotMapHelper.getLockedFormSlotKeys(pattern);
    if (lockedFormSlotKeys.contains(key) || shapeLockData.activatedOptionalSlotKeys.contains(key)) {
      return;
    }

    final List<String> nextOptional = ManageSentenceBlueprintAddGroupSlotMapHelper.removeOptionalWithDependents(
      pattern: pattern,
      selected: optionalBaseSlotKeys,
      key: key,
      protectedKeys: shapeLockData.activatedOptionalSlotKeys,
    );
    optionalBaseSlotKeys.assignAll(nextOptional);
    final Set<String> nextForm = {
      ...lockedFormSlotKeys,
      ...shapeLockData.activatedOptionalSlotKeys,
      ...nextOptional,
    };
    dialSlotKeys.removeWhere((item) => !nextForm.contains(item));
  }

  /// 打开候选句弹窗，并在用户选中后写回当前句位。
  Future<void> pickSentence(BuildContext context, int index) async {
    if (!isShapeLocked()) {
      ToastUtils.showToast(text: '先选好形态和要拧的槽，再开始绑句');
      return;
    }

    final PatternBlueprintEntity? pattern = patternBlueprint;
    final String? nid = pattern?.nid;
    if (nid == null || nid.isEmpty) {
      ToastUtils.showToast(text: '当前蓝图缺少 nid');
      return;
    }

    final PatternBlueprintSentenceBriefEntity? selected = await ManageSentenceAddSelectDialog.show(
      context: context,
      model: ManageSentenceAddSelectDialogModel(
        pageType: ZhenxieEnSentenceType.EN_SENTENCE_PATTERN,
        title: "第 ${index + 1} 句",
        nid: nid,
        baseSlotKeys: ManageSentenceBlueprintAddGroupSlotMapHelper.getBaseSlotKeys(
          patternBlueprint: patternBlueprint,
          optionalBaseSlotKeys: optionalBaseSlotKeys,
          shapeLockData: shapeLockData,
        ),
        dialSlotKeys: dialSlotKeys.toList(),
        boundSentenceIds: _activeBoundSentenceIds,
        unitId: unitId,
        patternName: LearningLangUtils.getLocalLang(pattern?.name)?.text,
        exampleSentence: _resolveExampleSentence(index),
      ),
    );
    if (selected == null) {
      return;
    }
    await _bindSentenceWithStructure(index: index, sentence: selected);
  }

  /// 手动输入 uid，并调用 bind-check 校验当前句位是否能绑定。
  Future<void> manualInputUid(BuildContext context, int index) async {
    if (!isShapeLocked()) {
      ToastUtils.showToast(text: '先选好形态和要拧的槽，再开始绑句');
      return;
    }

    final PatternBlueprintEntity? pattern = patternBlueprint;
    final String? nid = pattern?.nid;
    if (nid == null || nid.isEmpty) {
      ToastUtils.showToast(text: '当前蓝图缺少 nid');
      return;
    }

    final String? raw = await InputDialog.show(
      context: context,
      title: "句子 uid",
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
      Map<String, dynamic> reqData = {
        "sentenceId": sentenceId,
        "baseSlotKeys": ManageSentenceBlueprintAddGroupSlotMapHelper.getBaseSlotKeys(
          patternBlueprint: patternBlueprint,
          optionalBaseSlotKeys: optionalBaseSlotKeys,
          shapeLockData: shapeLockData,
        ),
        "boundSentenceIds": _activeBoundSentenceIds.where((item) => item != (boundSentenceMap[index]?.sentenceId ?? -1)).toList(),
      };
      response = await LanguageConsoleRequest.checkPatternRealizationSetPatternBind(
        nid: nid,
        data: reqData,
      );
    } finally {
      ToastUtils.hideLoading();
    }
    if (response == null) return;

    if (response.ok != true) {
      ToastUtils.showToast(text: response.reason ?? '这句不能绑到当前格位');
      return;
    }

    final PatternBlueprintSentenceBriefEntity boundSentence = response.sentenceStruct ??
        PatternBlueprintSentenceBriefEntity(
          sentenceId: response.sentenceId ?? sentenceId,
          content: response.text?.isNotEmpty == true ? response.text : "句子 $sentenceId",
          contentType: response.contentType,
          access: "INTERNAL",
        );
    await _bindSentenceWithStructure(index: index, sentence: boundSentence);
  }

  /// 提交“补句落库”，允许只带部分人工钉句。
  Future<void> addSentence() async {
    final int bindCount = isShapeLocked() ? _activeBoundSentenceIds.length : 0;
    final int totalCount = isShapeLocked() ? sentenceCountValue.value : 0;
    if (!isShapeLocked() || bindCount <= 0 || totalCount <= 0 || bindCount >= totalCount || totalCount > 4) {
      _showAddSentenceDisabledHint();
      return;
    }
    await _submitPatternSet(requireFull: false);
  }

  /// 提交“满句落库”，要求所有句位都已经绑满。
  Future<void> fullSentence() async {
    final int bindCount = isShapeLocked() ? _activeBoundSentenceIds.length : 0;
    final int totalCount = isShapeLocked() ? sentenceCountValue.value : 0;
    if (!isShapeLocked() || totalCount <= 0 || bindCount != totalCount) {
      _showSubmitHint(requireFull: true);
      return;
    }
    await _submitPatternSet(requireFull: true);
  }

  /// 当前启用句位里已经绑定的 sentenceId，按句位顺序输出。
  List<int> get _activeBoundSentenceIds {
    final List<int> resp = [];
    for (int index = 0; index < sentenceCountValue.value; index++) {
      final int? sentenceId = boundSentenceMap[index]?.sentenceId;
      if (sentenceId != null) {
        resp.add(sentenceId);
      }
    }
    return resp;
  }

  /// 取一个顶部样句提示，优先复用其他已绑定句。
  ZhenxieSentenceMemberSentenceEntity? _resolveExampleSentence(int currentIndex) {
    for (int index = 0; index < sentenceCountValue.value; index++) {
      if (index == currentIndex) continue;
      final PatternBlueprintSentenceBriefEntity? sentence = boundSentenceMap[index];
      if (sentence != null) {
        return _buildExampleSentenceStruct(sentence);
      }
    }
    return _buildExampleSentenceStruct(boundSentenceMap[currentIndex]);
  }

  /// 将蓝图页沿用的句子摘要整理成样句组件统一使用的句子结构。
  ZhenxieSentenceMemberSentenceEntity? _buildExampleSentenceStruct(PatternBlueprintSentenceBriefEntity? sentence) {
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

  /// 补句按钮灰态点击时，按当前盘面给出更具体的原因。
  void onAddSentenceDisabledTap() {
    _showAddSentenceDisabledHint();
  }

  /// 解析入口透传的预设句列表，过滤空对象并保持原始顺序。
  List<PatternBlueprintSentenceBriefEntity> _parsePresetSentenceList(dynamic rawList) {
    if (rawList is! List) {
      return const [];
    }
    final List<PatternBlueprintSentenceBriefEntity> resp = [];
    for (final dynamic item in rawList) {
      if (item is PatternBlueprintSentenceBriefEntity) {
        resp.add(item);
        continue;
      }
      if (item is Map) {
        resp.add(PatternBlueprintSentenceBriefEntity.fromJson(Map<String, dynamic>.from(item)));
      }
    }
    if (resp.length <= 8) {
      return resp;
    }
    return resp.sublist(0, 8);
  }

  /// 先回填当前句位，再补查完整结构，保证已绑句能拿到 segmentList 做高亮。
  Future<void> _bindSentenceWithStructure({
    required int index,
    required PatternBlueprintSentenceBriefEntity sentence,
  }) async {
    boundSentenceMap[index] = sentence;
    final PatternBlueprintSentenceBriefEntity nextSentence = await _fetchSentenceStructForBinding(sentence);
    if (isClosed) {
      return;
    }
    boundSentenceMap[index] = nextSentence;
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

  /// 用结构接口返回的 segment 等字段补全当前句子，同时保留原句已有的展示字段。
  PatternBlueprintSentenceBriefEntity _mergeSentenceStruct({
    required PatternBlueprintSentenceBriefEntity base,
    required PatternBlueprintSentenceBriefEntity struct,
  }) {
    return PatternBlueprintSentenceBriefEntity(
      sentenceId: struct.sentenceId ?? base.sentenceId,
      semanticId: struct.semanticId ?? base.semanticId,
      content: struct.content ?? base.content,
      definition: struct.definition ?? base.definition,
      contentType: struct.contentType ?? base.contentType,
      patternNid: struct.patternNid ?? base.patternNid,
      patternTemplate: struct.patternTemplate ?? base.patternTemplate,
      blueprintScope: struct.blueprintScope ?? base.blueprintScope,
      segmentList: struct.segmentList ?? base.segmentList,
      order: struct.order ?? base.order,
      realizationSetId: struct.realizationSetId ?? base.realizationSetId,
      access: struct.access ?? base.access,
    );
  }

  /// 执行 Pattern add-set 提交流程。
  Future<void> _submitPatternSet({required bool requireFull}) async {
    final PatternBlueprintEntity? pattern = patternBlueprint;
    final String? nid = pattern?.nid;
    if (nid == null || nid.isEmpty) {
      ToastUtils.showToast(text: '当前蓝图缺少 nid');
      return;
    }

    ToastUtils.showLoading();
    try {
      final List<int> sentenceIds = _activeBoundSentenceIds;
      Map<String, dynamic> reqData = {
        "sentenceIds": sentenceIds,
        "baseSlotKeys": ManageSentenceBlueprintAddGroupSlotMapHelper.getBaseSlotKeys(
          patternBlueprint: patternBlueprint,
          optionalBaseSlotKeys: optionalBaseSlotKeys,
          shapeLockData: shapeLockData,
        ),
        "dialSlotKeys": dialSlotKeys,
      };
      final PatternRealizationSetPatternMatchCheckEntity? matchResp = await LanguageConsoleRequest.checkPatternRealizationSetPatternMatch(
        nid: nid,
        data: reqData,
      );
      if (matchResp?.ok != true) {
        final String failureText =
            (matchResp?.failures ?? const []).map((item) => item.code ?? '').where((item) => item.isNotEmpty).join('、');
        ToastUtils.showToast(text: failureText.isNotEmpty ? failureText : '当前盘面未通过整组门禁');
        return;
      }

      final Map<String, dynamic> createReqData = {
        "sentenceIds": sentenceIds,
        "baseSlotKeys": ManageSentenceBlueprintAddGroupSlotMapHelper.getBaseSlotKeys(
          patternBlueprint: patternBlueprint,
          optionalBaseSlotKeys: optionalBaseSlotKeys,
          shapeLockData: shapeLockData,
        ),
        "dialSlotKeys": dialSlotKeys,
        "match_first": true,
      };
      if (!requireFull) {
        createReqData["fillCount"] = sentenceCountValue.value > 4 ? 4 : sentenceCountValue.value;
      }
      final Map<String, dynamic> parameter = {};

      if (unitId != null) {
        parameter['unitId'] = unitId;
      }
      if (target?.uid != null) {
        parameter['targetId'] = target?.uid;
      }

      final bool createResp = await LanguageConsoleRequest.createPatternRealizationSetPattern(
        nid: nid,
        data: createReqData,
        parameter: parameter,
      );
      if (!createResp) {
        return;
      }

      ToastUtils.showToast(
        text: '已发起创建任务',
        type: ToastType.success,
      );
      Get.back(result: true);
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 根据提交目标给出统一提示。
  void _showSubmitHint({required bool requireFull}) {
    if (!isShapeLocked()) {
      ToastUtils.showToast(text: '先把形态和要拧的槽锁好');
      return;
    }
    ToastUtils.showToast(text: requireFull ? '先把所有句位都绑满，再满句落库' : '至少先绑 1 句，再补句落库');
  }

  /// 按补句文档约束提示当前为什么不能走补句落库。
  void _showAddSentenceDisabledHint() {
    if (!isShapeLocked()) {
      ToastUtils.showToast(text: '先把形态和要拧的槽锁好');
      return;
    }
    final int bindCount = _activeBoundSentenceIds.length;
    if (bindCount <= 0) {
      ToastUtils.showToast(text: '至少先绑 1 句，再补句落库');
      return;
    }
    if (sentenceCountValue.value > 4) {
      ToastUtils.showToast(text: '补句落库最多只支持补到 4 句');
      return;
    }
    if (bindCount >= sentenceCountValue.value) {
      ToastUtils.showToast(text: '当前句位已绑满，请使用满句落库');
      return;
    }
    ToastUtils.showToast(text: '当前盘面暂时不能补句落库');
  }

  @override
  void onClose() {
    sentenceNumberController.dispose();
    super.onClose();
  }
}
