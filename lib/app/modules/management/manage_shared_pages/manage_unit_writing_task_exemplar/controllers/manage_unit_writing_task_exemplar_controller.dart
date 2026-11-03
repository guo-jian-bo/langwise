import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/zhenxie/common/zhenxie_beat_utils.dart';
import 'package:langwise/app/modules/zhenxie/zhenxie_composition_stages/models/zhenxie_composition_stages_models.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/common/mixins/mixins.dart';
import 'package:langwise/utils/utils.dart';
import 'package:langwise/utils/oss_upload_file_utils/oss_update_response_entity.dart';
import 'package:langwise/utils/oss_upload_file_utils/oss_upload_file_utils.dart';

import '../../../../../routes/routes.dart';

class ManageUnitWritingTaskExemplarController extends GetxController with DualBreadcrumbMixin {
  static const Set<String> _sentenceAbbreviations = <String>{
    'mr',
    'mrs',
    'ms',
    'dr',
    'prof',
    'st',
    'mt',
    'jr',
    'sr',
    'vs',
    'e.g',
    'i.e',
  };

  final String tagText;
  ManageUnitWritingTaskExemplarController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.MANAGE_UNIT_WRITING_TASK_EXEMPLAR;

  @override
  String get breadcrumbTitle => '写单元范文';

  int? unitId;
  int? taskId;
  int? exemplarCompositionId;
  int? givenCompositionId;
  String? role;
  bool isManagement = true;

  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final RxInt formRefreshSignal = 0.obs;
  final Rxn<CourseUnitWritingExemplarEditorPageEntity> editorData = Rxn<CourseUnitWritingExemplarEditorPageEntity>();
  final RxList<String> beatNidOrderList = <String>[].obs;
  final RxString textStep = 'choose'.obs;
  final RxList<int> selectedKnowledgeUids = <int>[].obs;
  final RxList<int> selectedGrammarTargetUids = <int>[].obs;
  final Map<String, ParagraphRhetoricalEntityList> beatMap = <String, ParagraphRhetoricalEntityList>{};

  final TextEditingController titleZhController = TextEditingController();
  final TextEditingController titleEnController = TextEditingController();
  final TextEditingController headTextController = TextEditingController();
  final TextEditingController tailTextController = TextEditingController();
  final TextEditingController reverseTextController = TextEditingController();
  final RxList<String> answerKeys = <String>[].obs;
  final RxList<String> answerUrls = <String>[].obs;
  final List<TextEditingController> paragraphContentControllers = <TextEditingController>[];
  final List<String> paragraphOriginalContents = <String>[];
  final List<List<ZhenxieTaskDetailsEntityParagraphBeatSpan>> paragraphBeatSpanDrafts = <List<ZhenxieTaskDetailsEntityParagraphBeatSpan>>[];

