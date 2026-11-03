import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/tag_routes.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:quiz_play/quiz_play.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/enum/enum.dart';
import '../../../../common/https/https.dart';
import '../../../../common/widgets/study_plan_widgets/study_plan_unlock_dialog.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../routes/routes.dart';
import '../../../routes/routes_breadcrumb_utils.dart';
import '../daily_task/controllers/mission_control_center_daily_task_controller.dart';
import '../milestone_challenge/controllers/mission_control_center_milestone_challenge_controller.dart';
import '../common/mission_control_center_statistics_dialog.dart';
import '../model/mission_model.dart';
import '../study_plan_calendar/controllers/mission_control_center_study_plan_calendar_controller.dart';

class MissionControlCenterController extends GetxController with RoutesBreadcrumbMixin {
  static const String examPlanStatusNoPlanNoWindow = "noPlanNoWindow";
  static const String examPlanStatusNoPlanInWindow = "noPlanInWindow";
  static const String examPlanStatusPlanReady = "planReady";

  final String tagText;
  MissionControlCenterController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.MISSION_CONTROL_CENTER;

  @override
  String get breadcrumbTitle => "学习规划";

  /// 传进来的参数 0=巩固今日 1=明日
  int review = 0;

  /// 学习规划默认展示tab 0=每日任务 1=超记日历 2=里程碑挑战
  int initialTab = 0;

  final ScrollController scrollController = ScrollController();

  final PageController examReviewPageController = PageController(
    viewportFraction: 0.7,
    initialPage: 2,
  );

  final GlobalKey listRootKey = GlobalKey();

  /// 当前mission下标
  final RxInt currentMissionIndex = 0.obs;

  /// 当前题目ID
  final RxInt currentExerciseId = 0.obs;

  /// 预计用时
  final RxInt exerciseDuration = 0.obs;

  /// 原始数据
  final Rx<TaskMissionEntity> missionEntity = TaskMissionEntity().obs;

  /// 实际展示的任务列表
  final RxList<MissionModel> missionList = <MissionModel>[].obs;

  /// 当前学习单元列表
  final RxList<CurrentCoursePlanInfoCourseItem> currentCoursePlanList = <CurrentCoursePlanInfoCourseItem>[].obs;

  /// 任务菜单列表
  final RxList<TaskMissionMenuEntityList> taskMissionMenuList = <TaskMissionMenuEntityList>[].obs;

  /// 今日是否有任务
  final RxBool isTodayMission = true.obs;

  /// 是否全部完成
  final RxBool isAllCompleted = false.obs;

  final RxInt selectedExamReviewIndex = 2.obs;
  final RxInt selectedBottomTabIndex = 0.obs;
  bool _dailyTaskLoaded = false;
  bool _studyPlanCalendarLoaded = false;
  bool _milestoneChallengeLoaded = false;
  final Map<int, Future<void>> _tabLoadFutures = {};
  bool _isShowingCurrentCourseUnlockDialog = false;
  bool _hasScheduledCurrentCourseUnlockDialogCheck = false;
  final Set<String> _handledCurrentCourseUnlockKeys = <String>{};

  List<MissionModel> get progressMissionList =>
      missionList.where((item) => !item.missions.isPreview).toList();

  int get completedMissionCount =>
      progressMissionList.where((item) => item.missions.learned).length;

  int get totalMissionCount => progressMissionList.length;

  List<TaskMissionEntityMissionKnowledgeItem> get todayMissionKnowledgeList =>
      missionEntity.value.displayKnowledgeList;

  TaskMissionEntityMissions? get currentMission {
    if (missionList.isEmpty) return null;
    final index = currentMissionIndex.value;
    if (index < 0 || index >= missionList.length) return null;
    return missionList[index].missions;
  }

  String get missionProgressText => "$completedMissionCount/$totalMissionCount";

  String get missionDurationText {
    final durationSeconds = missionEntity.value.duration;
    final durationMinutes = DateFormatUtil.convertSecondsToMinutes(durationSeconds?.round());
    return "$durationMinutes分钟";
  }

  String get missionAccuracyText {
    final accuracy = missionEntity.value.missionAccuracy;
    if (accuracy == null || accuracy <= 0) return "--";
    final percentValue = accuracy * 100;
    final display = percentValue % 1 == 0
        ? percentValue.toInt().toString()
        : percentValue.toStringAsFixed(1);
    return "$display%";
  }

  String get missionPointText => "${missionEntity.value.missionStars ?? 0}";

  TaskMissionEntityAssessmentSimpleResultDTO? get assessmentResult => missionEntity.value.assessmentSimpleResultDTO;

  TaskMissionEntityStudyPlanDTO? get studyPlan => missionEntity.value.studyPlanDTO;

  static const int _assessmentExpireDays = 90;

  DateTime? get _assessmentDate {
    final dateStr = assessmentResult?.assessmentDate?.trim();
    if (dateStr == null || dateStr.isEmpty) return null;
    return DateTime.tryParse(dateStr)?.toLocal();
  }

  int? get _assessmentElapsedDays {
    final assessmentDate = _assessmentDate;
    if (assessmentDate == null) return null;
    return DateTime.now().difference(assessmentDate).inDays;
  }

  bool get hasAssessmentResult {
    final result = assessmentResult;
    if (result == null) return false;
    final cefr = result.cefr?.trim();
    return (cefr?.isNotEmpty ?? false) || result.tier != null || _assessmentDate != null;
  }

  bool get isAssessmentExpired {
    final elapsedDays = _assessmentElapsedDays;
    if (elapsedDays == null) return false;
    return elapsedDays > _assessmentExpireDays;
  }

  String get assessmentBadgeLabel {
    if (!hasAssessmentResult) return "暂无\n等级";
    final cefr = assessmentResult?.cefr?.trim();
    if (cefr == null || cefr.isEmpty) return "A1";
    if (cefr == "Pre A1") return "A1";
    return cefr;
  }

