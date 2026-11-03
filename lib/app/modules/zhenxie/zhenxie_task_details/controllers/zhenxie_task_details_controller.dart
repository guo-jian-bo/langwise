import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/app/routes/tag_routes.dart';

import '../../../../../common/enum/enum.dart';
import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/mixins/mixins.dart';
import '../../../../../common/widgets/ask_dialog.dart';
import '../../../../../common/widgets/zhenxie_widgets/writing_boards/model/writing_board_data.dart';
import '../../../../../utils/mqtt_utils/mqtt_message_services_code.dart';
import '../../../../../utils/utils.dart';
import '../views/zhenxie_task_view_sample_lock_dialog.dart';
import 'zhenxie_task_details_board_controller.dart';
import 'zhenxie_task_details_correction_controller.dart';
import 'zhenxie_task_details_exemplar_controller.dart';
import 'zhenxie_task_details_task_controller.dart';
import 'zhenxie_task_exercise_controller.dart';

class ZhenxieTaskDetailsController extends GetxController with DualBreadcrumbMixin {
  final String tagText;
  ZhenxieTaskDetailsController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.ZHENXIE_TASK_DETAILS;

  @override
  String get breadcrumbTitle => "任务详情";

  /// 页面绑定的任务业务控制器。
  late final ZhenxieTaskDetailsTaskController taskController;

  /// 页面绑定的范文业务控制器。
  late final ZhenxieTaskDetailsExemplarController exemplarController;

  /// 页面绑定的批改记录控制器。
  late final ZhenxieTaskDetailsCorrectionController correctionController;

  /// 页面绑定的写作板控制器。
  late final ZhenxieTaskDetailsBoardController boardController;

  /// 页面绑定的范文练习控制器。
  late final ZhenxieTaskExerciseController exerciseController;

  // 传进来的参数 --------------------------- start
  /// 是否是管理端。
  bool isManagement = false;

  /// 任务 id。
  int? taskUid;

  /// 范文 id。
  int? compositionUid;

  /// 单元ID
  int? unitId;

  /// 给拍范文角色标记。
  String? role;

  /// 路由传入的写作板模式。
  WritingBoardModeEnum routeMode = WritingBoardModeEnum.task;
  // 传进来的参数 --------------------------- end

  /// 当前选中的批改记录下标 -1状态下代表没有选中任何批改记录
  final RxInt selectedCorrectionIndex = (-1).obs;

  /// 当前右侧显示的是资料、蓝图，还是后面要接的批改。
  final Rx<ZhenxieTaskDetailsTabType> tabType = ZhenxieTaskDetailsTabType.materials.obs;

  /// 当前写作板模式。
  final Rx<WritingBoardModeEnum> mode = WritingBoardModeEnum.task.obs;

  /// 段落 / 文章的步骤配置。
  final RxList<ParagraphRhetoricalEntityList> paragraphRhetoricalList = <ParagraphRhetoricalEntityList>[].obs;

  /// 当前页面实际展示的详情数据。
  final Rx<ZhenxieTaskDetailsEntity> detailsData = ZhenxieTaskDetailsEntity().obs;

  /// 页面初始化完成后的学习时长计时器。
  final Stopwatch _studyDurationStopwatch = Stopwatch();

  StreamSubscription<PushMessageServiceEnitiy>? _messageSubscription;

  @override
  void onInit() {
    super.onInit();
    _bindChildControllers();
    if (Get.arguments != null) {
      isManagement = Get.arguments["isManagement"] ?? false;
      taskUid = Get.arguments["taskUid"];
      unitId = Get.arguments["unitId"];
      // isManagement = false;
      // unitId = 14208;
      // taskUid = 498;
      compositionUid = Get.arguments["compositionUid"];
      role = Get.arguments["role"]?.toString();
      routeMode = WritingBoardModeEnum.fromValue(Get.arguments["mode"]?.toString());
    }
    _initPageMode();
    initData();
    initBreadcrumb(tagText, title: "");

    _messageSubscription = MqttNotificationMessage.instance.listenByCode(
      codes: [MqttMessageServicesCode.compositionReviewCompleted], 
      onData: (value) {
        _handleCompositionReviewCompletedMessage();
      },
    );
  }

