import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/enum/enum.dart';
import '../../../../../common/widgets/zhenxie_widgets/writing_boards/model/writing_board_data.dart';
import '../../../../../common/widgets/zhenxie_widgets/writing_boards/model/writing_board_submit_data.dart';
import '../../../../../common/widgets/zhenxie_widgets/writing_boards/utils/writing_board_controller_bundle.dart';
import '../../../../../common/widgets/zhenxie_widgets/writing_boards/utils/writing_board_mapper.dart';
import '../../../../../common/widgets/zhenxie_widgets/writing_boards/utils/writing_board_runtime_state.dart';
import '../../../../../common/widgets/zhenxie_widgets/zhenxie_paragraph_step_details_widget.dart';
import 'zhenxie_task_details_controller.dart';

class ZhenxieTaskDetailsBoardController extends GetxController {
  final String tagText;
  ZhenxieTaskDetailsBoardController({required this.tagText});

  /// 页面主控制器。
  /// 这里只拿页面模式和业务控制器，不在这里管接口请求。
  ZhenxieTaskDetailsController? _pageController;

  /// 文字写作板模式。
  final Rx<ZhenxieTaskTextSubmitModeEnum> writingBoardTextMode = ZhenxieTaskTextSubmitModeEnum.typing.obs;

  /// 写作板真正拿来渲染的结构。
  final Rxn<WritingBoardData> writingBoardData = Rxn<WritingBoardData>();

  /// 写作板当前输入中的运行时状态。
  final Rxn<WritingBoardRuntimeState> writingBoardRuntimeState = Rxn<WritingBoardRuntimeState>();

  /// 当前页面最近一次准备提交的数据快照。
  final Rxn<WritingBoardSubmitData> writingBoardSubmitData = Rxn<WritingBoardSubmitData>();

  /// 当前选中的拍位。
  final RxString selectBeatNid = "".obs;

  /// 写作板输入框和焦点节点集合。
  WritingBoardControllers? writingBoardControllers;

  /// 绑定页面主控制器。
  void bindPageController(ZhenxieTaskDetailsController controller) {
    _pageController = controller;
  }

  /// 拿到页面主控制器。
  ZhenxieTaskDetailsController requirePageController() {
    return _pageController!;
  }

  /// 初始化默认选中的拍位。
  void initSelectedBeatNid() {
    if (selectBeatNid.value.isNotEmpty) return;
    final pageController = requirePageController();
    final details = pageController.isExemplarContentMode()
        ? pageController.exemplarController.exemplarDetailsData.value
        : pageController.taskController.taskDetailsData.value;
    if (details == null) return;
    final slots = details.stage?.slots ?? [];
    if (pageController.isExemplarContentMode()) {
      for (final slot in slots) {
        if (slot?.fill == 'hidden' || slot?.beatNid?.isEmpty != false) continue;
        selectBeatNid.value = slot!.beatNid!;
        return;
      }
    }
    for (final slot in slots) {
      if (slot?.fill != 'write' || slot?.beatNid?.isEmpty != false) continue;
      selectBeatNid.value = slot!.beatNid!;
      return;
    }
    for (final slot in slots) {
      if (slot?.fill == 'hidden' || slot?.beatNid?.isEmpty != false) continue;
      selectBeatNid.value = slot!.beatNid!;
      return;
    }
  }

  /// 更改文字写作板模式。
  void changeWritingBoardTextMode() {
    final nextMode =
        writingBoardTextMode.value == ZhenxieTaskTextSubmitModeEnum.typing ? ZhenxieTaskTextSubmitModeEnum.paper : ZhenxieTaskTextSubmitModeEnum.typing;
    writingBoardTextMode.value = nextMode;
    final runtimeState = writingBoardRuntimeState.value;
    if (runtimeState != null) {
      writingBoardRuntimeState.value = runtimeState.copyWith(
        writingBoardTextMode: nextMode,
      );
      persistCurrentEditableRuntimeState();
    }
    final data = writingBoardData.value;
    if (data != null) {
      writingBoardData.value = data.copyWith(
        writingBoardTextMode: nextMode,
      );
    }
    syncWritingBoardDataFromRuntimeState();
  }

  /// 用指定详情和模式，构建一份退出对比用的基线快照。
  WritingBoardRuntimeState? buildExitCompareBaselineRuntimeState({
    required ZhenxieTaskDetailsEntity? details,
    required WritingBoardModeEnum mode,
  }) {
    if (details == null) return null;
    final pageController = requirePageController();
    final baselineTextMode = _resolveDetailsWritingBoardTextMode(details);
    final data = mapTaskDetailsToWritingBoardData(
      details: details,
      paragraphRhetoricalList: pageController.paragraphRhetoricalList.toList(),
      selectBeatNid: selectBeatNid.value,
      writingBoardTextMode: baselineTextMode,
      mode: mode,
      showKnowledgeAnchors: false,
      isManagement: pageController.isManagement,
    );
    return buildWritingBoardRuntimeState(data: data);
  }

