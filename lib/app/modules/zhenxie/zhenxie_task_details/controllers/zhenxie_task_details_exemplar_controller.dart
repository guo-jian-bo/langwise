import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../common/enum/enum.dart';
import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/widgets/zhenxie_widgets/writing_boards/model/writing_board_data.dart';
import '../../../../../common/widgets/zhenxie_widgets/writing_boards/model/writing_board_frame_section_type.dart';
import '../../../../../common/widgets/zhenxie_widgets/writing_boards/utils/writing_board_runtime_state.dart';
import '../../../../../utils/utils.dart';
import '../views/zhenxie_task_view_sample_lock_dialog.dart';
import 'zhenxie_task_details_controller.dart';

class ZhenxieTaskDetailsExemplarController extends GetxController {
  final String tagText;
  ZhenxieTaskDetailsExemplarController({required this.tagText});

  /// 页面主控制器，用于协调当前显示模式和写作板状态。
  ZhenxieTaskDetailsController? _pageController;

  /// 范文详情。页面切换范文时会直接读，所以这里也要用响应式。
  final Rxn<ZhenxieTaskDetailsEntity> exemplarDetailsData = Rxn<ZhenxieTaskDetailsEntity>();

  /// 范文详情对应的知识点。资料 tab 会直接读这份列表。
  final RxList<ElementsCardEntityDatas> exemplarKnowledgePointsList = <ElementsCardEntityDatas>[].obs;

  /// 范文详情对应的语法 Target 轻量信息。资料 tab 会直接读这份列表。
  final RxList<CourseWriteTargetItemEntity> exemplarGrammarTargetList = <CourseWriteTargetItemEntity>[].obs;

  /// 范文编辑态运行时快照。
  WritingBoardRuntimeState? sampleEditWritingBoardRuntimeState;

  /// 范文编辑态最近一次已加载或已保存的对比基线。
  WritingBoardRuntimeState? sampleEditExitCompareBaselineRuntimeState;

  /// 当前高亮的首尾结构区域，仅服务范文只读态蓝图联动。
  final Rxn<WritingBoardFrameSectionType> highlightedFrameSection = Rxn<WritingBoardFrameSectionType>();

  /// 首尾结构联动高亮的恢复计时器。
  Timer? _frameSectionHighlightTimer;

  /// 绑定页面主控制器，后续通过主控制器协调页面展示态。
  void bindPageController(ZhenxieTaskDetailsController controller) {
    _pageController = controller;
  }

  /// 当前绑定的页面主控制器。
  ZhenxieTaskDetailsController pageController() {
    return _pageController!;
  }

