import 'package:get/get.dart';
import '../../../../../common/enum/enum.dart';
import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/widgets/zhenxie_widgets/writing_boards/writing_boards.dart';
import '../../../../../utils/utils.dart';
import '../../../elements/utils/elements_page_utils.dart';
import '../helper/zhenxie_task_correction_review_item_helper.dart';
import 'zhenxie_task_details_controller.dart';

class ZhenxieTaskDetailsCorrectionController extends GetxController {
  final String tagText;
  ZhenxieTaskDetailsCorrectionController({required this.tagText});

  /// 页面主控制器，用于读取当前批改详情和任务静态资料。
  ZhenxieTaskDetailsController? _pageController;

  /// 当前选中的批改写作板显示模式。
  final Rx<ZhenxieTaskCorrectionWritingBoardModeEnum> correctionMode = ZhenxieTaskCorrectionWritingBoardModeEnum.annotation.obs;

  /// 当前右栏选中的批注筛选项。
  final Rx<ZhenxieReviewMarkerTabEnum> selectedMarkerTab = ZhenxieReviewMarkerTabEnum.all.obs;

  /// 当前左右联动选中的 marker id。
  final RxnString selectedMarkerId = RxnString();

  /// 当前左稿纸需要闪一下的 marker。
  final Rxn<ZhenxieTaskCorrectionPulse> flashMarkerPulse = Rxn<ZhenxieTaskCorrectionPulse>();

  /// 当前右栏批注卡片需要闪一下的 marker。
  final Rxn<ZhenxieTaskCorrectionPulse> flashCardPulse = Rxn<ZhenxieTaskCorrectionPulse>();

  /// 当前左稿纸需要闪一下的 part。
  final Rxn<ZhenxieTaskCorrectionPulse> flashPartPulse = Rxn<ZhenxieTaskCorrectionPulse>();

  /// 当前 focus 命中的业务 key。
  final RxnString focusAnchorKey = RxnString();

  /// 当前需要在稿纸上高亮的一组 anchors。
  final RxList<ZhenxieTaskDetailsMemberWritingReviewAnchor> focusAnchors = <ZhenxieTaskDetailsMemberWritingReviewAnchor>[].obs;

  /// 当前 pulse 自增序号。
  int _pulseTick = 0;

  /// 绑定页面主控制器，右栏批改区统一从这里读取当前展示数据。
  void bindPageController(ZhenxieTaskDetailsController controller) {
    _pageController = controller;
  }

  /// 获取当前页面主控制器。
  ZhenxieTaskDetailsController pageController() {
    return _pageController!;
  }

  /// 切换当前选中的批改写作板显示模式。
  void updateCorrectionMode(ZhenxieTaskCorrectionWritingBoardModeEnum mode) {
    if (mode == ZhenxieTaskCorrectionWritingBoardModeEnum.original && !shouldShowOriginalMode()) return;
    correctionMode.value = mode;
  }

  /// 更新当前批注筛选项。
  void updateSelectedMarkerTab(ZhenxieReviewMarkerTabEnum tab) {
    selectedMarkerTab.value = tab;
    final selectedItem = reviewItemById(selectedMarkerId.value);
    if (selectedItem != null && !_isItemVisibleInCurrentTab(selectedItem)) {
      selectedMarkerId.value = null;
      flashMarkerPulse.value = null;
      flashCardPulse.value = null;
    }
    if (correctionMode.value == ZhenxieTaskCorrectionWritingBoardModeEnum.correct) {
      final visibleItems = filteredReviewItems();
      final hasErrorIssue = visibleItems.any((item) => item.isErrorIssue());
      if (!hasErrorIssue) {
        correctionMode.value = ZhenxieTaskCorrectionWritingBoardModeEnum.annotation;
      }
    }
  }

  /// 返回当前页面正在看的作答详情。
  ZhenxieTaskDetailsMemberWriting? currentMemberWriting() {
    return pageController().detailsData.value.memberWriting;
  }

  /// 返回当前页面正在看的批改详情。
  ZhenxieTaskDetailsMemberWritingReview? currentReview() {
    return currentMemberWriting()?.review;
  }

  /// 当前作答类型是否为文字题。
  bool isTextAnswerKind() {
    return pageController().detailsData.value.stage?.answerKindEnum.isText ?? true;
  }

  /// 当前是否处于批改中状态。
  bool isReviewRunning() {
    final status = currentReview()?.statusEnum;
    return status == ZhenxieReviewStatusEnum.queued || status == ZhenxieReviewStatusEnum.running;
  }