  /// 把当前输入中的内容，回写到任务或范文自己的编辑快照里。
  void persistCurrentEditableRuntimeState() {
    final runtimeState = writingBoardRuntimeState.value;
    if (runtimeState == null) return;
    final pageController = requirePageController();
    final snapshot = runtimeState.copyWith(
      mode: pageController.mode.value,
      writingBoardTextMode: writingBoardTextMode.value,
    );
    if (pageController.isTaskDraftMode()) {
      pageController.taskController.draftWritingBoardRuntimeState = snapshot;
      return;
    }
    if (pageController.isExemplarEditMode()) {
      pageController.exemplarController.sampleEditWritingBoardRuntimeState = snapshot;
    }
  }

  /// 重新按当前模式拼一份写作板数据，并把输入控件也一起重建掉。
  void rebuildWritingBoardState() {
    final pageController = requirePageController();
    final details = pageController.isExemplarContentMode()
        ? pageController.exemplarController.exemplarDetailsData.value
        : pageController.taskController.taskDetailsData.value;
    if (details == null) return;
    final initialTextMode = _resolveCurrentWritingBoardTextMode(details);
    writingBoardTextMode.value = initialTextMode;
    // 范文只读态统一展示正文 anchors，包含独立范文页、任务查看范文和批改查看范文。
    final showKnowledgeAnchors = pageController.isExemplarReadOnlyMode();
    var data = mapTaskDetailsToWritingBoardData(
      details: details,
      paragraphRhetoricalList: pageController.paragraphRhetoricalList.toList(),
      selectBeatNid: selectBeatNid.value,
      writingBoardTextMode: initialTextMode,
      mode: pageController.mode.value,
      showKnowledgeAnchors: showKnowledgeAnchors,
      isManagement: pageController.isManagement,
    );
    late final WritingBoardRuntimeState runtimeState;
    if (pageController.isTaskDraftMode() && pageController.taskController.draftWritingBoardRuntimeState != null) {
      runtimeState = pageController.taskController.draftWritingBoardRuntimeState!.copyWith(
        mode: pageController.mode.value,
        writingBoardTextMode: pageController.taskController.draftWritingBoardRuntimeState!.writingBoardTextMode,
        focusedBeatNid: selectBeatNid.value.isNotEmpty
            ? selectBeatNid.value
            : pageController.taskController.draftWritingBoardRuntimeState!.focusedBeatNid,
      );
      data = applyRuntimeStateToWritingBoardData(
        data: data,
        runtimeState: runtimeState,
      );
    } else if (pageController.isExemplarEditMode() && pageController.exemplarController.sampleEditWritingBoardRuntimeState != null) {
      runtimeState = pageController.exemplarController.sampleEditWritingBoardRuntimeState!.copyWith(
        mode: pageController.mode.value,
        writingBoardTextMode: pageController.exemplarController.sampleEditWritingBoardRuntimeState!.writingBoardTextMode,
        focusedBeatNid: selectBeatNid.value.isNotEmpty
            ? selectBeatNid.value
            : pageController.exemplarController.sampleEditWritingBoardRuntimeState!.focusedBeatNid,
      );
      data = applyRuntimeStateToWritingBoardData(
        data: data,
        runtimeState: runtimeState,
      );
    } else if (pageController.isExemplarReadOnlyMode() && pageController.exemplarController.sampleEditWritingBoardRuntimeState != null) {
      runtimeState = pageController.exemplarController.sampleEditWritingBoardRuntimeState!.copyWith(
        mode: pageController.mode.value,
        writingBoardTextMode: pageController.exemplarController.sampleEditWritingBoardRuntimeState!.writingBoardTextMode,
        focusedBeatNid: selectBeatNid.value.isNotEmpty
            ? selectBeatNid.value
            : pageController.exemplarController.sampleEditWritingBoardRuntimeState!.focusedBeatNid,
      );
      data = applyRuntimeStateToWritingBoardData(
        data: data,
        runtimeState: runtimeState,
      );
    } else {
      runtimeState = buildWritingBoardRuntimeState(data: data);
      if (pageController.isTaskDraftMode()) {
        pageController.taskController.draftWritingBoardRuntimeState = runtimeState.copyWith();
      } else if (pageController.isExemplarEditMode()) {
        pageController.exemplarController.sampleEditWritingBoardRuntimeState = runtimeState.copyWith();
      }
    }
    writingBoardTextMode.value = runtimeState.writingBoardTextMode;
    writingBoardData.value = data;
    writingBoardRuntimeState.value = runtimeState;
    syncWritingBoardSubmitData();
    _disposeWritingBoardControllers();
    writingBoardControllers = buildWritingBoardControllers(
      data: data,
      runtimeState: runtimeState,
    );
    _bindWritingBoardFocusNodes();
  }

