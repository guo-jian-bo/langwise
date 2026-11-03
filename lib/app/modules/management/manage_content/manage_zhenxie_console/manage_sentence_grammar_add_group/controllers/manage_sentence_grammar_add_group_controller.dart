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

class ManageSentenceGrammarAddGroupController extends GetxController with ManageBreadcrumbMixin {
  /// 当前页面实例 tag。
  final String tag;

  ManageSentenceGrammarAddGroupController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_SENTENCE_GRAMMAR_ADD_GROUP;

  @override
  String get breadcrumbTitle => '添加一组';

  /// 页面入口传入的语法全景详情。
  ManageGrammarPanoramaEntity? grammarDetail;

  /// 单元 Target 入口传入的单元 id，只用于限制候选范围。
  int? unitId;

  /// 单元 Target 入口传入的 target id，用于创建接口参数。
  int? targetId;

  /// 当前全景轴定义。
  final RxList<ManageGrammarPanoramaAxisEntity> axesList = <ManageGrammarPanoramaAxisEntity>[].obs;

  /// 当前全景格位列表。
  final RxList<ManageGrammarPanoramaCellEntity> cellList = <ManageGrammarPanoramaCellEntity>[].obs;

  /// 当前各格位已绑定的句子，key 为 cell.key。
  final RxMap<String, PatternBlueprintSentenceBriefEntity> boundSentenceMap = <String, PatternBlueprintSentenceBriefEntity>{}.obs;

  /// 当前手输失败或整盘失败提示。
  final RxString boardError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    final dynamic arguments = Get.arguments;
    if (arguments is! Map) {
      return;
    }