  @override
  void onInit() {
    super.onInit();
    
    final Map args = Get.arguments is Map ? Get.arguments : const {};
    unitId = _parseInt(args['unitId']);
    taskId = _parseInt(args['taskId']);
    exemplarCompositionId = _parseInt(args['exemplarCompositionId']);
    givenCompositionId = _parseInt(args['givenCompositionId']);
    role = args['role']?.toString();
    initBreadcrumb(tagText,title:exemplarCompositionId == null ? '写单元范文' : '编辑单元范文' );
    final dynamic isManagementValue = args['isManagement'];
    if (isManagementValue != null) {
      isManagement = isManagementValue == true || isManagementValue.toString() == 'true';
    }
    titleZhController.addListener(_handleFormChanged);
    titleEnController.addListener(_handleFormChanged);
    headTextController.addListener(_handleFormChanged);
    tailTextController.addListener(_handleFormChanged);
    reverseTextController.addListener(_handleFormChanged);
    fetchData();
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  void _handleFormChanged() {
    formRefreshSignal.value += 1;
  }

  Future<void> fetchData({bool showLoading = true}) async {
    if (taskId == null) {
      ToastUtils.showManageToast(text: '任务信息为空');
      return;
    }
    if (showLoading) {
      ToastUtils.showLoading();
    }
    try {
      isLoading.value = true;
      await ensureZhenxieBeatData();
      final CourseUnitWritingExemplarEditorPageEntity? response = await LanguageConsoleRequest.getWriteCompositionExemplarEditor(
        taskId: taskId!,
        unitId: unitId,
        exemplarCompositionId: exemplarCompositionId,
      );
      if (response == null) {
        ToastUtils.showManageToast(text: '范文页加载失败');
        return;
      }
      editorData.value = response;
      beatNidOrderList.assignAll(zhenxieBeatOrderList);
      _syncFormData(response.data);
    } finally {
      isLoading.value = false;
      if (showLoading) {
        ToastUtils.hideLoading();
      }
    }
  }

  void _syncFormData(ZhenxieTaskDetailsEntity? detail) {
    textStep.value = 'choose';
    titleZhController.text = getLangText(detail?.title, 'zh');
    titleEnController.text = getLangText(detail?.title, 'en');
    headTextController.text = getPreferLangText(detail?.headText);
    tailTextController.text = getPreferLangText(detail?.tailText);
    _syncParagraphControllers(detail);
    reverseTextController.clear();
    _syncTextScope(detail);
    final int answerCount = getAnswerCount(detail);
    answerKeys.assignAll(_fitMediaList(_getAnswerKeyList(detail), answerCount));
    answerUrls.assignAll(_fitMediaList(_getAnswerUrlList(detail), answerCount));
    formRefreshSignal.value += 1;
  }

  void _syncParagraphControllers(ZhenxieTaskDetailsEntity? detail) {
    final List<ZhenxieTaskDetailsEntityParagraphInstance> memberList = getParagraphInstanceList(detail);
    for (int i = 0; i < paragraphContentControllers.length; i++) {
      paragraphContentControllers[i].removeListener(_handleFormChanged);
      paragraphContentControllers[i].dispose();
    }
    paragraphContentControllers.clear();
    paragraphOriginalContents.clear();
    paragraphBeatSpanDrafts.clear();
    for (int i = 0; i < memberList.length; i++) {
      final TextEditingController textController = TextEditingController(text: memberList[i].paragraph?.content ?? '');
      textController.addListener(_handleFormChanged);
      paragraphContentControllers.add(textController);
      paragraphOriginalContents.add(memberList[i].paragraph?.content ?? '');
      paragraphBeatSpanDrafts.add(_cloneParagraphBeatSpanList(memberList[i].paragraph?.beatSpans));
    }
  }

  List<ZhenxieTaskDetailsEntityParagraphBeatSpan> _cloneParagraphBeatSpanList(
    List<ZhenxieTaskDetailsEntityParagraphBeatSpan?>? beatSpans,
  ) {
    return (beatSpans ?? const <ZhenxieTaskDetailsEntityParagraphBeatSpan?>[])
        .whereType<ZhenxieTaskDetailsEntityParagraphBeatSpan>()
        .map((item) => ZhenxieTaskDetailsEntityParagraphBeatSpan.fromJson(item.toJson()))
        .toList();
  }

  void _syncTextScope(ZhenxieTaskDetailsEntity? detail) {
    final List<CourseUnitWritingEditorKnowledgeItemEntity> knowledgeList = getLexicalKnowledgeList();
    final List<int> matchedKnowledgeUids = knowledgeList
        .where((item) {
          return (detail?.knowledgePoints ?? const <ZhenxieTaskDetailsEntityKnowledgePoint?>[]).any((point) {
            return (point?.contentType ?? '') == (item.contentType ?? '') &&
                (point?.uid == item.contentId) &&
                (point?.semanticId == item.semanticId);
          });
        })
        .map((item) => item.uid ?? 0)
        .where((item) => item > 0)
        .toList();
    selectedKnowledgeUids.assignAll(
      matchedKnowledgeUids.isNotEmpty
          ? matchedKnowledgeUids
          : knowledgeList.map((item) => item.uid ?? 0).where((item) => item > 0).toList(),
    );

    final List<int> availableGrammarUids = (editorData.value?.grammarTargetList ?? const <CourseUnitWritingGrammarTargetItemEntity>[])
        .map((item) => item.uid ?? 0)
        .where((item) => item > 0)
        .toList();
    final List<int> matchedGrammarUids = (detail?.grammarTargetUids ?? const <int>[])
        .where((item) => availableGrammarUids.contains(item))
        .toList();
    selectedGrammarTargetUids.assignAll(
      matchedGrammarUids.isNotEmpty ? matchedGrammarUids : availableGrammarUids,
    );
  }

  List<String> _fitMediaList(List<String> values, int count) {
    final List<String> next = List<String>.from(values);
    if (next.length > count) {
      next.removeRange(count, next.length);
    }
    while (next.length < count) {
      next.add('');
    }
    return next;
  }

  List<String> _getAnswerKeyList(ZhenxieTaskDetailsEntity? detail) {
    final String answerKind = detail?.stage?.answerKind ?? '';
    if (answerKind == 'image') {
      return (detail?.answerImageKeys ?? const <String?>[]).whereType<String>().toList();
    }
    if (answerKind == 'audio') {
      return (detail?.answerAudioKeys ?? const <String?>[]).whereType<String>().toList();
    }
    if (answerKind == 'video') {
      return (detail?.answerVideoKeys ?? const <String?>[]).whereType<String>().toList();
    }
    return <String>[];
  }

  List<String> _getAnswerUrlList(ZhenxieTaskDetailsEntity? detail) {
    final String answerKind = detail?.stage?.answerKind ?? '';
    if (answerKind == 'image') {
      return (detail?.answerImageUrls ?? const <String?>[]).whereType<String>().toList();
    }
    if (answerKind == 'audio') {
      return (detail?.answerAudioUrls ?? const <String?>[]).whereType<String>().toList();
    }
    if (answerKind == 'video') {
      return (detail?.answerVideoUrls ?? const <String?>[]).whereType<String>().toList();
    }
    return <String>[];
  }

  String getLangText(List<LanguageText?>? values, String lang) {
    if (values == null || values.isEmpty) return '';
    for (int i = 0; i < values.length; i++) {
      final LanguageText? item = values[i];
      if ((item?.lang ?? '').toLowerCase() == lang.toLowerCase()) {
        return item?.text ?? '';
      }
    }
    return '';
  }

  String getPreferLangText(List<LanguageText?>? values) {
    final String zhText = getLangText(values, 'zh');
    if (zhText.isNotEmpty) return zhText;
    final String enText = getLangText(values, 'en');
    if (enText.isNotEmpty) return enText;
    if (values == null || values.isEmpty) return '';
    return values.first?.text ?? '';
  }

  List<ZhenxieTaskDetailsEntityParagraphInstance> getParagraphInstanceList(ZhenxieTaskDetailsEntity? detail) {
    final List<ZhenxieTaskDetailsEntityParagraphInstance> memberList =
        (detail?.memberList ?? const <ZhenxieTaskDetailsEntityParagraphInstance?>[]).whereType<ZhenxieTaskDetailsEntityParagraphInstance>().toList();
    memberList.sort((a, b) => (a.index ?? 0).compareTo(b.index ?? 0));
    return memberList;
  }

  bool isParagraphChanged(int index) {
    if (index < 0 || index >= paragraphContentControllers.length || index >= paragraphOriginalContents.length) return false;
    return paragraphContentControllers[index].text != paragraphOriginalContents[index];
  }

  List<ZhenxieTaskDetailsEntityParagraphBeatSpan> getParagraphBeatSpanList(int index) {
    if (index < 0 || index >= paragraphBeatSpanDrafts.length) return <ZhenxieTaskDetailsEntityParagraphBeatSpan>[];
    return paragraphBeatSpanDrafts[index];
  }

  List<String> getParagraphSentenceList(int index) {
    if (index < 0 || index >= paragraphContentControllers.length) return <String>[];
    return splitParagraphSentences(paragraphContentControllers[index].text);
  }

  List<String> splitParagraphSentences(String text) {
    final List<String> sentenceList = <String>[];

    void pushSentence(int start, int end) {
      final String raw = text.substring(start, end);
      final String trimmed = raw.trim();
      if (trimmed.isEmpty) return;
      sentenceList.add(trimmed);
    }

    int lineStart = 0;
    for (final String line in text.split('\n')) {
      final int lineEnd = lineStart + line.length;
      final Iterable<RegExpMatch> matches = RegExp("[.!?]+[\"'”’)\\]]*").allMatches(line);
      int start = lineStart;
      for (final RegExpMatch match in matches) {
        final int markStart = lineStart + match.start;
        final int end = lineStart + match.end;
        if (end < lineEnd && !RegExp(r'\s').hasMatch(text[end])) continue;
        final String mark = match.group(0) ?? '';
        final String following = text.substring(end, lineEnd);
        if (_isSentenceAbbreviation(text, markStart, mark, following)) continue;
        pushSentence(start, end);
        start = end;
      }
      pushSentence(start, lineEnd);
      lineStart = lineEnd + 1;
    }

    return sentenceList;
  }

  bool _isSentenceAbbreviation(
    String content,
    int markStart,
    String mark,
    String following,
  ) {
    if (!mark.replaceAll(RegExp("[\"'”’)\\]]+\$"), '').endsWith('.')) return false;
    int start = markStart;
    while (start > 0 && !RegExp(r'\s').hasMatch(content[start - 1])) {
      start -= 1;
    }
    final String token = content.substring(start, markStart).toLowerCase().replaceAll(RegExp("^[\"'“‘(]+"), '');
    if (_sentenceAbbreviations.contains(token)) return true;
    final String trimmedFollowing = following.trimLeft();
    final String next = trimmedFollowing.isEmpty ? '' : trimmedFollowing[0];
    return token.contains('.') && next.isNotEmpty && next != next.toUpperCase();
  }

  List<String> getAllowedBeatNidList(String? paragraphTypeNid) {
    const List<String> defaultBeatNids = <String>['opening', 'develop', 'turn', 'close'];
    final List<String> availableBeatNids = defaultBeatNids.where((item) {
      return beatMap.containsKey(item) || beatNidOrderList.contains(item);
    }).toList();
    return availableBeatNids.isNotEmpty ? availableBeatNids : defaultBeatNids;
  }

  void cycleParagraphBeat(int index, int spanIndex, String? paragraphTypeNid) {
    if (index < 0 || index >= paragraphBeatSpanDrafts.length) return;
    final List<ZhenxieTaskDetailsEntityParagraphBeatSpan> beatSpans = paragraphBeatSpanDrafts[index];
    if (spanIndex < 0 || spanIndex >= beatSpans.length) return;
    final List<String> allowedBeatNids = getAllowedBeatNidList(paragraphTypeNid);
    if (allowedBeatNids.isEmpty) return;
    final String currentBeatNid = beatSpans[spanIndex].beatNid ?? '';
    final int currentIndex = allowedBeatNids.indexOf(currentBeatNid);
    final int nextIndex = currentIndex < 0 ? 0 : (currentIndex + 1) % allowedBeatNids.length;
    beatSpans[spanIndex].beatNid = allowedBeatNids[nextIndex];
    formRefreshSignal.value += 1;
  }

  String getDifficultyLabel(ArticleBlueprintEntityDifficulty? difficulty) {
    final String minDifficultyLabel = DifficultieUtils.getLanguageDifficultieLevel1('en', difficulty?.min)?.name?.text ?? '';
    final String maxDifficultyLabel = DifficultieUtils.getLanguageDifficultieLevel1('en', difficulty?.max)?.name?.text ?? '';
    if (minDifficultyLabel.isEmpty || maxDifficultyLabel.isEmpty) return '';
    return minDifficultyLabel == maxDifficultyLabel ? minDifficultyLabel : '$minDifficultyLabel-$maxDifficultyLabel';
  }

  String getAnswerTypeText(String? answerKind) {
    if (answerKind == 'text') return '文字';
    if (answerKind == 'image') return '图片';
    if (answerKind == 'audio') return '音频';
    if (answerKind == 'video') return '视频';
    return '';
  }

  String getAnswerDetailText(ZhenxieTaskDetailsEntity? detail) {
    final String answerKind = detail?.stage?.answerKind ?? '';
    if (answerKind.isEmpty || answerKind == 'text') return '';
    final int answerCount = getAnswerCount(detail);
    if (answerCount <= 0) return '';
    return '$answerCount份';
  }

  int getAnswerCount(ZhenxieTaskDetailsEntity? detail) {
    final int? answerCount = detail?.answerCount;
    if (answerCount != null && answerCount > 0) return answerCount;
    final int? answerMinCount = detail?.stage?.answerMinCount;
    final int? answerMaxCount = detail?.stage?.answerMaxCount;
    if (answerMinCount != null && answerMinCount > 0) return answerMinCount;
    if (answerMaxCount != null && answerMaxCount > 0) return answerMaxCount;
    return 1;
  }

  bool get isTextAnswer {
    return editorData.value?.data?.stage?.answerKind == 'text';
  }

  List<CourseUnitWritingEditorKnowledgeItemEntity> getLexicalKnowledgeList() {
    return (editorData.value?.knowledgeList ?? const <CourseUnitWritingEditorKnowledgeItemEntity>[])
        .where((item) => (item.contentType ?? '') != 'EN_SENTENCE')
        .toList();
  }

  void enterTextStep(String step) {
    textStep.value = step;
  }

  void toggleKnowledgeSelection(int uid) {
    if (selectedKnowledgeUids.contains(uid)) {
      selectedKnowledgeUids.remove(uid);
    } else {
      selectedKnowledgeUids.add(uid);
    }
    selectedKnowledgeUids.refresh();
  }

  void selectAllKnowledge() {
    selectedKnowledgeUids.assignAll(getLexicalKnowledgeList().map((item) => item.uid ?? 0).where((item) => item > 0).toList());
  }

  void clearKnowledge() {
    selectedKnowledgeUids.clear();
  }

  void toggleGrammarSelection(int uid) {
    if (selectedGrammarTargetUids.contains(uid)) {
      selectedGrammarTargetUids.remove(uid);
    } else {
      selectedGrammarTargetUids.add(uid);
    }
    selectedGrammarTargetUids.refresh();
  }

  void selectAllGrammar() {
    selectedGrammarTargetUids.assignAll(
      (editorData.value?.grammarTargetList ?? const <CourseUnitWritingGrammarTargetItemEntity>[])
          .map((item) => item.uid ?? 0)
          .where((item) => item > 0)
          .toList(),
    );
  }

  void clearGrammar() {
    selectedGrammarTargetUids.clear();
  }

  int getReverseSentenceCount() {
    final String text = reverseTextController.text.trim();
    if (text.isEmpty) return 0;
    return splitParagraphSentences(text).length;
  }

  int getReverseBlockCount() {
    final String text = reverseTextController.text.trim();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\n\s*\n')).where((item) => item.trim().isNotEmpty).length;
  }

  String getGrammarScopeText() {
    final CourseUnitWritingGrammarScopeEntity? scope = editorData.value?.unitWriting?.grammarScope;
    final CourseUnitWritingGrammarScopeMetaEntity? meta = editorData.value?.unitWriting?.grammarScopeMeta;
    final List<String> labels = <String>[];
    final String timeLabel = _getGrammarAxisText(scope?.time, meta?.time);
    final String aspectLabel = _getGrammarAxisText(scope?.aspect, meta?.aspect);
    final String voiceLabel = _getGrammarAxisText(scope?.voice, meta?.voice);
    if (timeLabel.isNotEmpty) labels.add(timeLabel);
    if (aspectLabel.isNotEmpty) labels.add(aspectLabel);
    if (voiceLabel.isNotEmpty) labels.add(voiceLabel);
    return labels.isEmpty ? '不限' : labels.join('；');
  }

  String _getGrammarAxisText(List<String>? selectedCodes, CourseUnitWritingGrammarScopeMetaAxisEntity? axisMeta) {
    if (selectedCodes == null || selectedCodes.isEmpty || axisMeta == null) return '';
    final List<String> labels = selectedCodes
        .map((code) {
          final CourseUnitWritingGrammarScopeMetaOptionEntity? option =
              (axisMeta.options ?? const <CourseUnitWritingGrammarScopeMetaOptionEntity>[])
                  .firstWhereOrNull((item) => (item.code ?? '') == code);
          return option?.name ?? '';
        })
        .where((item) => item.isNotEmpty)
        .toList();
    return labels.join(' / ');
  }

  String getBeatName(String? beatNid) {
    if (beatNid == 'head') return '文首';
    if (beatNid == 'tail') return '文末';
    final ParagraphRhetoricalEntityList? beat = beatMap[beatNid];
    return getLangText((beat?.name ?? const <LanguageText?>[]).whereType<LanguageText>().toList(), 'zh');
  }

  bool hasHead(CompositionStageModel stage) {
    if (stage.hasHead != null) return stage.hasHead == true;
    return stage.compositionBlueprint?.frame?.hasHead == true;
  }

  bool hasTail(CompositionStageModel stage) {
    if (stage.hasTail != null) return stage.hasTail == true;
    return stage.compositionBlueprint?.frame?.hasTail == true;
  }

  String getHeadLabel(CompositionStageModel stage) {
    final List<LanguageText> headName = stage.headName.isNotEmpty
        ? stage.headName
        : stage.compositionBlueprint?.frame?.headName.toList() ?? const <LanguageText>[];
    return getLangText(headName, 'zh');
  }

  String getTailLabel(CompositionStageModel stage) {
    final List<LanguageText> tailName = stage.tailName.isNotEmpty
        ? stage.tailName
        : stage.compositionBlueprint?.frame?.tailName.toList() ?? const <LanguageText>[];
    return getLangText(tailName, 'zh');
  }

  Future<bool> setAnswerByInput(int index, String value) async {
    if (index < 0 || index >= answerKeys.length) return false;
    final String answerKind = editorData.value?.data?.stage?.answerKind ?? '';
    if (answerKind == 'image') {
      return await _setAnswerImageByInput(index, value);
    }
    if (answerKind == 'audio') {
      return await _setAnswerAudioByInput(index, value);
    }
    if (answerKind == 'video') {
      return await _setAnswerVideoByInput(index, value);
    }
    return false;
  }

  Future<bool> _setAnswerImageByInput(int index, String value) async {
    final String uidText = value.trim();
    final int? imageId = int.tryParse(uidText);
    if (imageId == null) {
      ToastUtils.showManageToast(text: '请输入正确的图片UID');
      return false;
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
        return false;
      }
      answerKeys[index] = imageKey;
      if (answerUrls.length <= index) {
        answerUrls.assignAll(List<String>.from(answerUrls)..addAll(List<String>.filled(index + 1 - answerUrls.length, '')));
      }
      answerUrls[index] = imageInfo.imageUrl ?? '';
      answerKeys.refresh();
      answerUrls.refresh();
      return true;
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<bool> _setAnswerAudioByInput(int index, String value) async {
    final String uidText = value.trim();
    final int? audioId = int.tryParse(uidText);
    if (audioId == null) {
      ToastUtils.showManageToast(text: '请输入正确的音频UID');
      return false;
    }
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
        return false;
      }
      answerKeys[index] = audioKey;
      if (answerUrls.length <= index) {
        answerUrls.assignAll(List<String>.from(answerUrls)..addAll(List<String>.filled(index + 1 - answerUrls.length, '')));
      }
      answerUrls[index] = audioInfo.audioUrl ?? '';
      answerKeys.refresh();
      answerUrls.refresh();
      return true;
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<bool> _setAnswerVideoByInput(int index, String value) async {
    final String uidText = value.trim();
    final int? videoId = int.tryParse(uidText);
    if (videoId == null) {
      ToastUtils.showManageToast(text: '请输入正确的视频UID');
      return false;
    }
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
        return false;
      }
      answerKeys[index] = videoKey;
      if (answerUrls.length <= index) {
        answerUrls.assignAll(List<String>.from(answerUrls)..addAll(List<String>.filled(index + 1 - answerUrls.length, '')));
      }
      answerUrls[index] = videoInfo.videoUrl ?? '';
      answerKeys.refresh();
      answerUrls.refresh();
      return true;
    } finally {
      ToastUtils.hideLoading();
    }
  }

