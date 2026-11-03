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

class ManageSentenceParadigmAddGroupController extends GetxController with ManageBreadcrumbMixin {
  /// 当前页面实例 tag。
  final String tag;

  ManageSentenceParadigmAddGroupController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_SENTENCE_PARADIGM_ADD_GROUP;

  @override
  String get breadcrumbTitle => '添加一组';

  /// 页面入口传入的句型对照详情。
  SentencePatternCompareEntity? detailData;

  /// 单元 Target 入口传入的单元 id，只用于限制候选范围。
  int? unitId;

  /// 单元 Target 入口传入的 target id，用于创建接口参数。
  int? targetId;

  /// 单元 Target 入口传入的预填句子 id，按上级勾选顺序组织。
  List<int> presetSentenceIds = const [];

  /// 当前对照成员列表，按详情页原始顺序组织。
  final RxList<SentencePatternCompareMemberEntity> memberList = <SentencePatternCompareMemberEntity>[].obs;

  /// 当前各格位已绑定的句子，key 为成员下标。
  final RxMap<int, PatternBlueprintSentenceBriefEntity> boundSentenceMap = <int, PatternBlueprintSentenceBriefEntity>{}.obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    final dynamic arguments = Get.arguments;
    if (arguments is! Map) {
      return;
    }

