import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/today_plan/views/wish_dialog.dart';
import 'package:langwise/app/routes/app_pages.dart';
import 'package:langwise/app/routes/routes_breadcrumb_utils.dart';
import 'package:langwise/app/routes/tag_routes.dart';
import 'package:langwise/common/public_controller/config_controller.dart';
import 'package:langwise/common/widgets/guide_engine/guide_manager.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/utils.dart';
import 'package:lib_common/common.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/https/https.dart';
import '../../../../common/stores/stores.dart';
import '../../../../common/values/values.dart';
import '../../../../theme/theme.dart';
import '../../home/controllers/home_controller.dart';
import '../../mission_control_center/controllers/mission_control_center_controller.dart';
import '../common/today_plan_calender_tip.dart';
import '../common/today_plan_introduction_tip.dart';
import '../common/today_plan_pause_dialog.dart';
import '../views/today_plan_edit_dialog.dart';

class TodayPlanController extends GetxController with RoutesBreadcrumbMixin {
  final String tagText;
  TodayPlanController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.TODAY_PLAN;

  @override
  String get breadcrumbTitle => "学习计划";

  /// 传进来的当前计划的page下标
  int todayPlanPageIndex = 0;
  int todayPlanCount = 0;

  final PersonalizedLearningPlanController personalizedLearningPlanController = PersonalizedLearningPlanController();

  /// 日历控制器
  PageController? calendarController;

  /// 日历最小日期
  final DateTime calendarMinDate = DateTime(2025);

  /// 日历当前年月
  final Rx<DateTime> calendarCurrentDate = DateTime.now().obs;

  /// 切换日历的时候的加载
  final RxBool calendarLoading = false.obs;

  final Rx<StudyPlanCalendarEntity> studyPlanCalendar = StudyPlanCalendarEntity().obs;

  /// 当前月份学习日历数据
  final RxList<StudyPlanCalendarEntityList> calendarPlanList = <StudyPlanCalendarEntityList>[].obs;

  final RxList<JoinedCoursesEntity> courseBaseList = <JoinedCoursesEntity>[].obs;

  final Rx<CoursePlanPathInfoEntity> planOrgData = CoursePlanPathInfoEntity().obs;

  final RxList<PersonalizedLearningPlanPageData> learningPlanPages = <PersonalizedLearningPlanPageData>[].obs;

  /// 超级记忆
  final RxBool superMemo = false.obs;

  /// 黄金陪练比
  final RxBool goldRatioSwitch = false.obs;

  /// 每日复习题目数量
  final RxInt reviewLimit = 0.obs;

  /// 是否显示添加计划按钮
  final RxBool showAddPlanButton = false.obs;

  /// 推荐起点
  final RxList<StudyPlanStartUnitEntity> recommendedStartingPointList = <StudyPlanStartUnitEntity>[].obs;