  /// 更新当前选中的拍位。
  void updateSelectedBeatNid(String beatNid) {
    if (beatNid.isEmpty) return;
    selectBeatNid.value = beatNid;
    final runtimeState = writingBoardRuntimeState.value;
    if (runtimeState != null) {
      runtimeState.focusedBeatNid = beatNid;
      writingBoardRuntimeState.value = runtimeState.copyWith();
      persistCurrentEditableRuntimeState();
    }
    syncWritingBoardDataFromRuntimeState();
  }

  /// 更新某个拍位的正文输入。
  void updateStepText(String beatNid, String text) {
    final runtimeState = writingBoardRuntimeState.value;
    if (runtimeState == null) return;
    runtimeState.stepTextMap[beatNid] = text;
    writingBoardRuntimeState.value = runtimeState.copyWith(
      stepTextMap: Map<String, String>.from(runtimeState.stepTextMap),
    );
    persistCurrentEditableRuntimeState();
    syncWritingBoardDataFromRuntimeState();
  }

  /// 更新文首输入。
  void updateHeadText(String text) {
    final runtimeState = writingBoardRuntimeState.value;
    if (runtimeState == null) return;
    runtimeState.headText = text;
    writingBoardRuntimeState.value = runtimeState.copyWith();
    persistCurrentEditableRuntimeState();
    syncWritingBoardDataFromRuntimeState();
  }

  /// 更新文尾输入。
  void updateTailText(String text) {
    final runtimeState = writingBoardRuntimeState.value;
    if (runtimeState == null) return;
    runtimeState.tailText = text;
    writingBoardRuntimeState.value = runtimeState.copyWith();
    persistCurrentEditableRuntimeState();
    syncWritingBoardDataFromRuntimeState();
  }

  /// 更新图片作答。
  void updateAnswerImages(List<WritingBoardMediaItemData> items) {
    final runtimeState = writingBoardRuntimeState.value;
    if (runtimeState == null) return;
    runtimeState.answerImages = List<WritingBoardMediaItemData>.from(items);
    writingBoardRuntimeState.value = runtimeState.copyWith(
      answerImages: List<WritingBoardMediaItemData>.from(items),
    );
    persistCurrentEditableRuntimeState();
    syncWritingBoardDataFromRuntimeState();
  }

  /// 更新视频作答。
  void updateAnswerVideos(List<WritingBoardMediaItemData> items) {
    final runtimeState = writingBoardRuntimeState.value;
    if (runtimeState == null) return;
    runtimeState.answerVideos = List<WritingBoardMediaItemData>.from(items);
    writingBoardRuntimeState.value = runtimeState.copyWith(
      answerVideos: List<WritingBoardMediaItemData>.from(items),
    );
    persistCurrentEditableRuntimeState();
    syncWritingBoardDataFromRuntimeState();
  }

  /// 更新音频作答。
  void updateAnswerAudios(List<WritingBoardMediaItemData> items) {
    final runtimeState = writingBoardRuntimeState.value;
    if (runtimeState == null) return;
    runtimeState.answerAudios = List<WritingBoardMediaItemData>.from(items);
    writingBoardRuntimeState.value = runtimeState.copyWith(
      answerAudios: List<WritingBoardMediaItemData>.from(items),
    );
    persistCurrentEditableRuntimeState();
    syncWritingBoardDataFromRuntimeState();
  }

  /// 更新文字题“写在纸上”模式的纸面照片。
  void updatePaperImages(List<WritingBoardMediaItemData> items) {
    final runtimeState = writingBoardRuntimeState.value;
    if (runtimeState == null) return;
    runtimeState.paperImages = List<WritingBoardMediaItemData>.from(items);
    writingBoardRuntimeState.value = runtimeState.copyWith(
      paperImages: List<WritingBoardMediaItemData>.from(items),
    );
    persistCurrentEditableRuntimeState();
    syncWritingBoardDataFromRuntimeState();
  }

  /// 让指定拍位的输入框拿到焦点。
  void requestStepFocus(String beatNid) {
    updateSelectedBeatNid(beatNid);
    writingBoardControllers?.stepFocusNodes[beatNid]?.requestFocus();
  }

