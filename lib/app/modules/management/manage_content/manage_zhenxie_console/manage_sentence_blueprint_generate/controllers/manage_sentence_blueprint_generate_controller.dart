import 'dart:math';

import 'package:api/api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/utils/utils.dart';

import '../../../../../../../common/entities/entities.dart';
import '../../../../../../../common/enum/enum.dart';
import '../../../../../../../common/https/https.dart';
import '../../../../../../../common/widgets/widgets.dart';
import '../../../../../../routes/routes.dart';
import '../../../../utils/utils.dart';

class ManageSentenceBlueprintGenerateController extends GetxController with ManageBreadcrumbMixin {
  final String tag;
  ManageSentenceBlueprintGenerateController({required this.tag});

  @override
  String get breadcrumbRoute => Routes.MANAGE_SENTENCE_BLUEPRINT_GENERATE;

  @override
  String get breadcrumbTitle => '生成句子';

  /// 入口传入的单元 id，用于拉取当前 Target 的详情和已挂句列表。
  int? unitId;

  /// 入口传入的 Target uid，用于定位当前句型目标。
  int? targetUid;

  /// 当前 Target 的骨架数据，顶部句型骨架区域直接消费。
  final Rx<PatternBlueprintEntity> patternBlueprint = PatternBlueprintEntity().obs;

  /// 当前 Target 已经挂上的句子，供“已有句子列表”直接循环展示。
  final RxList<PatternBlueprintSentenceBriefEntity> existingSentenceList = <PatternBlueprintSentenceBriefEntity>[].obs;

  /// 已经选择的单元词汇
  final RxList<KnowledgeCommonEntityList> selectedVocabularyList = <KnowledgeCommonEntityList>[].obs;

  /// “这次写哪些形态”每一行的骨架和句数输入。
  final RxList<ManageSentenceBlueprintGenerateShapeRowEntity> shapeRowList = <ManageSentenceBlueprintGenerateShapeRowEntity>[].obs;