    final dynamic rawDetailData = arguments['detailData'];
    if (rawDetailData is SentencePatternCompareEntity) {
      detailData = rawDetailData;
    }
    targetId = arguments['targetId'];
    unitId = arguments['unitId'];
    presetSentenceIds = _parsePresetSentenceIdList(arguments['presetSentenceIds']);
    initData();
  }

  /// 首次进入页面时重置本地草稿态。
  Future<void> initData() async {
    boundSentenceMap.clear();
    memberList.assignAll(_resolveMemberList(detailData));
    if (presetSentenceIds.isEmpty || memberList.isEmpty) {
      return;
    }
    final List<PatternBlueprintSentenceBriefEntity> presetSentences = await _queryPresetSentences();
    if (isClosed || presetSentences.isEmpty) {
      return;
    }
    _applyPresetSentences(presetSentences);
  }

  /// 当前卡片列表展示态。
  List<ManageSentenceAddBindingCardModel> buildBindingCardList() {
    return List<ManageSentenceAddBindingCardModel>.generate(memberList.length, (index) {
      final SentencePatternCompareMemberEntity member = memberList[index];
      return ManageSentenceAddBindingCardModel(
        index: index,
        title: _resolveMemberLabel(member),
        sentence: boundSentenceMap[index],
        valueNid: member.valueNid,
        exampleSentence: _buildExampleSentence(member),
        contrastFocus: member.contrastFocus,
        foci: _findExampleFoci(member.valueNid),
      );
    });
  }

  /// 当前已绑定句数。
  int get bindCount => _activeBoundSentenceIds.length;

  /// 当前总格位数。
  int get totalCount => memberList.length;

  /// 是否允许执行补句落库。
  bool get isAddSentenceEnabled => bindCount > 0;

  /// 是否允许执行满句落库。
  bool get isFullSentenceEnabled => totalCount > 0 && bindCount == totalCount;

  /// 打开候选句弹窗，并在用户选中后写回当前格位。
  Future<void> pickSentence(BuildContext context, int index) async {
    final String? nid = detailData?.nid;
    if (nid == null || nid.isEmpty) {
      ToastUtils.showToast(text: '当前对照缺少 nid');
      return;
    }
    if (index < 0 || index >= memberList.length) {
      return;
    }

    final SentencePatternCompareMemberEntity member = memberList[index];
    final PatternBlueprintSentenceBriefEntity? selected = await ManageSentenceAddSelectDialog.show(
      context: context,
      model: ManageSentenceAddSelectDialogModel(
        pageType: ZhenxieEnSentenceType.EN_SENTENCE_PARADIGM,
        title: "第 ${index + 1} 句",
        nid: nid,
        baseSlotKeys: const [],
        dialSlotKeys: const [],
        boundSentenceIds: _activeBoundSentenceIdsExcluding(index),
        unitId: unitId,
        patternName: _resolveMemberLabel(member),
        exampleSentence: _buildExampleSentence(member),
        valueNid: member.valueNid,
        contrastFocus: member.contrastFocus,
        foci: _findExampleFoci(member.valueNid),
      ),
    );
    if (selected == null) {
      return;
    }

    boundSentenceMap[index] = selected;
  }

  /// 手动输入 uid，并校验当前句子是否能绑到当前格位。
  Future<void> manualInputUid(BuildContext context, int index) async {
    final String? nid = detailData?.nid;
    if (nid == null || nid.isEmpty) {
      ToastUtils.showToast(text: '当前对照缺少 nid');
      return;
    }
    if (index < 0 || index >= memberList.length) {
      return;
    }

    final SentencePatternCompareMemberEntity member = memberList[index];
    final String? valueNid = member.valueNid;
    if (valueNid == null || valueNid.isEmpty) {
      ToastUtils.showToast(text: '当前格位缺少 valueNid');
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
      response = await LanguageConsoleRequest.checkPatternRealizationSetParadigmBind(
        nid: nid,
        data: <String, dynamic>{
          "valueNid": valueNid,
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

    boundSentenceMap[index] = PatternBlueprintSentenceBriefEntity(
      sentenceId: response.sentenceId ?? sentenceId,
      content: response.text?.isNotEmpty == true ? response.text : "句子 $sentenceId",
      access: "INTERNAL",
    );
  }

  /// 提交“补句落库”，允许只带当前已人工选中的成员句。
  Future<void> addSentence() async {
    if (!isAddSentenceEnabled) {
      _showSubmitHint(requireFull: false);
      return;
    }
    await _submitParadigmSet(matchFirst: false);
  }

  /// 提交“满句落库”，要求所有格位都已经绑定完成。
  Future<void> fullSentence() async {
    if (!isFullSentenceEnabled) {
      _showSubmitHint(requireFull: true);
      return;
    }
    await _submitParadigmSet(matchFirst: true);
  }

  /// 当前已绑定的 sentenceId，按成员顺序输出。
  List<int> get _activeBoundSentenceIds {
    final List<int> resp = <int>[];
    for (int index = 0; index < memberList.length; index++) {
      final int? sentenceId = boundSentenceMap[index]?.sentenceId;
      if (sentenceId != null) {
        resp.add(sentenceId);
      }
    }
    return resp;
  }

  /// 组装当前提交使用的 bindings。
  List<Map<String, dynamic>> _buildBindings() {
    final List<Map<String, dynamic>> resp = <Map<String, dynamic>>[];
    for (int index = 0; index < memberList.length; index++) {
      final SentencePatternCompareMemberEntity member = memberList[index];
      final int? sentenceId = boundSentenceMap[index]?.sentenceId;
      final String? valueNid = member.valueNid;
      if (sentenceId == null || valueNid == null || valueNid.isEmpty) {
        continue;
      }
      resp.add(<String, dynamic>{
        "valueNid": valueNid,
        "sentenceId": sentenceId,
      });
    }
    return resp;
  }

  /// 执行 Paradigm add-set 提交流程。
  Future<void> _submitParadigmSet({required bool matchFirst}) async {
    final String? nid = detailData?.nid;
    if (nid == null || nid.isEmpty) {
      ToastUtils.showToast(text: '当前对照缺少 nid');
      return;
    }

    final List<Map<String, dynamic>> bindings = _buildBindings();
    if (bindings.isEmpty) {
      ToastUtils.showToast(text: '至少先绑 1 句，再补句落库');
      return;
    }

    ToastUtils.showLoading();
    try {
      final PatternRealizationSetPatternMatchCheckEntity? matchResp = await LanguageConsoleRequest.checkPatternRealizationSetParadigmMatch(
        nid: nid,
        data: <String, dynamic>{
          "bindings": bindings,
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
        "bindings": bindings,
        "matchFirst": matchFirst,
      };
      final Map<String, dynamic> parameter = <String, dynamic>{};
      if (unitId != null) {
        parameter['unitId'] = unitId;
      }
      if (targetId != null) {
        parameter['targetId'] = targetId;
      }

      final bool createResp = await LanguageConsoleRequest.createPatternRealizationSetParadigm(
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
    ToastUtils.showToast(text: requireFull ? '先把所有格位都绑满，再满句落库' : '至少先绑 1 句，再补句落库');
  }

  /// 过滤出当前页真正可用的成员列表。
  List<SentencePatternCompareMemberEntity> _resolveMemberList(SentencePatternCompareEntity? detail) {
    final Iterable<SentencePatternCompareMemberEntity?> rawList =
        detail?.memberList?.isNotEmpty == true ? detail!.memberList! : detail?.members ?? const <SentencePatternCompareMemberEntity?>[];
    return rawList.whereType<SentencePatternCompareMemberEntity>().where((item) => item.valueNid?.isNotEmpty == true).toList();
  }

  /// 解析入口透传的预填句子 id，过滤非法值并保持原始顺序。
  List<int> _parsePresetSentenceIdList(dynamic rawList) {
    if (rawList is! List) {
      return const [];
    }
    final List<int> resp = <int>[];
    final Set<int> seen = <int>{};
    for (final dynamic item in rawList) {
      final int? sentenceId = item is int ? item : int.tryParse("$item");
      if (sentenceId == null || sentenceId <= 0 || !seen.add(sentenceId)) {
        continue;
      }
      resp.add(sentenceId);
    }
    return resp;
  }

  /// 批量拉预填句结构，确保预绑时能拿到 patternNid 和 segmentList。
  Future<List<PatternBlueprintSentenceBriefEntity>> _queryPresetSentences() async {
    ToastUtils.showLoading();
    try {
      final Map<String, dynamic> reqData = <String, dynamic>{
        "contents": presetSentenceIds
            .map((sentenceId) => <String, dynamic>{
                  "type": "EN_SENTENCE",
                  "uid": sentenceId,
                })
            .toList(),
      };
      final PatternBlueprintEntity? sentenceStruct = await LanguageConsoleRequest.querySentenceStructure(data: reqData);
      if (sentenceStruct == null) {
        return const [];
      }
      final List<PatternBlueprintSentenceBriefEntity?> sentenceRealizations = sentenceStruct.sentenceRealizationList ?? const <PatternBlueprintSentenceBriefEntity?>[];
      final List<PatternBlueprintSentenceBriefEntity> resp = <PatternBlueprintSentenceBriefEntity>[];
      for (final int sentenceId in presetSentenceIds) {
        final PatternBlueprintSentenceBriefEntity? matchedSentence = _matchPresetSentenceStruct(
          sentenceRealizations: sentenceRealizations,
          sentenceId: sentenceId,
        );
        if (matchedSentence == null) {
          continue;
        }
        resp.add(matchedSentence);
      }
      return resp;
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 把预填句按句型映射到当前成员格位，同一格位只占第一句。
  void _applyPresetSentences(List<PatternBlueprintSentenceBriefEntity> presetSentences) {
    final Set<int> usedIndexes = <int>{};
    for (final PatternBlueprintSentenceBriefEntity sentence in presetSentences) {
      final String? patternNid = sentence.patternNid;
      if (patternNid == null || patternNid.isEmpty) {
        continue;
      }
      for (int index = 0; index < memberList.length; index++) {
        if (usedIndexes.contains(index)) {
          continue;
        }
        if (_resolveMemberPatternNid(memberList[index]) != patternNid) {
          continue;
        }
        usedIndexes.add(index);
        boundSentenceMap[index] = sentence;
        break;
      }
    }
  }

  /// 从结构接口返回的 realization 列表里，按 sentenceId 找回当前预填句。
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

  /// 生成当前成员顶部展示用的样句。
  ZhenxieSentenceMemberSentenceEntity _buildExampleSentence(SentencePatternCompareMemberEntity member) {
    final ZhenxieSentenceMemberEntity? exampleMember = _findExampleMember(member.valueNid);
    final ZhenxieSentenceMemberSentenceEntity? sentence = exampleMember?.sentence;
    if (sentence != null) {
      return sentence;
    }

    return ZhenxieSentenceMemberSentenceEntity(
      content: member.teachingExample,
      patternNid: member.realizationInfo?.pattern?.nid ?? member.realization?.patternNid,
      patternTemplate: member.realizationInfo?.pattern?.template,
    );
  }

  /// 生成当前成员顶部展示用的样句高亮区间。
  List<ZhenxieSentenceMemberFocusEntity?>? _findExampleFoci(String? valueNid) {
    return _findExampleMember(valueNid)?.foci;
  }

  /// 当前成员的展示标题。
  String _resolveMemberLabel(SentencePatternCompareMemberEntity member) {
    return LearningLangUtils.getLocalLang(member.realizationInfo?.pattern?.name)?.text ??
        member.valueNid ??
        '当前格位';
  }

  /// 当前成员目标句型 nid，供预填句自动落格时匹配。
  String? _resolveMemberPatternNid(SentencePatternCompareMemberEntity member) {
    return member.realizationInfo?.patternNid ?? member.realization?.patternNid;
  }

  /// 返回排除当前格位后的已绑定 sentenceId 列表。
  List<int> _activeBoundSentenceIdsExcluding(int currentIndex) {
    final List<int> resp = <int>[];
    for (int index = 0; index < memberList.length; index++) {
      if (index == currentIndex) {
        continue;
      }
      final int? sentenceId = boundSentenceMap[index]?.sentenceId;
      if (sentenceId != null) {
        resp.add(sentenceId);
      }
    }
    return resp;
  }

  /// 从已有对照组里为当前 valueNid 找一个可展示的成员。
  ZhenxieSentenceMemberEntity? _findExampleMember(String? valueNid) {
    if (valueNid == null || valueNid.isEmpty) {
      return null;
    }

    for (final ZhenxieRealizationSetsEntity realizationSet in _resolveRealizationSetList()) {
      final List<ZhenxieSentenceMemberEntity?> memberList = realizationSet.members ?? const <ZhenxieSentenceMemberEntity?>[];
      for (final ZhenxieSentenceMemberEntity? member in memberList) {
        if (member?.valueNid == valueNid && member?.sentence != null) {
          return member;
        }
      }
    }
    return null;
  }

  /// 取详情页里可复用的对照组列表，优先用当前详情已展开的数据。
  List<ZhenxieRealizationSetsEntity> _resolveRealizationSetList() {
    final SentencePatternCompareEntity? detail = detailData;
    final Iterable<ZhenxieRealizationSetsEntity?> rawList = detail!.realizationSets ?? [];
    return rawList.whereType<ZhenxieRealizationSetsEntity>().toList();
  }
}