  /// 当前是否处于批改失败状态。
  bool isReviewFailed() {
    return currentReview()?.statusEnum == ZhenxieReviewStatusEnum.failed;
  }

  /// 当前是否已经完成批改。
  bool isReviewDone({
    ZhenxieTaskDetailsMemberWritingReview? review,
  }) {
    return (review ?? currentReview())?.statusEnum == ZhenxieReviewStatusEnum.done;
  }

  /// 当前作答是否为纸面原稿模式。
  bool isPaperMemberWriting({
    ZhenxieTaskDetailsMemberWriting? memberWriting,
  }) {
    return (memberWriting ?? currentMemberWriting())?.source == ZhenxieTaskTextSubmitModeEnum.paper.value;
  }

  /// 当前批改模式切换条是否需要显示原稿模式。
  bool shouldShowOriginalMode({
    ZhenxieTaskDetailsMemberWriting? memberWriting,
    bool? isTextAnswerKindValue,
  }) {
    return (isTextAnswerKindValue ?? isTextAnswerKind()) && isPaperMemberWriting(memberWriting: memberWriting);
  }

  /// 返回当前批改区统一排序后的批注列表。
  List<ZhenxieTaskCorrectionReviewItem> reviewItems() {
    final parts = currentMemberWriting()?.parts?.whereType<ZhenxieTaskDetailsMemberWritingPart>().toList() ??
        const <ZhenxieTaskDetailsMemberWritingPart>[];
    final issues = currentReview()?.issues?.whereType<ZhenxieTaskDetailsMemberWritingReviewIssue>().toList() ??
        const <ZhenxieTaskDetailsMemberWritingReviewIssue>[];
    final highlights = currentReview()?.highlights?.whereType<ZhenxieTaskDetailsMemberWritingReviewHighlight>().toList() ??
        const <ZhenxieTaskDetailsMemberWritingReviewHighlight>[];
    return buildZhenxieTaskCorrectionReviewItems(
      parts: parts,
      issues: issues,
      highlights: highlights,
    );
  }

  /// 返回当前筛选后的批注列表。
  List<ZhenxieTaskCorrectionReviewItem> filteredReviewItems() {
    final items = reviewItems();
    if (selectedMarkerTab.value == ZhenxieReviewMarkerTabEnum.all) return items;
    return items.where((item) => item.filterKey() == selectedMarkerTab.value.value).toList();
  }

  /// 读取指定筛选项下的数量。
  int markerTabCount(ZhenxieReviewMarkerTabEnum tab) {
    if (tab == ZhenxieReviewMarkerTabEnum.all) return reviewItems().length;
    return reviewItems().where((item) => item.filterKey() == tab.value).length;
  }

  /// 读取指定 id 对应的批注条目。
  ZhenxieTaskCorrectionReviewItem? reviewItemById(String? id) {
    if ((id ?? '').isEmpty) return null;
    for (final item in reviewItems()) {
      if (item.id == id) return item;
    }
    return null;
  }

  /// 左稿纸点击 marker 后同步右栏选中态。
  void handleBoardMarkerSelection(String markerId) {
    final item = reviewItemById(markerId);
    if (item == null) return;
    if (!_isItemVisibleInCurrentTab(item)) {
      selectedMarkerTab.value = ZhenxieReviewMarkerTabEnum.all;
    }
    clearFocusAnchors();
    selectedMarkerId.value = markerId;
    flashCardPulse.value = ZhenxieTaskCorrectionPulse(
      id: markerId,
      tick: ++_pulseTick,
    );
  }

  /// 右栏点击批注卡片后同步稿纸选中态和闪动。
  void handleRailMarkerSelection(String markerId) {
    final item = reviewItemById(markerId);
    if (item == null) return;
    if (!_isItemVisibleInCurrentTab(item)) {
      selectedMarkerTab.value = ZhenxieReviewMarkerTabEnum.all;
    }
    final shouldFallbackToAnnotation = _shouldFallbackToAnnotationMode(item);
    if (shouldFallbackToAnnotation) {
      correctionMode.value = ZhenxieTaskCorrectionWritingBoardModeEnum.annotation;
    }
    selectedMarkerId.value = markerId;
    flashMarkerPulse.value = ZhenxieTaskCorrectionPulse(
      id: markerId,
      tick: ++_pulseTick,
    );
  }