  String get currentLevelLabel {
    if (!hasAssessmentResult) return "去评测";
    final tier = assessmentResult?.tier;
    if (tier != null) return "Level $tier";
    if (displayCurrentCoursePlanList.isNotEmpty) {
      return displayCurrentCoursePlanList.first.currentInfo?.levelName ?? "Level 4";
    }
    return "Level 4";
  }

  Color get assessmentBadgeColor => StatusUtils.getCefrBackgroundColor(assessmentResult?.cefr).color2;

  Color get assessmentPanelBadgeColor {
    if (!hasAssessmentResult) return AppTheme.cFeedbackErrorText.color;
    return assessmentBadgeColor;
  }

  Color get assessmentPanelTitleColor {
    if (!hasAssessmentResult) return AppTheme.cFeedbackErrorText.color;
    return AppTheme.cTextPrimary.color;
  }

  Color get assessmentPanelSubtitleColor {
    if (!hasAssessmentResult) return AppTheme.cTextSecondary.color;
    if (isAssessmentExpired) return AppTheme.cFeedbackWarningText.color;
    return AppTheme.cTextSecondary.color;
  }

  String get assessmentSubtitle {
    if (!hasAssessmentResult) return "开始听说读写能力评估";
    if (isAssessmentExpired) return "评测超过$_assessmentExpireDays天，建议重新评测";
    final parts = <String>[
      "最近评测 · ${_formatDaysAgo(assessmentResult?.assessmentDate)}",
    ];

    return parts.join("\n");
  }

  String get workdayStudyBadgeLabel {
    final workTime = studyPlan?.workTime?.trim();
    if (workTime == null || workTime.isEmpty) return "工作日";
    return workTime.split("、").first.trim();
  }

  bool get isStudyPlanRestDay => DateFormatUtil.isTodayWeekend();

  String get workdayStudyTagLabel => isStudyPlanRestDay ? "休息日" : "工作日";

  Color get studyPlanAccentColor => isStudyPlanRestDay
      ? const Color(0xFFF59E0B)
      : const Color(0xFF60A5FA);

  String get workdayStudyLabel => "${((studyPlan?.dailyStudyDuration ?? 1800) / 60).round()}";

  String get workdayStudyUnit => "分钟 / 天";

  String get studyPlanSubtitle => "最近学习 · ${_formatDaysAgo(studyPlan?.lastStudy)}";

  String get studyPlanCalendarTag => '${tagText}_study_plan_calendar';
  String get dailyTaskTag => '${tagText}_daily_task';
  String get milestoneChallengeTag => '${tagText}_milestone_challenge';

  String get examPlanStatus => missionEntity.value.examPlanDTO?.status ?? "";
  bool get hideExamPlanPanel {
    if (examPlanStatus.isEmpty) return true;
    if (examPlanStatus == examPlanStatusNoPlanNoWindow) return true;
    if (examPlanStatus == examPlanStatusPlanReady && currentExamPlan == null) return true;
    return false;
  }
  bool get showExamPlanGuide => examPlanStatus == examPlanStatusNoPlanInWindow;
  bool get showExamPlanReady => examPlanStatus == examPlanStatusPlanReady;

  TaskMissionEntityExamPlanItem? get currentExamPlan {
    final list = missionEntity.value.examPlanDTO?.list?.whereType<TaskMissionEntityExamPlanItem>().toList() ?? [];
    if (list.isEmpty) return null;
    final sortedPlans = list
      ..sort((a, b) {
        final aDate = _parseExamDate(a.examDate);
        final bDate = _parseExamDate(b.examDate);
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        final now = DateTime.now();
        final aDiff = _startOfDay(aDate).difference(_startOfDay(now)).inDays;
        final bDiff = _startOfDay(bDate).difference(_startOfDay(now)).inDays;
        final aWeight = aDiff >= 0 ? aDiff : 1 << 30;
        final bWeight = bDiff >= 0 ? bDiff : 1 << 30;
        if (aWeight != bWeight) return aWeight.compareTo(bWeight);
        return aDate.compareTo(bDate);
      });
    return sortedPlans.firstOrNull;
  }

  String get examTitleLabel {
    final title = currentExamPlan?.name?.trim();
    if (title == null || title.isEmpty) return "考试名称";
    return title;
  }

  int get examCountdownDays {
    final examDate = _parseExamDate(currentExamPlan?.examDate);
    if (examDate == null) return 54;
    return examDate.difference(DateTime.now()).inDays.clamp(0, 9999);
  }

  List<MissionControlExamReviewCard> get examReviewCards {
    final timeSlots = currentExamPlan?.timeSlots?.whereType<PreparationPlanTimeSlots>().toList() ?? [];
    if (timeSlots.isEmpty) return const [];
    final sortedSlots = timeSlots
      ..sort((a, b) {
        final aReview = a.reviewNumber ?? 0;
        final bReview = b.reviewNumber ?? 0;
        if (aReview != bReview) return aReview.compareTo(bReview);
        final aDate = DateFormatUtil.tryParseDate(a.date);
        final bDate = DateFormatUtil.tryParseDate(b.date);
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return aDate.compareTo(bDate);
      });
    final focusReviewNumber = _resolveFocusedReviewNumber(sortedSlots);
    return sortedSlots.map((slot) {
      final reviewNumber = slot.reviewNumber ?? 0;
      final isPrimary = reviewNumber == focusReviewNumber;
      return MissionControlExamReviewCard(
        stageLabel: "第 $reviewNumber 次复习",
        statusLabel: _buildExamSlotStatusLabel(slot),
        date: _formatExamSlotDate(slot.date),
        time: _formatExamSlotTime(slot.hour, slot.minute),
        actionLabel: _buildExamSlotActionLabel(slot),
        statusColor: _buildExamSlotStatusColor(slot),
        isPrimary: isPrimary,
        actionEnabled: _canStartExamSlot(slot),
        reviewDate: slot.date,
      );
    }).toList();
  }

  Future<void> onTapCreateExamPlan(BuildContext context) async {
    final student = await LockUtils.checkStudent(context);
    if (!student) return;
    await TagRoutes.toNamed(Routes.EXAM_PREPARATION);
  }