  /// 绑定子控制器，并回传当前页面控制器供其协调页面状态。
  void _bindChildControllers() {
    taskController = Get.find<ZhenxieTaskDetailsTaskController>(tag: tagText);
    exemplarController = Get.find<ZhenxieTaskDetailsExemplarController>(tag: tagText);
    correctionController = Get.find<ZhenxieTaskDetailsCorrectionController>(tag: tagText);
    boardController = Get.find<ZhenxieTaskDetailsBoardController>(tag: tagText);
    exerciseController = Get.find<ZhenxieTaskExerciseController>(tag: tagText);
    taskController.bindPageController(this);
    exemplarController.bindPageController(this);
    correctionController.bindPageController(this);
    boardController.bindPageController(this);
    exerciseController.bindPageController(this);
  }

  /// 初始化页面模式，直接根据路由传入的稳定值解析宏对象。
  void _initPageMode() {
    mode.value = routeMode;
    if (mode.value.usesExemplarContent) {
      tabType.value = ZhenxieTaskDetailsTabType.blueprint;
      return;
    }
    if (mode.value == WritingBoardModeEnum.correction) {
      tabType.value = ZhenxieTaskDetailsTabType.correction;
    }
  }

  /// 初始化页面基础数据。
  Future<void> initData() async {
    try {
      ToastUtils.showLoading();
      await getParagraphRhetoricalList();
      String originalTitle = mode.value.usesExemplarContent ? "范文详情" : "任务详情";
      if (mode.value.usesExemplarContent) {
        await exemplarController.getExemplarDetailsData();
        final name = LearningLangUtils.getLocalLang(exemplarController.exemplarDetailsData.value?.name);
        updateBreadcrumbTitle(name?.text ?? originalTitle);
      } else {
        await taskController.getTaskDetailsData();
        final name = LearningLangUtils.getLocalLang(taskController.taskDetailsData.value?.name);
        updateBreadcrumbTitle(name?.text ?? originalTitle);
      }
    } finally {
      ToastUtils.hideLoading();
      _startStudyDuration();
    }
  }

  /// 页面初始化完成后开始累计学习时长。
  void _startStudyDuration() {
    if (_studyDurationStopwatch.isRunning || _studyDurationStopwatch.elapsedMilliseconds > 0) return;
    _studyDurationStopwatch.start();
  }

  /// 当前已累计的学习时长，单位秒。
  double getStudyDurationSeconds() {
    return _studyDurationStopwatch.elapsedMilliseconds / 1000;
  }

  /// 停止累计学习时长。
  void stopStudyDuration() {
    _studyDurationStopwatch.stop();
  }

  /// 进入新一轮重写后，重置并重新开始累计学习时长。
  void restartStudyDuration() {
    _studyDurationStopwatch
      ..stop()
      ..reset()
      ..start();
  }

  /// 收到任务批改完成通知后，静默回刷批改数据，但保持用户当前查看上下文不跳变。
  Future<void> _handleCompositionReviewCompletedMessage() async {
    try {
      if (isClosed || mode.value.usesExemplarContent || taskUid == null || taskUid! <= 0) return;
      final currentViewingWritingId = detailsData.value.memberWriting?.uid;
      if (!isCorrectionContextMode() || currentViewingWritingId == null || currentViewingWritingId <= 0) {
        await taskController.getTaskDetailsData();
        return;
      }
      final memberDetail = await StudyAppRequest.getCompositionTaskMemberDetail(
        taskId: taskUid!,
        parameters: {
          "writingId": currentViewingWritingId,
        },
      );
      if (memberDetail == null || isClosed) return;
      final taskDetails = taskController.taskDetailsData.value;
      if (taskDetails == null) return;
      final currentMemberWriting = memberDetail.compositionWriting;
      taskDetails.memberReviewHistory = memberDetail.reviewHistory;
      taskDetails.memberWriting = currentMemberWriting;
      taskDetails.compositionWritingId = currentMemberWriting?.uid;
      taskController.taskDetailsData.refresh();
      syncDisplayDataByMode();
      if (isCorrectionMode() &&
          currentMemberWriting?.uid == currentViewingWritingId &&
          correctionController.correctionMode.value == ZhenxieTaskCorrectionWritingBoardModeEnum.original &&
          correctionController.isReviewDone(review: currentMemberWriting?.review)) {
        correctionController.updateCorrectionMode(ZhenxieTaskCorrectionWritingBoardModeEnum.annotation);
      }
      boardController.rebuildWritingBoardState();
    } catch (_) {}
  }