  /// 是否显示超记日历按钮提示
  final RxBool showSuperMemoCalenderPrompt = false.obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);

    if (Get.arguments != null) {
      todayPlanPageIndex = Get.arguments['tabIndex'] ?? 0;
      todayPlanCount = Get.arguments['todayPlanCount'] ?? 0;
    }

    initData();
    getSuperMemoCalenderPrompt();
    
  }

  /// 本地获取是否显示超记日历提示
  void getSuperMemoCalenderPrompt() async{
    bool res = StorageUtil().getBool(SUPER_MEMO_CALENDER_PROMPT_KEY);
    if(res) return;
    showSuperMemoCalenderPrompt.value = true;

    // 5秒后隐藏提示
    await Future.delayed(const Duration(seconds: 5));
    if(isClosed) return;
    hideSuperMemoCalenderPrompt();

  }

  /// 隐藏超记日历提示
  void hideSuperMemoCalenderPrompt() {
    showSuperMemoCalenderPrompt.value = false;
    StorageUtil().setBool(SUPER_MEMO_CALENDER_PROMPT_KEY, true);
  }



  Future<int?> _showValidAssessmentPlanDialog(String? explain) async {
    final ctx = Get.context;
    if (ctx == null) return null;

    try {
      ToastUtils.showLoading();
      final detail = await PracticeQuestionsReqest.getUserAiAssessmentResultDetail();
      if (detail?.plan == null) return null;

      final pages = _buildAiAssessmentPlanPages(detail!);
      if (pages.isEmpty) return null;
      await PracticeQuestionsReqest.updateAssessmentStatus(detail.base.assessmentId ?? 0);

      ToastUtils.hideLoading();
      dynamic res = await Get.to(_ValidAssessmentPlanDialog(
        pages: pages,
        explain: explain,
        lastAssessment: detail.lastAssessment,
      ));
      return res;
      
    } finally {
      ToastUtils.hideLoading();
    }
  }

  List<PersonalizedLearningPlanPageData> _buildAiAssessmentPlanPages(AiAssessmentResultDetailEntity detail) {
    final rights = detail.base.planRights;
    final plan = detail.plan;
    if (plan == null) return const [];

    PersonalizedLearningPlanPageData buildPage(String id, List<AiAssessmentPlanCardEntity> cards, List<Color> colors) {
      final cardDatas = <PersonalizedLearningPlanCardData>[];
      for (var i = 0; i < cards.length; i++) {
        final c = cards[i];
        final minutes = ((c.dailyStudyDuration ?? 0) / 60).round();
        final range = c.tierRange;
        final String? levelText;
        if (range == null) {
          levelText = null;
        } else if (range.max == null && range.min != null) {
          levelText = 'L${range.min}';
        } else if (range.min == null && range.max != null) {
          levelText = 'L0 → L${range.max}';
        } else if (range.min != null && range.max != null) {
          if (range.min == range.max) {
            levelText = 'L${range.min}';
          } else {
            levelText = 'L${range.min} → L${range.max}';
          }
        } else {
          levelText = null;
        }

        final statusText = c.status == 'EXECUTED'
            ? '已完成'
            : c.status == "RUNNING"
                ? '进行中'
                : c.status == "READY"
                    ? "可执行"
                    : "待执行";

        final icons = <PersonalizedLearningPlanIconData>[];
        for (int j = 0; j < c.directionList.length; j++) {
          final d = c.directionList[j];
          final title = LearningLangUtils.getLocalLang(d.title)?.text ?? '';
          if (title.isEmpty) continue;
          icons.add(
            PersonalizedLearningPlanIconData(
              heroTag: '${id}_${i}_${d.direction ?? title}',
              title: title,
              svgAsset: d.iconUrl,
              selected: !(d.exclude ?? false),
            ),
          );
        }

        cardDatas.add(
          PersonalizedLearningPlanCardData(
            id: '${id}_card_$i',
            title: c.name ?? '',
            rights: rights,
            type: id,
            subTitle: c.description,
            levelName: c.levelName,
            levelText: levelText,
            statusText: statusText,
            minutesPerDay: minutes,
            startPoint: range?.min ?? 0,
            semester: c.semester ?? 0,
            gradient: colors,
            icons: icons,
            moduleId: c.moduleId,
            levelId: c.levelId,
            moduleInfoList: c.moduleInfoList,
            directionList: c.directionList,
            description: c.description ?? '',
            isEnable: c.status == "READY" || c.status == "RUNNING",
            courseId: c.courseId,
            status: c.status,
            trigger: c.trigger,
          ),
        );
      }

      return PersonalizedLearningPlanPageData(id: id, cards: cardDatas);
    }

    final pages = <PersonalizedLearningPlanPageData>[];
    if (plan.official.isNotEmpty) {
      pages.add(
        buildPage(
          'official',
          plan.official,
          const [
            Color(0xFF22D3EE),
            Color(0xFF0891B2),
          ],
        ),
      );
    }
    if (plan.textbook.isNotEmpty) {
      pages.add(
        buildPage(
          'textbook',
          plan.textbook,
          const [
            Color(0xFF00D492),
            Color(0xFF009966),
          ],
        ),
      );
    }
    if (plan.phonics.isNotEmpty) {
      pages.add(
        buildPage(
          'phonics',
          plan.phonics,
          const [
            Color(0xFFC084FC),
            Color(0xFF9333EA),
          ],
        ),
      );
    }

    return pages;
  }

  Future<void> initData() async {
    
    await _loadCoursePlanPathInfo();
  }

  Future<void> _loadCoursePlanPathInfo() async {
    ToastUtils.showLoading();
    final resp = await StudyPlanRequest.getCoursePlanPathInfo();
    if (resp == null) {
      ToastUtils.hideLoading();
      return;
    }
    planOrgData.value = resp;
    int? jumpIndex;
    if ((GuideManager.instance.hasLockedTask &&
            (GuideManager.instance.activeTask?.taskId == 'JoinOfficialCourses' ||GuideManager.instance.activeTask?.taskId == 'JoinPhonics' || GuideManager.instance.activeTask?.taskId == 'JoinTextbookExpansion')) ||
        (resp.validAssessmentPlan ?? false) && Get.currentRoute == Routes.TODAY_PLAN) {
      jumpIndex = await _showValidAssessmentPlanDialog(resp.validAssessmentExplain);
    }
    learningPlanPages.value = _buildLearningPlanPages(resp);
    ToastUtils.hideLoading();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if(jumpIndex != null){
        personalizedLearningPlanController.jumpToPage(jumpIndex);
        await refreshData();
      }
      if (Get.currentRoute != Routes.TODAY_PLAN) return;
      if (!GuideManager.instance.hasLockedTask) return;
      await GuideManager.instance.tryShowCurrentStep(ignoreRoute: true);
    });
  }


  /// 刷新数据
  Future<void> refreshData() async {
    try {
      ToastUtils.showLoading();
      final resp = await StudyPlanRequest.getCoursePlanPathInfo();
      if (resp == null) return;
      learningPlanPages.value = _buildLearningPlanPages(resp);
    } finally{
      ToastUtils.hideLoading();
    }
  }

  List<PersonalizedLearningPlanPageData> _buildLearningPlanPages(CoursePlanPathInfoEntity resp) {
    PersonalizedLearningPlanPageData buildPage(String id, CoursePlanPathCourseEntity course, List<Color> colors) {
      final cardDatas = <PersonalizedLearningPlanCardData>[];
      final steps = course.steps;
      for (int i = 0; i < steps.length; i++) {
        final s = steps[i];
        int minutes = ((s.dailyStudyDuration ?? 0) / 60).round();
        final range = s.tierRange;
        final String? levelText;
        if (range == null) {
          levelText = null;
        } else if (range.max == null && range.min != null) {
          levelText = 'L${range.min}';
        } else if (range.min == null && range.max != null) {
          levelText = 'L0 → L${range.max}';
        } else if (range.min != null && range.max != null) {
          if (range.min == range.max) {
            levelText = 'L${range.min}';
          } else {
            levelText = 'L${range.min} → L${range.max}';
          }
        } else {
          levelText = null;
        }

        final statusText = s.status == 'EXECUTED'
            ? '已完成'
            : s.status == "RUNNING"
                ? '进行中'
                : s.status == "READY"
                    ? "可执行"
                    : "待执行";

        final icons = <PersonalizedLearningPlanIconData>[];
        if (s.status != 'RUNNING') {
          for (int j = 0; j < s.directionList.length; j++) {
            final d = s.directionList[j];
            final title = LearningLangUtils.getLocalLang(d.title)?.text ?? '';
            if (title.isEmpty) continue;
            icons.add(
              PersonalizedLearningPlanIconData(
                heroTag: '${id}_${i}_${d.direction ?? title}',
                title: title,
                svgAsset: d.iconUrl,
                selected: !(d.exclude ?? false),
              ),
            );
          }
        } else {
          minutes = ((course.studyPlan!.dailyStudyDuration ?? 0) / 60).round();
          List<LessonTypeEntityList?> dList = course.studyPlan!.directionList ?? [];
          for (int j = 0; j < dList.length; j++) {
            final d = dList[j];
            final title = LearningLangUtils.getLocalLang(d?.title)?.text ?? '';
            if (title.isEmpty) continue;
            icons.add(
              PersonalizedLearningPlanIconData(
                heroTag: '${id}_${i}_${d?.direction ?? title}',
                title: title,
                svgAsset: d?.iconUrl,
                selected: !(d?.exclude ?? false),
              ),
            );
          }
        }

        cardDatas.add(
          PersonalizedLearningPlanCardData(
              id: '${id}_card_$i',
              title: s.name ?? '',
              type: id,
              subTitle: s.description,
              levelText: levelText,
              statusText: statusText,
              levelName: s.levelName,
              minutesPerDay: minutes,
              gradient: colors,
              icons: icons,
              startPoint: s.tierRange?.min ?? 0,
              moduleInfoList: s.moduleInfoList,
              directionList: s.directionList,
              description: s.description ?? '',
              status: s.status,
              isEnable: s.status == "READY" || s.status == "RUNNING",
              courseId: course.courseId,
              rights: course.rights,
              moduleId: s.moduleId,
              levelId: s.levelId,
              pause: course.studyPlan?.pause ?? false,
              resumeDate: course.studyPlan?.resumeDate ?? '',
              isFromPlan: true,
              trigger: s.trigger,
              studyPlan: course.studyPlan,
              semester: s.semester ?? 0),
        );
      }

      return PersonalizedLearningPlanPageData(id: id, isFollowSystem: course.assessmentPlan == 1, courseId: course.courseId ?? 0, cards: cardDatas);
    }

    final pages = <PersonalizedLearningPlanPageData>[];
    final courses = resp.planPathCourses;
    for (final c in courses) {
      final sp = c.specialty;
      if (sp == 'EN_OFFICIAL') {
        pages.add(
          buildPage(
            'official',
            c,
            const [
              Color(0xFF22D3EE),
              Color(0xFF0891B2),
            ],
          ),
        );
      } else if (sp == 'EN_TEXTBOOK') {
        pages.add(
          buildPage(
            'textbook',
            c,
            const [
              Color(0xFF00D492),
              Color(0xFF009966),
            ],
          ),
        );
      } else if (sp == 'EN_PHONICS') {
        pages.add(
          buildPage(
            'phonics',
            c,
            const [
              Color(0xFFC084FC),
              Color(0xFF9333EA),
            ],
          ),
        );
      } else {
        pages.add(
          buildPage(
            'textbook',
            c,
            const [
              Color(0xFF00D492),
              Color(0xFF009966),
            ],
          ),
        );
      }
    }
    return pages;
  }


  /// 获取课程学习日历
  Future<void> getPlanCalendarList({bool isLoading = true}) async {
    try {
      calendarLoading.value = isLoading;
      Map<String, dynamic> reqParams = {
        "year": calendarCurrentDate.value.year,
        "month": calendarCurrentDate.value.month,
      };
      StudyPlanCalendarEntity? studyPlanCalendarEntity = await StudyPlanRequest.getPlanCalendarList(reqParams);
      if (studyPlanCalendarEntity == null) return;
      studyPlanCalendar.value = studyPlanCalendarEntity;
      List<StudyPlanCalendarEntityList?> list = studyPlanCalendarEntity.list ?? [];
      calendarPlanList.clear();
      for (int i = 0; i < list.length; i++) {
        if (list[i] == null) continue;
        calendarPlanList.add(list[i]!);
      }
    } finally {
      calendarLoading.value = false;
    }
  }

  /// 获取已经加入的课程， 用作判断是否显示添加计划按钮，如果计划列表内有全部加入的课程，就不显示添加计划按钮
  Future<void> getJoinedCoursesList() async {
    List<JoinedCoursesEntity>? list = await StudyPlanRequest.getJoinedCoursesList();
    if (list == null) return;
    courseBaseList.value = list;
  }

  /// 修改学习计划，这里只修改黄金学练和智能复习
  Future<void> modifyPlan(bool gold, bool memo) async {
    Map<String, dynamic> reqData = {
      "goldRatio": gold,
      "superMemo": memo,
    };
    ToastUtils.showLoading();
    bool editRes = await StudyPlanRequest.createStudyPlan(reqData);
    ToastUtils.hideLoading();
    if (!editRes) return;
    goldRatioSwitch.value = gold;
    superMemo.value = memo;
  }

  /// 每日复习时长上限弹窗
  Future<void> timeSetUpDialog(BuildContext context) async {
    String? inputRes = await InputDialog.show(
      context: context,
      title: "设置每日复习题目数量",
      content: "请填写每日复习题目数量",
      hintText: "请输入数字",
      inputDesc: "输入0表示不限数量，最大可设置为999",
      keyboardType: TextInputType.number,
      maxLength: 3, //最大999
      realName: reviewLimit.value.toString(),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
    );
    if (inputRes == null) return;
    int? value = int.tryParse(inputRes);
    if (value == null) return;
    Map<String, dynamic> reqData = {
      "reviewLimit": {
        "language": Get.find<ConfigController>().userSetting.value.learningLang,
        "enable": superMemo.value,
        "limit": value,
      },
    };
    ToastUtils.showLoading();
    bool editRes = await StudyPlanRequest.createStudyPlan(reqData);
    ToastUtils.hideLoading();
    if (!editRes) return;
    reviewLimit.value = value;
  }

  /// 编辑设置
  Future<void> editSetting(BuildContext context) async {
    bool isPwdRight = await ParentPasswordialog.show(context: context);
    if (!isPwdRight) return;

    bool res = await TodayPlanEditDialog.show(
      context: context,
      goldRatioSwitch: goldRatioSwitch.value,
      superMemo: superMemo.value,
      reviewLimit: reviewLimit.value,
    );
    if (!res) return;
    initData();
  }

  /// 暂停恢复计划
  Future<void> pauseRecoverPlan(BuildContext context, StudyPlanEntityPlanCourses data) async {
    if (data.courseId == null) return;
    Map<String, dynamic> reqData = {};
    if (data.pause == true) {
      bool? askRes = await AskDialog.showUserAsk(
        context: context,
        title: "要恢复新内容的学习吗？",
        content: "恢复后，会更新今日任务，系统将恢复为您安排新任务学习，已学知识点的复习任务也会正常进行。您可以随时暂停新内容的学习。",
        define: "确认恢复",
        defineColor: AppTheme.cFeedbackSuccessText.color,
      );
      if (!askRes) return;
      reqData['pause'] = false;
    } else {
      // 是否全部暂停
      bool isAllPause = true;
      
      List<String> otherPlanNames = [];
      for(var item in planOrgData.value.planPathCourses){
        if(data.courseId != item.courseId){
          otherPlanNames.add(item.courseName ?? "");
          if ((item.studyPlan?.pause ?? false) == false) {
            isAllPause = false;
          }
        }
      }

      int dailyStudyDuration = (data.dailyStudyDuration ?? 0) ~/ 60;

      String planInfoText = "";
      if (isAllPause) {
        planInfoText = "并把本计划的$dailyStudyDuration分钟全部分配给复习。";
      } else {
        planInfoText = "并把本计划的$dailyStudyDuration分钟智能分配给复习和${otherPlanNames.join("、")}计划的新学。";
      }

      TodayPlanPauseDialogResult? res = await TodayPlanPauseDialog.show(context: context, planInfoText: planInfoText);
      if (res == null) return;
      reqData['pause'] = true;
      if (res.recoverDate != null) {
        reqData["resumeDate"] = DateFormatUtil.formatStr(res.recoverDate!);
      }
    }
    bool isPwdRight = await ParentPasswordialog.show(context: context);
    if (!isPwdRight) return;
    try {
      ToastUtils.showLoading();
      bool reqRes = await StudyPlanRequest.pauseOrResumeStudyPlan(data.courseId!, reqData);
      if (!reqRes) return;
      await initData();
      ToastUtils.showToast(text: "操作成功", type: ToastType.success);
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().initHomeCardList();
      }
      final missionController = TagRoutes.findLast<MissionControlCenterController>(Routes.MISSION_CONTROL_CENTER);
      if (missionController != null) {
        await missionController.getTaskMission(showLoading: false);
      }
    } finally {
      ToastUtils.hideLoading();
    }
  }


  /// 获取推荐起点
  Future<void> getRecommendedStartingPoint() async {
    if (UserStore.to.userInfo.value.assessmentTier == null) return;
    Map<String, dynamic> reqParams = {
      "tier": UserStore.to.userInfo.value.assessmentTier,
    };
    List<StudyPlanStartUnitEntity>? startUnitEntityList = await StudyPlanRequest.getRecommendedStartingPoint(reqParams);
    if (startUnitEntityList == null) return;
    recommendedStartingPointList.value = startUnitEntityList;
  }

  Future<void> toEditPlan(StudyPlanEntityPlanCourses data, BuildContext context, int index) async {
    bool isPwdRight = await ParentPasswordialog.show(context: context);
    if (!isPwdRight) return;
    await TagRoutes.toNamed(Routes.NEW_CREATE_STUDY_PLAN, arguments: {
      'courseId': data.courseId,
      'initPlan': false,
      'titleName': index == 0
          ? '官方课程'
          : index == 1
              ? '教材'
              : '自然拼读'
    });
  }

  /// 去评测
  Future<void> toUserEvaluation(BuildContext context) async {
    await PracticeQuestionsReqest.startToAssessment(context);
    getRecommendedStartingPoint();
  }

  /// 去评测结果页面
  Future<void> toUserEvaluationResult(BuildContext context) async {
    await TagRoutes.toNamed(Routes.USER_EVALUATION_LEVEL);
  }

  ///去超记日历页面
  Future<void> toSuperMemoCalender(BuildContext context) async {
    hideSuperMemoCalenderPrompt();
    await TagRoutes.toNamed(Routes.SUPER_MEMO_CALENDER);
  }

  /// 显示 黄金学练 超级记忆 介绍
  void showIntroductionTip(BuildContext context) {
    TodayPlanIntroductionTip.show(context: context);
  }

  /// 显示超级日历说明
  void showCalenderTip(BuildContext context) {
    TodayPlanCalenderTip.show(context: context);
  }

  /// 显示设置心愿
  void showWishDialog(BuildContext context) {
    WishDialog.show(context: context);
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}

