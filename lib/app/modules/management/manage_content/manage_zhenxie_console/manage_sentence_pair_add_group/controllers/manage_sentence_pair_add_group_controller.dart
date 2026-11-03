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

class ManageSentencePairAddGroupController extends GetxController with ManageBreadcrumbMixin {
  /// 当前页面实例 tag。
  final String tag;

  ManageSentencePairAddGroupController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_SENTENCE_PAIR_ADD_GROUP;

  @override
  String get breadcrumbTitle => '添加一组';

  /// 页面入口传入的句间配链详情。
  SentencePairEntity? pairDetail;

  /// 单元 Target 入口传入的单元 id，只用于限制候选范围。
  int? unitId;

  /// 单元 Target 入口传入的 target id，用于创建接口参数。
  int? targetId;

  /// 单元 Target 入口传入的预填 from 句子 id。
  int? presetSentenceId;

  /// 固定两个格位：from / to。
  final List<String> cellKeyList = <String>['from', 'to'];

  /// 当前各格位已绑定的句子，key 为 from / to。
  final RxMap<String, PatternBlueprintSentenceBriefEntity> boundSentenceMap = <String, PatternBlueprintSentenceBriefEntity>{}.obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    final dynamic arguments = Get.arguments;
    if (arguments is! Map) {
      return;
    }