  /// 段落 / 文章的步骤。
  Future<void> getParagraphRhetoricalList() async {
    try {
      final entity = await LanguageUtil.getParagraphRhetoricalList();
      if (entity == null) return;
      final list = entity.list ?? [];
      paragraphRhetoricalList.clear();
      for (final item in list) {
        if (item == null) continue;
        paragraphRhetoricalList.add(item);
      }
    } catch (_) {}
  }

  /// 查询指定详情数据对应的知识点列表。
  Future<List<ElementsCardEntityDatas>> getKnowledgePointsList({
    required ZhenxieTaskDetailsEntity details,
  }) async {
    final knowledgePoints = details.knowledgePoints ?? [];
    if (knowledgePoints.isEmpty) return <ElementsCardEntityDatas>[];
    final reqData = <Map<String, dynamic>>[];
    for (final item in knowledgePoints) {
      if (item == null) continue;
      reqData.add({
        "type": item.contentType,
        "uid": item.uid,
        "semanticId": item.semanticId,
      });
    }
    final list = await LanguageUtil.getKnowledgeList(data: reqData);
    if (list == null) return <ElementsCardEntityDatas>[];
    return list;
  }

  /// 查询指定详情数据对应的语法 Target 轻量信息列表。
  Future<List<CourseWriteTargetItemEntity>> getGrammarTargetList({
    required ZhenxieTaskDetailsEntity details,
  }) async {
    final grammarTargetUids = details.grammarTargetUids ?? [];
    if (grammarTargetUids.isEmpty) return <CourseWriteTargetItemEntity>[];
    final targetIds = <int>[];
    for (final item in grammarTargetUids) {
      if (item <= 0) continue;
      targetIds.add(item);
    }
    if (targetIds.isEmpty) return <CourseWriteTargetItemEntity>[];
    final list = await CourseAppUtil.getCourseWriteTargetList(
      data: {"targetIds": targetIds},
    );
    if (list == null) return <CourseWriteTargetItemEntity>[];
    return list;
  }

  /// 当前是否处于任务作答态。
  bool isTaskDraftMode() {
    return mode.value == WritingBoardModeEnum.task;
  }

  /// 当前是否处于任务查看范文态。
  bool isTaskExemplarMode() {
    return mode.value == WritingBoardModeEnum.taskExemplar;
  }

  /// 当前是否处于范文查看态。
  bool isExemplarReadOnlyMode() {
    return mode.value.isExemplarReadOnlyMode || mode.value == WritingBoardModeEnum.correctionExemplar;
  }

  /// 当前是否处于范文编辑态。
  bool isExemplarEditMode() {
    return mode.value == WritingBoardModeEnum.exemplarEdit;
  }

  /// 当前是否处于批改记录查看态。
  bool isCorrectionMode() {
    return mode.value == WritingBoardModeEnum.correction;
  }

  /// 当前是否处于批改查看范文态。
  bool isCorrectionExemplarMode() {
    return mode.value == WritingBoardModeEnum.correctionExemplar;
  }

  /// 当前是否处于任意批改上下文。
  bool isCorrectionContextMode() {
    return mode.value.isCorrectionContextMode;
  }

  /// 当前是否正在展示范文内容。
  bool isExemplarContentMode() {
    return mode.value.usesExemplarContent;
  }

  /// 当前任务是否已经提交，可用于解锁范文和蓝图查看。
  bool hasSubmittedTask() {
    final details = taskController.taskDetailsData.value;
    if (details?.memberWriting?.statusEnum == ZhenxieTaskAnswerStatusEnum.submitted) return true;
    return details?.memberReviewHistory?.whereType<ZhenxieTaskDetailsReviewHistory>().isNotEmpty == true;
  }