  /// 按当前筛选列表切换上一条或下一条批注。
  void stepSelectedMarker(int delta) {
    final items = filteredReviewItems();
    if (items.isEmpty) return;
    var currentIndex = -1;
    for (var index = 0; index < items.length; index++) {
      if (items[index].id == selectedMarkerId.value) {
        currentIndex = index;
        break;
      }
    }
    final nextIndex = currentIndex < 0 ? (delta > 0 ? 0 : items.length - 1) : currentIndex + delta;
    if (nextIndex < 0 || nextIndex >= items.length) return;
    handleRailMarkerSelection(items[nextIndex].id);
  }

  /// 右栏点每段点评后，让稿纸对应 part 闪一下。
  void flashReviewPart(String partKey) {
    if (partKey.isEmpty) return;
    if (correctionMode.value == ZhenxieTaskCorrectionWritingBoardModeEnum.original) {
      correctionMode.value = ZhenxieTaskCorrectionWritingBoardModeEnum.annotation;
    }
    flashPartPulse.value = ZhenxieTaskCorrectionPulse(
      id: partKey,
      tick: ++_pulseTick,
    );
  }

  /// 切换核心词 / 语法点命中高亮。
  void toggleFocusAnchors({
    required String focusKey,
    required List<ZhenxieTaskDetailsMemberWritingReviewAnchor> anchors,
  }) {
    if (focusKey.isEmpty || anchors.isEmpty) return;
    if (correctionMode.value != ZhenxieTaskCorrectionWritingBoardModeEnum.annotation) {
      correctionMode.value = ZhenxieTaskCorrectionWritingBoardModeEnum.annotation;
    }
    if (focusAnchorKey.value == focusKey) {
      clearFocusAnchors();
      return;
    }
    focusAnchorKey.value = focusKey;
    focusAnchors.assignAll(anchors);
  }

  /// 清空当前 focus anchors。
  void clearFocusAnchors() {
    focusAnchorKey.value = null;
    focusAnchors.clear();
  }

  /// 处理关系标签点击，优先跳知识点，其次跳语法详情页。
  void handleRelationChipTap({
    ZhenxieTaskDetailsMemberWritingReviewKnowledge? knowledge,
    int? grammarTargetUid,
  }) {
    if (knowledge != null) {
      ElementsPageUtils.jumpElementsPage(
        contentId: knowledge.uid,
        contentType: knowledge.contentType,
        semanticId: knowledge.semanticId,
        styleId: null,
        dialect: null,
        isManagement: pageController().isManagement,
      );
      return;
    }
    if (grammarTargetUid == null || grammarTargetUid <= 0) return;
    pageController().jumpToGrammarDetail(grammarTargetUid);
  }

  /// 切换批改记录或模式前，重置当前联动态。
  void resetReviewInteractionState() {
    selectedMarkerTab.value = ZhenxieReviewMarkerTabEnum.all;
    selectedMarkerId.value = null;
    flashMarkerPulse.value = null;
    flashCardPulse.value = null;
    flashPartPulse.value = null;
    clearFocusAnchors();
    syncInitialCorrectionMode();
  }

  /// 按当前记录状态恢复批改稿纸默认模式。
  void syncInitialCorrectionMode({
    ZhenxieTaskDetailsMemberWriting? memberWriting,
    bool? isTextAnswerKindValue,
  }) {
    final targetWriting = memberWriting ?? currentMemberWriting();
    if (shouldShowOriginalMode(
          memberWriting: targetWriting,
          isTextAnswerKindValue: isTextAnswerKindValue,
        ) &&
        !isReviewDone(review: targetWriting?.review)) {
      correctionMode.value = ZhenxieTaskCorrectionWritingBoardModeEnum.original;
      return;
    }
    if (correctionMode.value == ZhenxieTaskCorrectionWritingBoardModeEnum.original ||
        !shouldShowOriginalMode(
          memberWriting: targetWriting,
          isTextAnswerKindValue: isTextAnswerKindValue,
        )) {
      correctionMode.value = ZhenxieTaskCorrectionWritingBoardModeEnum.annotation;
    }
  }

