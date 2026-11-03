import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/zhenxie/common/zhenxie_beat_utils.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/common/mixins/mixins.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';

import '../../../../../routes/routes.dart';
import '../../../../../routes/tag_routes.dart';

class ManageUnitWritingPipelineController extends GetxController with DualBreadcrumbMixin {
  final String tagText;
  ManageUnitWritingPipelineController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.MANAGE_UNIT_WRITING_PIPELINE;

  @override
  String get breadcrumbTitle => '写作管线';

  int? unitId;
  bool isManagement = true;

  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final Rxn<CourseUnitWritingDetailEntity> detailData = Rxn<CourseUnitWritingDetailEntity>();
  final RxList<String> beatNidOrderList = <String>[].obs;
  final Map<String, ParagraphRhetoricalEntityList> beatMap = <String, ParagraphRhetoricalEntityList>{};
  final RxList<String> selectedTimes = <String>[].obs;
  final RxList<String> selectedAspects = <String>[].obs;
  final RxList<String> selectedVoices = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    final Map args = Get.arguments is Map ? Get.arguments : <String, dynamic>{};
    unitId = _parseInt(args['unitId']);
    final dynamic isManagementValue = args['isManagement'];
    if (isManagementValue != null) {
      isManagement = isManagementValue == true || isManagementValue.toString() == 'true';
    }
    fetchData();
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  Future<void> fetchData({bool showLoading = true}) async {
    if (unitId == null) {
      ToastUtils.showManageToast(text: '单元ID为空');
      return;
    }
    if (showLoading) {
      ToastUtils.showLoading();
    }
    try {
      isLoading.value = true;
      await ensureZhenxieBeatData();
      final CourseUnitWritingDetailEntity? response = await CourseConsoleRequest.getUnitWritingDetail(unitId!);
      if (response == null) {
        ToastUtils.showManageToast(text: '写作管线加载失败');
        return;
      }
      detailData.value = response;
      _syncScopeDraft(response.grammarScope);
    } finally {
      isLoading.value = false;
      if (showLoading) {
        ToastUtils.hideLoading();
      }
    }
  }

  void _syncScopeDraft(CourseUnitWritingGrammarScopeEntity? scope) {
    selectedTimes.assignAll(scope?.time ?? const <String>[]);
    selectedAspects.assignAll(scope?.aspect ?? const <String>[]);
    selectedVoices.assignAll(scope?.voice ?? const <String>[]);
  }

  void toggleTime(String code) {
    _toggleCode(selectedTimes, code);
  }

  void toggleAspect(String code) {
    _toggleCode(selectedAspects, code);
  }

  void toggleVoice(String code) {
    _toggleCode(selectedVoices, code);
  }

  void _toggleCode(RxList<String> values, String code) {
    if (values.contains(code)) {
      values.remove(code);
      return;
    }
    values.add(code);
  }

  bool canSaveGrammarScope() {
    final CourseUnitWritingDetailEntity? detail = detailData.value;
    return (detail?.stage?.nid ?? '').isNotEmpty && isGrammarScopeDirty();
  }

  bool isGrammarScopeDirty() {
    final CourseUnitWritingGrammarScopeEntity? current = detailData.value?.grammarScope;
    return !_isSameCodeList(selectedTimes, current?.time) ||
        !_isSameCodeList(selectedAspects, current?.aspect) ||
        !_isSameCodeList(selectedVoices, current?.voice);
  }

  bool _isSameCodeList(List<String> left, List<String>? right) {
    final List<String> rightList = right ?? const <String>[];
    if (left.length != rightList.length) return false;
    final List<String> leftSorted = List<String>.from(left)..sort();
    final List<String> rightSorted = List<String>.from(rightList)..sort();
    return listEquals(leftSorted, rightSorted);
  }

  Future<void> saveGrammarScope() async {
    if (!canSaveGrammarScope() || unitId == null || detailData.value == null) return;
    final String? stageNid = detailData.value?.stage?.nid;
    if ((stageNid ?? '').isEmpty) {
      ToastUtils.showManageToast(text: '当前未配置阶梯');
      return;
    }
    final Map<String, dynamic> data = <String, dynamic>{
      'stageNid': stageNid,
      'grammarScope': <String, dynamic>{
        'time': selectedTimes.toList(),
        'aspect': selectedAspects.toList(),
        'voice': selectedVoices.toList(),
      },
    };
    try {
      isSaving.value = true;
      ToastUtils.showLoading();
      final CourseUnitWritingDetailEntity? response = await CourseConsoleRequest.saveUnitWritingMount(unitId!, data);
      if (response == null) return;
      detailData.value = response;
      _syncScopeDraft(response.grammarScope);
      ToastUtils.showManageToast(text: '保存成功');
    } finally {
      isSaving.value = false;
      ToastUtils.hideLoading();
    }
  }

  Future<void> openTaskPage() async {
    if (unitId == null) {
      ToastUtils.showManageToast(text: '单元ID为空');
      return;
    }
    await TagRoutes.toNamed(
      Routes.MANAGE_UNIT_WRITING_TASK_LIST,
      arguments: <String, dynamic>{
        'unitId': unitId,
        'isManagement': true,
      },
    );
  }