class _ValidAssessmentPlanDialog extends StatefulWidget {
  final List<PersonalizedLearningPlanPageData> pages;
  final String? explain;
  final String? lastAssessment;

  const _ValidAssessmentPlanDialog({required this.pages, required this.explain, required this.lastAssessment});

  @override
  State<_ValidAssessmentPlanDialog> createState() => _ValidAssessmentPlanDialogState();
}

class _ValidAssessmentPlanDialogState extends State<_ValidAssessmentPlanDialog> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final last = DateFormatUtil.formatStrtoStr((widget.lastAssessment ?? '').trim(), newPattern: 'yyyy年MM月dd日');

    return Scaffold(
      body: Stack(
        children: [
          ModalBarrier(
            dismissible: false,
            color: Colors.black.withValues(alpha: 0.45),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: double.infinity, maxHeight: double.infinity),
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                decoration: BoxDecoration(
                  color: AppTheme.cSurfacePrimary.color,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(
                      '你有新的规划还未执行',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28.wMin,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.cTextPrimary.color,
                      ),
                    ),
                    SizedBox(height: 12.wMin),
                    Visibility(
                      visible: last.isNotEmpty,
                      child: Text(
                        '评测时间:$last',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18.wMin,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.cTextSecondary.color,
                        ),
                      ),
                    ),
                    SizedBox(height: 10.wMin),
                    Expanded(
                      child: PersonalizedLearningPlanWidget(
                        pages: widget.pages,
                        showTitle: false,
                        isFromPlan: true,
                        isNoticeDialog: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
