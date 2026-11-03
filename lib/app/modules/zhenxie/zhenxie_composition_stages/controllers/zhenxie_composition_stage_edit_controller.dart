import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/mixins/mixins.dart';
import '../../../../../utils/utils.dart';
import '../models/zhenxie_composition_stages_models.dart';

class ZhenxieCompositionStageEditController extends GetxController with DualBreadcrumbMixin {
  final String tagText;

  ZhenxieCompositionStageEditController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.ZHENXIE_COMPOSITION_STAGE_EDIT;

  @override
  String get breadcrumbTitle => '编辑写作阶梯';

  bool isManagement = false;
  String stageNid = '';

  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final Rxn<CompositionStageModel> detailData = Rxn<CompositionStageModel>();
  final RxList<CompositionStageMilestoneLiteModel> milestoneOptions = <CompositionStageMilestoneLiteModel>[].obs;
  final RxList<ParagraphRhetoricalEntityList> beatList = <ParagraphRhetoricalEntityList>[].obs;

  final TextEditingController nameZhController = TextEditingController();
  final TextEditingController nameEnController = TextEditingController();
  final TextEditingController descriptionZhController = TextEditingController();
  final TextEditingController descriptionEnController = TextEditingController();
  final TextEditingController orderController = TextEditingController();
  final TextEditingController answerMinCountController = TextEditingController();
  final TextEditingController answerMaxCountController = TextEditingController();

  final Map<String, ParagraphRhetoricalEntityList> beatMap = <String, ParagraphRhetoricalEntityList>{};