  List<String> get specialMissionTitles {
    if (taskMissionMenuList.isNotEmpty) {
      return taskMissionMenuList.map((item) => item.title ?? "").where((item) => item.isNotEmpty).toList();
    }
    return const ["听", "说", "读", "写", "综合"];
  }

  int get specialMissionDiamondTotal =>
      taskMissionMenuList.fold<int>(0, (sum, item) => sum + (item.diamondCount ?? 0));

  int get specialMissionDiamondMaxTotal =>
      taskMissionMenuList.fold<int>(0, (sum, item) => sum + (item.diamondMax ?? 0));

  List<CurrentCoursePlanInfoCourseItem> get displayCurrentCoursePlanList {
    return currentCoursePlanList.toList();
  }

  String _formatDaysAgo(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "--";
    final parsed = DateTime.tryParse(dateStr)?.toLocal();
    if (parsed == null) return "--";
    final days = DateTime.now().difference(parsed).inDays;
    if (days <= 0) return "今天";
    return "$days天前";
  }

  Future<void> onTapAssessmentPanel() async {
    await TagRoutes.toNamed(Routes.USER_EVALUATION_LEVEL);
  }

  Future<void> onTapStudyPlanPanel() async {
    await TagRoutes.toNamed(Routes.STUDY_PLAN);
  }

  Future<void> onTapBottomTab(int index) async {
    await _changeBottomTab(index);
  }

  Future<void> onTapCurrentCourse(CurrentCoursePlanInfoCourseItem item) async {
    if (!canTapCurrentCourse(item)) {
      ToastUtils.showToast(text: "暂无课程详情");
      return;
    }
    final info = item.currentInfo;
    final courseId = info?.courseId ?? item.courseId;
    final levelId = info?.levelId;
    final moduleId = info?.moduleId;
    if (courseId == null || levelId == null || moduleId == null) {
      ToastUtils.showToast(text: "暂无课程详情");
      return;
    }
    await TagRoutes.toNamed(
      Routes.OFFICIAL_COURSE_DETAILS,
      arguments: {
        "courseId": courseId,
        "levelId": levelId,
        "moduleId": moduleId,
      },
    );
  }

  bool canTapCurrentCourse(CurrentCoursePlanInfoCourseItem item) {
    final info = item.currentInfo;
    return (info?.courseId ?? item.courseId) != null &&
        info?.levelId != null &&
        info?.moduleId != null;
  }

  String currentCourseDisplayTitle(CurrentCoursePlanInfoCourseItem item) {
    final title = item.currentInfo?.unitName?.trim();
    if (title != null && title.isNotEmpty) return title;
    final courseName = item.courseName?.trim();
    if (courseName != null && courseName.isNotEmpty) return courseName;
    return "学习单元";
  }

  double? currentCourseUnitPercent(CurrentCoursePlanInfoCourseItem item) {
    final info = item.currentInfo;
    final total = info?.unitTotal ?? 0;
    final index = info?.unitIndex ?? 0;
    if (total <= 0 || index <= 0) return null;
    return ((index / total) * 100).clamp(0, 100).toDouble();
  }

  Future<void> onTapCurrentCoursePreview(CurrentCoursePlanInfoCourseItem item) async {
    final knowledgeList = await _loadCurrentCourseKnowledgeList(item);
    if (knowledgeList == null || knowledgeList.isEmpty) {
      ToastUtils.showToast(text: "暂无预习内容");
      return;
    }
    await TagRoutes.toNamed(
      Routes.OFFICIAL_COURSE_DETAILS_PREVIEW,
      arguments: {
        "unitName": item.currentInfo?.unitName,
        "knowledgeList": knowledgeList,
      },
    );
  }

  Future<void> onTapCurrentCoursePhonics(CurrentCoursePlanInfoCourseItem item) async {
    final courseId = item.courseId ?? item.currentInfo?.courseId;
    if (courseId == null) {
      ToastUtils.showToast(text: "当前课程暂无拼读内容");
      return;
    }
    await TagRoutes.toNamed(
      Routes.PHONICS_COURSE,
      arguments: {
        "courseId": courseId,
      },
    );
  }

  Future<void> onTapCurrentCourseFlashNotes(CurrentCoursePlanInfoCourseItem item) async {
    final knowledgeList = await _loadCurrentCourseKnowledgeList(item);
    if (knowledgeList == null || knowledgeList.isEmpty) {
      ToastUtils.showToast(text: "暂无闪记内容");
      return;
    }
    await TagRoutes.toNamed(
      Routes.OFFICIAL_COURSE_DETAILS_FLASH_NOTES,
      arguments: {
        "knowledgeList": knowledgeList,
      },
    );
  }

  Future<void> onTapCurrentCourseDictation(CurrentCoursePlanInfoCourseItem item) async {
    final knowledgeList = await _loadCurrentCourseKnowledgeList(item);
    if (knowledgeList == null || knowledgeList.isEmpty) {
      ToastUtils.showToast(text: "暂无听写内容");
      return;
    }
    await TagRoutes.toNamed(
      Routes.OFFICIAL_COURSE_DETAILS_DICTATION,
      arguments: {
        "unitName": item.currentInfo?.unitName,
        "knowledgeList": knowledgeList,
      },
    );
  }