  /// 查询范文详情，并在需要时同步到当前页面展示态。
  Future<bool> getExemplarDetailsData({
    int? targetCompositionUid,
    bool syncCurrentView = true,
  }) async {
    final pageController = this.pageController();
    int? exemplarCompositionId;
    if (targetCompositionUid != null) {
      exemplarCompositionId = targetCompositionUid;
    } else if (pageController.compositionUid != null) {
      exemplarCompositionId = pageController.compositionUid;
    } else {
      exemplarCompositionId = pageController.taskController.taskDetailsData.value?.exemplarCompositionId;
    }
    if (exemplarCompositionId == null) return false;
    try {
      final parameters = {
        "compositionId": exemplarCompositionId,
      };
      ZhenxieTaskDetailsEntity? entity;
      if (pageController.isManagement) {
        entity = await LanguageConsoleRequest.getZhenxieInstanceDetails(parameters: parameters);
      } else {
        entity = await LanguageUtil.getZhenxieInstanceDetails(parameters: parameters);
      }
      if (entity == null) return false;
      final knowledgePoints = await pageController.getKnowledgePointsList(details: entity);
      final grammarTargets = await pageController.getGrammarTargetList(details: entity);
      exemplarDetailsData.value = entity;
      exemplarKnowledgePointsList.assignAll(knowledgePoints);
      exemplarGrammarTargetList.assignAll(grammarTargets);
      syncSampleEditExitCompareBaseline();
      if (syncCurrentView && (pageController.isExemplarContentMode() || pageController.routeMode.usesExemplarContent)) {
        pageController.syncDisplayDataByMode();
        pageController.boardController.initSelectedBeatNid();
        pageController.boardController.rebuildWritingBoardState();
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// 以当前范文详情稳定数据重建“退出未保存判断”基线。
  void syncSampleEditExitCompareBaseline() {
    sampleEditExitCompareBaselineRuntimeState = pageController().boardController.buildExitCompareBaselineRuntimeState(
          details: exemplarDetailsData.value,
          mode: WritingBoardModeEnum.exemplarEdit,
        );
  }

  /// 查看范文，或从范文态切回任务态。
  Future<void> viewSample(BuildContext context) async {
    final pageController = this.pageController();
    if (pageController.isCorrectionExemplarMode()) {
      pageController.updateBoardMode(WritingBoardModeEnum.correction);
      pageController.tabType.value = ZhenxieTaskDetailsTabType.correction;
      clearFrameSectionHighlight();
      pageController.boardController.rebuildWritingBoardState();
      return;
    }
    if (pageController.isTaskExemplarMode()) {
      pageController.updateBoardMode(WritingBoardModeEnum.task);
      pageController.tabType.value = ZhenxieTaskDetailsTabType.materials;
      clearFrameSectionHighlight();
      pageController.boardController.rebuildWritingBoardState();
      return;
    }
    if (pageController.shouldLockExemplarView()) {
      final res = await ZhenxieTaskViewSampleLockDialog.show(
        context: context,
        isManagement: pageController.isManagement,
        title: "范文锁定",
        content: "这一关要看你自己能不能写出来。写完并提交之后，范文才会打开，用来对照。",
      );
      if (!res) return;
    }
    if (exemplarDetailsData.value == null) {
      try {
        ToastUtils.showLoading();
        final res = await getExemplarDetailsData(
          targetCompositionUid: pageController.taskController.taskDetailsData.value?.exemplarCompositionId,
          syncCurrentView: false,
        );
        if (!res) {
          ToastUtils.showToast(text: "范文详情获取失败");
          return;
        }
      } finally {
        ToastUtils.hideLoading();
      }
    }
    final nextMode = pageController.isCorrectionMode() ? WritingBoardModeEnum.correctionExemplar : WritingBoardModeEnum.taskExemplar;
    pageController.tabType.value = ZhenxieTaskDetailsTabType.materials;
    pageController.updateBoardMode(nextMode);
    pageController.boardController.rebuildWritingBoardState();
  }

  /// 切到管理端范文编辑态。
  void enterEditMode() {
    final pageController = this.pageController();
    pageController.updateBoardMode(WritingBoardModeEnum.exemplarEdit);
    pageController.boardController.rebuildWritingBoardState();
  }

  /// 管理端编辑保存范文方法。
  Future<void> saveSample() async {
    final pageController = this.pageController();
    final runtimeState = pageController.boardController.writingBoardRuntimeState.value;
    if (runtimeState == null) return;
    pageController.boardController.persistCurrentEditableRuntimeState();
    _writeSampleRuntimeStateBackToDetails(runtimeState);
    sampleEditExitCompareBaselineRuntimeState = runtimeState.copyWith();
    pageController.updateBoardMode(WritingBoardModeEnum.exemplar);
    pageController.boardController.rebuildWritingBoardState();
    ToastUtils.showToast(text: "范文保存占位已接线", type: ToastType.success);
  }

  /// 将当前范文编辑态输入结果回写到详情实体，保证切回查看态时内容保持一致。
  void _writeSampleRuntimeStateBackToDetails(WritingBoardRuntimeState runtimeState) {
    final pageController = this.pageController();
    final details = exemplarDetailsData.value;
    if (details == null) return;
    details.headText = _upsertLearningLangText(
      source: details.headText,
      text: runtimeState.headText,
    );
    details.tailText = _upsertLearningLangText(
      source: details.tailText,
      text: runtimeState.tailText,
    );
    final paragraphs = details.memberList ?? <ZhenxieTaskDetailsEntityParagraphInstance?>[];
    for (final step in pageController.boardController.writingBoardData.value?.steps ?? const <WritingBoardStepData>[]) {
      final nextText = runtimeState.stepTextMap[step.beatNid];
      if (nextText == null) continue;
      final paragraph = paragraphs.firstWhereOrNull((item) {
        return item?.paragraphId == step.paragraphId || item?.paragraph?.uid == step.paragraphId || item?.beatNid == step.beatNid;
      });
      if (paragraph != null) {
        paragraph.paragraph ??= ZhenxieTaskDetailsEntityParagraphContent();
        paragraph.paragraph!.content = nextText;
      }
    }
    if (details.stage?.answerKindEnum == ZhenxieTaskAnswerKindEnum.image) {
      details.answerImageUrls =
          runtimeState.answerImages.map((item) => item.url ?? item.localPath ?? '').where((item) => item.isNotEmpty).toList();
    } else if (details.stage?.answerKindEnum == ZhenxieTaskAnswerKindEnum.video) {
      details.answerVideoUrls =
          runtimeState.answerVideos.map((item) => item.url ?? item.localPath ?? '').where((item) => item.isNotEmpty).toList();
    } else if (details.stage?.answerKindEnum == ZhenxieTaskAnswerKindEnum.audio) {
      details.answerAudioUrls =
          runtimeState.answerAudios.map((item) => item.url ?? item.localPath ?? '').where((item) => item.isNotEmpty).toList();
    }
    if (pageController.isExemplarContentMode()) {
      pageController.detailsData.refresh();
    }
  }

  /// 触发首尾结构联动高亮，2 秒后自动恢复。
  void highlightFrameSection(WritingBoardFrameSectionType type) {
    if (!pageController().isExemplarReadOnlyMode()) return;
    _frameSectionHighlightTimer?.cancel();
    highlightedFrameSection.value = type;
    _frameSectionHighlightTimer = Timer(const Duration(seconds: 2), () {
      highlightedFrameSection.value = null;
    });
  }

  /// 清理当前首尾结构高亮状态。
  void clearFrameSectionHighlight() {
    _frameSectionHighlightTimer?.cancel();
    _frameSectionHighlightTimer = null;
    highlightedFrameSection.value = null;
  }

  /// 按学习语言主键更新或补充一条 `LanguageText`。
  List<LanguageText?> _upsertLearningLangText({
    required List<LanguageText?>? source,
    required String text,
  }) {
    final nextList = source != null ? List<LanguageText?>.from(source) : <LanguageText?>[];
    final learningLang = LearningLangUtils.getLearningLang(nextList)?.lang ??
        nextList.firstWhereOrNull((item) => item?.lang?.isNotEmpty == true)?.lang ??
        'en';
    final target = nextList.firstWhereOrNull((item) => item?.lang == learningLang);
    if (target != null) {
      target.text = text;
      return nextList;
    }
    nextList.add(LanguageText(lang: learningLang, text: text));
    return nextList;
  }

  @override
  void onClose() {
    clearFrameSectionHighlight();
    super.onClose();
  }
}