  void clearAnswer(int index) {
    if (index < 0 || index >= answerKeys.length) return;
    answerKeys[index] = '';
    if (index < answerUrls.length) {
      answerUrls[index] = '';
      answerUrls.refresh();
    }
    answerKeys.refresh();
  }

  Future<void> uploadAnswer(BuildContext context, int index) async {
    final String answerKind = editorData.value?.data?.stage?.answerKind ?? '';
    if (answerKind == 'image') {
      await _uploadImage(context, index);
      return;
    }
    if (answerKind == 'audio') {
      await _uploadAudio(index);
      return;
    }
    if (answerKind == 'video') {
      await _uploadVideo(index);
    }
  }

  Future<void> _uploadImage(BuildContext context, int index) async {
    final FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg', 'jpeg', 'webp'],
    );
    final String? filePath = result?.files.single.path;
    if (filePath == null) return;
    await _saveUploadedFile(
      index: index,
      filePath: filePath,
      fileType: OssFileManageType.image,
      successText: '图片上传成功',
    );
  }

  Future<void> _uploadAudio(int index) async {
    final FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'm4a', 'aac'],
    );
    if (result == null || result.files.single.path == null) return;
    await _saveUploadedFile(
      index: index,
      filePath: result.files.single.path!,
      fileType: OssFileManageType.track,
      successText: '音频上传成功',
    );
  }

  Future<void> _uploadVideo(int index) async {
    final FilePickerResult? result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp4', 'mov', 'm4v'],
    );
    if (result == null || result.files.single.path == null) return;
    await _saveUploadedFile(
      index: index,
      filePath: result.files.single.path!,
      fileType: OssFileManageType.video,
      successText: '视频上传成功',
    );
  }

  Future<void> _saveUploadedFile({
    required int index,
    required String filePath,
    required OssFileManageType fileType,
    required String successText,
  }) async {
    try {
      ToastUtils.showLoading();
      final OssUpdateResponseEntity? record = await OssUploadFileUtils.uploadManageFile(
        filePath: filePath,
        fileModule: OssFileManageModule.scriptTmp,
        fileType: fileType,
      );
      if (record == null || (record.key ?? '').isEmpty) return;
      answerKeys[index] = record.key ?? '';
      if (answerUrls.length <= index) {
        answerUrls.assignAll(List<String>.from(answerUrls)..addAll(List<String>.filled(index + 1 - answerUrls.length, '')));
      }
      answerUrls[index] = record.url ?? '';
      answerKeys.refresh();
      answerUrls.refresh();
      ToastUtils.showManageToast(text: successText);
    } finally {
      ToastUtils.hideLoading();
    }
  }

  List<LanguageText> _buildTitleList() {
    final List<LanguageText> values = <LanguageText>[];
    final String zh = titleZhController.text.trim();
    final String en = titleEnController.text.trim();
    if (zh.isNotEmpty) {
      values.add(LanguageText(lang: 'zh', text: zh));
    }
    if (en.isNotEmpty) {
      values.add(LanguageText(lang: 'en', text: en));
    }
    return values;
  }

  List<LanguageText> _buildEdgeTextList(List<LanguageText?>? currentValues, String text) {
    final List<LanguageText> values = (currentValues ?? const <LanguageText?>[]).whereType<LanguageText>().toList();
    final bool hasZh = values.any((item) => (item.lang ?? '').toLowerCase() == 'zh');
    final bool hasEn = values.any((item) => (item.lang ?? '').toLowerCase() == 'en');
    final String targetLang = hasZh ? 'zh' : (hasEn ? 'en' : 'zh');
    final List<LanguageText> next = values.where((item) => (item.lang ?? '').toLowerCase() != targetLang).toList();
    if (text.trim().isNotEmpty) {
      next.add(LanguageText(lang: targetLang, text: text.trim()));
    }
    next.sort((a, b) {
      final int aValue = (a.lang ?? '').toLowerCase() == 'zh' ? 1 : 0;
      final int bValue = (b.lang ?? '').toLowerCase() == 'zh' ? 1 : 0;
      return bValue.compareTo(aValue);
    });
    return next;
  }

  List<Map<String, dynamic>> _buildTextParagraphList(ZhenxieTaskDetailsEntity detail) {
    final List<ZhenxieTaskDetailsEntityParagraphInstance> memberList = getParagraphInstanceList(detail);
    return List<Map<String, dynamic>>.generate(memberList.length, (index) {
      final ZhenxieTaskDetailsEntityParagraphInstance member = memberList[index];
      final bool changed = isParagraphChanged(index);
      return <String, dynamic>{
        'index': index,
        'beatNid': member.beatNid,
        'paragraphId': member.paragraphId,
        'paragraphTypeNid': member.paragraphTypeNid,
        'paragraph': <String, dynamic>{
          'uid': member.paragraph?.uid,
          'content': paragraphContentControllers[index].text.trim(),
          'pronunciation': member.paragraph?.pronunciation,
          'beatSpans': changed
              ? <Map<String, dynamic>>[]
              : getParagraphBeatSpanList(index).map((item) => item.toJson()).toList(),
          'anchors': changed
              ? <Map<String, dynamic>>[]
              : (member.paragraph?.anchors ?? const <ZhenxieTaskDetailsEntityContentAnchor?>[])
                  .whereType<ZhenxieTaskDetailsEntityContentAnchor>()
                  .map((item) => item.toJson())
                  .toList(),
        },
      };
    });
  }

  List<String> collectIssues() {
    final List<String> issues = <String>[];
    final ZhenxieTaskDetailsEntity? detail = editorData.value?.data;
    if (detail == null) {
      issues.add('当前没有范文数据');
      return issues;
    }
    if (titleZhController.text.trim().isEmpty) {
      issues.add('请填写中文标题');
    }
    final String answerKind = detail.stage?.answerKind ?? '';
    if (answerKind == 'text') {
      if (exemplarCompositionId == null) {
        issues.add('当前文字范文需先生成后再编辑保存');
        return issues;
      }
      final CompositionStageModel? stage = detail.stage == null ? null : CompositionStageModel.fromJson(detail.stage!.toJson());
      if (stage?.hasHead == true && headTextController.text.trim().isEmpty) {
        issues.add('请填写文首内容');
        return issues;
      }
      if (stage?.hasTail == true && tailTextController.text.trim().isEmpty) {
        issues.add('请填写文尾内容');
        return issues;
      }
      for (int index = 0; index < paragraphContentControllers.length; index++) {
        if (paragraphContentControllers[index].text.trim().isEmpty) {
          issues.add('请补全第 ${index + 1} 段正文');
          return issues;
        }
      }
      return issues;
    }
    final int answerCount = getAnswerCount(detail);
    if (answerKeys.length != answerCount) {
      issues.add('范文素材份数不完整');
    }
    for (int index = 0; index < answerKeys.length; index++) {
      if (answerKeys[index].trim().isEmpty) {
        issues.add('请补全第 ${index + 1} 份${getAnswerTypeText(detail.stage?.answerKind)}素材');
        break;
      }
    }
    return issues;
  }

  Future<void> generateTextExemplar() async {
    if (isSaving.value) return;
    if (unitId == null || taskId == null) {
      ToastUtils.showManageToast(text: '任务信息为空');
      return;
    }
    try {
      isSaving.value = true;
      ToastUtils.showLoading();
      final List<Map<String, dynamic>> knowledgePoints = getLexicalKnowledgeList()
          .where((item) => selectedKnowledgeUids.contains(item.uid))
          .map((item) => <String, dynamic>{
                'contentType': item.contentType,
                'uid': item.contentId,
                'semanticId': item.semanticId,
              })
          .toList();
      final String? response = await CourseConsoleRequest.generateUnitWritingTaskExemplar(
        unitId!,
        <String, dynamic>{
          'taskId': taskId,
          'knowledgePoints': knowledgePoints,
          'grammarTargetUids': selectedGrammarTargetUids.toList(),
          if (role == 'given') 'role': 'given',
        },
      );
      if ((response ?? '').isEmpty) return;
      ToastUtils.showManageToast(text: response!);
      Get.back<bool>(result: true);
    } finally {
      isSaving.value = false;
      ToastUtils.hideLoading();
    }
  }

  Future<void> structureTextExemplar(String text) async {
    if (isSaving.value) return;
    if (unitId == null || taskId == null) {
      ToastUtils.showManageToast(text: '任务信息为空');
      return;
    }
    if (text.trim().isEmpty) {
      ToastUtils.showManageToast(text: '请输入英文原文');
      return;
    }
    try {
      isSaving.value = true;
      ToastUtils.showLoading();
      final String? response = await CourseConsoleRequest.structureUnitWritingTaskExemplar(
        unitId!,
        <String, dynamic>{
          'taskId': taskId,
          'text': text.trim(),
          if (role == 'given') 'role': 'given',
        },
      );
      if ((response ?? '').isEmpty) return;
      ToastUtils.showManageToast(text: response!);
      Get.back<bool>(result: true);
    } finally {
      isSaving.value = false;
      ToastUtils.hideLoading();
    }
  }

  Future<void> submitExemplar() async {
    if (isSaving.value) return;
    final ZhenxieTaskDetailsEntity? detail = editorData.value?.data;
    if (taskId == null || detail == null) {
      ToastUtils.showManageToast(text: '范文信息为空');
      return;
    }
    final List<String> issues = collectIssues();
    if (issues.isNotEmpty) {
      ToastUtils.showManageToast(text: issues.first);
      return;
    }
    final Map<String, dynamic> data = <String, dynamic>{
      'taskId': taskId,
      'title': _buildTitleList().map((e) => e.toJson()).toList(),
    };
    if (unitId != null) {
      data['unitId'] = unitId;
    }
    if (exemplarCompositionId != null) {
      data['compositionId'] = exemplarCompositionId;
    }
    final String answerKind = detail.stage?.answerKind ?? '';
    if (answerKind == 'text') {
      data['headText'] = _buildEdgeTextList(detail.headText, headTextController.text).map((item) => item.toJson()).toList();
      data['tailText'] = _buildEdgeTextList(detail.tailText, tailTextController.text).map((item) => item.toJson()).toList();
      data['paragraphs'] = _buildTextParagraphList(detail);
    }
    if (answerKind == 'image') {
      data['answerImageKeys'] = answerKeys.toList();
    }
    if (answerKind == 'audio') {
      data['answerAudioKeys'] = answerKeys.toList();
    }
    if (answerKind == 'video') {
      data['answerVideoKeys'] = answerKeys.toList();
    }
    try {
      isSaving.value = true;
      ToastUtils.showLoading();
      final ZhenxieTaskDetailsEntity? response = await LanguageConsoleRequest.saveWriteCompositionExemplar(data);
      if (response == null) return;
      ToastUtils.showManageToast(text: '范文保存成功');
      Get.back<bool>(result: true);
    } finally {
      isSaving.value = false;
      ToastUtils.hideLoading();
    }
  }

  @override
  void onClose() {
    titleZhController.removeListener(_handleFormChanged);
    titleEnController.removeListener(_handleFormChanged);
    headTextController.removeListener(_handleFormChanged);
    tailTextController.removeListener(_handleFormChanged);
    reverseTextController.removeListener(_handleFormChanged);
    titleZhController.dispose();
    titleEnController.dispose();
    headTextController.dispose();
    tailTextController.dispose();
    for (int i = 0; i < paragraphContentControllers.length; i++) {
      paragraphContentControllers[i].removeListener(_handleFormChanged);
      paragraphContentControllers[i].dispose();
    }
    reverseTextController.dispose();
    super.onClose();
  }
}