  Future<List<UnitKnowledgePointsEntityKnowledgeList>?> _loadCurrentCourseKnowledgeList(
    CurrentCoursePlanInfoCourseItem item,
  ) async {
    final info = item.currentInfo;
    final courseId = info?.courseId ?? item.courseId;
    final moduleId = info?.moduleId;
    final unitId = info?.unitId;
    if (courseId == null || moduleId == null || unitId == null) return null;
    try {
      ToastUtils.showLoading();
      final entity = await OfficialCourseDetailsRequest.getUnitTarget(courseId, moduleId, unitId);
      if (entity == null) return null;
      final list = entity.knowledgeList?.whereType<UnitKnowledgePointsEntityKnowledgeList>().toList() ?? [];
      return list.where((item) => item.isWord || item.isPhrase || item.isSentence).toList();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<void> getCurrentCoursePlanInfoList() async {
    final entity = await MissionRequest.getCurrentCoursePlanInfoList();
    currentCoursePlanList.clear();
    final list = entity?.courseList;
    if (list == null) return;
    for (int i = 0; i < list.length; i++) {
      final item = list[i];
      if (item == null) continue;
      currentCoursePlanList.add(item);
    }
  }

  void _scheduleCurrentCourseUnlockDialogCheck() {
    if (_hasScheduledCurrentCourseUnlockDialogCheck) return;
    _hasScheduledCurrentCourseUnlockDialogCheck = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _hasScheduledCurrentCourseUnlockDialogCheck = false;
      _showCurrentCourseUnlockDialogsIfNeeded();
    });
  }

  bool _canShowCurrentCourseUnlockDialog() {
    if (_isShowingCurrentCourseUnlockDialog) return false;
    if (Get.context == null) return false;
    if (Get.currentRoute != Routes.MISSION_CONTROL_CENTER) return false;
    if (selectedBottomTabIndex.value != 0) return false;
    if (currentCoursePlanList.isEmpty) return false;
    return true;
  }

  Future<void> _showCurrentCourseUnlockDialogsIfNeeded() async {
    if (!_canShowCurrentCourseUnlockDialog()) return;

    _isShowingCurrentCourseUnlockDialog = true;
    try {
      final planEntity = await StudyPlanRequest.getPlanData();
      if (planEntity == null) return;

      final currentCourseIds = currentCoursePlanList
          .map((item) => item.currentInfo?.courseId ?? item.courseId)
          .whereType<int>()
          .toSet();
      if (currentCourseIds.isEmpty) return;

      final planPathCourses = planEntity.planPathCourses ?? [];
      while (_canShowMissionUnlockDialogNext()) {
        final unlockInfo = _takeNextCurrentCourseUnlockInfo(
          planPathCourses: planPathCourses,
          currentCourseIds: currentCourseIds,
          assessmentId: planEntity.assessmentId,
        );
        if (unlockInfo == null) return;

        await StudyPlanUnlockDialog.showUnlock(
          context: Get.context!,
          step: unlockInfo.step,
          specialty: unlockInfo.specialty,
          stepCount: unlockInfo.stepCount,
          canShowIndex: unlockInfo.canShowIndex,
          assessmentId: unlockInfo.assessmentId,
        );
      }
    } finally {
      _isShowingCurrentCourseUnlockDialog = false;
    }
  }

  bool _canShowMissionUnlockDialogNext() {
    if (Get.context == null) return false;
    if (Get.currentRoute != Routes.MISSION_CONTROL_CENTER) return false;
    if (selectedBottomTabIndex.value != 0) return false;
    return true;
  }

  _MissionCurrentCourseUnlockInfo? _takeNextCurrentCourseUnlockInfo({
    required List<PlanEntityPlanPathCourses?> planPathCourses,
    required Set<int> currentCourseIds,
    required int? assessmentId,
  }) {
    for (final plan in planPathCourses) {
      if (plan == null || plan.specialty == null || plan.courseId == null) continue;
      if (!currentCourseIds.contains(plan.courseId)) continue;

      final canShowIndex = plan.canShowIndex ?? 0;
      if (canShowIndex <= 0) continue;

      final handledKey = "${plan.courseId}_$canShowIndex";
      if (_handledCurrentCourseUnlockKeys.contains(handledKey)) {
        plan.canShowIndex = 0;
        continue;
      }

      final steps = plan.steps ?? [];
      if (steps.isEmpty) continue;
      if (canShowIndex - 1 >= steps.length) continue;

      final step = steps[canShowIndex - 1];
      if (step == null) continue;

      plan.canShowIndex = 0;
      _handledCurrentCourseUnlockKeys.add(handledKey);
      return _MissionCurrentCourseUnlockInfo(
        step: step,
        specialty: plan.specialty!,
        stepCount: steps.length,
        canShowIndex: canShowIndex,
        assessmentId: assessmentId,
      );
    }
    return null;
  }

  Future<void> onTapExamAction(MissionControlExamReviewCard card, BuildContext context) async {
    if (!card.actionEnabled) return;
    final student = await LockUtils.checkStudent(context);
    if (!student) return;
    final examId = currentExamPlan?.uid;
    final reviewDate = card.reviewDate;
    if (examId == null || reviewDate == null || reviewDate.isEmpty) return;
    try {
      ToastUtils.showLoading();
      final entity = await HomeRequest.getExamPreparationData(
        examId,
        {"date": reviewDate},
      );
      if (entity == null) return;
      final list = entity.exercises ?? [];
      if (list.isEmpty) return;
      final quizList = <QuizModel>[];
      for (int i = 0; i < list.length; i++) {
        final item = list[i];
        if (item?.exercise == null) continue;
        final quizModel = item!.exercise!;
        quizModel.testType = item.testType;
        quizModel.context = item.context;
        quizModel.duration = item.duration?.toDouble();
        quizList.add(quizModel);
      }
      if (quizList.isEmpty) return;
      await TagRoutes.toNamed(
        Routes.PRACTICE_QUESTIONS,
        arguments: {
          "quizDatas": quizList,
          "questionIsReport": true,
          "isShowPercentageProgress": true,
          "settingTotalDurationSecond": entity.duration,
        },
      );
    } finally {
      ToastUtils.hideLoading();
      _syncExamReviewSelection();
    }
  }

  int _resolveFocusedReviewNumber(List<PreparationPlanTimeSlots> slots) {
    final currentSlot = slots.firstWhereOrNull((slot) => slot.isStart);
    if (currentSlot != null) return currentSlot.reviewNumber ?? 1;
    final waitingSlot = slots.firstWhereOrNull((slot) => slot.isWaiting);
    if (waitingSlot != null) return waitingSlot.reviewNumber ?? 1;
    return slots.lastOrNull?.reviewNumber ?? 1;
  }