  /// 当前上下文里查看范文是否仍然需要锁定。
  bool shouldLockExemplarView() {
    if (taskController.taskDetailsData.value?.stage?.lockExemplarView != true) return false;
    return !hasSubmittedTask();
  }

  /// 当前上下文里查看蓝图是否仍然需要锁定。
  bool shouldLockBlueprintTab() {
    if (taskController.taskDetailsData.value?.stage?.lockBlueprintTab != true) return false;
    return !hasSubmittedTask();
  }

  /// 当前任务下的批改历史摘要列表。
  List<ZhenxieTaskDetailsReviewHistory> reviewHistoryList() {
    return detailsData.value.memberReviewHistory?.whereType<ZhenxieTaskDetailsReviewHistory>().toList() ?? const [];
  }

  /// 当前正在看的批改历史摘要。
  ZhenxieTaskDetailsReviewHistory? currentReviewHistory() {
    final historyList = reviewHistoryList();
    if (historyList.isEmpty) return null;
    final currentWritingId = detailsData.value.memberWriting?.uid;
    for (final item in historyList) {
      if (currentWritingId != null && item.writingId == currentWritingId) return item;
    }
    for (var index = 0; index < historyList.length; index++) {
      if (index == selectedCorrectionIndex.value) return historyList[index];
    }
    for (final item in historyList) {
      if (item.selected == true) return item;
    }
    return historyList.first;
  }

  /// 切换当前写作板页面模式，并同步刷新当前展示态。
  void updateBoardMode(WritingBoardModeEnum nextMode) {
    if (mode.value != nextMode) {
      correctionController.resetReviewInteractionState();
    }
    mode.value = nextMode;
    syncDisplayDataByMode();
  }

  /// 切换批改记录
  Future<void> updateSelectedCorrectionId(int index) async {
    final historyList = reviewHistoryList();
    if (index < 0 || index >= historyList.length) {
      correctionController.resetReviewInteractionState();
      boardController.rebuildWritingBoardState();
      return;
    }
    final target = historyList[index];
    final currentWritingId = detailsData.value.memberWriting?.uid;
    if (target.writingId == currentWritingId) {
      correctionController.resetReviewInteractionState();
      selectedCorrectionIndex.value = index;
      mode.value = WritingBoardModeEnum.correction;
      tabType.value = ZhenxieTaskDetailsTabType.correction;
      exemplarController.clearFrameSectionHighlight();
      syncDisplayDataByMode();
      boardController.rebuildWritingBoardState();
      return;
    }
    if (taskUid == null || target.writingId == null) {
      ToastUtils.showToast(text: "当前批改记录缺少写作ID");
      return;
    }
    try {
      ToastUtils.showLoading();
      final memberDetail = await StudyAppRequest.getCompositionTaskMemberDetail(
        taskId: taskUid!,
        parameters: {
          "writingId": target.writingId,
        },
      );
      if (memberDetail == null) {
        ToastUtils.showToast(text: "切换批改记录失败");
        return;
      }
      final taskDetails = taskController.taskDetailsData.value;
      if (taskDetails == null) {
        ToastUtils.showToast(text: "当前任务详情还未准备好");
        return;
      }
      taskDetails.memberReviewHistory = memberDetail.reviewHistory;
      taskDetails.memberWriting = memberDetail.compositionWriting;
      taskDetails.compositionWritingId = memberDetail.compositionWriting?.uid;
      taskController.taskDetailsData.refresh();
      correctionController.resetReviewInteractionState();
      selectedCorrectionIndex.value = index;
      mode.value = WritingBoardModeEnum.correction;
      tabType.value = ZhenxieTaskDetailsTabType.correction;
      exemplarController.clearFrameSectionHighlight();
      syncDisplayDataByMode();
      detailsData.refresh();
    } finally {
      ToastUtils.hideLoading();
    }
    boardController.rebuildWritingBoardState();
  }

