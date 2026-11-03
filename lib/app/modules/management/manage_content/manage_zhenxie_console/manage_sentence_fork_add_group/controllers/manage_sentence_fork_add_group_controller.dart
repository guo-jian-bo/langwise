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

class ManageSentenceForkAddGroupController extends GetxController with ManageBreadcrumbMixin {
  /// 当前页面实例 tag。
  final String tag;

  ManageSentenceForkAddGroupController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_SENTENCE_FORK_ADD_GROUP;

  @override
  String get breadcrumbTitle => '添加一组';

  /// 页面入口传入的句间配链分叉详情。
  SentenceForkEntity? forkDetail;

  /// 单元 Target 入口传入的单元 id，只用于限制候选范围。
  int? unitId;

  /// 单元 Target 入口传入的 target id，用于创建接口参数。
  int? targetId;

  /// 单元 Target 入口传入的预填 from 句子 id。
  int? presetSentenceId;

  /// 当前分叉成员列表，对应多个 to 分支。
  final RxList<SentenceForkMemberEntity> memberList = <SentenceForkMemberEntity>[].obs;

  /// 当前各格位已绑定的句子，key 为 from 或 to:valueNid。
  final RxMap<String, PatternBlueprintSentenceBriefEntity> boundSentenceMap = <String, PatternBlueprintSentenceBriefEntity>{}.obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    final dynamic arguments = Get.arguments;
    if (arguments is! Map) {
      return;
    }