  String? _buildExamSlotStatusLabel(PreparationPlanTimeSlots slot) {
    if (slot.isFinish) return "已完成";
    if (slot.isStart) return "进行中";
    return null;
  }

  String _buildExamSlotActionLabel(PreparationPlanTimeSlots slot) {
    if (slot.isFinish) return "重新备考";
    if (slot.isStart) return "立即备考";
    return "开始备考";
  }

  bool _canStartExamSlot(PreparationPlanTimeSlots slot) {
    return slot.isStart || slot.isFinish;
  }

  Color _buildExamSlotStatusColor(PreparationPlanTimeSlots slot) {
    if (slot.isFinish) return const Color(0xFF10B981);
    if (slot.isStart) return const Color(0xFF818CF8);
    return const Color(0xFF6B7280);
  }

  String _formatExamSlotDate(String? date) {
    if (date == null || date.isEmpty) return "--";
    return DateFormatUtil.formatStrtoStr(date, newPattern: 'yyyy-MM-dd');
  }

  String _formatExamSlotTime(int? hour, int? minute) {
    final safeHour = hour ?? 0;
    final safeMinute = minute ?? 0;
    return "${safeHour.toString().padLeft(2, '0')}:${safeMinute.toString().padLeft(2, '0')}";
  }

  void _syncExamReviewSelection() {
    final cards = examReviewCards;
    if (cards.isEmpty) {
      selectedExamReviewIndex.value = 0;
      return;
    }
    final primaryIndex = cards.indexWhere((card) => card.isPrimary);
    final targetIndex = primaryIndex >= 0 ? primaryIndex : 0;
    selectedExamReviewIndex.value = targetIndex;
    if (examReviewPageController.hasClients) {
      examReviewPageController.jumpToPage(targetIndex);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!examReviewPageController.hasClients) return;
        examReviewPageController.jumpToPage(targetIndex);
      });
    }
  }

  DateTime? _parseExamDate(String? value) {
    return DateFormatUtil.tryParseDate(value)?.toLocal();
  }

  DateTime _startOfDay(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  void _ensureSuperMemoController() {
    if (Get.isRegistered<MissionControlCenterStudyPlanCalendarController>(tag: studyPlanCalendarTag)) return;
    Get.put<MissionControlCenterStudyPlanCalendarController>(
      MissionControlCenterStudyPlanCalendarController(tagText: studyPlanCalendarTag),
      tag: studyPlanCalendarTag,
      permanent: false,
    );
  }

  void _ensureDailyTaskController() {
    if (Get.isRegistered<MissionControlCenterDailyTaskController>(tag: dailyTaskTag)) return;
    Get.put<MissionControlCenterDailyTaskController>(
      MissionControlCenterDailyTaskController(tagText: tagText),
      tag: dailyTaskTag,
      permanent: false,
    );
  }

  void _ensureMilestoneChallengeController() {
    if (Get.isRegistered<MissionControlCenterMilestoneChallengeController>(tag: milestoneChallengeTag)) return;
    Get.put<MissionControlCenterMilestoneChallengeController>(
      MissionControlCenterMilestoneChallengeController(),
      tag: milestoneChallengeTag,
      permanent: false,
    );
  }

  void ensureTabController(int index) {
    switch (index) {
      case 0:
        _ensureDailyTaskController();
        break;
      case 1:
        _ensureSuperMemoController();
        break;
      case 2:
        _ensureMilestoneChallengeController();
        break;
    }
  }

  Future<void> _refreshDailyMissionData() async {
    await getTaskMission(showLoading: false, scrollToCurrent: false);
    _syncExamReviewSelection();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToCurrentMission();
    });
    _dailyTaskLoaded = true;
  }

  Future<void> _refreshSuperMemoData() async {
    _ensureSuperMemoController();
    final controller = Get.find<MissionControlCenterStudyPlanCalendarController>(tag: studyPlanCalendarTag);
    await controller.refreshData(isCalendarLoading: false);
    _studyPlanCalendarLoaded = true;
  }

  Future<void> _refreshMilestoneChallengeData() async {
    _ensureMilestoneChallengeController();
    final controller = Get.find<MissionControlCenterMilestoneChallengeController>(tag: milestoneChallengeTag);
    await controller.refreshData();
    _milestoneChallengeLoaded = true;
  }

  bool _isTabLoaded(int index) {
    switch (index) {
      case 1:
        return _studyPlanCalendarLoaded;
      case 2:
        return _milestoneChallengeLoaded;
      case 0:
      default:
        return _dailyTaskLoaded;
    }
  }

  bool _shouldRefreshOnTabEnter(int index) {
    return index == 1 || index == 2;
  }

  Future<void> _loadTabDataIfNeeded(int index, {bool forceRefresh = false}) {
    if (!forceRefresh && _isTabLoaded(index)) return Future.value();
    final existingFuture = _tabLoadFutures[index];
    if (existingFuture != null) return existingFuture;
    final future = _loadTabData(index);
    _tabLoadFutures[index] = future;
    return future.whenComplete(() {
      if (identical(_tabLoadFutures[index], future)) {
        _tabLoadFutures.remove(index);
      }
    });
  }

  Future<void> _loadTabData(int index) async {
    switch (index) {
      case 1:
        await _refreshSuperMemoData();
        return;
      case 2:
        await _refreshMilestoneChallengeData();
        return;
      case 0:
      default:
        await _refreshDailyMissionData();
        return;
    }
  }

  Future<void> _preloadRemainingTabs(int currentIndex) async {
    for (int index = 0; index < 3; index++) {
      if (index == currentIndex) continue;
      ensureTabController(index);
      await _loadTabDataIfNeeded(index);
    }
  }

  Future<void> _changeBottomTab(int index) async {
    if (selectedBottomTabIndex.value == index) return;
    selectedBottomTabIndex.value = index;
    await _loadTabDataIfNeeded(index, forceRefresh: _shouldRefreshOnTabEnter(index));
    if (index == 0) {
      _scheduleCurrentCourseUnlockDialogCheck();
    }
  }

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    if (Get.arguments != null) {
      review = Get.arguments['review'] ?? 0;
      initialTab = _resolveInitialTab(Get.arguments['initialTab']);
    }
    selectedBottomTabIndex.value = initialTab;
    ensureTabController(0);
    ensureTabController(1);
    ensureTabController(2);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTabDataIfNeeded(initialTab).then((_) {
        _preloadRemainingTabs(initialTab);
      });
    });
  }

  int _resolveInitialTab(dynamic value) {
    if (value is int) {
      return value.clamp(0, 2);
    }
    final text = value?.toString().trim().toLowerCase();
    switch (text) {
      case '1':
      case 'calendar':
      case 'study_plan_calendar':
      case 'super_memo':
      case 'super_memo_calendar':
      case '超记日历':
        return 1;
      case '2':
      case 'milestone':
      case 'milestone_challenge':
      case '里程碑挑战':
        return 2;
      case '0':
      case 'daily':
      case 'daily_task':
      case '每日任务':
      default:
        return 0;
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    examReviewPageController.dispose();
    _dailyTaskLoaded = false;
    _studyPlanCalendarLoaded = false;
    _milestoneChallengeLoaded = false;
    _isShowingCurrentCourseUnlockDialog = false;
    _hasScheduledCurrentCourseUnlockDialogCheck = false;
    _handledCurrentCourseUnlockKeys.clear();
    _tabLoadFutures.clear();
    if (Get.isRegistered<MissionControlCenterStudyPlanCalendarController>(tag: studyPlanCalendarTag)) {
      Get.delete<MissionControlCenterStudyPlanCalendarController>(tag: studyPlanCalendarTag, force: true);
    }
    if (Get.isRegistered<MissionControlCenterDailyTaskController>(tag: dailyTaskTag)) {
      Get.delete<MissionControlCenterDailyTaskController>(tag: dailyTaskTag, force: true);
    }
    if (Get.isRegistered<MissionControlCenterMilestoneChallengeController>(tag: milestoneChallengeTag)) {
      Get.delete<MissionControlCenterMilestoneChallengeController>(tag: milestoneChallengeTag, force: true);
    }
    super.onClose();
  }


  Future<void> getTaskMission({bool showLoading = true, bool scrollToCurrent = true}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      if (showLoading) ToastUtils.showLoading();
      TaskMissionEntity? entity = await MissionRequest.getMissionList(review);
      if (entity == null) return;
      await getTaskMissionMenu();
      missionEntity.value = entity;
      currentExerciseId.value = entity.exerciseId ?? 0;
      exerciseDuration.value = entity.exerciseDuration ?? 0;
      groupMissionData(entity);
      getCurrentMission();
      await getCurrentCoursePlanInfoList();
      _scheduleCurrentCourseUnlockDialogCheck();

      if (scrollToCurrent) {
        scrollToCurrentMission();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollToCurrentMission();
        });
      }
    } finally {
      review = 0;
      if (showLoading) ToastUtils.hideLoading();
    }
  }

  /// 获取任务菜单列表
  Future<void> getTaskMissionMenu() async {
    TaskMissionMenuEntity? entity = await MissionRequest.getTaskMissionMenu();
    if (entity == null) return;
    List<TaskMissionMenuEntityList?>? list = entity.list;
    if (list == null) return;
    taskMissionMenuList.clear();
    for (int i = 0; i < list.length; i++) {
      if (list[i] == null) continue;
      taskMissionMenuList.add(list[i]!);
    }
  }

  /// 对任务数据进行分组
  void groupMissionData(TaskMissionEntity entity) {
    List<TaskMissionEntityMissions?> missions = entity.missions ?? [];

    missionList.clear();
    for (int i = 0; i < missions.length; i++) {
      if (missions[i] == null) continue;
      int? missionId = missions[i]?.missionId;
      if (missionId == null) continue;

      missionList.add(MissionModel(
        missions: missions[i]!,
      ));
    }

    if(missionList.isEmpty){
      isAllCompleted.value = false;
      isTodayMission.value = false;
      return;
    }

    missionList.sort((a, b) => (a.missions.missionIndex ?? 0).compareTo(b.missions.missionIndex ?? 0));

    isAllCompleted.value = true;
    for (int i = 0; i < missionList.length; i++) {
      bool learned = missionList[i].missions.learned;
      if(learned) continue;
      isAllCompleted.value = false;
      break;
    }

  }

  /// 获取当前的mission
  void getCurrentMission() {
    if (missionList.isEmpty) return;
    currentMissionIndex.value = 0;
    for (int i = 0; i < missionList.length; i++) {
      bool notYetLearned = missionList[i].missions.notYetLearned;
      if (notYetLearned) {
        currentMissionIndex.value = i;
        break;
      }
    }
  }

  Future<void> onTapMissionOverview() async {
    final knowledgeList = todayMissionKnowledgeList;
    if (knowledgeList.isEmpty) {
      ToastUtils.showToast(text: "暂无内容");
      return;
    }
    await TagRoutes.toNamed(
      Routes.MISSION_CONTENT_SELECT,
      arguments: {
        "missionTitle": "今日知识概览",
        "missionSubtitle": "每日任务",
        "knowledgeList": knowledgeList,
        "learnUploadType": null,
      },
    );
  }

  Future<void>? scrollToCurrentMission() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!scrollController.hasClients) return;
    if (missionList.isEmpty) return;

    double itemWidth = 180.wMin;

    // 计算滚动视图的可见宽度
    double viewportWidth = scrollController.position.viewportDimension;

    // 计算当前任务的中心位置
    double targetCenter = (currentMissionIndex.value * itemWidth) + itemWidth / 2 + 18.wMin;

    // 计算滚动位置，让当前任务居中
    double targetScrollOffset = targetCenter - viewportWidth / 2;

    // 获取滚动范围的最小值和最大值
    double minScrollExtent = scrollController.position.minScrollExtent;
    double maxScrollExtent = scrollController.position.maxScrollExtent;

    // 确保滚动位置不超出范围
    targetScrollOffset = targetScrollOffset.clamp(minScrollExtent, maxScrollExtent);

    // 执行滚动动画
    scrollController.animateTo(
      targetScrollOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  /// 根据missionId获取任务下的所有exercise
  List<TaskMissionEntityExercises>? getMissionExercises(List<TaskMissionEntityExercises?> exercises, int missionId) {
    if (exercises.isEmpty) return null;
    List<TaskMissionEntityExercises> respList = [];
    for (int i = 0; i < exercises.length; i++) {
      if (exercises[i] == null) continue;
      if (exercises[i]?.missionId != missionId) continue;
      respList.add(exercises[i]!);
    }
    return respList;
  }

  /// 提前学按钮
  Future<void> advanceLearning(BuildContext context) async {
    bool askRes = await AskDialog.showUserAsk(
      context: context,
      title: "温馨提示",
      content: "是否确认提前学习？",
      showLastCountdown: true,
    );
    if (!askRes) return;
    
    review = 1;
    try {
      ToastUtils.showLoading();
      await getTaskMission(showLoading: false, scrollToCurrent: false);
    } finally {
      review = 0;
      ToastUtils.hideLoading();
    }
  }


  /// 开始任务
  Future<void> startMission(MissionModel mission, int index, {bool again = false}) async {

    if(mission.missions.isTest){
      await testMission(mission, index, again: again);
    } else if(mission.missions.isPreview){
      await previewMission(mission, index);
    }else{
      await toMission(mission, index);
    }
  }


  /// 普通任务
  Future<void> toMission(MissionModel mission, int index) async {
    try {
      ToastUtils.showLoading();
      int? missionId = mission.missions.missionId;
      if(missionId == null) return;
      TaskMissionEntity? entity = await MissionRequest.getMissionQuizList(missionId);
      if(entity == null) return;
      currentExerciseId.value = entity.exerciseId ?? 0;
      List<TaskMissionEntityExercises?>? exercises = entity.exercises??[];
      if(exercises.isEmpty) return;
      List<TaskMissionEntityExercises> missionExercises = [];
      for (int i = 0; i < exercises.length; i++) {
        if (exercises[i] == null) continue;
        missionExercises.add(exercises[i]!);
      }

      mission.exercises = missionExercises;

      await normalDoMission(mission, index);
      
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 预习任务
  Future<void> previewMission(MissionModel mission, int index) async {
    try {
      ToastUtils.showLoading();

      final sourceKnowledgeList = mission.missions.displayKnowledgeList;
      if (sourceKnowledgeList.isEmpty) {
        ToastUtils.showToast(text: "暂无预习内容");
        return;
      }

      final detailList = await MissionRequest.getMissionContentDetailList(
        sourceKnowledgeList,
        missionType: mission.missions.isPreviewRelearn ? null : "PREVIEW",
      );
      List<UnitKnowledgePointsEntityKnowledgeList> knowledgeList = [];
      for (final item in detailList) {
        if (item.isWord) knowledgeList.add(item);
        if (item.isPhrase) knowledgeList.add(item);
        if (item.isSentence) knowledgeList.add(item);
        if (item.isText) knowledgeList.add(item);
      }
      
      if (knowledgeList.isEmpty) {
        ToastUtils.showToast(text: "暂无预习内容");
        return;
      }

      await TagRoutes.toNamed(Routes.OFFICIAL_COURSE_DETAILS_PREVIEW, arguments: {
        "unitName": mission.missions.title,
        "knowledgeList": knowledgeList,
        "enableLearnUpload": true,
        "learnUploadType": null,
      });
      await getTaskMission(showLoading: false, scrollToCurrent: false);

    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 测试任务
  Future<void> testMission(MissionModel mission, int index, {bool again = false}) async {
    if(mission.missions.targetId == null) return;

    if(!again && mission.missions.learned){
      // 没有分数不让进
      if(mission.missions.score == null || mission.missions.score == 0){
        ToastUtils.showToast(text: "当前单元测试没有题目");
        return;
      }

      // 已经评测过 跳转至结果页面
      goToTestResultPage(targetId: mission.missions.targetId);
      return;
    }
    
    List<TaskMissionEntityExercises> exerciseList = [];
    int? unitTestRecordId;
    try {
      ToastUtils.showLoading();

      int restart = 0;
      /// 重新开始
      if(again){
        // 需要拉取接口 是否继续
        restart = 1;
      }

      TaskMissionUnitTestEntity? unitTestEntity = await MissionRequest.getTestMissionExercises(
        mission.missions.targetId!,
        restart: restart,
      );
      if(unitTestEntity == null) return;

      if(unitTestEntity.hasExercises == false){
        // 没有题目
        ToastUtils.showToast(text: "当前单元测试没有题目");
        mission.missions.status = LearnedStatusEnum.learned;
        missionList.refresh();
        getTaskMission(showLoading: false, scrollToCurrent: false);
        return;
      }

      unitTestRecordId = unitTestEntity.unitTestRecordId;
      
      if(unitTestEntity.exerciseId != null){
        currentExerciseId.value = unitTestEntity.exerciseId!;
      }
      
      List<TaskMissionEntityExercises?> exercises = unitTestEntity.exercises ?? [];
      if(exercises.isEmpty) return;
      for (int i = 0; i < exercises.length; i++) {
        if(exercises[i] == null) continue;
        exerciseList.add(exercises[i]!);
      }

    } finally{
      ToastUtils.hideLoading();
    }

    mission.exercises = exerciseList;
    
    await normalDoMission(
      mission, 
      index, 
      isAutoSkip: true, 
      maxErrorCount: 1, 
      isCanSwitchByNumber: false, 
      unitTestRecordId: unitTestRecordId,
      isShowImageGloss: false,
    );
    
  }

  /// 正常做题
  Future<void> normalDoMission(
    MissionModel mission, 
    int index, 
    {
      bool? isAutoSkip, 
      int? maxErrorCount, 
      bool? isCanSwitchByNumber,
      int? unitTestRecordId,
      bool isShowImageGloss = true,
    }) async {

    ErrorLogUtils.to.logInfo("练习 - mission ----- 开始");
    List<TaskMissionEntityExercises> exercises = mission.exercises??[];

    List<QuizModel> quizList = [];

    for (int i = 0; i < exercises.length; i++) {
      if (exercises[i].exercise == null) continue;
      exercises[i].exercise?.context = exercises[i].context;
      exercises[i].exercise?.testType = exercises[i].testType;
      exercises[i].exercise?.duration = exercises[i].duration;
      quizList.add(exercises[i].exercise!);
    }
    if (quizList.isEmpty) return;
    try {
      ToastUtils.showLoading();
      await CacheManagerUtils.instance.cacheQuizAssetsFirstTwo(quizList, exerciseCurrentId: currentExerciseId.value);
    } finally {}
    dynamic res = await TagRoutes.toNamed(
      Routes.PRACTICE_QUESTIONS,
      arguments: {
        "currentQuizId": currentExerciseId.value,
        "quizDatas": quizList,
        "questionIsReport": true,
        "isCollectCard": false,
        "isShowPercentageProgress": true,
        "settingTotalDurationSecond": mission.missions.estimatedTime?.toInt(),
        "isAutoSkip": isAutoSkip,
        "maxErrorCount": maxErrorCount,
        "isShowImageGloss": isShowImageGloss,
        "isCanSwitchByNumber": isCanSwitchByNumber,
      },
    );
    ErrorLogUtils.to.logInfo("练习 - mission ----- 退出了做题页面 $res");
    if (res == null) return;
    if (res["manual"] == true) return; // 说明是手动暂停退出 不显示结算页面

    ErrorLogUtils.to.logInfo("练习 - mission ----- 结束 --- 准备显示结果");

    if(mission.missions.isPreview){
      
    }else if(mission.missions.isTest){
      goToTestResultPage(unitTestRecordId: unitTestRecordId);
    }else{
      goToCompletePage(mission.missions);
    }
    
  }

  /// 跳转至评测结果页面
  Future<void> goToTestResultPage({int? unitTestRecordId, int? targetId}) async{
    ErrorLogUtils.to.logInfo("练习 - mission ----- 跳转至评测结果页面");
    dynamic res = await TagRoutes.toNamed(
      Routes.MISSION_TEST_RESULT,
      arguments: {
        "unitTestRecordId": unitTestRecordId,
        "targetId": targetId,
      },
    );
    if(res == null) return;
  }

  /// 跳转至mission完成页面
  Future<void> goToCompletePage(TaskMissionEntityMissions missions) async {
    ErrorLogUtils.to.logInfo("练习 - mission ----- 跳转至mission完成页面 ${missions.missionId}");
    if(missions.missionId == null) return;

    bool isLastMission = false;

    int currentIndex = 0;
    for (int i = 0; i < missionList.length; i++) {
      if (missionList[i].missions.missionId == missions.missionId) {
        isLastMission = i == missionList.length - 1;
        currentIndex = i;
        break;
      }
    }

    TaskMissionEntityMissions? nextMission;
    if(!isLastMission){
      nextMission = missionList[currentIndex + 1].missions;
    }

    dynamic res = await TagRoutes.toNamed(
      Routes.MISSION_COMPLETE,
      arguments: {
        "missionId": missions.missionId,
        "isLastMission": isLastMission,
        "nextMission": nextMission,
      },
    );
    if (res == null) return; // 0=返回控制中心 1=再做一遍 2=继续下一个任务
    if (res == 0){
      return;
    }
    if (res == 1) {
      int index = 0;
      MissionModel? missionModel;
      for (int i = 0; i < missionList.length; i++) {
        if (missionList[i].missions.missionId == missions.missionId) {
          index = i;
          missionModel = missionList[i];
          break;
        }
      }
      if (missionModel == null) return;
      startMission(missionModel, index);
    } else if (res == 2) {
      // 继续下一个任务
      startMission(missionList[currentMissionIndex.value], currentMissionIndex.value);
    }
  }


  /// 显示任务统计弹窗
  void showMissionStatisticsDialog(BuildContext context) {
    MissionControlCenterStatisticsDialog.show(
      context: context, 
      missionDurationAvg: DateFormatUtil.convertMillisecondsToMinSec(missionEntity.value.missionDurationAvgInt), 
      missionScoreAvg: "${missionEntity.value.missionScoreAvg??0}", 
      duration: DateFormatUtil.convertMillisecondsToMinSec(missionEntity.value.durationInt), 
      missionPoints: "+${missionEntity.value.missionPoints??0}",
    );
  }

  /// 任务菜单弹窗
  Future<void> showMissionTaskPop(BuildContext context, TaskMissionMenuEntityList item) async {
    if(item.type == null) return;

    TagRoutes.toNamed(
      Routes.MISSION_SPECIAL,
      arguments: {
        "taskType": item.type,
      },
    );
  }

  Future<void> onTapSpecialMission(TaskMissionMenuEntityList item) async {
    if (item.type == null) return;
    await TagRoutes.toNamed(
      Routes.MISSION_SPECIAL,
      arguments: {
        "taskType": item.type,
      },
    );
  }
}

class _MissionCurrentCourseUnlockInfo {
  final StudyPlanCardStepModel step;
  final String specialty;
  final int stepCount;
  final int canShowIndex;
  final int? assessmentId;

  const _MissionCurrentCourseUnlockInfo({
    required this.step,
    required this.specialty,
    required this.stepCount,
    required this.canShowIndex,
    required this.assessmentId,
  });
}

class MissionControlExamReviewCard {
  final String stageLabel;
  final String? statusLabel;
  final String date;
  final String time;
  final String actionLabel;
  final Color statusColor;
  final bool isPrimary;
  final bool actionEnabled;
  final String? reviewDate;

  const MissionControlExamReviewCard({
    required this.stageLabel,
    this.statusLabel,
    required this.date,
    required this.time,
    required this.actionLabel,
    required this.statusColor,
    this.isPrimary = false,
    this.actionEnabled = false,
    this.reviewDate,
  });
}