  /// 当前形态句数校验文案；为空表示校验通过。
  final RxString shapeCountErrorText = ''.obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tag);
    if (Get.arguments != null) {
      unitId = Get.arguments["unitId"];
      targetUid = Get.arguments["targetUid"];
    }
    initData();
  }

  /// 读取当前 Target 详情，只取句型骨架 payload。
  Future<void> initData() async {
    if (unitId == null || targetUid == null) return;
    try {
      ToastUtils.showLoading();
      await getTargetDetails();
      await getExistingSentences();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 获取 Target 详情
  Future<void> getTargetDetails() async {
    try {
      ResponseEntity<ManageUnitGrammarTargetDetailEntity?>? response = await UnitUtil.unitGrammarTargetDetail(
        unitId: unitId.toString(),
        config: RequestConfig(
          requireToken: true,
          parameters: {
            'targetUid': targetUid,
            'isManagement': true,
          },
        ),
      );
      if (response == null || isClosed) return;
      final Map<String, dynamic> grammarStructPayload = response.data?.grammarUnifiedInfo?.payload ?? const {};
      final String? type = response.data?.grammarUnifiedInfo?.type;
      if (type == ZhenxieEnSentenceType.EN_SENTENCE_PATTERN.rawValue || type == ZhenxieEnSentenceType.EN_SENTENCE_PYRAMID.rawValue) {
        patternBlueprint.value = PatternBlueprintEntity.fromJson(grammarStructPayload);
        _buildShapeRowsFromPattern();
      }
    } catch (_) {}
  }

  /// 获取当前 Target 已经挂上的句子列表，并拍平成 View 直用的一维句子数组。
  Future<void> getExistingSentences() async {
    try {
      final List<PatternBlueprintSentenceBriefEntity>? response = await CourseConsoleRequest.getUnitSentenceStructureBlueprintList(
        unitId: unitId!,
        targetId: targetUid!,
      );
      if (response == null || isClosed) return;
      existingSentenceList.assignAll(response);
    } catch (_) {}
  }

  /// 选择单元词汇
  Future<void> selectVocabulary() async {
    if (unitId == null) return;
    final List<int> ids = <int>[];
    for (final KnowledgeCommonEntityList item in selectedVocabularyList) {
      final int? knowledgeId = item.knowledgeId;
      if (knowledgeId != null && knowledgeId > 0) {
        ids.add(knowledgeId);
      }
    }
    final dynamic res = await ManagePageRegistry.jumpTo(
      Routes.MANAGE_SELECT_UNIT_VOCABULAY,
      arguments: {
        "unitId": unitId,
        "initIds": ids,
      },
    );
    if (res is! List) return;
    selectedVocabularyList.assignAll(res.whereType<KnowledgeCommonEntityList>());
  }

  /// 删除指定的单元词汇
  void deleteSelectedVocabulary(KnowledgeCommonEntityList item) {
    selectedVocabularyList.removeWhere((element) => element.knowledgeId == item.knowledgeId);
  }

  @override
  void onClose() {
    _disposeShapeCountControllers();
    super.onClose();
  }

  /// 根据当前骨架里的 required / growthPriority 派生“这次写哪些形态”列表。
  void _buildShapeRowsFromPattern() {
    _disposeShapeCountControllers();
    final List<PatternBlueprintOpenSlotEntity> openSlots = <PatternBlueprintOpenSlotEntity>[];
    for (final PatternBlueprintOpenSlotEntity? slot in patternBlueprint.value.openSlots ?? <PatternBlueprintOpenSlotEntity?>[]) {
      if (slot != null) {
        openSlots.add(slot);
      }
    }

    final List<String> requiredSlotKeys = <String>[];
    final List<String> optionalSlotKeys = <String>[];
    final List<_ManageSentenceBlueprintGrowthSlotEntry> growthSlots = <_ManageSentenceBlueprintGrowthSlotEntry>[];
    for (int index = 0; index < openSlots.length; index++) {
      final PatternBlueprintOpenSlotEntity slot = openSlots[index];
      final String slotKey = slot.slotKey?.trim() ?? '';
      if (slotKey.isEmpty) continue;
      if (slot.required == false) {
        optionalSlotKeys.add(slotKey);
      } else {
        requiredSlotKeys.add(slotKey);
      }
      if (slot.growthPriority != null) {
        growthSlots.add(_ManageSentenceBlueprintGrowthSlotEntry(
          slotKey: slotKey,
          growthPriority: slot.growthPriority!,
          sourceIndex: index,
        ));
      }
    }
    growthSlots.sort((a, b) {
      final int priorityResult = a.growthPriority.compareTo(b.growthPriority);
      if (priorityResult != 0) {
        return priorityResult;
      }
      return a.sourceIndex.compareTo(b.sourceIndex);
    });

    final List<ManageSentenceBlueprintGenerateShapeRowEntity> rows = <ManageSentenceBlueprintGenerateShapeRowEntity>[
      _buildShapeRow(
        key: 'kernel',
        openedSlotKeys: const <String>[],
        requiredSlotKeys: requiredSlotKeys,
        optionalSlotKeys: optionalSlotKeys,
        defaultCount: 4,
      ),
    ];
    for (int index = 0; index < growthSlots.length; index++) {
      final List<String> openedSlotKeys = growthSlots.sublist(0, index + 1).map((item) => item.slotKey).toList();
      rows.add(_buildShapeRow(
        key: growthSlots[index].slotKey,
        openedSlotKeys: openedSlotKeys,
        requiredSlotKeys: requiredSlotKeys,
        optionalSlotKeys: optionalSlotKeys,
        defaultCount: 0,
      ));
    }
    shapeRowList.assignAll(rows);
    refreshShapeCountError();
  }

  /// 组装单行形态配置；每一行都包含自己需要点亮和标“不用”的槽位。
  ManageSentenceBlueprintGenerateShapeRowEntity _buildShapeRow({
    required String key,
    required List<String> openedSlotKeys,
    required List<String> requiredSlotKeys,
    required List<String> optionalSlotKeys,
    required int defaultCount,
  }) {
    final List<String> unusedSlotKeys = optionalSlotKeys.where((slotKey) => !openedSlotKeys.contains(slotKey)).toList();
    return ManageSentenceBlueprintGenerateShapeRowEntity(
      key: key,
      openedSlotKeys: openedSlotKeys,
      highlightSlotKeys: <String>[
        ...requiredSlotKeys,
        ...openedSlotKeys,
      ],
      unusedSlotKeys: unusedSlotKeys,
      countController: TextEditingController(text: '$defaultCount'),
    );
  }

  /// 刷新当前句数是否存在跳层或基句缺失。
  void refreshShapeCountError() {
    shapeCountErrorText.value = _buildShapeCountError();
  }

  /// 输入框失焦或提交时，把句数归一化到 0-6。
  void normalizeShapeCountInput(ManageSentenceBlueprintGenerateShapeRowEntity row) {
    final int value = _parseShapeCount(row.countController.text);
    final String normalizedText = '$value';
    if (row.countController.text != normalizedText) {
      row.countController.value = TextEditingValue(
        text: normalizedText,
        selection: TextSelection.collapsed(offset: normalizedText.length),
      );
    }
    refreshShapeCountError();
  }

  /// 当前是否已经至少填写了一行句数。
  bool hasAnyShapeCount() {
    for (final ManageSentenceBlueprintGenerateShapeRowEntity row in shapeRowList) {
      if (_parseShapeCount(row.countController.text) > 0) {
        return true;
      }
    }
    return false;
  }

  /// 构建层级句数校验文案，口径对齐 Web。
  String _buildShapeCountError() {
    final List<bool> enabledStates = shapeRowList.map((row) => _parseShapeCount(row.countController.text) > 0).toList();
    if (enabledStates.isEmpty || enabledStates.every((item) => !item)) {
      return '';
    }

    bool hasGap = false;
    for (final bool enabled in enabledStates) {
      if (!enabled) {
        hasGap = true;
        continue;
      }
      if (!hasGap) {
        continue;
      }
      if (enabledStates.first) {
        return '不能跳过中间层。缺的那一层和它后面的句子，请到金字塔组里补。';
      }
      return '后面的层要先有基句。不写基句、只补后面的层，请到金字塔组里从已有句子往上补。';
    }
    return '';
  }

  /// 解析并夹紧句数输入，保证始终落在 0-6。
  int _parseShapeCount(String text) {
    return max(0, min(6, int.tryParse(text.trim()) ?? 0));
  }

  /// 统一释放形态句数输入框控制器，避免页面销毁后残留。
  void _disposeShapeCountControllers() {
    for (final ManageSentenceBlueprintGenerateShapeRowEntity row in shapeRowList) {
      row.countController.dispose();
    }
  }

  /// 生成句型
  Future<void> generateSentenceBlueprint(BuildContext context) async {
    for (final ManageSentenceBlueprintGenerateShapeRowEntity row in shapeRowList) {
      normalizeShapeCountInput(row);
    }
    if (shapeCountErrorText.value.isNotEmpty) {
      ToastUtils.showToast(text: shapeCountErrorText.value);
      return;
    }
    if (!hasAnyShapeCount()) {
      ToastUtils.showToast(text: '请至少填写一行句数');
      return;
    }

    if (unitId == null || targetUid == null) {
      ToastUtils.showToast(text: '缺少单元或目标信息');
      return;
    }

    final List<Map<String, dynamic>> shapes = _buildCreateSentenceShapes();
    if (shapes.isEmpty) {
      ToastUtils.showToast(text: '请至少填写一行句数');
      return;
    }

    final List<int> knowledgeUids = _buildKnowledgeUids();
    ToastUtils.showLoading();
    try {
      final ResponseEntity<String>? response = await UnitUtil.createUnitGrammarSentenceByPattern(
        unitId: unitId.toString(),
        config: RequestConfig(
          requireToken: true,
          data: {
            'unitId': unitId,
            'targetUid': targetUid,
            'shapes': shapes,
            'knowledgeUids': knowledgeUids,
          },
        ),
      );
      if (response == null || isClosed) {
        return;
      }
      if (isClosed) return;

      await AskDialog.showUserCancelAsk(
        context: context,
        title: "后台生成中",
        content: response.data ?? "大约 5 分钟。完成后句子会出现在未归组池里。",
        define: "知道了",
        showCancel: false,
      );
      Get.back();
      
    } catch (_) {
      if (isClosed) return;
      ToastUtils.showToast(text: '生成句子失败');
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 把界面上的句数行转成接口要求的 shapes[]；0 句的行不提交。
  List<Map<String, dynamic>> _buildCreateSentenceShapes() {
    final List<Map<String, dynamic>> resp = <Map<String, dynamic>>[];
    for (final ManageSentenceBlueprintGenerateShapeRowEntity row in shapeRowList) {
      final int count = _parseShapeCount(row.countController.text);
      if (count <= 0) {
        continue;
      }
      resp.add({
        'activated_optional_slot_keys': row.openedSlotKeys,
        'count': count,
      });
    }
    return resp;
  }

  /// 指定词汇页选择的是单元知识 uid；不选时传空数组，表示使用本单元全部词汇。
  List<int> _buildKnowledgeUids() {
    final List<int> resp = <int>[];
    for (final KnowledgeCommonEntityList item in selectedVocabularyList) {
      final int? knowledgeUid = item.knowledgeId;
      if (knowledgeUid == null || knowledgeUid <= 0 || resp.contains(knowledgeUid)) {
        continue;
      }
      resp.add(knowledgeUid);
    }
    return resp;
  }
}

/// “这次写哪些形态”单行数据。
class ManageSentenceBlueprintGenerateShapeRowEntity {
  /// 当前行自己的 key；基句固定为 kernel，增长层用 slotKey。
  final String key;

  /// 当前行已经打开的增长槽。
  final List<String> openedSlotKeys;

  /// 当前行需要按正常态展示的槽位。
  final List<String> highlightSlotKeys;

  /// 当前行需要标成“不用”的槽位。
  final List<String> unusedSlotKeys;

  /// 当前行句数输入框。
  final TextEditingController countController;

  ManageSentenceBlueprintGenerateShapeRowEntity({
    required this.key,
    required this.openedSlotKeys,
    required this.highlightSlotKeys,
    required this.unusedSlotKeys,
    required this.countController,
  });
}

/// 增长槽排序项；先按 growthPriority，再按原始顺序兜底。
class _ManageSentenceBlueprintGrowthSlotEntry {
  final String slotKey;
  final int growthPriority;
  final int sourceIndex;

  const _ManageSentenceBlueprintGrowthSlotEntry({
    required this.slotKey,
    required this.growthPriority,
    required this.sourceIndex,
  });
}