  /// 点击某个拍位圆章。
  void onTapStepStamp(BuildContext context, String beatNid) {
    updateSelectedBeatNid(beatNid);
    final pageController = requirePageController();
    final step = writingBoardData.value?.steps.firstWhereOrNull((item) => item.beatNid == beatNid);
    if (step == null) return;
    final shouldOpenDialog = pageController.isExemplarReadOnlyMode() || !step.editable;
    if (!shouldOpenDialog) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      ZhenxieParagraphStepDetailsDialog.show(
        context: context,
        isManagement: pageController.isManagement,
        detailsData: pageController.detailsData.value,
        paragraphRhetoricalList: pageController.paragraphRhetoricalList.toList(),
        initBeatNid: beatNid,
      );
    });
  }

  /// 用运行时状态覆盖写作板渲染数据。
  WritingBoardData applyRuntimeStateToWritingBoardData({
    required WritingBoardData data,
    required WritingBoardRuntimeState runtimeState,
  }) {
    final useExemplarContent = data.mode.usesExemplarContent;
    final mediaItems = data.answerKindEnum == ZhenxieTaskAnswerKindEnum.image
        ? runtimeState.answerImages
        : data.answerKindEnum == ZhenxieTaskAnswerKindEnum.video
            ? runtimeState.answerVideos
            : data.answerKindEnum == ZhenxieTaskAnswerKindEnum.audio
                ? runtimeState.answerAudios
                : const <WritingBoardMediaItemData>[];
    return data.copyWith(
      writingBoardTextMode: runtimeState.writingBoardTextMode,
      headText: (data.headEditable || useExemplarContent) ? runtimeState.headText : data.headText,
      tailText: (data.tailEditable || useExemplarContent) ? runtimeState.tailText : data.tailText,
      steps: data.steps.map((step) {
        final stepText = (step.editable || useExemplarContent) ? runtimeState.stepTextMap[step.beatNid] ?? '' : step.text;
        return step.copyWith(
          selected: step.beatNid == selectBeatNid.value,
          focused: runtimeState.focusedBeatNid == step.beatNid,
          text: stepText,
        );
      }).toList(),
      mediaAnswer: useExemplarContent
          ? data.mediaAnswer
          : data.mediaAnswer?.copyWith(
              items: List<WritingBoardMediaItemData>.from(mediaItems),
            ),
      paperImageAnswer: data.answerKindEnum.isText
          ? data.paperImageAnswer?.copyWith(
              items: List<WritingBoardMediaItemData>.from(runtimeState.paperImages),
            )
          : data.paperImageAnswer,
      exemplarMediaAnswer: useExemplarContent
          ? data.exemplarMediaAnswer?.copyWith(
              items: List<WritingBoardMediaItemData>.from(mediaItems),
            )
          : data.exemplarMediaAnswer,
    );
  }

  /// 把运行时状态重新刷回到页面上的写作板数据。
  void syncWritingBoardDataFromRuntimeState() {
    final data = writingBoardData.value;
    final runtimeState = writingBoardRuntimeState.value;
    if (data == null || runtimeState == null) return;
    writingBoardData.value = applyRuntimeStateToWritingBoardData(
      data: data,
      runtimeState: runtimeState,
    );
    syncWritingBoardSubmitData();
  }

  /// 刷新当前的提交快照。
  void syncWritingBoardSubmitData() {
    final pageController = requirePageController();
    writingBoardSubmitData.value = pageController.taskController.buildWritingBoardSubmitData();
  }

  /// 手动更新当前提交快照。
  void updateWritingBoardSubmitData(WritingBoardSubmitData? data) {
    writingBoardSubmitData.value = data;
  }

  /// 判断当前板子里有没有没保存的改动。
  bool hasPendingExitChanges({
    ZhenxieTaskDetailsEntity? details,
    WritingBoardRuntimeState? runtimeState,
    WritingBoardModeEnum? mode,
  }) {
    final pageController = requirePageController();
    final compareMode = mode ?? pageController.mode.value;
    final compareRuntimeState = runtimeState ?? writingBoardRuntimeState.value;
    final data = details == null
        ? writingBoardData.value
        : mapTaskDetailsToWritingBoardData(
            details: details,
            paragraphRhetoricalList: pageController.paragraphRhetoricalList.toList(),
            selectBeatNid: selectBeatNid.value,
            writingBoardTextMode: _resolveDetailsWritingBoardTextMode(details),
            mode: compareMode,
            showKnowledgeAnchors: false,
            isManagement: pageController.isManagement,
          );
    if (data == null || compareRuntimeState == null) return false;
    final useCustomCompareContext = details != null || runtimeState != null || mode != null;
    if (!useCustomCompareContext && !pageController.isTaskDraftMode() && !pageController.isExemplarEditMode()) return false;
    final baselineRuntimeState = useCustomCompareContext
        ? buildExitCompareBaselineRuntimeState(
            details: details,
            mode: compareMode,
          )
        : pageController.isTaskDraftMode()
            ? pageController.taskController.taskExitCompareBaselineRuntimeState
            : pageController.exemplarController.sampleEditExitCompareBaselineRuntimeState;
    if (baselineRuntimeState == null) return false;
    final currentPayload = _buildExitComparePayload(
      data: data,
      runtimeState: compareRuntimeState,
    );
    final baselinePayload = _buildExitComparePayload(
      data: data,
      runtimeState: baselineRuntimeState,
    );
    return jsonEncode(currentPayload) != jsonEncode(baselinePayload);
  }

  /// 把当前板子的内容整理成稳定可比对的结构。
  Map<String, dynamic> _buildExitComparePayload({
    required WritingBoardData data,
    required WritingBoardRuntimeState runtimeState,
  }) {
    return {
      'answerKind': data.answerKindEnum.value,
      'writingBoardTextMode': runtimeState.writingBoardTextMode.value,
      'headText': data.showHead ? runtimeState.headText : null,
      'tailText': data.showTail ? runtimeState.tailText : null,
      'steps': data.steps
          .map((item) => {
                'beatNid': item.beatNid,
                'text': runtimeState.stepTextMap[item.beatNid] ?? '',
              })
          .toList(),
      'answerImages': _buildExitCompareMediaPayload(runtimeState.answerImages),
      'answerVideos': _buildExitCompareMediaPayload(runtimeState.answerVideos),
      'answerAudios': _buildExitCompareMediaPayload(runtimeState.answerAudios),
      'paperImages': _buildExitCompareMediaPayload(runtimeState.paperImages),
    };
  }

  /// 根据详情里的草稿来源恢复当前文字提交模式。
  ZhenxieTaskTextSubmitModeEnum _resolveDetailsWritingBoardTextMode(ZhenxieTaskDetailsEntity details) {
    return ZhenxieTaskTextSubmitModeEnum.fromValue(details.memberWriting?.source);
  }

  /// 根据当前页面上下文恢复写作板文字模式，优先使用已有运行时快照。
  ZhenxieTaskTextSubmitModeEnum _resolveCurrentWritingBoardTextMode(ZhenxieTaskDetailsEntity details) {
    final pageController = requirePageController();
    if (pageController.isTaskDraftMode() && pageController.taskController.draftWritingBoardRuntimeState != null) {
      return pageController.taskController.draftWritingBoardRuntimeState!.writingBoardTextMode;
    }
    if (pageController.isExemplarEditMode() && pageController.exemplarController.sampleEditWritingBoardRuntimeState != null) {
      return pageController.exemplarController.sampleEditWritingBoardRuntimeState!.writingBoardTextMode;
    }
    return _resolveDetailsWritingBoardTextMode(details);
  }

  /// 把媒体结果压成轻量结构，方便做稳定比较。
  List<Map<String, dynamic>> _buildExitCompareMediaPayload(List<WritingBoardMediaItemData> items) {
    return items
        .map((item) => {
              'key': item.key ?? '',
              'url': item.url ?? '',
              'localPath': item.localPath ?? '',
            })
        .toList();
  }

  /// 释放旧的输入控制器。
  void _disposeWritingBoardControllers() {
    writingBoardControllers?.dispose();
    writingBoardControllers = null;
  }

  /// 监听输入框焦点，保证键盘切换时，拍位选中态也跟着同步。
  void _bindWritingBoardFocusNodes() {
    final stepFocusNodes = writingBoardControllers?.stepFocusNodes ?? {};
    stepFocusNodes.forEach((beatNid, focusNode) {
      focusNode.addListener(() {
        if (!focusNode.hasFocus) return;
        if (selectBeatNid.value == beatNid && writingBoardRuntimeState.value?.focusedBeatNid == beatNid) return;
        selectBeatNid.value = beatNid;
        final runtimeState = writingBoardRuntimeState.value;
        if (runtimeState == null) return;
        runtimeState.focusedBeatNid = beatNid;
        writingBoardRuntimeState.value = runtimeState.copyWith();
        persistCurrentEditableRuntimeState();
        syncWritingBoardDataFromRuntimeState();
      });
    });
  }

  @override
  void onClose() {
    _disposeWritingBoardControllers();
    super.onClose();
  }
}
