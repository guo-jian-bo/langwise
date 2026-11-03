import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/enum/enum.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/widgets/zhenxie_widgets/writing_boards/model/writing_board_data.dart';
import '../../../../../common/widgets/zhenxie_widgets/writing_boards/model/writing_board_submit_data.dart';
import '../../../../../common/widgets/zhenxie_widgets/writing_boards/utils/writing_board_mapper.dart';
import '../../../../../common/widgets/zhenxie_widgets/writing_boards/utils/writing_board_runtime_state.dart';
import '../../../../../common/widgets/zhenxie_widgets/writing_boards/utils/writing_board_submit_mapper.dart' as writing_board_submit_mapper;
import '../../../../../utils/oss_upload_file_utils/oss_upload_file_utils.dart';
import '../../../../../utils/utils.dart';
import 'zhenxie_task_details_controller.dart';

class ZhenxieTaskDetailsTaskController extends GetxController {
  final String tagText;
  ZhenxieTaskDetailsTaskController({required this.tagText});

  /// 页面主控制器，用于协调页面模式与写作板公共状态。
  ZhenxieTaskDetailsController? _pageController;

  /// 任务详情。页面上会直接读它，所以这里要用响应式。
  final Rxn<ZhenxieTaskDetailsEntity> taskDetailsData = Rxn<ZhenxieTaskDetailsEntity>();

  /// 任务详情对应的知识点。切 tab 时页面会直接读，所以也要跟着响应。
  final RxList<ElementsCardEntityDatas> taskKnowledgePointsList = <ElementsCardEntityDatas>[].obs;

  /// 任务详情对应的语法 Target 轻量信息。资料 tab 会直接读这份列表。
  final RxList<CourseWriteTargetItemEntity> taskGrammarTargetList = <CourseWriteTargetItemEntity>[].obs;

  /// 任务写作态运行时快照。
  WritingBoardRuntimeState? draftWritingBoardRuntimeState;

  /// 任务写作态最近一次已加载或已保存的对比基线。
  WritingBoardRuntimeState? taskExitCompareBaselineRuntimeState;

  /// 绑定页面主控制器，后续所有页面编排都经由主控制器协调。
  void bindPageController(ZhenxieTaskDetailsController controller) {
    _pageController = controller;
  }

  /// 当前绑定的页面主控制器。
  ZhenxieTaskDetailsController pageController() {
    return _pageController!;
  }