    final dynamic rawGrammarDetail = arguments['grammarDetail'];
    if (rawGrammarDetail is ManageGrammarPanoramaEntity) {
      grammarDetail = rawGrammarDetail;
    }
    targetId = arguments['targetId'];
    unitId = arguments['unitId'];
    initData();
  }

  /// 首次进入页面时重置本地草稿态。
  void initData() {
    boundSentenceMap.clear();
    boardError.value = '';
    axesList.assignAll(
      (grammarDetail?.axes ?? const <ManageGrammarPanoramaAxisEntity?>[]).whereType<ManageGrammarPanoramaAxisEntity>().toList(),
    );
    cellList.assignAll(_buildSortedCellList());
  }

  /// 当前卡片列表展示态。
  List<ManageSentenceAddBindingCardModel> buildBindingCardList() {
    return List<ManageSentenceAddBindingCardModel>.generate(cellList.length, (int index) {
      final ManageGrammarPanoramaCellEntity cell = cellList[index];
      final String cellKey = cell.key ?? '';
      return ManageSentenceAddBindingCardModel(
        index: index,
        title: _buildCellLabel(cell),
        cellKey: cellKey,
        valueNid: cellKey,
        sentence: boundSentenceMap[cellKey],
        exampleSentence: _buildExampleSentence(cell),
      );
    });
  }

  /// 当前已绑定句数。
  int get bindCount => _boundBindingRows.length;

  /// 当前总格位数。
  int get totalCount => cellList.length;

  /// 是否允许执行补句落库。
  bool get isAddSentenceEnabled => bindCount > 0;

  /// 是否允许执行满句落库。
  bool get isFullSentenceEnabled => totalCount > 0 && bindCount == totalCount;

  /// 打开候选句弹窗，并在用户选中后写回当前格位。
  Future<void> pickSentence(BuildContext context, ManageGrammarPanoramaCellEntity cell) async {
    final String? nid = grammarDetail?.nid;
    final String? cellKey = cell.key;
    if (nid == null || nid.isEmpty) {
      ToastUtils.showToast(text: '当前全景缺少 nid');
      return;
    }
    if (cellKey == null || cellKey.isEmpty) {
      ToastUtils.showToast(text: '当前格位缺少 key');
      return;
    }

    final PatternBlueprintSentenceBriefEntity? selected = await ManageSentenceAddSelectDialog.show(
      context: context,
      model: ManageSentenceAddSelectDialogModel(
        pageType: ZhenxieEnSentenceType.EN_SENTENCE_GRAMMAR_GRID,
        title: _buildCellLabel(cell),
        nid: nid,
        baseSlotKeys: const <String>[],
        dialSlotKeys: const <String>[],
        boundSentenceIds: _activeBoundSentenceIdsExcluding(cellKey),
        unitId: unitId,
        patternName: _buildCellLabel(cell),
        exampleSentence: _buildExampleSentence(cell),
        valueNid: cellKey,
        pairCellKey: cellKey,
        gridAxisValues: _buildAxisValueMap(cell),
      ),
    );
    if (selected == null) {
      return;
    }

    boundSentenceMap[cellKey] = selected;
    boardError.value = '';
  }

  /// 手动输入 uid，并校验当前句子是否能绑到当前格位。
  Future<void> manualInputUid(BuildContext context, ManageGrammarPanoramaCellEntity cell) async {
    final String? nid = grammarDetail?.nid;
    final String? cellKey = cell.key;
    if (nid == null || nid.isEmpty) {
      ToastUtils.showToast(text: '当前全景缺少 nid');
      return;
    }
    if (cellKey == null || cellKey.isEmpty) {
      ToastUtils.showToast(text: '当前格位缺少 key');
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
      response = await LanguageConsoleRequest.checkPatternRealizationSetGridBind(
        nid: nid,
        data: <String, dynamic>{
          "cell": cellKey,
          "sentenceId": sentenceId,
          "valueNid": cellKey,
          "axisValues": _buildAxisValueMap(cell),
        },
      );
    } finally {
      ToastUtils.hideLoading();
    }
    if (response == null) return;

    if (response.ok != true) {
      boundSentenceMap.remove(cellKey);
      boardError.value = response.reason ?? '这句不能绑到当前格位';
      ToastUtils.showToast(text: boardError.value);
      return;
    }

    boundSentenceMap[cellKey] = PatternBlueprintSentenceBriefEntity(
      sentenceId: response.sentenceId ?? sentenceId,
      content: response.text?.isNotEmpty == true ? response.text : "句子 $sentenceId",
      access: "INTERNAL",
    );
    boardError.value = '';
  }

  /// 提交“补句落库”，允许只带部分人工钉句。
  Future<void> addSentence() async {
    if (!isAddSentenceEnabled) {
      _showSubmitHint(requireFull: false);
      return;
    }
    await _submitGridSet(matchFirst: false);
  }

  /// 提交“满句落库”，要求所有格位都已经绑满。
  Future<void> fullSentence() async {
    if (!isFullSentenceEnabled) {
      _showSubmitHint(requireFull: true);
      return;
    }
    await _submitGridSet(matchFirst: true);
  }

  /// 当前已绑定格位的提交行。
  List<Map<String, dynamic>> get _boundBindingRows {
    final List<Map<String, dynamic>> resp = <Map<String, dynamic>>[];
    for (final ManageGrammarPanoramaCellEntity cell in cellList) {
      final String? cellKey = cell.key;
      final int? sentenceId = cellKey == null ? null : boundSentenceMap[cellKey]?.sentenceId;
      if (cellKey == null || cellKey.isEmpty || sentenceId == null) {
        continue;
      }
      resp.add(<String, dynamic>{
        "valueNid": cellKey,
        "sentenceId": sentenceId,
        "cell": cellKey,
        "axisValues": _buildAxisValueMap(cell),
      });
    }
    return resp;
  }

  /// 执行 Grammar Grid add-set 提交流程。
  Future<void> _submitGridSet({required bool matchFirst}) async {
    final String? nid = grammarDetail?.nid;
    if (nid == null || nid.isEmpty) {
      ToastUtils.showToast(text: '当前全景缺少 nid');
      return;
    }

    final List<Map<String, dynamic>> bindings = _boundBindingRows;
    if (bindings.isEmpty) {
      ToastUtils.showToast(text: '至少先绑 1 句，再补句落库');
      return;
    }

    final int? firstSentenceId = bindings.first['sentenceId'] as int?;

    ToastUtils.showLoading();
    try {
      final Map<String, dynamic> requestData = <String, dynamic>{
        "bindings": bindings,
        "matchFirst": matchFirst,
      };
      if (firstSentenceId != null) {
        requestData["fromSentenceId"] = firstSentenceId;
      }

      final PatternRealizationSetPatternMatchCheckEntity? matchResp = await LanguageConsoleRequest.checkPatternRealizationSetGridMatch(
        nid: nid,
        data: requestData,
      );
      if (matchResp?.ok != true) {
        final String failureText = (matchResp?.failures ?? const <PatternRealizationSetPatternMatchFailureEntity>[])
            .map((item) => item.code ?? '')
            .where((item) => item.isNotEmpty)
            .join('、');
        boardError.value = failureText.isNotEmpty ? failureText : '当前盘面未通过整组门禁';
        ToastUtils.showToast(text: boardError.value);
        return;
      }

      final Map<String, dynamic> createReqData = <String, dynamic>{
        "bindings": bindings,
        "matchFirst": matchFirst,
      };
      if (firstSentenceId != null) {
        createReqData["fromSentenceId"] = firstSentenceId;
      }
      final Map<String, dynamic> parameter = <String, dynamic>{};
      if (unitId != null) {
        parameter['unitId'] = unitId;
      }
      if (targetId != null) {
        parameter['targetId'] = targetId;
      }

      final bool createResp = await LanguageConsoleRequest.createPatternRealizationSetGrid(
        nid: nid,
        data: createReqData,
        parameter: parameter,
      );
      if (!createResp) {
        return;
      }

      boardError.value = '';
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

  /// 返回排除当前格位后的已绑定 sentenceId 列表。
  List<int> _activeBoundSentenceIdsExcluding(String currentCellKey) {
    final List<int> resp = <int>[];
    boundSentenceMap.forEach((key, sentence) {
      if (key == currentCellKey) {
        return;
      }
      final int? sentenceId = sentence.sentenceId;
      if (sentenceId != null && !resp.contains(sentenceId)) {
        resp.add(sentenceId);
      }
    });
    return resp;
  }

  /// 按详情页已有顺序和轴顺序整理格位列表。
  List<ManageGrammarPanoramaCellEntity> _buildSortedCellList() {
    final List<ManageGrammarPanoramaCellEntity> list = (grammarDetail?.cells ?? const <ManageGrammarPanoramaCellEntity?>[])
        .whereType<ManageGrammarPanoramaCellEntity>()
        .where((item) => item.key?.isNotEmpty == true)
        .toList();
    final List<String> rowValues =
        axesList.isNotEmpty ? axesList.first.values?.whereType<String>().toList() ?? const <String>[] : const <String>[];
    final List<String> colValues =
        axesList.length > 1 ? axesList[1].values?.whereType<String>().toList() ?? const <String>[] : const <String>[];
    list.sort((ManageGrammarPanoramaCellEntity a, ManageGrammarPanoramaCellEntity b) {
      final int rowCompare = _axisValueOrder(a.rowValue, rowValues).compareTo(_axisValueOrder(b.rowValue, rowValues));
      if (rowCompare != 0) {
        return rowCompare;
      }
      final int colCompare = _axisValueOrder(a.colValue, colValues).compareTo(_axisValueOrder(b.colValue, colValues));
      if (colCompare != 0) {
        return colCompare;
      }
      return (a.key ?? '').compareTo(b.key ?? '');
    });
    return list;
  }

  /// 计算某个轴值在当前轴定义里的顺序。
  int _axisValueOrder(String? value, List<String> orderedValues) {
    if (value == null || value.isEmpty) {
      return 1 << 20;
    }
    final int index = orderedValues.indexOf(value);
    return index >= 0 ? index : 1 << 20;
  }

  /// 构建格位展示标题。
  String _buildCellLabel(ManageGrammarPanoramaCellEntity cell) {
    final ManageGrammarPanoramaAxisValuesEntity? axisValues = cell.axisValues;
    final String coordinateLabel = _buildCoordinateLabel(<String, String>{
      if (axisValues?.time?.isNotEmpty == true) "time": axisValues!.time!,
      if (axisValues?.polarity?.isNotEmpty == true) "polarity": axisValues!.polarity!,
    });
    if (coordinateLabel.isNotEmpty) {
      return coordinateLabel;
    }
    final String? label = LearningLangUtils.getLocalLang(cell.label)?.text;
    if (label?.isNotEmpty == true) {
      return label!;
    }
    final String rowText = cell.rowValue ?? '';
    final String colText = cell.colValue ?? '';
    if (rowText.isNotEmpty && colText.isNotEmpty) {
      return '$rowText · $colText';
    }
    return cell.key ?? '当前格位';
  }

  /// 按参考页规则把轴值转成中文格位标题。
  String _buildCoordinateLabel(Map<String, String> axisValues) {
    final String? time = axisValues['time'];
    final String? polarity = axisValues['polarity'];
    if (time?.isNotEmpty == true && polarity?.isNotEmpty == true) {
      return '${_axisValueZh(time!)}·${_axisValueZh(polarity!)}';
    }
    return axisValues.values.map(_axisValueZh).where((item) => item.isNotEmpty).join('·');
  }

  /// 把轴值转成中文标签。
  String _axisValueZh(String value) {
    switch (value) {
      case 'past':
        return '过去';
      case 'present':
        return '现在';
      case 'future':
        return '将来';
      case 'affirmative':
        return '肯定';
      case 'negative':
        return '否定';
      default:
        return value;
    }
  }

  /// 从已有宫格示例里取当前格位默认样句。
  ZhenxieSentenceMemberSentenceEntity _buildExampleSentence(ManageGrammarPanoramaCellEntity cell) {
    final String? cellKey = cell.key;
    if (cellKey?.isNotEmpty == true) {
      final List<ZhenxieRealizationSetsEntity?> realizationSets =
          grammarDetail?.realizationSets ?? const <ZhenxieRealizationSetsEntity?>[];
      for (final ZhenxieRealizationSetsEntity? set in realizationSets) {
        final List<ZhenxieSentenceMemberEntity?> memberList = List<ZhenxieSentenceMemberEntity?>.from(
          set?.members ?? const <ZhenxieSentenceMemberEntity?>[],
        );
        for (final ZhenxieSentenceMemberEntity? item in memberList) {
          if (item?.valueNid == cellKey && item?.sentence != null) {
            return item!.sentence!;
          }
        }
      }
    }
    return ZhenxieSentenceMemberSentenceEntity(
      content: _buildCellLabel(cell),
    );
  }

  /// 把当前 cell 转成请求体需要的轴值 map。
  Map<String, String> _buildAxisValueMap(ManageGrammarPanoramaCellEntity cell) {
    final Map<String, String> map = <String, String>{};
    if (axesList.isNotEmpty && axesList.first.axisKey?.isNotEmpty == true && cell.rowValue?.isNotEmpty == true) {
      map[axesList.first.axisKey!] = cell.rowValue!;
    }
    if (axesList.length > 1 && axesList[1].axisKey?.isNotEmpty == true && cell.colValue?.isNotEmpty == true) {
      map[axesList[1].axisKey!] = cell.colValue!;
    }
    final ManageGrammarPanoramaAxisValuesEntity? axisValues = cell.axisValues;
    if (axisValues?.time?.isNotEmpty == true && !map.values.contains(axisValues!.time!)) {
      map.putIfAbsent('time', () => axisValues.time!);
    }
    if (axisValues?.polarity?.isNotEmpty == true && !map.values.contains(axisValues!.polarity!)) {
      map.putIfAbsent('polarity', () => axisValues.polarity!);
    }
    return map;
  }
}