    final dynamic rawForkDetail = arguments['forkDetail'];
    if (rawForkDetail is SentenceForkEntity) {
      forkDetail = rawForkDetail;
    }
    targetId = arguments['targetId'];
    unitId = arguments['unitId'];
    presetSentenceId = _parsePresetSentenceId(arguments['presetSentenceId']);
    initData();
  }

  /// 首次进入页面时重置本地草稿态。
  Future<void> initData() async {
    boundSentenceMap.clear();
    memberList.assignAll(
      (forkDetail?.members ?? const <SentenceForkMemberEntity?>[])
          .whereType<SentenceForkMemberEntity>()
          .where((item) => item.valueNid?.isNotEmpty == true)
          .toList(),
    );
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
    final List<ManageSentenceAddBindingCardModel> resp = <ManageSentenceAddBindingCardModel>[
      ManageSentenceAddBindingCardModel(
        index: 0,
        title: _resolvePatternName(cellKey: 'from'),
        cellKey: 'from',
        valueNid: _resolveFromCellValueNid(),
        sentence: boundSentenceMap['from'],
        exampleSentence: _buildFromExampleSentence(),
      ),
    ];

    for (int index = 0; index < memberList.length; index++) {
      final SentenceForkMemberEntity member = memberList[index];
      final String cellStorageKey = _buildToStorageKey(member.valueNid);
      resp.add(
        ManageSentenceAddBindingCardModel(
          index: index + 1,
          title: _resolvePatternName(cellKey: 'to', valueNid: member.valueNid),
          cellKey: 'to',
          valueNid: member.valueNid,
          sentence: boundSentenceMap[cellStorageKey],
          exampleSentence: _buildToExampleSentence(member),
        ),
      );
    }
    return resp;
  }

  /// 当前已绑定句数。
  int get bindCount => _activeBoundSentenceIds.length;

  /// 当前总格位数。
  int get totalCount => memberList.length + 1;

  /// 当前是否已经绑上共用端 from。
  bool get hasBoundFromSentence => _resolveFromSentenceId() != null;

  /// 当前 from 是否来自入口预填，预填后不允许改动。
  bool get fromPinned => presetSentenceId != null;

  /// 是否允许执行补句落库。
  bool get isAddSentenceEnabled => hasBoundFromSentence;

  /// 是否允许执行满句落库。
  bool get isFullSentenceEnabled => _resolveFromSentenceId() != null && _buildToBindings().length == memberList.length;

  /// 打开候选句弹窗，并在用户选中后写回当前格位。
  Future<void> pickSentence(
    BuildContext context, {
    required String cellKey,
    String? valueNid,
  }) async {
    final String? nid = forkDetail?.nid;
    if (nid == null || nid.isEmpty) {
      ToastUtils.showToast(text: '当前分叉缺少 nid');
      return;
    }

    final String resolvedValueNid = _resolveRequestValueNid(cellKey: cellKey, valueNid: valueNid);
    if (resolvedValueNid.isEmpty) {
      ToastUtils.showToast(text: '当前格位缺少 valueNid');
      return;
    }
    if (fromPinned && cellKey == 'from') {
      ToastUtils.showToast(text: '上一句已选定');
      return;
    }

    final PatternBlueprintSentenceBriefEntity? selected = await ManageSentenceAddSelectDialog.show(
      context: context,
      model: ManageSentenceAddSelectDialogModel(
        pageType: ZhenxieEnSentenceType.EN_SENTENCE_PATTERN_PAIR_FORK,
        title: _resolveDialogTitle(cellKey: cellKey, valueNid: valueNid),
        nid: nid,
        baseSlotKeys: const <String>[],
        dialSlotKeys: const <String>[],
        boundSentenceIds: _activeBoundSentenceIdsExcluding(cellKey: cellKey, valueNid: valueNid),
        unitId: unitId,
        patternName: _resolvePatternName(cellKey: cellKey, valueNid: valueNid),
        exampleSentence: cellKey == 'from' ? _buildFromExampleSentence() : _buildToExampleSentence(_findMember(valueNid)),
        valueNid: resolvedValueNid,
        pairCellKey: cellKey,
      ),
    );
    if (selected == null) {
      return;
    }

    boundSentenceMap[_buildStorageKey(cellKey: cellKey, valueNid: valueNid)] = selected;
  }

  /// 手动输入 uid，并校验当前句子是否能绑到当前格位。
  Future<void> manualInputUid(
    BuildContext context, {
    required String cellKey,
    String? valueNid,
  }) async {
    final String? nid = forkDetail?.nid;
    if (nid == null || nid.isEmpty) {
      ToastUtils.showToast(text: '当前分叉缺少 nid');
      return;
    }

    final String resolvedValueNid = _resolveRequestValueNid(cellKey: cellKey, valueNid: valueNid);
    if (resolvedValueNid.isEmpty) {
      ToastUtils.showToast(text: '当前格位缺少 valueNid');
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
      response = await LanguageConsoleRequest.checkPatternRealizationSetPairForkBind(
        nid: nid,
        data: <String, dynamic>{
          "cell": cellKey,
          "sentenceId": sentenceId,
          "valueNid": resolvedValueNid,
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

    boundSentenceMap[_buildStorageKey(cellKey: cellKey, valueNid: valueNid)] = PatternBlueprintSentenceBriefEntity(
      sentenceId: response.sentenceId ?? sentenceId,
      content: response.text?.isNotEmpty == true ? response.text : "句子 $sentenceId",
      access: "INTERNAL",
    );
  }

  /// 提交“补句落库”，允许只钉 from，或带齐套分支一起落库。
  Future<void> addSentence() async {
    if (!isAddSentenceEnabled) {
      _showSubmitHint(requireFull: false);
      return;
    }
    await _submitForkSet(matchFirst: false);
  }

  /// 提交“满句落库”，要求所有格位都已经绑满。
  Future<void> fullSentence() async {
    if (!isFullSentenceEnabled) {
      _showSubmitHint(requireFull: true);
      return;
    }
    await _submitForkSet(matchFirst: true);
  }

  /// 当前启用格位里已经绑定的 sentenceId。
  List<int> get _activeBoundSentenceIds {
    final List<int> resp = <int>[];
    for (final PatternBlueprintSentenceBriefEntity sentence in boundSentenceMap.values) {
      final int? sentenceId = sentence.sentenceId;
      if (sentenceId != null && !resp.contains(sentenceId)) {
        resp.add(sentenceId);
      }
    }
    return resp;
  }

  /// 执行 Pair-Fork add-set 提交流程。
  Future<void> _submitForkSet({required bool matchFirst}) async {
    final String? nid = forkDetail?.nid;
    if (nid == null || nid.isEmpty) {
      ToastUtils.showToast(text: '当前分叉缺少 nid');
      return;
    }

    final int? fromSentenceId = _resolveFromSentenceId();
    final List<Map<String, dynamic>> bindings = _buildToBindings();
    if (fromSentenceId == null) {
      ToastUtils.showToast(text: '先钉共用端，再补句落库');
      return;
    }
    if (_hasPartialToBindings(bindings)) {
      ToastUtils.showToast(text: '齐套 bindings 必须覆盖全部分支，残缺请只钉共用端');
      return;
    }

    ToastUtils.showLoading();
    try {
      final Map<String, dynamic> matchReqData = <String, dynamic>{
        "fromSentenceId": fromSentenceId,
      };
      if (bindings.isNotEmpty) {
        matchReqData["bindings"] = bindings;
      }
      final PatternRealizationSetPatternMatchCheckEntity? matchResp = await LanguageConsoleRequest.checkPatternRealizationSetPairForkMatch(
        nid: nid,
        data: matchReqData,
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
        "matchFirst": matchFirst,
      };
      if (bindings.isNotEmpty) {
        createReqData["bindings"] = bindings;
      }
      final Map<String, dynamic> parameter = <String, dynamic>{};
      if (unitId != null) {
        parameter['unitId'] = unitId;
      }
      if (targetId != null) {
        parameter['targetId'] = targetId;
      }

      final bool createResp = await LanguageConsoleRequest.createPatternRealizationSetPairFork(
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
    ToastUtils.showToast(text: requireFull ? '先把所有格位都绑满，再满句落库' : '先钉共用端，再补句落库');
  }

  /// 当前是否存在残缺的 to 分支绑定。
  bool _hasPartialToBindings(List<Map<String, dynamic>> bindings) {
    return bindings.isNotEmpty && bindings.length != memberList.length;
  }

  /// 构建当前已手动绑定的 to 分支列表。
  List<Map<String, dynamic>> _buildToBindings() {
    final List<Map<String, dynamic>> resp = <Map<String, dynamic>>[];
    for (final SentenceForkMemberEntity member in memberList) {
      final String? valueNid = member.valueNid;
      final int? sentenceId = boundSentenceMap[_buildToStorageKey(valueNid)]?.sentenceId;
      if (valueNid == null || valueNid.isEmpty || sentenceId == null) {
        continue;
      }
      resp.add(<String, dynamic>{
        "valueNid": valueNid,
        "sentenceId": sentenceId,
      });
    }
    return resp;
  }

  /// 顶部默认 from 样句。
  ZhenxieSentenceMemberSentenceEntity _buildFromExampleSentence() {
    final ZhenxieSentenceMemberSentenceEntity? forkFromSentence = _resolveExampleRealizationSet()?.forkFromMember?.sentence;
    if (forkFromSentence != null) {
      return forkFromSentence;
    }
    final String fallbackText = forkDetail?.boardExample?.fromText ?? memberList.firstOrNull?.teachingExampleFrom ?? '';
    return ZhenxieSentenceMemberSentenceEntity(
      content: fallbackText,
      patternNid: forkDetail?.sharedFrom?.patternNid,
      patternTemplate: forkDetail?.sharedFrom?.pattern?.template,
    );
  }

  /// 顶部默认 to 样句。
  ZhenxieSentenceMemberSentenceEntity _buildToExampleSentence(SentenceForkMemberEntity? member) {
    final ZhenxieSentenceMemberEntity? branch = _findExampleToBranch(member?.valueNid);
    if (branch?.sentence != null) {
      return branch!.sentence!;
    }

    final SentenceForkBoardExampleMatchEntity? boardMatch = _findBoardExampleMatch(member?.valueNid);
    return ZhenxieSentenceMemberSentenceEntity(
      content: boardMatch?.toText ?? member?.teachingExampleTo ?? '',
      patternNid: member?.pair?.toRealization?.patternNid ?? member?.pair?.toRealization?.pattern?.nid,
      patternTemplate: member?.pair?.toRealization?.pattern?.template,
    );
  }

  /// 当前格位在弹窗上的说明标题。
  String _resolveDialogTitle({required String cellKey, String? valueNid}) {
    return _resolvePatternName(cellKey: cellKey, valueNid: valueNid);
  }

  /// 当前格位展示标题。
  String _resolvePatternName({required String cellKey, String? valueNid}) {
    if (cellKey == 'from') {
      final String? patternName = LearningLangUtils.getLocalLang(forkDetail?.sharedFrom?.pattern?.name)?.text;
      return patternName??"";
    }
    final SentenceForkMemberEntity? member = _findMember(valueNid);
    final String? title = LearningLangUtils.getLocalLang(member?.pair?.toRealization?.pattern?.name)?.text ??
        LearningLangUtils.getLocalLang(member?.valueLabel?.name)?.text ??
        member?.valueNid;
    return title ?? "";
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

  /// 请求接口时使用的 valueNid。
  String _resolveRequestValueNid({required String cellKey, String? valueNid}) {
    if (cellKey == 'from') {
      return _resolveFromCellValueNid();
    }
    return valueNid ?? '';
  }

  /// 入口 from 格位默认借用第一个分支 valueNid，满足 fork 接口要求。
  String _resolveFromCellValueNid() {
    return memberList.firstOrNull?.valueNid ?? '';
  }

  /// 返回排除当前格位后的已绑定 sentenceId 列表。
  List<int> _activeBoundSentenceIdsExcluding({required String cellKey, String? valueNid}) {
    final List<int> resp = <int>[];
    final String currentKey = _buildStorageKey(cellKey: cellKey, valueNid: valueNid);
    boundSentenceMap.forEach((key, sentence) {
      if (key == currentKey) {
        return;
      }
      final int? sentenceId = sentence.sentenceId;
      if (sentenceId != null && !resp.contains(sentenceId)) {
        resp.add(sentenceId);
      }
    });
    return resp;
  }

  /// 当前 from 句子 id。
  int? _resolveFromSentenceId() {
    return boundSentenceMap['from']?.sentenceId;
  }

  /// 取一个默认展示用的 realization set。
  ZhenxieRealizationSetsEntity? _resolveExampleRealizationSet() {
    final List<ZhenxieRealizationSetsEntity> setList =
        (forkDetail?.realizationSets ?? const <ZhenxieRealizationSetsEntity?>[])
            .whereType<ZhenxieRealizationSetsEntity>()
            .toList();
    if (setList.isEmpty) {
      return null;
    }
    setList.sort((a, b) => (b.order ?? 0).compareTo(a.order ?? 0));
    return setList.first;
  }

  /// 按 valueNid 找一个默认 to 分支。
  ZhenxieSentenceMemberEntity? _findExampleToBranch(String? valueNid) {
    if (valueNid == null || valueNid.isEmpty) {
      return null;
    }
    final List<ZhenxieSentenceMemberEntity?> forkToList = _resolveExampleRealizationSet()?.forkToMembers ?? const <ZhenxieSentenceMemberEntity?>[];
    for (final ZhenxieSentenceMemberEntity? branch in forkToList) {
      if (branch?.valueNid == valueNid) {
        return branch;
      }
    }
    return null;
  }

  /// 从 boardExample 中按 valueNid 找默认 to 文案。
  SentenceForkBoardExampleMatchEntity? _findBoardExampleMatch(String? valueNid) {
    if (valueNid == null || valueNid.isEmpty) {
      return null;
    }
    final List<SentenceForkBoardExampleMatchEntity?> matchList =
        forkDetail?.boardExample?.matches ?? const <SentenceForkBoardExampleMatchEntity?>[];
    for (final SentenceForkBoardExampleMatchEntity? item in matchList) {
      if (item?.valueNid == valueNid) {
        return item;
      }
    }
    return null;
  }

  /// 通过 valueNid 找成员。
  SentenceForkMemberEntity? _findMember(String? valueNid) {
    if (valueNid == null || valueNid.isEmpty) {
      return null;
    }
    for (final SentenceForkMemberEntity member in memberList) {
      if (member.valueNid == valueNid) {
        return member;
      }
    }
    return null;
  }

  /// pair-fork 的 to 句位存储 key。
  String _buildToStorageKey(String? valueNid) {
    return _buildStorageKey(cellKey: 'to', valueNid: valueNid);
  }

  /// 页面内部统一的句位存储 key。
  String _buildStorageKey({required String cellKey, String? valueNid}) {
    if (cellKey == 'from') {
      return 'from';
    }
    return 'to:${valueNid ?? ''}';
  }

}