  /// 获取任务详情并同步到页面展示态。
  Future<bool> getTaskDetailsData() async {
    final pageController = this.pageController();
    if (pageController.taskUid == null) return false;
    try {
      final parameters = {
        "taskId": pageController.taskUid,
      };
      if(pageController.unitId != null){
        parameters['unitId'] = pageController.unitId;
      }
      ZhenxieTaskDetailsEntity? entity;
      if (pageController.isManagement) {
        entity = await LanguageConsoleRequest.getZhenxieTaskDetails(parameters: parameters);
      } else {
        entity = await LanguageUtil.getZhenxieTaskDetails(parameters: parameters);
      }
      if (entity == null) return false;
      final knowledgePoints = await pageController.getKnowledgePointsList(details: entity);
      final grammarTargets = await pageController.getGrammarTargetList(details: entity);
      taskDetailsData.value = entity;
      taskKnowledgePointsList.assignAll(knowledgePoints);
      taskGrammarTargetList.assignAll(grammarTargets);
      syncTaskExitCompareBaseline();
      pageController.syncInitialCorrectionModeByDetails();
      if (!pageController.isExemplarContentMode()) {
        pageController.syncDisplayDataByMode();
      }
      pageController.boardController.initSelectedBeatNid();
      pageController.boardController.rebuildWritingBoardState();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// 以当前任务详情稳定数据重建“退出未保存判断”基线。
  void syncTaskExitCompareBaseline() {
    taskExitCompareBaselineRuntimeState = pageController().boardController.buildExitCompareBaselineRuntimeState(
          details: taskDetailsData.value,
          mode: WritingBoardModeEnum.task,
        );
  }

  /// 当前是否已经存在可继续写的重写草稿。
  bool hasRewriteDraftEntry() {
    if (draftWritingBoardRuntimeState != null) return true;
    final details = taskDetailsData.value;
    if (details?.memberWriting?.status == 'draft') return true;
    final currentWritingId = details?.memberWriting?.uid;
    if (details?.compositionWritingId == null || currentWritingId == null) return false;
    return details!.compositionWritingId != currentWritingId;
  }

  /// 当前任务是否已经有服务端草稿记录，可用于展示“已暂存”状态。
  bool hasSavedTaskDraft() {
    return taskDetailsData.value?.memberWriting?.statusEnum == ZhenxieTaskAnswerStatusEnum.draft;
  }

  /// 从批改态进入重写前，先准备好当前应该回填到画板的草稿。
  Future<bool> ensureRewriteDraftReady() async {
    final details = taskDetailsData.value;
    final taskId = pageController().taskUid;
    final currentWriting = details?.memberWriting;
    if (taskId == null) {
      ToastUtils.showToast(text: "写作任务ID不能为空");
      return false;
    }
    if (draftWritingBoardRuntimeState != null) return true;
    if (details?.memberWriting?.status == 'draft') {
      _syncTaskDraftAfterRewrite(
        details!.memberWriting!,
        previousWriting: currentWriting,
      );
      return true;
    }
    final writing = await StudyAppRequest.rewriteCompositionTask(taskId: taskId);
    if (writing == null) {
      ToastUtils.showToast(text: "进入重写失败");
      return false;
    }
    _syncTaskDraftAfterRewrite(
      writing,
      previousWriting: currentWriting,
    );
    return true;
  }

  /// 保存草稿。
  Future<void> saveDraft() async {
    final submitData = buildWritingBoardSubmitData();
    final taskId = submitData?.taskId;
    if (submitData == null || taskId == null) {
      ToastUtils.showToast(text: "当前还没有可暂存的写作数据");
      return;
    }
    if (!_hasAnyDraftContent(submitData)) {
      ToastUtils.showToast(text: "还没有填写任何内容，先写一点再保存草稿吧");
      return;
    }
    final res = await _saveWritingDraft(
      taskId: taskId,
      submitData: submitData,
    );
    if (res == null) return;
    _syncMemberWritingAfterDraft(res);
    taskExitCompareBaselineRuntimeState = pageController().boardController.writingBoardRuntimeState.value?.copyWith();
    pageController().restartStudyDuration();
  }

  /// 提交任务。
  Future<void> submitTask() async {
    final submitData = buildWritingBoardSubmitData();
    final data = pageController().boardController.writingBoardData.value;
    final taskId = submitData?.taskId;
    if (submitData == null || data == null || taskId == null) {
      ToastUtils.showToast(text: "当前还没有可提交的写作数据");
      return;
    }
    final validationMessage = _validateSubmitContent(
      data: data,
      submitData: submitData,
    );
    if (validationMessage != null) {
      ToastUtils.showToast(text: validationMessage);
      return;
    }
    final res = await _submitCompositionTask(
      taskId: taskId,
      submitData: submitData,
    );
    if (res == null) return;
    // 当前草稿已经提交完成，清掉本地草稿快照，避免后续重写误判成“继续旧草稿”。
    draftWritingBoardRuntimeState = null;
    pageController().stopStudyDuration();
    ToastUtils.showToast(text: "提交成功", type: ToastType.success);
    getTaskDetailsData();
  }

  /// 校验当前提交内容是否满足作答要求。
  String? _validateSubmitContent({
    required WritingBoardData data,
    required WritingBoardSubmitData submitData,
  }) {
    if (data.answerKindEnum.isText && submitData.writingBoardTextModeEnum == ZhenxieTaskTextSubmitModeEnum.paper) {
      if (_hasAnyMediaItems(submitData.paperImages)) return null;
      return "请先上传纸面照片";
    }
    final mediaAnswer = data.mediaAnswer;
    if (mediaAnswer != null) {
      final currentItems = mediaAnswer.kind == 'image'
          ? submitData.answerImages
          : mediaAnswer.kind == 'video'
              ? submitData.answerVideos
              : submitData.answerAudios;
      final minCount = mediaAnswer.minCount;
      if (currentItems.length < minCount) {
        return "请先完成$minCount个${_mediaAnswerKindLabel(mediaAnswer.kind)}作答";
      }
      if (minCount <= 0 && currentItems.isEmpty) {
        return "请先填写作答内容";
      }
      return null;
    }
    if (data.showHead && data.headEditable && (submitData.headText ?? '').isEmpty) {
      return "请先填写文首";
    }
    if (data.showTail && data.tailEditable && (submitData.tailText ?? '').isEmpty) {
      return "请先填写文尾";
    }
    for (final step in data.steps) {
      if (!step.editable) continue;
      final submitStep = submitData.steps.firstWhereOrNull((item) => item.beatNid == step.beatNid);
      if ((submitStep?.text ?? '').isEmpty) {
        return "请先完成 ${step.beatLabel} 的内容";
      }
    }
    if ((submitData.headText ?? '').isNotEmpty) return null;
    if ((submitData.tailText ?? '').isNotEmpty) return null;
    if (submitData.steps.any((item) => item.text.isNotEmpty)) return null;
    if (_hasAnyMediaItems(submitData.answerImages)) return null;
    if (_hasAnyMediaItems(submitData.answerVideos)) return null;
    if (_hasAnyMediaItems(submitData.answerAudios)) return null;
    return "请先填写作答内容";
  }

  /// 判断当前模式下是否已经存在至少一项可保存的草稿内容。
  bool _hasAnyDraftContent(WritingBoardSubmitData submitData) {
    if (submitData.answerKindEnum.isText) {
      if (submitData.writingBoardTextModeEnum == ZhenxieTaskTextSubmitModeEnum.paper) {
        return _hasAnyMediaItems(submitData.paperImages);
      }
      if ((submitData.headText ?? '').isNotEmpty) return true;
      if ((submitData.tailText ?? '').isNotEmpty) return true;
      return submitData.steps.any((item) => item.text.isNotEmpty);
    }
    if (submitData.answerKindEnum == ZhenxieTaskAnswerKindEnum.image) {
      return _hasAnyMediaItems(submitData.answerImages);
    }
    if (submitData.answerKindEnum == ZhenxieTaskAnswerKindEnum.video) {
      return _hasAnyMediaItems(submitData.answerVideos);
    }
    if (submitData.answerKindEnum == ZhenxieTaskAnswerKindEnum.audio) {
      return _hasAnyMediaItems(submitData.answerAudios);
    }
    return false;
  }

  /// 构建当前用于暂存 / 提交的写作板结果。
  WritingBoardSubmitData? buildWritingBoardSubmitData() {
    final pageController = this.pageController();
    final runtimeState = buildEffectiveDraftRuntimeState();
    final data = buildDraftWritingBoardData();
    if (runtimeState == null || data == null) return null;
    return writing_board_submit_mapper.buildWritingBoardSubmitData(
      details: taskDetailsData.value ?? pageController.detailsData.value,
      data: data,
      runtimeState: runtimeState,
      selectBeatNid: pageController.boardController.selectBeatNid.value,
    );
  }

  /// 获取当前有效的草稿态运行时状态。
  WritingBoardRuntimeState? buildEffectiveDraftRuntimeState() {
    final pageController = this.pageController();
    if (draftWritingBoardRuntimeState != null) {
      return draftWritingBoardRuntimeState!.copyWith();
    }
    if (pageController.isTaskDraftMode()) {
      return pageController.boardController.writingBoardRuntimeState.value?.copyWith();
    }
    return null;
  }

  /// 构建当前有效的草稿态写作板数据。
  WritingBoardData? buildDraftWritingBoardData() {
    final pageController = this.pageController();
    final runtimeState = buildEffectiveDraftRuntimeState();
    if (runtimeState == null || taskDetailsData.value == null) return null;
    final data = mapTaskDetailsToWritingBoardData(
      details: taskDetailsData.value!,
      paragraphRhetoricalList: pageController.paragraphRhetoricalList.toList(),
      selectBeatNid: pageController.boardController.selectBeatNid.value,
      writingBoardTextMode: runtimeState.writingBoardTextMode,
      mode: WritingBoardModeEnum.task,
      showKnowledgeAnchors: false,
      isManagement: pageController.isManagement,
    );
    return pageController.boardController.applyRuntimeStateToWritingBoardData(
      data: data,
      runtimeState: runtimeState,
    );
  }

  /// 判断媒体列表里是否已经存在有效结果。
  bool _hasAnyMediaItems(List<WritingBoardSubmitMediaItemData> items) {
    return items.any((item) {
      return item.localPath?.isNotEmpty == true || item.url?.isNotEmpty == true || item.key?.isNotEmpty == true;
    });
  }

  /// 将页面层提交数据映射成新甄写协议请求体。
  Map<String, dynamic> _buildSubmitRequestData({
    required WritingBoardSubmitData submitData,
    required List<String> mediaKeys,
    required List<String> paperImageKeys,
  }) {
    // 媒体题只提交资源列表，避免把正文字段带上后触发协议校验。
    final isTextAnswerKind = submitData.answerKindEnum.isText;
    final isPaperTextMode = isTextAnswerKind && submitData.writingBoardTextModeEnum == ZhenxieTaskTextSubmitModeEnum.paper;
    return {
      "source": submitData.writingBoardTextModeEnum.value, // typed：输入；paper：写在纸上
      // 课上作答优先透传页面路由带进来的 unitId，已有草稿回填值只作为兜底。
      "unitId": pageController().unitId,
      "headText": isTextAnswerKind && !isPaperTextMode ? submitData.headText : null,
      "tailText": isTextAnswerKind && !isPaperTextMode ? submitData.tailText : null,
      "parts": isTextAnswerKind && !isPaperTextMode
          ? submitData.steps.map((item) {
              return {
                "key": item.beatNid,
                "beatNid": item.beatNid,
                "text": item.text,
              };
            }).toList()
          : <Map<String, dynamic>>[],
      "mediaKeys": mediaKeys,
      "paperImageKeys": isPaperTextMode ? paperImageKeys : <String>[],
      "duration": pageController().getStudyDurationSeconds(),
    };
  }

  /// 将当前媒体类型转换成用户端上传资源类型。
  OssUploadUserType _buildUploadFileType(String kind) {
    if (kind == 'video') return OssUploadUserType.video;
    if (kind == 'audio') return OssUploadUserType.track;
    return OssUploadUserType.image;
  }

  /// 上传本地媒体并产出提交所需的 key 列表。
  Future<List<String>?> _buildSubmitMediaKeys({
    required List<WritingBoardSubmitMediaItemData> items,
    required String kind,
  }) async {
    if (items.isEmpty) return <String>[];
    final uploadFileType = _buildUploadFileType(kind);
    final nextKeys = <String>[];
    final nextRuntimeItems = items.asMap().entries.map((entry) {
      final item = entry.value;
      return WritingBoardMediaItemData(
        key: item.key,
        url: item.url,
        localPath: item.localPath,
      );
    }).toList();
    for (final entry in items.asMap().entries) {
      final index = entry.key;
      final item = entry.value;
      if (item.key?.isNotEmpty == true) {
        nextKeys.add(item.key!);
        continue;
      }
      if (item.localPath?.isNotEmpty != true) {
        ToastUtils.showToast(text: "存在未完成上传的资源，请重新选择后再试");
        return null;
      }
      final record = await OssUploadFileUtils.uploadUserFile(
        filePath: item.localPath!,
        fileModule: OssFileUserModule.composition,
        fileType: uploadFileType,
      );
      if (record == null || record.key == null) return null;
      nextKeys.add(record.key!);
      nextRuntimeItems[index] = nextRuntimeItems[index].copyWith(
        key: record.key,
        url: record.url,
      );
    }
    _syncUploadedRuntimeMediaItems(
      kind: kind,
      items: nextRuntimeItems,
    );
    return nextKeys;
  }

  /// 将刚上传完成的资源 key 回写到运行时状态，避免重复上传。
  void _syncUploadedRuntimeMediaItems({
    required String kind,
    required List<WritingBoardMediaItemData> items,
  }) {
    final boardController = pageController().boardController;
    if (kind == 'image') {
      boardController.updateAnswerImages(items);
    } else if (kind == 'video') {
      boardController.updateAnswerVideos(items);
    } else if (kind == 'audio') {
      boardController.updateAnswerAudios(items);
    }
  }

  /// 将刚上传完成的纸面照片 key 回写到运行时状态，避免重复上传。
  void _syncUploadedPaperRuntimeItems(List<WritingBoardMediaItemData> items) {
    pageController().boardController.updatePaperImages(items);
  }

  /// 保存草稿并返回服务端最新草稿详情。
  Future<ZhenxieTaskDetailsMemberWriting?> _saveWritingDraft({
    required int taskId,
    required WritingBoardSubmitData submitData,
  }) async {
    try {
      ToastUtils.showLoading();
      pageController().boardController.updateWritingBoardSubmitData(submitData);
      final mediaKeys = await _buildSubmitMediaKeysByAnswerKind(submitData);
      if (mediaKeys == null) return null;
      final paperImageKeys = await _buildSubmitPaperImageKeys(submitData);
      if (paperImageKeys == null) return null;
      final reqData = _buildSubmitRequestData(
        submitData: submitData,
        mediaKeys: mediaKeys,
        paperImageKeys: paperImageKeys,
      );
      debugPrint('WritingBoardDraftPayload: ${jsonEncode(reqData)}');
      final res = await StudyAppRequest.saveCompositionTaskDraft(
        taskId: taskId,
        data: reqData,
      );
      if (res == null) return null;
      ToastUtils.showToast(text: "保存草稿成功", type: ToastType.success);
      return res;
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 提交任务并返回批改动作结果。
  Future<ZhenxieTaskSubmitResultEntity?> _submitCompositionTask({
    required int taskId,
    required WritingBoardSubmitData submitData,
  }) async {
    try {
      ToastUtils.showLoading();
      pageController().boardController.updateWritingBoardSubmitData(submitData);
      final mediaKeys = await _buildSubmitMediaKeysByAnswerKind(submitData);
      if (mediaKeys == null) return null;
      final paperImageKeys = await _buildSubmitPaperImageKeys(submitData);
      if (paperImageKeys == null) return null;
      final reqData = _buildSubmitRequestData(
        submitData: submitData,
        mediaKeys: mediaKeys,
        paperImageKeys: paperImageKeys,
      );
      debugPrint('WritingBoardSubmitPayload: ${jsonEncode(reqData)}');
      return await StudyAppRequest.submitCompositionTask(
        taskId: taskId,
        data: reqData,
      );
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 按当前作答类型构建接口要求的 `mediaKeys`。
  Future<List<String>?> _buildSubmitMediaKeysByAnswerKind(WritingBoardSubmitData submitData) async {
    if (submitData.answerKindEnum == ZhenxieTaskAnswerKindEnum.image) {
      return _buildSubmitMediaKeys(
        items: submitData.answerImages,
        kind: ZhenxieTaskAnswerKindEnum.image.value,
      );
    }
    if (submitData.answerKindEnum == ZhenxieTaskAnswerKindEnum.video) {
      return _buildSubmitMediaKeys(
        items: submitData.answerVideos,
        kind: ZhenxieTaskAnswerKindEnum.video.value,
      );
    }
    if (submitData.answerKindEnum == ZhenxieTaskAnswerKindEnum.audio) {
      return _buildSubmitMediaKeys(
        items: submitData.answerAudios,
        kind: ZhenxieTaskAnswerKindEnum.audio.value,
      );
    }
    return <String>[];
  }

  /// 为文字题“写在纸上”模式构建接口要求的 `paperImageKeys`。
  Future<List<String>?> _buildSubmitPaperImageKeys(WritingBoardSubmitData submitData) async {
    if (!submitData.answerKindEnum.isText) return <String>[];
    if (submitData.writingBoardTextModeEnum != ZhenxieTaskTextSubmitModeEnum.paper) return <String>[];
    final nextKeys = <String>[];
    final nextRuntimeItems = submitData.paperImages.map((item) {
      return WritingBoardMediaItemData(
        key: item.key,
        url: item.url,
        localPath: item.localPath,
      );
    }).toList();
    for (final entry in submitData.paperImages.asMap().entries) {
      final index = entry.key;
      final item = entry.value;
      if (item.key?.isNotEmpty == true) {
        nextKeys.add(item.key!);
        continue;
      }
      if (item.localPath?.isNotEmpty != true) {
        ToastUtils.showToast(text: "存在未完成上传的纸面照片，请重新选择后再试");
        return null;
      }
      final record = await OssUploadFileUtils.uploadUserFile(
        filePath: item.localPath!,
        fileModule: OssFileUserModule.composition,
        fileType: OssUploadUserType.image,
      );
      if (record == null || record.key == null) return null;
      nextKeys.add(record.key!);
      nextRuntimeItems[index] = nextRuntimeItems[index].copyWith(
        key: record.key,
        url: record.url,
      );
    }
    _syncUploadedPaperRuntimeItems(nextRuntimeItems);
    return nextKeys;
  }

  /// 将最新草稿回写到页面详情实体，保证退出对比基线和当前展示一致。
  void _syncMemberWritingAfterDraft(ZhenxieTaskDetailsMemberWriting writing) {
    final details = taskDetailsData.value;
    if (details == null) return;
    details.memberWriting = writing;
    details.compositionWritingId = writing.uid;
    taskDetailsData.refresh();
    if (!pageController().isExemplarContentMode()) {
      pageController().detailsData.refresh();
    }
  }

  /// 将重写接口返回的草稿回写到任务态，供切回画板时直接复用。
  void _syncTaskDraftAfterRewrite(
    ZhenxieTaskDetailsMemberWriting writing, {
    ZhenxieTaskDetailsMemberWriting? previousWriting,
  }) {
    final details = taskDetailsData.value;
    if (details == null) return;
    _inheritRewriteDraftPaperResources(
      targetWriting: writing,
      previousWriting: previousWriting,
    );
    details.memberWriting = writing;
    details.compositionWritingId = writing.uid;
    draftWritingBoardRuntimeState = pageController().boardController.buildExitCompareBaselineRuntimeState(
          details: details,
          mode: WritingBoardModeEnum.task,
        );
    taskExitCompareBaselineRuntimeState = draftWritingBoardRuntimeState?.copyWith();
    taskDetailsData.refresh();
  }

  /// 重写接口未完整回传纸稿资源时，沿用当前记录里的 paper 资源，保证回到任务态后还能继续改。
  void _inheritRewriteDraftPaperResources({
    required ZhenxieTaskDetailsMemberWriting targetWriting,
    ZhenxieTaskDetailsMemberWriting? previousWriting,
  }) {
    if (previousWriting?.source != ZhenxieTaskTextSubmitModeEnum.paper.value) return;
    final sourceWriting = previousWriting!;
    targetWriting.source ??= sourceWriting.source;
    final sourceKeys = sourceWriting.paperImageKeys?.whereType<String>().where((item) => item.isNotEmpty).toList() ?? const <String>[];
    final sourceUrls = sourceWriting.paperImageUrls?.whereType<String>().where((item) => item.isNotEmpty).toList() ?? const <String>[];
    final targetKeys = targetWriting.paperImageKeys?.whereType<String>().where((item) => item.isNotEmpty).toList() ?? const <String>[];
    final targetUrls = targetWriting.paperImageUrls?.whereType<String>().where((item) => item.isNotEmpty).toList() ?? const <String>[];
    if (targetKeys.isEmpty && sourceKeys.isNotEmpty) {
      targetWriting.paperImageKeys = List<String>.from(sourceKeys);
    }
    if (targetUrls.isEmpty && sourceUrls.isNotEmpty) {
      targetWriting.paperImageUrls = List<String>.from(sourceUrls);
    }
  }

  /// 将媒体类型转换成用户可读文案。
  String _mediaAnswerKindLabel(String kind) {
    final answerKindEnum = ZhenxieTaskAnswerKindEnum.fromValue(kind);
    if (answerKindEnum == ZhenxieTaskAnswerKindEnum.text) return "媒体";
    return answerKindEnum.label;
  }
}
