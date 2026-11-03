import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/zhenxie/common/zhenxie_write_catalog_card_data.dart';
import 'package:langwise/app/modules/zhenxie/common/zhenxie_beat_utils.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/common/mixins/mixins.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:langwise/utils/oss_upload_file_utils/oss_update_response_entity.dart';
import 'package:langwise/utils/oss_upload_file_utils/oss_upload_file_utils.dart';

import '../../../../../routes/routes.dart';

class ManageUnitWritingTaskEditorController extends GetxController with DualBreadcrumbMixin {
  final String tagText;
  ManageUnitWritingTaskEditorController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.MANAGE_UNIT_WRITING_TASK_EDITOR;

  @override
  String get breadcrumbTitle => taskId == null ? '新建单元写作任务' : '编辑单元写作任务';

  int? unitId;
  int? taskId;
  bool isManagement = true;

  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxInt currentStep = 1.obs;
  final RxInt formRefreshSignal = 0.obs;
  final Rxn<CourseUnitWritingTaskEditorPageEntity> editorData = Rxn<CourseUnitWritingTaskEditorPageEntity>();
  final RxList<String> beatNidOrderList = <String>[].obs;
  final Map<String, ParagraphRhetoricalEntityList> beatMap = <String, ParagraphRhetoricalEntityList>{};

  final TextEditingController nameZhController = TextEditingController();
  final TextEditingController nameEnController = TextEditingController();
  final TextEditingController stemZhController = TextEditingController();
  final TextEditingController stemEnController = TextEditingController();
  final RxList<String> stemImages = <String>[].obs;
  final RxList<String> stemImageUrls = <String>[].obs;
  final RxList<String> stemImageInputUids = <String>[].obs;
  final RxList<String> stemAudios = <String>[].obs;
  final RxList<String> stemAudioUrls = <String>[].obs;
  final RxString stemAudioInputUid = ''.obs;
  final RxList<String> stemVideos = <String>[].obs;
  final RxList<String> stemVideoUrls = <String>[].obs;
  final RxString stemVideoInputUid = ''.obs;
  final RxnInt answerCount = RxnInt();
  final RxBool showStemAudioEditor = false.obs;
  final RxBool showStemVideoEditor = false.obs;
  final RxList<CourseUnitWritingKnowledgePointEntity> selectedKnowledgePoints = <CourseUnitWritingKnowledgePointEntity>[].obs;
  final RxList<int> selectedGrammarTargetUids = <int>[].obs;

  @override
  void onInit() {
    super.onInit();
    // initBreadcrumb(tagText);
    nameZhController.addListener(_handleFormChanged);
    nameEnController.addListener(_handleFormChanged);
    stemZhController.addListener(_handleFormChanged);
    stemEnController.addListener(_handleFormChanged);
    final Map args = Get.arguments is Map ? Get.arguments : const {};
    final dynamic unitIdValue = args['unitId'];
    final dynamic taskIdValue = args['taskId'];
    initBreadcrumb(tagText,title: taskId == null ? '新建单元写作任务' : '编辑单元写作任务');
    unitId = unitIdValue is int ? unitIdValue : int.tryParse(unitIdValue?.toString() ?? '');
    taskId = taskIdValue is int ? taskIdValue : int.tryParse(taskIdValue?.toString() ?? '');
    final dynamic isManagementValue = args['isManagement'];
    if (isManagementValue != null) {
      isManagement = isManagementValue == true || isManagementValue.toString() == 'true';
    }
    fetchData();
  }