  /// 对当前选中的提交记录重新发起批改，并按提交批改同口径全量刷新任务详情。
  Future<void> retryReview() async {
    final taskId = pageController().taskUid;
    final writing = currentMemberWriting();
    final writingId = writing?.uid;
    final validationMessage = _validateRetryReview(
      taskId: taskId,
      writing: writing,
    );
    if (validationMessage != null) {
      ToastUtils.showToast(text: validationMessage);
      return;
    }
    try {
      ToastUtils.showLoading();
      final res = await StudyAppRequest.retryCompositionTaskReview(
        taskId: taskId!,
        writingId: writingId!,
      );
      if (res == null) return;
      _applyRetryResultLocally(res);
      ToastUtils.showToast(text: "已重新发起批改", type: ToastType.success);
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 当前条目在当前筛选下是否可见。
  bool _isItemVisibleInCurrentTab(ZhenxieTaskCorrectionReviewItem item) {
    if (selectedMarkerTab.value == ZhenxieReviewMarkerTabEnum.all) return true;
    return item.filterKey() == selectedMarkerTab.value.value;
  }

  /// 判断当前点击条目是否需要切回批注模式。
  bool _shouldFallbackToAnnotationMode(ZhenxieTaskCorrectionReviewItem item) {
    if (correctionMode.value == ZhenxieTaskCorrectionWritingBoardModeEnum.annotation) return false;
    if (correctionMode.value == ZhenxieTaskCorrectionWritingBoardModeEnum.upgrade ||
        correctionMode.value == ZhenxieTaskCorrectionWritingBoardModeEnum.original) {
      return true;
    }
    if (!item.isErrorIssue()) return true;
    return !_canStayInCorrectMode(item);
  }

  /// 判断当前 error 条目在订正模式下是否真的有可点击产物。
  bool _canStayInCorrectMode(ZhenxieTaskCorrectionReviewItem item) {
    final partKey = item.anchor.partKey ?? '';
    if (partKey.isEmpty) return false;
    final parts = currentMemberWriting()?.parts?.whereType<ZhenxieTaskDetailsMemberWritingPart>().toList() ??
        const <ZhenxieTaskDetailsMemberWritingPart>[];
    if (parts.isEmpty) return false;
    ZhenxieTaskDetailsMemberWritingPart? targetPart;
    for (final part in parts) {
      if ((part.key ?? '') == partKey || (part.beatNid ?? '') == partKey) {
        targetPart = part;
        break;
      }
    }
    if (targetPart == null || (targetPart.text ?? '').isEmpty) return false;
    final issues = currentReview()?.issues
            ?.whereType<ZhenxieTaskDetailsMemberWritingReviewIssue>()
            .where((issue) => (issue.anchor?.partKey ?? '') == partKey)
            .toList() ??
        const <ZhenxieTaskDetailsMemberWritingReviewIssue>[];
    if (issues.isEmpty) return false;
    final markerBundle = buildReviewBoardMarkerBundle(
      parts: parts,
      review: currentReview(),
    );
    final appliedEdits = buildReviewBoardAppliedEdits(
      text: targetPart.text ?? '',
      issues: issues,
      markers: markerBundle.markersByPart[partKey] ?? const <ReviewBoardMarkerData>[],
    );
    return appliedEdits.any((edit) => edit.id == item.id);
  }

  /// 校验当前选中记录是否允许重批。
  String? _validateRetryReview({
    required int? taskId,
    required ZhenxieTaskDetailsMemberWriting? writing,
  }) {
    if (taskId == null || taskId <= 0) return "写作任务ID不能为空";
    if (writing?.uid == null || writing!.uid! <= 0) return "写作ID不能为空";
    if (writing.statusEnum != ZhenxieTaskAnswerStatusEnum.submitted) return "当前记录不支持重新批改";
    final reviewStatus = writing.review?.statusEnum;
    if (reviewStatus == ZhenxieReviewStatusEnum.queued || reviewStatus == ZhenxieReviewStatusEnum.running) {
      return "当前批改仍在进行中";
    }
    if (reviewStatus == ZhenxieReviewStatusEnum.failed || reviewStatus == ZhenxieReviewStatusEnum.done) return null;
    return "当前记录不支持重新批改";
  }

  /// 当详情刷新暂时失败时，先把当前页本地状态切到排队中，避免停在失败态。
  void _applyRetryResultLocally(ZhenxieTaskSubmitResultEntity res) {
    final taskDetails = pageController().taskController.taskDetailsData.value;
    final writing = taskDetails?.memberWriting;
    if (taskDetails == null || writing == null) return;
    writing.review ??= ZhenxieTaskDetailsMemberWritingReview();
    writing.review!.status = res.status ?? ZhenxieReviewStatusEnum.queued.value;
    writing.review!.statusTitle = res.statusTitle;
    writing.review!.statusDescription = res.statusDescription;
    writing.review!.error = null;
    writing.review!.warnings = null;
    writing.score = null;
    taskDetails.compositionWritingId = writing.uid;
    pageController().taskController.taskDetailsData.refresh();
    resetReviewInteractionState();
    pageController().syncDisplayDataByMode();
    pageController().boardController.rebuildWritingBoardState();
    pageController().taskController.taskDetailsData.refresh();
  }
}