  /// 批改记录模式下进入重写态，优先带出已有草稿。
  Future<void> continueRewriteCorrection() async {
    final shouldRestartStudyDuration = !taskController.hasRewriteDraftEntry();
    try {
      ToastUtils.showLoading();
      final ready = await taskController.ensureRewriteDraftReady();
      if (!ready) return;
    } finally {
      ToastUtils.hideLoading();
    }
    correctionController.resetReviewInteractionState();
    selectedCorrectionIndex.value = -1;
    updateBoardMode(WritingBoardModeEnum.task);
    if (shouldRestartStudyDuration) restartStudyDuration();
    tabType.value = ZhenxieTaskDetailsTabType.materials;
    exemplarController.clearFrameSectionHighlight();
    boardController.rebuildWritingBoardState();
  }

  /// 跳转到课程语法详情页。
  Future<void> jumpToGrammarDetail(int? grammarTargetUid) async {
    if (grammarTargetUid == null || grammarTargetUid <= 0) return;
    final currentUnitId = unitId ?? detailsData.value.memberWriting?.unitId;
    if (currentUnitId == null || currentUnitId <= 0) return;
    // await TagRoutes.toNamed(
    //   Routes.MANAGE_UNIT_GRAMMAR_TARGET_DETAILS,
    //   arguments: {
    //     'unitId': currentUnitId,
    //     'targetUid': grammarTargetUid,
    //   },
    // );

    await TagRoutes.toNamed(
      Routes.COURSE_UNIT_GRAMMAR_DETAILS,
      arguments: {
        "unitId": currentUnitId,
        "targetUid": grammarTargetUid,
        "isManagement": isManagement,
      },
    );
  }

  /// 按当前模式同步 View 消费的展示详情数据。
  void syncDisplayDataByMode() {
    final details = isExemplarContentMode() ? exemplarController.exemplarDetailsData.value : taskController.taskDetailsData.value;
    if (details == null) return;
    detailsData.value = details;
    // 这里经常是把同一个详情实例重新同步给页面展示态，需要显式 refresh 才能让 Obx 稳定重建。
    detailsData.refresh();
    if (isCorrectionContextMode()) {
      correctionController.syncInitialCorrectionMode(
        memberWriting: details.memberWriting,
        isTextAnswerKindValue: details.stage?.answerKindEnum.isText ?? true,
      );
      syncSelectedCorrectionIndex();
      return;
    }
    correctionController.resetReviewInteractionState();
    selectedCorrectionIndex.value = -1;
  }

  /// 首次进入任务详情时，如果服务端已经给了选中的提交记录，就自动切到批改模式。
  void syncInitialCorrectionModeByDetails() {
    if (routeMode != WritingBoardModeEnum.task || mode.value != WritingBoardModeEnum.task) return;
    final memberWriting = taskController.taskDetailsData.value?.memberWriting;
    if (memberWriting?.statusEnum != ZhenxieTaskAnswerStatusEnum.submitted) return;
    final historyList =
        taskController.taskDetailsData.value?.memberReviewHistory?.whereType<ZhenxieTaskDetailsReviewHistory>().toList() ?? const [];
    if (historyList.isEmpty) return;
    final currentWritingId = memberWriting?.uid;
    final hasSelectedHistory = historyList.any((item) => item.selected == true);
    final hasMatchedHistory = currentWritingId != null && historyList.any((item) => item.writingId == currentWritingId);
    if (!hasSelectedHistory && !hasMatchedHistory) return;
    mode.value = WritingBoardModeEnum.correction;
    tabType.value = ZhenxieTaskDetailsTabType.correction;
    correctionController.syncInitialCorrectionMode(
      memberWriting: memberWriting,
      isTextAnswerKindValue: taskController.taskDetailsData.value?.stage?.answerKindEnum.isText ?? true,
    );
  }

  /// 按当前详情里的选中记录同步历史下标。
  void syncSelectedCorrectionIndex() {
    final historyList = reviewHistoryList();
    final currentWritingId = detailsData.value.memberWriting?.uid;
    for (var index = 0; index < historyList.length; index++) {
      final item = historyList[index];
      if (item.selected == true) {
        selectedCorrectionIndex.value = index;
        return;
      }
      if (currentWritingId != null && item.writingId == currentWritingId) {
        selectedCorrectionIndex.value = index;
        return;
      }
    }
    selectedCorrectionIndex.value = historyList.isEmpty ? -1 : 0;
  }