  Future<void> openBlueprintPage() async {
    final Map<String, dynamic>? compositionBlueprint = detailData.value?.stage?.compositionBlueprint;
    final String familyNid = compositionBlueprint?['compositionFamilyNid']?.toString() ?? '';
    final String blueprintNid = compositionBlueprint?['nid']?.toString() ?? '';
    if (familyNid.isEmpty || blueprintNid.isEmpty) {
      ToastUtils.showManageToast(text: '当前阶梯未配置蓝图');
      return;
    }
    await TagRoutes.toNamed(
      Routes.ZHENXIE_ARTICLE_BLUEPRINT_DETAILS,
      arguments: <String, dynamic>{
        'nid': familyNid,
        'blueprintNid': blueprintNid,
        'isManagement': true,
      },
    );
  }

  Future<void> changeStage() async {
    if (unitId == null || detailData.value == null) {
      ToastUtils.showManageToast(text: '单元信息为空');
      return;
    }
    final dynamic result = await TagRoutes.toNamed(
      Routes.MANAGE_UNIT_WRITING_STAGE_PICK,
      arguments: <String, dynamic>{
        'unitId': unitId,
        'isManagement': true,
        'currentStage': detailData.value?.stage?.toJson(),
        'currentStageNid': detailData.value?.stage?.nid ?? '',
        'currentStageName': getLangText(detailData.value?.stage?.name, 'zh'),
        'taskCount': detailData.value?.taskCount ?? 0,
        'compositionTaskCount': detailData.value?.compositionTaskCount ?? 0,
      },
    );
    final String nextStageNid = result?.toString() ?? '';
    final String currentStageNid = detailData.value?.stage?.nid ?? '';
    if (nextStageNid.isEmpty || nextStageNid == currentStageNid) return;
    final Map<String, dynamic> data = <String, dynamic>{
      'stageNid': nextStageNid,
      'grammarScope': <String, dynamic>{
        'time': selectedTimes.toList(),
        'aspect': selectedAspects.toList(),
        'voice': selectedVoices.toList(),
      },
    };
    try {
      isSaving.value = true;
      ToastUtils.showLoading();
      final CourseUnitWritingDetailEntity? response = await CourseConsoleRequest.saveUnitWritingMount(unitId!, data);
      if (response == null) return;
      detailData.value = response;
      _syncScopeDraft(response.grammarScope);
      ToastUtils.showManageToast(text: '更换成功');
    } finally {
      isSaving.value = false;
      ToastUtils.hideLoading();
    }
  }

  String getLangText(List<LanguageText>? values, String lang) {
    if (values == null || values.isEmpty) return '';
    for (int i = 0; i < values.length; i++) {
      if (values[i].lang == lang) {
        return values[i].text ?? '';
      }
    }
    return '';
  }

  String getDifficultyLabel(CardContentDifficulty? difficulty) {
    final String minDifficultyLabel = DifficultieUtils.getLanguageDifficultieLevel1('en', difficulty?.min)?.name?.text ?? '';
    final String maxDifficultyLabel = DifficultieUtils.getLanguageDifficultieLevel1('en', difficulty?.max)?.name?.text ?? '';
    if (minDifficultyLabel.isEmpty || maxDifficultyLabel.isEmpty) return '';
    return minDifficultyLabel == maxDifficultyLabel ? minDifficultyLabel : '$minDifficultyLabel-$maxDifficultyLabel';
  }

  String getGenreLabel(String? genreNid) {
    if (genreNid == 'narrative') return '记叙文';
    if (genreNid == 'expository') return '说明文';
    if (genreNid == 'argumentative') return '议论文';
    if (genreNid == 'practical') return '应用文';
    return genreNid ?? '';
  }

  Color getGenreColor(String? genreNid) {
    if (genreNid == 'narrative') return AppTheme.cSurfaceWarning.color;
    if (genreNid == 'expository') return AppTheme.cSurfaceSuccess.color;
    if (genreNid == 'argumentative') return AppTheme.cSurfaceInfo.color;
    if (genreNid == 'practical') return AppTheme.cTextBrand.color;
    return AppTheme.cTextSecondary.color;
  }

  String getAnswerTypeText(String? answerKind) {
    if (answerKind == 'text') return '文字';
    if (answerKind == 'image') return '图片';
    if (answerKind == 'audio') return '音频';
    if (answerKind == 'video') return '视频';
    return '';
  }

  String getAnswerDetailText(CourseUnitWritingEditorStageEntity? stage) {
    if (stage == null || stage.answerKind == null || stage.answerKind == 'text') return '';
    final int? answerMinCount = stage.answerMinCount;
    final int? answerMaxCount = stage.answerMaxCount;
    if (answerMinCount != null && answerMaxCount != null) {
      if (answerMinCount == answerMaxCount) return '$answerMinCount份';
      return '$answerMinCount-$answerMaxCount份';
    }
    if (answerMinCount != null) return '$answerMinCount份';
    if (answerMaxCount != null) return '$answerMaxCount份';
    return '';
  }

  String getBeatName(String? beatNid) {
    if (beatNid == 'head') return '文首';
    if (beatNid == 'tail') return '文末';
    final ParagraphRhetoricalEntityList? beat = beatMap[beatNid];
    return getLangText((beat?.name ?? const <LanguageText?>[]).whereType<LanguageText>().toList(), 'zh');
  }
}