    final dynamic rawPairDetail = arguments['pairDetail'];
    if (rawPairDetail is SentencePairEntity) {
      pairDetail = rawPairDetail;
    }
    targetId = arguments['targetId'];
    unitId = arguments['unitId'];
    presetSentenceId = _parsePresetSentenceId(arguments['presetSentenceId']);
    initData();
  }

  /// 首次进入页面时重置本地草稿态。
  Future<void> initData() async {
    boundSentenceMap.clear();
    if (presetSentenceId == null) {
      return;
    }
    final PatternBlueprintSentenceBriefEntity presetSentence = await _queryPresetSentence();
    if (isClosed) {
      return;
    }
    boundSentenceMap['from'] = presetSentence;
  }

  /// 当前卡片列表展示态。
  List<ManageSentenceAddBindingCardModel> buildBindingCardList() {
    return List<ManageSentenceAddBindingCardModel>.generate(cellKeyList.length, (int index) {
      final String cellKey = cellKeyList[index];
      return ManageSentenceAddBindingCardModel(
        index: index,
        title: _resolveCellPatternName(cellKey),
        cellKey: cellKey,
        sentence: boundSentenceMap[cellKey],
        exampleSentence: _buildExampleSentence(cellKey),
      );
    });
  }

  /// 当前已绑定句数。
  int get bindCount => _activeBoundSentenceIds.length;

  /// 当前总格位数。
  int get totalCount => cellKeyList.length;

  /// 当前是否已经绑上 from 句位。
  bool get hasBoundFromSentence => boundSentenceMap['from']?.sentenceId != null;

  /// 当前 from 是否来自入口预填，预填后不允许改动。
  bool get fromPinned => presetSentenceId != null;

  /// 是否允许执行补句落库。
  bool get isAddSentenceEnabled => hasBoundFromSentence;

  /// 是否允许执行满句落库。
  bool get isFullSentenceEnabled => bindCount == totalCount;

  /// 打开候选句弹窗，并在用户选中后写回当前格位。
  Future<void> pickSentence(BuildContext context, String cellKey) async {
    final String? nid = pairDetail?.nid;
    if (nid == null || nid.isEmpty) {
      ToastUtils.showToast(text: '当前配链缺少 nid');
      return;
    }
    if (!cellKeyList.contains(cellKey)) {
      return;
    }
    if (fromPinned && cellKey == 'from') {
      ToastUtils.showToast(text: '上一句已选定');
      return;
    }

    final PatternBlueprintSentenceBriefEntity? selected = await ManageSentenceAddSelectDialog.show(
      context: context,
      model: ManageSentenceAddSelectDialogModel(
        pageType: ZhenxieEnSentenceType.EN_SENTENCE_PATTERN_PAIR,
        title: cellKey == 'from' ? '前句' : '后句',
        nid: nid,
        baseSlotKeys: const <String>[],
        dialSlotKeys: const <String>[],
        boundSentenceIds: _activeBoundSentenceIdsExcluding(cellKey),
        unitId: unitId,
        patternName: _resolveCellPatternName(cellKey),
        exampleSentence: _buildExampleSentence(cellKey),
        pairCellKey: cellKey,
      ),
    );
    if (selected == null) {
      return;
    }

    boundSentenceMap[cellKey] = selected;
  }

  /// 手动输入 uid，并校验当前句子是否能绑到当前格位。
  Future<void> manualInputUid(BuildContext context, String cellKey) async {
    final String? nid = pairDetail?.nid;
    if (nid == null || nid.isEmpty) {
      ToastUtils.showToast(text: '当前配链缺少 nid');
      return;
    }
    if (!cellKeyList.contains(cellKey)) {
      return;
    }
    if (fromPinned && cellKey == 'from') {
      ToastUtils.showToast(text: '上一句已选定');
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
      response = await LanguageConsoleRequest.checkPatternRealizationSetPairBind(
        nid: nid,
        data: <String, dynamic>{
          "cell": cellKey,
          "sentenceId": sentenceId,
        },
      );
    } finally {
      ToastUtils.hideLoading();
    }
    if (response == null) return;

    if (response.ok != true) {
      ToastUtils.showToast(text: response.reason ?? '这句不能绑到当前格位');
      return;
    }

    boundSentenceMap[cellKey] = PatternBlueprintSentenceBriefEntity(
      sentenceId: response.sentenceId ?? sentenceId,
      content: response.text?.isNotEmpty == true ? response.text : "句子 $sentenceId",
      access: "INTERNAL",
    );
  }

  /// 提交“补句落库”，允许只带部分人工钉句。
  Future<void> addSentence() async {
    if (!isAddSentenceEnabled) {
      _showSubmitHint(requireFull: false);
      return;
    }
    await _submitPairSet(matchFirst: false);
  }

  /// 提交“满句落库”，要求两个格位都已经绑满。
  Future<void> fullSentence() async {
    if (!isFullSentenceEnabled) {
      _showSubmitHint(requireFull: true);
      return;
    }
    await _submitPairSet(matchFirst: true);
  }

  /// 当前启用格位里已经绑定的 sentenceId。
  List<int> get _activeBoundSentenceIds {
    final List<int> resp = <int>[];
    for (final String cellKey in cellKeyList) {
      final int? sentenceId = boundSentenceMap[cellKey]?.sentenceId;
      if (sentenceId != null) {
        resp.add(sentenceId);
      }
    }
    return resp;
  }

  /// 执行 Pair add-set 提交流程。
  Future<void> _submitPairSet({required bool matchFirst}) async {
    final String? nid = pairDetail?.nid;
    if (nid == null || nid.isEmpty) {
      ToastUtils.showToast(text: '当前配链缺少 nid');
      return;
    }

    final int? fromSentenceId = boundSentenceMap['from']?.sentenceId;
    final int? toSentenceId = boundSentenceMap['to']?.sentenceId;
    if (fromSentenceId == null && toSentenceId == null) {
      ToastUtils.showToast(text: '至少先绑 1 句，再补句落库');
      return;
    }

    ToastUtils.showLoading();
    try {
      final PatternRealizationSetPatternMatchCheckEntity? matchResp = await LanguageConsoleRequest.checkPatternRealizationSetPairMatch(
        nid: nid,
        data: <String, dynamic>{
          "fromSentenceId": fromSentenceId,
          "toSentenceId": toSentenceId,
        },
      );
      if (matchResp?.ok != true) {
        final String failureText = (matchResp?.failures ?? const <PatternRealizationSetPatternMatchFailureEntity>[])
            .map((item) => item.code ?? '')
            .where((item) => item.isNotEmpty)
            .join('、');
        ToastUtils.showToast(text: failureText.isNotEmpty ? failureText : '当前盘面未通过整组门禁');
        return;
      }

      final Map<String, dynamic> createReqData = <String, dynamic>{
        "fromSentenceId": fromSentenceId,
        "toSentenceId": toSentenceId,
        "matchFirst": matchFirst,
      };
      final Map<String, dynamic> parameter = <String, dynamic>{};
      if (unitId != null) {
        parameter['unitId'] = unitId;
      }
      if (targetId != null) {
        parameter['targetId'] = targetId;
      }

      final bool createResp = await LanguageConsoleRequest.createPatternRealizationSetPair(
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
    ToastUtils.showToast(text: requireFull ? '先把两个格位都绑满，再满句落库' : '先绑这一端，再补句落库');
  }

  /// 生成当前格位顶部展示用的样句。
  PatternBlueprintSentenceBriefEntity _buildExampleSentence(String cellKey) {
    final SentencePairSentenceRealizationEntity? exampleSet = _resolveExampleSet();
    final SentencePairSentenceBriefEntity? sentenceBrief =
        cellKey == 'from' ? exampleSet?.fromSentenceStruct : exampleSet?.toSentenceStruct;
    if (sentenceBrief != null) {
      return _convertPairSentenceBrief(sentenceBrief);
    }

    return PatternBlueprintSentenceBriefEntity(
      content: cellKey == 'from' ? pairDetail?.teachingExampleFrom : pairDetail?.teachingExampleTo,
      patternNid: cellKey == 'from' ? pairDetail?.fromRealization?.patternNid : pairDetail?.toRealization?.patternNid,
      patternTemplate: cellKey == 'from' ? pairDetail?.fromRealization?.pattern?.template : pairDetail?.toRealization?.pattern?.template,
    );
  }

  /// 解析入口透传的预填 from 句子 id。
  int? _parsePresetSentenceId(dynamic rawValue) {
    final int? sentenceId = rawValue is int ? rawValue : int.tryParse("$rawValue");
    if (sentenceId == null || sentenceId <= 0) {
      return null;
    }
    return sentenceId;
  }

  /// 查询预填 from 句子的结构化摘要，确保页面首屏可直接回显。
  Future<PatternBlueprintSentenceBriefEntity> _queryPresetSentence() async {
    final int sentenceId = presetSentenceId!;
    ToastUtils.showLoading();
    try {
      final Map<String, dynamic> reqData = <String, dynamic>{
        "contents": <Map<String, dynamic>>[
          <String, dynamic>{
            "type": "EN_SENTENCE",
            "uid": sentenceId,
          }
        ],
      };
      final PatternBlueprintEntity? sentenceStruct = await LanguageConsoleRequest.querySentenceStructure(data: reqData);
      final PatternBlueprintSentenceBriefEntity? matchedSentence = _matchPresetSentenceStruct(
        sentenceRealizations: sentenceStruct?.sentenceRealizationList ?? const <PatternBlueprintSentenceBriefEntity?>[],
        sentenceId: sentenceId,
      );
      if (matchedSentence != null) {
        return matchedSentence;
      }
      ToastUtils.showToast(text: '预填上一句未取到完整结构，先按 uid 回显');
      return PatternBlueprintSentenceBriefEntity(
        sentenceId: sentenceId,
        content: "句子 $sentenceId",
        contentType: "EN_SENTENCE",
        access: "INTERNAL",
      );
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 从结构接口返回的 realization 列表里按 sentenceId 找回预填句。
  PatternBlueprintSentenceBriefEntity? _matchPresetSentenceStruct({
    required List<PatternBlueprintSentenceBriefEntity?> sentenceRealizations,
    required int sentenceId,
  }) {
    for (final PatternBlueprintSentenceBriefEntity? item in sentenceRealizations) {
      if (item == null) {
        continue;
      }
      if (item.sentenceId == sentenceId) {
        return item;
      }
    }
    return null;
  }

  /// 当前格位对应的句型名称。
  String _resolveCellPatternName(String cellKey) {
    final String prefix = cellKey == 'from' ? '上一句' : '下一句';
    final List<LanguageText?>? nameList =
        cellKey == 'from' ? pairDetail?.fromRealization?.pattern?.name : pairDetail?.toRealization?.pattern?.name;
    final String? patternName = LearningLangUtils.getLocalLang(nameList)?.text;
    if (patternName == null || patternName.isEmpty) {
      return prefix;
    }
    return '$prefix: $patternName';
  }

  /// 返回排除当前格位后的已绑定 sentenceId 列表。
  List<int> _activeBoundSentenceIdsExcluding(String currentCellKey) {
    final List<int> resp = <int>[];
    for (final String cellKey in cellKeyList) {
      if (cellKey == currentCellKey) {
        continue;
      }
      final int? sentenceId = boundSentenceMap[cellKey]?.sentenceId;
      if (sentenceId != null) {
        resp.add(sentenceId);
      }
    }
    return resp;
  }

  /// 从已有句对子里取一个顶部默认样句来源。
  SentencePairSentenceRealizationEntity? _resolveExampleSet() {
    final List<SentencePairSentenceRealizationEntity> setList =
        (pairDetail?.realizationSetList ?? const <SentencePairSentenceRealizationEntity?>[])
            .whereType<SentencePairSentenceRealizationEntity>()
            .toList();
    if (setList.isEmpty) {
      return null;
    }
    setList.sort((a, b) => (b.order ?? 0).compareTo(a.order ?? 0));
    return setList.first;
  }

  /// 把 pair 句子摘要转成公共添加组件复用的句子摘要实体。
  PatternBlueprintSentenceBriefEntity _convertPairSentenceBrief(SentencePairSentenceBriefEntity sentenceBrief) {
    return PatternBlueprintSentenceBriefEntity(
      sentenceId: sentenceBrief.sentenceId,
      content: sentenceBrief.content,
      definition: sentenceBrief.definition,
      patternNid: sentenceBrief.patternNid,
      patternTemplate: sentenceBrief.patternTemplate,
      blueprintScope: sentenceBrief.blueprintScope,
      order: sentenceBrief.order,
      access: sentenceBrief.access,
    );
  }
}