  /// 切换右侧 tab，蓝图锁定时先弹锁弹窗。
  Future<void> updateTabType(BuildContext context, ZhenxieTaskDetailsTabType type) async {
    if (type == tabType.value) return;
    if (type == ZhenxieTaskDetailsTabType.exercise) {
      tabType.value = type;
      await exerciseController.ensureExerciseListLoaded();
      return;
    }
    if (type != ZhenxieTaskDetailsTabType.blueprint) {
      tabType.value = type;
      return;
    }
    if (isExemplarContentMode() || !shouldLockBlueprintTab()) {
      tabType.value = type;
      return;
    }
    final res = await ZhenxieTaskViewSampleLockDialog.show(
      context: context,
      isManagement: isManagement,
      title: "蓝图先收着",
      content: "这一关要看你自己能不能写出来。写完并提交之后，蓝图才会打开。",
    );
    if (!res) return;
    tabType.value = type;
  }

  /// 管理端编辑入口是否具备完整跳转参数。
  bool hasManageEditorRouteParams() {
    return unitId != null && unitId! > 0 && taskUid != null && taskUid! > 0;
  }

  /// 管理端点击编辑按钮时，按当前模式跳到任务编辑页或范文编辑页。
  Future<void> toManageEditor() async {
    final bool isExemplarMode = isExemplarContentMode();
    if (unitId == null || unitId! <= 0) {
      ToastUtils.showToast(text: "unitId不能为空");
      return;
    }
    if (taskUid == null || taskUid! <= 0) {
      ToastUtils.showToast(text: "taskId不能为空");
      return;
    }

    dynamic result;
    if (isExemplarMode) {
      result = await TagRoutes.toNamed<bool>(
        Routes.MANAGE_UNIT_WRITING_TASK_EXEMPLAR,
        arguments: {
          'unitId': unitId,
          'taskId': taskUid,
          'exemplarCompositionId': compositionUid,
          if (role == 'given') 'role': 'given',
          'isManagement': isManagement,
        },
      );
    } else {
      result = await TagRoutes.toNamed<bool>(
        Routes.MANAGE_UNIT_WRITING_TASK_EDITOR,
        arguments: {
          'unitId': unitId,
          'taskId': taskUid,
          'isManagement': isManagement,
        },
      );
    }
    if (result == true) await initData();
  }

  /// 管理端在范文详情页点击重新生成时，进入写单元范文页。
  Future<void> toManageRegenerateExemplar() async {
    if (unitId == null || unitId! <= 0) {
      ToastUtils.showToast(text: "unitId不能为空");
      return;
    }
    if (taskUid == null || taskUid! <= 0) {
      ToastUtils.showToast(text: "taskId不能为空");
      return;
    }
    final bool? result = await TagRoutes.toNamed<bool>(
      Routes.MANAGE_UNIT_WRITING_TASK_EXEMPLAR,
      arguments: {
        'unitId': unitId,
        'taskId': taskUid,
        if (role == 'given') 'role': 'given',
        'isManagement': isManagement,
      },
    );
    if (result == true) Get.back(result: true);
  }

  /// 处理页面返回：有未保存修改时先弹确认框，否则直接退出。
  Future<bool> handlePageBack(BuildContext context) async {
    final shouldExit = await _confirmExitIfNeeded(context);
    if (!shouldExit) return false;
    Get.back();
    return true;
  }

  /// 退出前判断当前模式是否需要弹出未保存确认框。
  Future<bool> _confirmExitIfNeeded(BuildContext context) async {
    if (!boardController.hasPendingExitChanges()) return true;
    final askRes = await AskDialog.showUserAsk(
      context: context,
      title: '温馨提示',
      content: '还有未保存的更改，确定要退出吗',
      cancel: '继续退出',
      define: '继续写作',
    );
    if (askRes) return false;
    return true;
  }


  @override
  void onClose() {
    try {
      _messageSubscription?.cancel();
    } catch (_) {}
    super.onClose();
  }

}