  final List<int> difficultyLevelList = <int>[0, 1, 2, 3, 4, 5, 6];
  final List<String> answerKindList = <String>['text', 'image', 'video', 'audio'];
  final List<String> fillList = <String>['write', 'given', 'hidden'];

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    final dynamic arguments = Get.arguments;
    if (arguments is Map<String, dynamic>) {
      stageNid = arguments['stageNid']?.toString() ?? '';
      isManagement = arguments['isManagement'] == true;
    }
    initData();
  }

  @override
  void onClose() {
    nameZhController.dispose();
    nameEnController.dispose();
    descriptionZhController.dispose();
    descriptionEnController.dispose();
    orderController.dispose();
    answerMinCountController.dispose();
    answerMaxCountController.dispose();
    super.onClose();
  }

  Future<void> initData() async {
    if (stageNid.isEmpty) {
      ToastUtils.showManageToast(text: '阶梯 nid 缺失');
      return;
    }
    try {
      isLoading.value = true;
      ToastUtils.showLoading();
      final List<dynamic> responses = await Future.wait<dynamic>([
        LanguageConsoleRequest.getWriteCompositionStageDetail(stageNid: stageNid),
        LanguageConsoleRequest.getWriteCompositionMilestoneList(),
        LanguageUtil.getParagraphRhetoricalList(),
      ]);

      final Map<String, dynamic>? detailResponse = responses[0] as Map<String, dynamic>?;
      final List<Map<String, dynamic>>? milestoneResponse = responses[1] as List<Map<String, dynamic>>?;
      final ParagraphRhetoricalEntity? beatResponse = responses[2] as ParagraphRhetoricalEntity?;

      if (detailResponse == null) return;

      detailData.value = CompositionStageModel.fromJson(detailResponse);
      milestoneOptions.assignAll(
        (milestoneResponse ?? <Map<String, dynamic>>[])
            .map(CompositionStageMilestoneLiteModel.fromJson)
            .toList(),
      );
      _rebuildBeatMap(beatResponse);
      _syncEditingControllers();
    } finally {
      ToastUtils.hideLoading();
      isLoading.value = false;
    }
  }

  String getLangText(List<LanguageText>? values, String lang) {
    if (values == null || values.isEmpty) return '';
    for (int i = 0; i < values.length; i++) {
      final LanguageText item = values[i];
      if ((item.lang ?? '').toLowerCase() == lang.toLowerCase()) {
        return item.text ?? '';
      }
    }
    return '';
  }

  String getBeatName(String? beatNid) {
    if (beatNid == 'head') return '文首';
    if (beatNid == 'tail') return '文末';
    final ParagraphRhetoricalEntityList? beat = beatMap[beatNid];
    if (beat == null) return '';
    return getLangText((beat.name ?? const <LanguageText?>[]).whereType<LanguageText>().toList(), 'zh');
  }

  String getBeatDescription(String? beatNid) {
    final ParagraphRhetoricalEntityList? beat = beatMap[beatNid];
    if (beat == null) return '';
    return getLangText((beat.description ?? const <LanguageText?>[]).whereType<LanguageText>().toList(), 'zh');
  }

  String getFillLabel(String fill) {
    if (fill == 'write') return '写';
    if (fill == 'given') return '给';
    if (fill == 'hidden') return '藏';
    return '';
  }

  String getAnswerKindLabel(String kind) {
    if (kind == 'text') return '文本';
    if (kind == 'image') return '图片';
    if (kind == 'video') return '视频';
    if (kind == 'audio') return '音频';
    return kind;
  }

  String getDifficultyLabel(int level) {
    return DifficultieUtils.getLanguageDifficultieLevel1('en', level)?.name?.text ?? '';
  }

  String getMilestoneLabel(CompositionStageMilestoneLiteModel milestone) {
    return getLangText(milestone.name, 'zh');
  }

  String getParagraphTypeLabel(String? beatNid, String? paragraphTypeNid) {
    final List<CompositionBlueprintAllowedParagraphModel> options = buildAllowedParagraphs(beatNid);
    for (int i = 0; i < options.length; i++) {
      if (options[i].paragraphTypeNid == paragraphTypeNid) {
        return getLangText(options[i].paragraphTypeName, 'zh');
      }
    }
    return '';
  }

  String getCoverUrl() {
    final CompositionStageModel? stage = detailData.value;
    if ((stage?.coverUrl ?? '').isNotEmpty) return stage!.coverUrl!;
    if ((stage?.compositionBlueprint?.coverUrl ?? '').isNotEmpty) return stage!.compositionBlueprint!.coverUrl!;
    return '';
  }

  String getBlueprintName() {
    return getLangText(detailData.value?.compositionBlueprint?.name, 'zh');
  }

  String getBlueprintDescription() {
    return getLangText(detailData.value?.compositionBlueprint?.description, 'zh');
  }

  String getStageTitle() {
    return getLangText(detailData.value?.name, 'zh');
  }

  bool hasHead() {
    return detailData.value?.headFill != null;
  }

  bool hasTail() {
    return detailData.value?.tailFill != null;
  }

  String getHeadLabel() {
    return getLangText(detailData.value?.compositionBlueprint?.frame?.headName, 'zh');
  }

  String getTailLabel() {
    return getLangText(detailData.value?.compositionBlueprint?.frame?.tailName, 'zh');
  }

  int getDifficultyMin() {
    return detailData.value?.difficulty?.min ?? 0;
  }

  int getDifficultyMax() {
    return detailData.value?.difficulty?.max ?? 0;
  }

  String getAnswerKind() {
    return detailData.value?.answerKind ?? answerKindList.first;
  }

  String getHeadFill() {
    return detailData.value?.headFill ?? 'hidden';
  }

  String getTailFill() {
    return detailData.value?.tailFill ?? 'hidden';
  }

  List<CompositionStageSlotModel> buildEditableSlots() {
    final List<CompositionStageSlotModel> slots = List<CompositionStageSlotModel>.from(
      detailData.value?.slots ?? const <CompositionStageSlotModel>[],
    );
    slots.sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));
    return slots;
  }

  List<CompositionBlueprintAllowedParagraphModel> buildAllowedParagraphs(String? beatNid) {
    final List<CompositionBlueprintSlotModel> slots = detailData.value?.compositionBlueprint?.slots ?? const <CompositionBlueprintSlotModel>[];
    for (int i = 0; i < slots.length; i++) {
      if (slots[i].beatNid == beatNid) {
        return slots[i].allowedParagraphs;
      }
    }
    return const <CompositionBlueprintAllowedParagraphModel>[];
  }

  void updateName(String lang, String text) {
    final CompositionStageModel? stage = detailData.value;
    if (stage == null) return;
    stage.name = _writeLang(stage.name, lang, text);
    detailData.refresh();
  }

  void updateDescription(String lang, String text) {
    final CompositionStageModel? stage = detailData.value;
    if (stage == null) return;
    stage.description = _writeLang(stage.description, lang, text);
    detailData.refresh();
  }

  void updateOrder(String text) {
    final CompositionStageModel? stage = detailData.value;
    final int? value = int.tryParse(text);
    if (stage == null || value == null) return;
    stage.order = value;
    detailData.refresh();
  }

  void updateDifficultyMin(int value) {
    final CompositionStageModel? stage = detailData.value;
    if (stage == null) return;
    stage.difficulty ??= CardContentDifficulty();
    stage.difficulty!.min = value;
    detailData.refresh();
  }

  void updateDifficultyMax(int value) {
    final CompositionStageModel? stage = detailData.value;
    if (stage == null) return;
    stage.difficulty ??= CardContentDifficulty();
    stage.difficulty!.max = value;
    detailData.refresh();
  }

  void updateLockBlueprintTab(bool value) {
    final CompositionStageModel? stage = detailData.value;
    if (stage == null) return;
    stage.lockBlueprintTab = value;
    detailData.refresh();
  }

  void updateLockExemplarView(bool value) {
    final CompositionStageModel? stage = detailData.value;
    if (stage == null) return;
    stage.lockExemplarView = value;
    detailData.refresh();
  }

  void updateAnswerKind(String value) {
    final CompositionStageModel? stage = detailData.value;
    if (stage == null) return;
    stage.answerKind = value;
    if (value == 'text') {
      stage.answerMinCount = 1;
      stage.answerMaxCount = 1;
      answerMinCountController.text = '1';
      answerMaxCountController.text = '1';
    }
    detailData.refresh();
  }

  void updateAnswerMinCount(String text) {
    final CompositionStageModel? stage = detailData.value;
    final int? value = int.tryParse(text);
    if (stage == null || value == null) return;
    stage.answerMinCount = value;
    detailData.refresh();
  }

  void updateAnswerMaxCount(String text) {
    final CompositionStageModel? stage = detailData.value;
    final int? value = int.tryParse(text);
    if (stage == null || value == null) return;
    stage.answerMaxCount = value;
    detailData.refresh();
  }

  void updateHeadFill(String fill) {
    final CompositionStageModel? stage = detailData.value;
    if (stage == null) return;
    stage.headFill = fill;
    detailData.refresh();
  }

  void updateTailFill(String fill) {
    final CompositionStageModel? stage = detailData.value;
    if (stage == null) return;
    stage.tailFill = fill;
    detailData.refresh();
  }

  void updateSlotParagraphType(String beatNid, String? paragraphTypeNid) {
    if (paragraphTypeNid == null || paragraphTypeNid.isEmpty) return;
    final CompositionStageModel? stage = detailData.value;
    if (stage == null) return;
    for (int i = 0; i < stage.slots.length; i++) {
      if (stage.slots[i].beatNid == beatNid) {
        stage.slots[i].paragraphTypeNid = paragraphTypeNid;
        detailData.refresh();
        return;
      }
    }
  }

  void updateSlotFill(String beatNid, String fill) {
    final CompositionStageModel? stage = detailData.value;
    if (stage == null) return;
    for (int i = 0; i < stage.slots.length; i++) {
      if (stage.slots[i].beatNid == beatNid) {
        stage.slots[i].fill = fill;
        detailData.refresh();
        return;
      }
    }
  }

  void toggleMilestone(String nid) {
    final CompositionStageModel? stage = detailData.value;
    if (stage == null || nid.isEmpty) return;
    final List<String> next = List<String>.from(stage.milestones);
    if (next.contains(nid)) {
      next.remove(nid);
    } else {
      next.add(nid);
    }
    stage.milestones = next;
    detailData.refresh();
  }

  Future<void> save() async {
    final CompositionStageModel? stage = detailData.value;
    if (stage == null || isSaving.value) return;

    final String nameZh = nameZhController.text.trim();
    final String nameEn = nameEnController.text.trim();
    final String descriptionZh = descriptionZhController.text.trim();
    final String descriptionEn = descriptionEnController.text.trim();
    final int? order = int.tryParse(orderController.text.trim());
    final int? answerMinCount = int.tryParse(answerMinCountController.text.trim());
    final int? answerMaxCount = int.tryParse(answerMaxCountController.text.trim());

    if (nameZh.isEmpty || nameEn.isEmpty || descriptionZh.isEmpty || descriptionEn.isEmpty) {
      ToastUtils.showManageToast(text: '中英文名字和说明都要填');
      return;
    }
    if (getDifficultyMin() > getDifficultyMax()) {
      ToastUtils.showManageToast(text: '难度下限不能大于上限');
      return;
    }
    if (order == null || answerMinCount == null || answerMaxCount == null) {
      ToastUtils.showManageToast(text: '请完整填写数字字段');
      return;
    }
    if (answerMinCount > answerMaxCount) {
      ToastUtils.showManageToast(text: '作答最少不能大于最多');
      return;
    }

    stage.name = _writeLang(stage.name, 'zh', nameZh);
    stage.name = _writeLang(stage.name, 'en', nameEn);
    stage.description = _writeLang(stage.description, 'zh', descriptionZh);
    stage.description = _writeLang(stage.description, 'en', descriptionEn);
    stage.order = order;
    stage.answerMinCount = getAnswerKind() == 'text' ? 1 : answerMinCount;
    stage.answerMaxCount = getAnswerKind() == 'text' ? 1 : answerMaxCount;
    stage.headFill = hasHead() ? getHeadFill() : 'hidden';
    stage.tailFill = hasTail() ? getTailFill() : 'hidden';

    final Map<String, dynamic> payload = <String, dynamic>{
      'nid': stage.nid,
      'name': stage.name.map((item) => item.toJson()).toList(),
      'description': stage.description.map((item) => item.toJson()).toList(),
      'difficulty': <String, dynamic>{
        'min': getDifficultyMin(),
        'max': getDifficultyMax(),
      },
      'order': stage.order,
      'lockBlueprintTab': stage.lockBlueprintTab ?? false,
      'lockExemplarView': stage.lockExemplarView ?? false,
      'answerKind': getAnswerKind(),
      'answerMinCount': stage.answerMinCount,
      'answerMaxCount': stage.answerMaxCount,
      'slots': stage.slots.map((item) => item.toJson()).toList(),
      'headFill': stage.headFill,
      'tailFill': stage.tailFill,
      'milestones': stage.milestones,
    };

    try {
      isSaving.value = true;
      ToastUtils.showLoading();
      final Map<String, dynamic>? response = await LanguageConsoleRequest.editWriteCompositionStage(data: payload);
      if (response == null) return;
      detailData.value = CompositionStageModel.fromJson(response);
      _syncEditingControllers();
      ToastUtils.showManageToast(text: '保存成功');
      Get.back(result: true);
    } finally {
      ToastUtils.hideLoading();
      isSaving.value = false;
    }
  }

  void _syncEditingControllers() {
    final CompositionStageModel? stage = detailData.value;
    if (stage == null) return;
    nameZhController.text = getLangText(stage.name, 'zh');
    nameEnController.text = getLangText(stage.name, 'en');
    descriptionZhController.text = getLangText(stage.description, 'zh');
    descriptionEnController.text = getLangText(stage.description, 'en');
    orderController.text = stage.order?.toString() ?? '';
    answerMinCountController.text = stage.answerMinCount?.toString() ?? '';
    answerMaxCountController.text = stage.answerMaxCount?.toString() ?? '';
  }

  void _rebuildBeatMap(ParagraphRhetoricalEntity? beatResponse) {
    final List<ParagraphRhetoricalEntityList> nextBeatList = (beatResponse?.list ?? const <ParagraphRhetoricalEntityList?>[])
        .whereType<ParagraphRhetoricalEntityList>()
        .toList();
    beatList.assignAll(nextBeatList);
    beatMap
      ..clear()
      ..addEntries(nextBeatList.map((item) => MapEntry(item.nid ?? '', item)));
  }

  List<LanguageText> _writeLang(List<LanguageText> items, String lang, String text) {
    final List<LanguageText> next = items.where((item) => (item.lang ?? '').toLowerCase() != lang.toLowerCase()).toList();
    next.add(LanguageText(lang: lang, text: text));
    next.sort((a, b) {
      final int aValue = (a.lang ?? '') == 'zh' ? 1 : 0;
      final int bValue = (b.lang ?? '') == 'zh' ? 1 : 0;
      return bValue.compareTo(aValue);
    });
    return next;
  }
}