  @override
  void onClose() {
    nameZhController.removeListener(_handleFormChanged);
    nameEnController.removeListener(_handleFormChanged);
    stemZhController.removeListener(_handleFormChanged);
    stemEnController.removeListener(_handleFormChanged);
    nameZhController.dispose();
    nameEnController.dispose();
    stemZhController.dispose();
    stemEnController.dispose();
    super.onClose();
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
      final CourseUnitWritingTaskEditorPageEntity? response = await CourseConsoleRequest.getUnitWritingTaskEditor(
        unitId!,
        taskId: taskId,
      );
      if (response == null) {
        ToastUtils.showManageToast(text: '写作任务编辑页加载失败');
        return;
      }
      editorData.value = response;
      final CourseUnitWritingEditorTaskEntity? task = response.task;
      nameZhController.text = getLangText(task?.name, 'zh');
      nameEnController.text = getLangText(task?.name, 'en', fallbackToFirst: false);
      stemZhController.text = getLangText(task?.stem, 'zh');
      stemEnController.text = getLangText(task?.stem, 'en', fallbackToFirst: false);
      stemImages.assignAll(task?.stemImages ?? const <String>[]);
      stemImageUrls.assignAll(task?.stemImageUrls ?? const <String>[]);
      stemImageInputUids.assignAll(List<String>.filled(stemImages.length, ''));
      stemAudios.assignAll(task?.stemAudios ?? const <String>[]);
      stemAudioUrls.assignAll(task?.stemAudioUrls ?? const <String>[]);
      stemAudioInputUid.value = '';
      stemVideos.assignAll(task?.stemVideos ?? const <String>[]);
      stemVideoUrls.assignAll(task?.stemVideoUrls ?? const <String>[]);
      stemVideoInputUid.value = '';
      answerCount.value = task?.answerCount ?? response.stage?.answerMinCount;
      showStemAudioEditor.value = stemAudios.isNotEmpty || stemAudioUrls.isNotEmpty;
      showStemVideoEditor.value = stemVideos.isNotEmpty || stemVideoUrls.isNotEmpty;
      selectedKnowledgePoints.assignAll(task?.knowledgePoints ?? const <CourseUnitWritingKnowledgePointEntity>[]);
      selectedGrammarTargetUids.assignAll(task?.grammarTargetUids ?? const <int>[]);
    } finally {
      isLoading.value = false;
      if (showLoading) {
        ToastUtils.hideLoading();
      }
    }
  }

  void _handleFormChanged() {
    formRefreshSignal.value += 1;
  }

  void toPrevStep() {
    if (currentStep.value > 1) {
      currentStep.value -= 1;
    }
  }

  void toNextStep() {
    if (currentStep.value < 4 && canGoNext(editorData.value)) {
      currentStep.value += 1;
    }
  }

  void setAnswerCount(int count) {
    answerCount.value = count;
  }

  void setStemImageCount(int count) {
    final List<String> nextKeys = List<String>.from(stemImages);
    final List<String> nextUrls = List<String>.from(stemImageUrls);
    final List<String> nextInputUids = List<String>.from(stemImageInputUids);
    if (count < nextKeys.length) {
      nextKeys.removeRange(count, nextKeys.length);
    }
    if (count < nextUrls.length) {
      nextUrls.removeRange(count, nextUrls.length);
    }
    if (count < nextInputUids.length) {
      nextInputUids.removeRange(count, nextInputUids.length);
    }
    while (nextKeys.length < count) {
      nextKeys.add('');
    }
    while (nextUrls.length < count) {
      nextUrls.add('');
    }
    while (nextInputUids.length < count) {
      nextInputUids.add('');
    }
    stemImages.assignAll(nextKeys);
    stemImageUrls.assignAll(nextUrls);
    stemImageInputUids.assignAll(nextInputUids);
  }

  Future<void> setStemImageByInput(int index, String value) async {
    if (index < 0 || index >= stemImages.length) return;
    final String uidText = value.trim();
    final int? imageId = int.tryParse(uidText);
    if (imageId == null) {
      ToastUtils.showManageToast(text: '请输入正确的图片UID');
      return;
    }
    try {
      ToastUtils.showLoading();
      final ContentReviewImage? imageInfo = await LanguageConsoleRequest.queryReviewImageInfo(
        parameters: <String, dynamic>{
          'imageId': imageId,
        },
      );
      final String imageKey = imageInfo?.imageKey ?? '';
      if (imageInfo == null || imageKey.isEmpty) {
        ToastUtils.showManageToast(text: '未找到对应图片素材');
        return;
      }
      stemImages[index] = imageKey;
      if (stemImageUrls.length <= index) {
        stemImageUrls.assignAll(List<String>.from(stemImageUrls)..addAll(List<String>.filled(index + 1 - stemImageUrls.length, '')));
      }
      stemImageUrls[index] = imageInfo.imageUrl ?? '';
      if (stemImageInputUids.length <= index) {
        stemImageInputUids.assignAll(List<String>.from(stemImageInputUids)..addAll(List<String>.filled(index + 1 - stemImageInputUids.length, '')));
      }
      stemImageInputUids[index] = uidText;
      stemImages.refresh();
      stemImageUrls.refresh();
      stemImageInputUids.refresh();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<void> uploadStemImage(BuildContext context, int index) async {
    if (index < 0 || index >= stemImages.length) return;
    final FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg', 'webp'],
    );
    final String? filePath = result?.files.single.path;
    if (filePath == null) return;
    final File file = File(filePath);
    try {
      ToastUtils.showLoading();
      final OssUpdateResponseEntity? record = await OssUploadFileUtils.uploadManageFile(
        filePath: file.path,
        fileModule: OssFileManageModule.scriptTmp,
        fileType: OssFileManageType.image,
      );
      if (record == null || (record.key ?? '').isEmpty) return;
      stemImages[index] = record.key ?? '';
      if (stemImageUrls.length <= index) {
        stemImageUrls.assignAll(List<String>.from(stemImageUrls)..addAll(List<String>.filled(index + 1 - stemImageUrls.length, '')));
      }
      stemImageUrls[index] = record.url ?? '';
      if (stemImageInputUids.length <= index) {
        stemImageInputUids.assignAll(List<String>.from(stemImageInputUids)..addAll(List<String>.filled(index + 1 - stemImageInputUids.length, '')));
      }
      stemImageInputUids[index] = '';
      stemImages.refresh();
      stemImageUrls.refresh();
      stemImageInputUids.refresh();
      ToastUtils.showManageToast(text: '图片上传成功');
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<void> setStemAudioByInput(String value) async {
    final int? audioId = int.tryParse(value.trim());
    if (audioId == null) {
      ToastUtils.showManageToast(text: '请输入正确的音频UID');
      return;
    }
    showStemAudioEditor.value = true;
    try {
      ToastUtils.showLoading();
      final ManageAudioProjectEntityAudioInfo? audioInfo = await LanguageConsoleRequest.queryAudioInfo(
        parameters: <String, dynamic>{
          'audioId': audioId,
        },
      );
      final String audioKey = audioInfo?.fileKey ?? '';
      if (audioInfo == null || audioKey.isEmpty) {
        ToastUtils.showManageToast(text: '未找到对应音频素材');
        return;
      }
      stemAudios.assignAll(<String>[audioKey]);
      stemAudioUrls.assignAll(<String>[audioInfo.audioUrl ?? '']);
      stemAudioInputUid.value = audioId.toString();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  void enableStemAudioEditor() {
    showStemAudioEditor.value = true;
  }

  Future<void> uploadStemAudio() async {
    final FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'm4a', 'aac'],
    );
    if (result == null || result.files.single.path == null) return;
    try {
      ToastUtils.showLoading();
      final OssUpdateResponseEntity? record = await OssUploadFileUtils.uploadManageFile(
        filePath: result.files.single.path!,
        fileModule: OssFileManageModule.scriptTmp,
        fileType: OssFileManageType.track,
      );
      if (record == null || (record.key ?? '').isEmpty) return;
      stemAudios.assignAll(<String>[record.key ?? '']);
      stemAudioUrls.assignAll(<String>[record.url ?? '']);
      stemAudioInputUid.value = '';
      ToastUtils.showManageToast(text: '音频上传成功');
    } finally {
      ToastUtils.hideLoading();
    }
  }

  void clearStemAudio() {
    showStemAudioEditor.value = false;
    stemAudios.clear();
    stemAudioUrls.clear();
    stemAudioInputUid.value = '';
  }

  Future<void> setStemVideoByInput(String value) async {
    final int? videoId = int.tryParse(value.trim());
    if (videoId == null) {
      ToastUtils.showManageToast(text: '请输入正确的视频UID');
      return;
    }
    showStemVideoEditor.value = true;
    try {
      ToastUtils.showLoading();
      final TeamStyleEntityStyleItemsVideo? videoInfo = await LanguageConsoleRequest.queryVideoInfo(
        parameters: <String, dynamic>{
          'videoId': videoId,
        },
      );
      final String videoKey = videoInfo?.videoKey ?? '';
      if (videoInfo == null || videoKey.isEmpty) {
        ToastUtils.showManageToast(text: '未找到对应视频素材');
        return;
      }
      stemVideos.assignAll(<String>[videoKey]);
      stemVideoUrls.assignAll(<String>[videoInfo.videoUrl ?? '']);
      stemVideoInputUid.value = videoId.toString();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  void enableStemVideoEditor() {
    showStemVideoEditor.value = true;
  }

  Future<void> uploadStemVideo() async {
    final FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp4', 'mov', 'm4v'],
    );
    if (result == null || result.files.single.path == null) return;
    try {
      ToastUtils.showLoading();
      final OssUpdateResponseEntity? record = await OssUploadFileUtils.uploadManageFile(
        filePath: result.files.single.path!,
        fileModule: OssFileManageModule.scriptTmp,
        fileType: OssFileManageType.video,
      );
      if (record == null || (record.key ?? '').isEmpty) return;
      stemVideos.assignAll(<String>[record.key ?? '']);
      stemVideoUrls.assignAll(<String>[record.url ?? '']);
      stemVideoInputUid.value = '';
      ToastUtils.showManageToast(text: '视频上传成功');
    } finally {
      ToastUtils.hideLoading();
    }
  }

  void clearStemVideo() {
    showStemVideoEditor.value = false;
    stemVideos.clear();
    stemVideoUrls.clear();
    stemVideoInputUid.value = '';
  }

  Future<void> submitTask() async {
    if (isSaving.value) return;
    final CourseUnitWritingTaskEditorPageEntity? pageData = editorData.value;
    if (unitId == null || pageData == null) {
      ToastUtils.showManageToast(text: '写作任务数据为空');
      return;
    }
    final List<String> issues = collectIssues(pageData);
    if (issues.isNotEmpty) {
      ToastUtils.showManageToast(text: issues.first);
      return;
    }
    final Map<String, dynamic> data = <String, dynamic>{
      'name': _buildLanguageTextList(
        zhText: nameZhController.text,
        enText: nameEnController.text,
      ).map((item) => item.toJson()).toList(),
      'stem': _buildLanguageTextList(
        zhText: stemZhController.text,
        enText: stemEnController.text,
      ).map((item) => item.toJson()).toList(),
      'stemImages': stemImages.where((item) => item.isNotEmpty).toList(),
      'stemAudios': stemAudios.where((item) => item.isNotEmpty).toList(),
      'stemVideos': stemVideos.where((item) => item.isNotEmpty).toList(),
      'knowledgePoints': selectedKnowledgePoints.map((item) => item.toJson()).toList(),
      'grammarTargetUids': selectedGrammarTargetUids.toList(),
      'dropExemplar': false,
    };
    if (answerCount.value != null) {
      data['answerCount'] = answerCount.value;
    }
    if ((pageData.unitWriting?.stage?.nid ?? '').isEmpty && (pageData.stage?.nid ?? '').isNotEmpty) {
      data['stageNid'] = pageData.stage!.nid;
    }
    if (taskId != null) {
      data['taskId'] = taskId;
    }
    try {
      isSaving.value = true;
      ToastUtils.showLoading();
      final CourseUnitWritingEditorTaskEntity? response = taskId == null
          ? await CourseConsoleRequest.createUnitWritingTask(unitId!, data)
          : await CourseConsoleRequest.editUnitWritingTask(unitId!, data);
      if (response == null) {
        // ToastUtils.showManageToast(text: taskId == null ? '创建失败' : '编辑失败');
        return;
      }
      ToastUtils.showManageToast(text: taskId == null ? '创建成功' : '编辑成功');
      Get.back(result: true);
    } finally {
      isSaving.value = false;
      ToastUtils.hideLoading();
    }
  }

  String getLangText(List<LanguageText>? values, String lang, {bool fallbackToFirst = true}) {
    if (values == null || values.isEmpty) return '';
    for (int i = 0; i < values.length; i++) {
      if ((values[i].lang ?? '').toLowerCase() == lang.toLowerCase()) {
        return values[i].text ?? '';
      }
    }
    if (!fallbackToFirst) return '';
    return values.first.text ?? '';
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

  bool shouldShowAnswerCountEditor(StageCardData? stage) {
    if (stage == null || stage.answerKind == 'text') return false;
    final int? answerMinCount = stage.answerMinCount;
    final int? answerMaxCount = stage.answerMaxCount;
    if (answerMinCount == null || answerMaxCount == null) return false;
    return answerMaxCount > answerMinCount;
  }

  bool isMediaStepDone() {
    for (int index = 0; index < stemImages.length; index++) {
      if (stemImages[index].trim().isEmpty) return false;
    }
    if (showStemAudioEditor.value) {
      if (stemAudios.isEmpty || stemAudios.first.trim().isEmpty) return false;
    }
    if (showStemVideoEditor.value) {
      if (stemVideos.isEmpty || stemVideos.first.trim().isEmpty) return false;
    }
    return true;
  }

  bool isStepDone(CourseUnitWritingTaskEditorPageEntity? pageData, int step) {
    if (step == 1) {
      if (nameZhController.text.trim().isEmpty || stemZhController.text.trim().isEmpty || pageData?.stage == null) {
        return false;
      }
      if (requiresAnswerCount(pageData?.stage) && answerCount.value == null) {
        return false;
      }
      return true;
    }
    if (step == 2) {
      return isMediaStepDone();
    }
    if (step == 3) {
      return selectedKnowledgePoints.any((item) => (item.contentType ?? '') != 'EN_SENTENCE') || selectedGrammarTargetUids.isNotEmpty;
    }
    return false;
  }

  bool requiresAnswerCount(StageCardData? stage) {
    if (stage == null || stage.answerKind == 'text') return false;
    return (stage.answerMinCount ?? 0) > 0 || (stage.answerMaxCount ?? 0) > 0;
  }

  bool canGoNext(CourseUnitWritingTaskEditorPageEntity? pageData) {
    if (currentStep.value == 3) return true;
    return isStepDone(pageData, currentStep.value);
  }

  List<String> collectIssues(CourseUnitWritingTaskEditorPageEntity? pageData) {
    final List<String> issues = <String>[];
    if (pageData?.stage == null) {
      issues.add('当前未配置写作阶梯');
    }
    if (nameZhController.text.trim().isEmpty) {
      issues.add('请填写中文短名');
    }
    if (stemZhController.text.trim().isEmpty) {
      issues.add('请填写中文题干');
    }
    if (requiresAnswerCount(pageData?.stage) && answerCount.value == null) {
      issues.add('请设置作答份数');
    }
    if (!isMediaStepDone()) {
      issues.add('题面媒体还有未填写的素材');
    }
    return issues;
  }

  bool isLexicalKnowledgeItem(CourseUnitWritingEditorKnowledgeItemEntity item) {
    return (item.contentType ?? '') != 'EN_SENTENCE';
  }

  bool isKnowledgePointSelected(CourseUnitWritingEditorKnowledgeItemEntity item) {
    for (int index = 0; index < selectedKnowledgePoints.length; index++) {
      final CourseUnitWritingKnowledgePointEntity point = selectedKnowledgePoints[index];
      if ((point.contentType ?? '') != (item.contentType ?? '')) continue;
      if (point.uid != item.contentId) continue;
      if (point.semanticId != item.semanticId) continue;
      return true;
    }
    return false;
  }

  int getSelectedLexicalKnowledgeCount(List<CourseUnitWritingEditorKnowledgeItemEntity> lexicalList) {
    int count = 0;
    for (int index = 0; index < lexicalList.length; index++) {
      if (isKnowledgePointSelected(lexicalList[index])) {
        count += 1;
      }
    }
    return count;
  }

  int getOutsideLexicalKnowledgeCount(List<CourseUnitWritingEditorKnowledgeItemEntity> lexicalList) {
    int count = 0;
    for (int index = 0; index < selectedKnowledgePoints.length; index++) {
      final CourseUnitWritingKnowledgePointEntity point = selectedKnowledgePoints[index];
      if ((point.contentType ?? '') == 'EN_SENTENCE') continue;
      bool matched = false;
      for (int lexicalIndex = 0; lexicalIndex < lexicalList.length; lexicalIndex++) {
        final CourseUnitWritingEditorKnowledgeItemEntity item = lexicalList[lexicalIndex];
        if ((point.contentType ?? '') != (item.contentType ?? '')) continue;
        if (point.uid != item.contentId) continue;
        if (point.semanticId != item.semanticId) continue;
        matched = true;
        break;
      }
      if (!matched) {
        count += 1;
      }
    }
    return count;
  }

  void toggleKnowledgePoint(CourseUnitWritingEditorKnowledgeItemEntity item) {
    final List<CourseUnitWritingKnowledgePointEntity> next = List<CourseUnitWritingKnowledgePointEntity>.from(selectedKnowledgePoints);
    int selectedIndex = -1;
    for (int index = 0; index < next.length; index++) {
      final CourseUnitWritingKnowledgePointEntity point = next[index];
      if ((point.contentType ?? '') != (item.contentType ?? '')) continue;
      if (point.uid != item.contentId) continue;
      if (point.semanticId != item.semanticId) continue;
      selectedIndex = index;
      break;
    }
    if (selectedIndex >= 0) {
      next.removeAt(selectedIndex);
    } else {
      next.add(
        CourseUnitWritingKnowledgePointEntity(
          contentType: item.contentType,
          uid: item.contentId,
          semanticId: item.semanticId,
        ),
      );
    }
    selectedKnowledgePoints.assignAll(next);
  }

  void selectAllLexicalKnowledge(List<CourseUnitWritingEditorKnowledgeItemEntity> lexicalList) {
    final List<CourseUnitWritingKnowledgePointEntity> next = <CourseUnitWritingKnowledgePointEntity>[];
    for (int index = 0; index < selectedKnowledgePoints.length; index++) {
      final CourseUnitWritingKnowledgePointEntity point = selectedKnowledgePoints[index];
      bool matched = false;
      for (int lexicalIndex = 0; lexicalIndex < lexicalList.length; lexicalIndex++) {
        final CourseUnitWritingEditorKnowledgeItemEntity item = lexicalList[lexicalIndex];
        if ((point.contentType ?? '') != (item.contentType ?? '')) continue;
        if (point.uid != item.contentId) continue;
        if (point.semanticId != item.semanticId) continue;
        matched = true;
        break;
      }
      if (!matched) {
        next.add(point);
      }
    }
    for (int index = 0; index < lexicalList.length; index++) {
      final CourseUnitWritingEditorKnowledgeItemEntity item = lexicalList[index];
      next.add(
        CourseUnitWritingKnowledgePointEntity(
          contentType: item.contentType,
          uid: item.contentId,
          semanticId: item.semanticId,
        ),
      );
    }
    selectedKnowledgePoints.assignAll(next);
  }

  void clearLexicalKnowledge(List<CourseUnitWritingEditorKnowledgeItemEntity> lexicalList) {
    final List<CourseUnitWritingKnowledgePointEntity> next = <CourseUnitWritingKnowledgePointEntity>[];
    for (int index = 0; index < selectedKnowledgePoints.length; index++) {
      final CourseUnitWritingKnowledgePointEntity point = selectedKnowledgePoints[index];
      bool matched = false;
      for (int lexicalIndex = 0; lexicalIndex < lexicalList.length; lexicalIndex++) {
        final CourseUnitWritingEditorKnowledgeItemEntity item = lexicalList[lexicalIndex];
        if ((point.contentType ?? '') != (item.contentType ?? '')) continue;
        if (point.uid != item.contentId) continue;
        if (point.semanticId != item.semanticId) continue;
        matched = true;
        break;
      }
      if (!matched) {
        next.add(point);
      }
    }
    selectedKnowledgePoints.assignAll(next);
  }

  bool isGrammarTargetSelected(int? uid) {
    if (uid == null) return false;
    return selectedGrammarTargetUids.contains(uid);
  }

  void toggleGrammarTarget(int? uid) {
    if (uid == null) return;
    final List<int> next = List<int>.from(selectedGrammarTargetUids);
    if (next.contains(uid)) {
      next.remove(uid);
    } else {
      next.add(uid);
    }
    selectedGrammarTargetUids.assignAll(next);
  }

  void clearGrammarTargets() {
    selectedGrammarTargetUids.clear();
  }

  String getAnswerDetailText(StageCardData? stage) {
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

  List<LanguageText> _buildLanguageTextList({
    required String zhText,
    required String enText,
  }) {
    final List<LanguageText> values = <LanguageText>[];
    if (zhText.trim().isNotEmpty) {
      values.add(LanguageText(
        lang: 'zh',
        text: zhText,
      ));
    }
    if (enText.trim().isNotEmpty) {
      values.add(LanguageText(
        lang: 'en',
        text: enText,
      ));
    }
    return values;
  }
}
