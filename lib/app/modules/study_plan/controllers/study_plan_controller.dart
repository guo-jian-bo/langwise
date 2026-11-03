import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/mission_control_center/controllers/mission_control_center_controller.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/app/routes/routes_breadcrumb_utils.dart';
import 'package:langwise/app/routes/tag_routes.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/https/https.dart';
import '../../../../common/widgets/guide_engine/guide_engine.dart';
import '../../../../common/widgets/study_plan_widgets/study_plan_widget.dart';
import '../../../../utils/utils.dart';

class StudyPlanController extends GetxController with RoutesBreadcrumbMixin {
  final String tagText;
  StudyPlanController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.STUDY_PLAN;

  @override
  String get breadcrumbTitle => "学习计划";

  // 传进来的参数 
  /// 初始化的计划下标
  int planIndex = 0;

  /// 超记统计
  final Rx<MemberStatisticsEntity> memberStatistics = MemberStatisticsEntity().obs;

  /// 当前学员信息
  final Rx<CurrentMemberInfoEntity> currentMemberInfo = CurrentMemberInfoEntity().obs;

  /// 计划详情
  final Rx<PlanEntity> planEntity = PlanEntity().obs;

  /// 计划列表
  final RxList<StudyPlanCardModel> planList = <StudyPlanCardModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    if (Get.arguments != null) {
      planIndex = Get.arguments["planIndex"] ?? 0;
    }
    
    initData(isInit: true);
  }

  Future<void> initData({bool showLoading = true, bool isInit = false}) async{
    try {
      if(showLoading) ToastUtils.showLoading();
      if(isInit){
        await GuideTaskController.to.loadTasks(pageCode: AppRoutesCode.studyPlan);
      }
      await getCurrentMemberInfo();
      getMemberStatistics();
      await getPlanList(isInit: isInit);

      if(isInit){
        GuideTaskController.to.start(AppRoutesCode.studyPlan);
      }
    } finally{
      if(showLoading) ToastUtils.hideLoading();
    }
  }

  /// 获取用户学习信息
  Future<void> getCurrentMemberInfo() async {
    CurrentMemberInfoEntity? info = await UserRequest.getCurrentMemberInfo();
    if (info == null) return;
    currentMemberInfo.value = info;
  }

  /// 获取用户超记统计
  Future<void> getMemberStatistics() async {
    MemberStatisticsEntity? info = await StudiesRequest.getMemberStatistics();
    if (info == null) return;
    memberStatistics.value = info;
  }


  /// 查询计划
  Future<void> getPlanList({bool isInit = false}) async{
    try {
      PlanEntity? resp = await StudyPlanRequest.getPlanData();
      if(resp == null) return;
      planEntity.value = resp;

      planList.clear();

      List<PlanEntityPlanPathCourses?> planPathCourses = resp.planPathCourses??[];
      for(PlanEntityPlanPathCourses? v in planPathCourses){
        if(v?.specialty == null || v?.courseId == null) continue;
        List<StudyPlanCardStepModel?> steps = v?.steps??[];

        StudyCourseStatusEnum courseStatus = getCourseStatus(v);

        String? currentUnitInfoText;
        String? nextUnitInfoText;
        if(v?.studyPlan != null){
          nextUnitInfoText = "预计还有 ${v?.studyPlan?.nextUnitDay ?? 0} 天学习到下一个单元";
        }
        PlanEntityPlanPathCoursesStudyPlanStartUnitInfo? currentUnitInfo = v?.studyPlan?.currentUnitInfo;
        if(currentUnitInfo != null){
          currentUnitInfoText = "${currentUnitInfo.levelName??''} / ${currentUnitInfo.moduleName??''} / ${currentUnitInfo.unitName??''}";
        }

        StudyPlanCardModel cardModel = StudyPlanCardModel(
          courseId: v!.courseId!,
          assessmentId: resp.assessmentId,
          specialty: v.specialty!,
          steps: steps,
          courseStatus: courseStatus,
          resumeDate: v.studyPlan?.resumeDate,
          currentUnitInfoText: currentUnitInfoText,
          nextUnitInfoText: nextUnitInfoText,
          studyPlan: v.studyPlan,
        );
        planList.add(cardModel);
      }

      if(isInit){
        showUnlockPlanDialog();
        showValidAssessmentPlanDialog();
      }

    } finally{}
  }

  /// 显示解锁计划弹窗
  Future<void> showUnlockPlanDialog() async{
    if(Get.context == null) return;
    if(Get.currentRoute != Routes.STUDY_PLAN) return;
    
    List<PlanEntityPlanPathCourses?> planPathCourses = planEntity.value.planPathCourses??[];
    if(planPathCourses.isEmpty) return;

    // 检查是否有解锁计划
    PlanEntityPlanPathCourses? unlockPlan;
    StudyPlanCardStepModel? unlockStep;
    int stepCount = 0;
    int unlockCanShowIndex = 0;
    for(PlanEntityPlanPathCourses? v in planPathCourses){
      if(v == null) continue;
      int canShowIndex = v.canShowIndex??0;
      if(canShowIndex == 0) continue;
      
      List<StudyPlanCardStepModel?> steps = v.steps??[];
      if(steps.isEmpty) continue;
      if(canShowIndex - 1 >= steps.length) continue;
      StudyPlanCardStepModel? step = steps[canShowIndex - 1];
      if(step == null) continue;
      unlockPlan = v;
      unlockStep = step;
      stepCount = steps.length;
      unlockCanShowIndex = canShowIndex;
      // 显示后 重置canShowIndex=0 避免重复显示
      v.canShowIndex = 0;
      break;
    }
    if(unlockPlan == null || unlockStep == null || unlockPlan.specialty == null) return;

    await StudyPlanUnlockDialog.showUnlock(
      context: Get.context!,
      step: unlockStep,
      specialty: unlockPlan.specialty!,
      stepCount: stepCount,
      canShowIndex: unlockCanShowIndex,
      assessmentId: planEntity.value.assessmentId,
    );
    
    // 再次检测是否有解锁计划
    showUnlockPlanDialog();
  }

  /// 显示推荐计划弹窗
  Future<void> showValidAssessmentPlanDialog() async{
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(Get.context == null) return;
      if(Get.currentRoute != Routes.STUDY_PLAN) return;
      if(planEntity.value.validAssessmentPlan != true) return;
      TagRoutes.toNamed(
        Routes.PLAN_VALID_ASSESSMENT,
        arguments: {
          "planIndex": planIndex,
        },
      );
    });
  }

  /// 获取课程计划状态
  StudyCourseStatusEnum getCourseStatus(PlanEntityPlanPathCourses? plan){
    List<StudyPlanCardStepModel?> steps = plan?.steps??[];

    StudyCourseStatusEnum courseStatus = StudyCourseStatusEnum.PENDING;

    // steps是否全部是已完成的状态
    bool isAllExecuted = steps.every((element) => element?.statusEnum == StudyPlanStatusEnum.EXECUTED);
    if(steps.isEmpty) isAllExecuted = false;
    /// 是否全部是等待中状态
    bool isAllPending = steps.every((element) => element?.statusEnum == StudyPlanStatusEnum.PENDING);
    if(steps.isEmpty) isAllPending = false;

    if(isAllExecuted){
      courseStatus = StudyCourseStatusEnum.EXECUTED;
    }else if(isAllPending){
      courseStatus = StudyCourseStatusEnum.UNLOCKED;
    }else {
      if(plan?.studyPlan != null){
        if(plan?.studyPlan?.pause == true){
          courseStatus = StudyCourseStatusEnum.PAUSED;
        }else{
          courseStatus = StudyCourseStatusEnum.RUNNING;
        }
      }
    }

    return courseStatus;
  }


  /// 去等级评测结果页面
  Future<void> goAssessmentResultPage() async{
    if(currentMemberInfo.value.assessmentTier == null){
      await TagRoutes.toNamed(
        Routes.USER_EVALUATION,
        arguments: {
          'pageType': 0,
        },
      );
    }else{
      await TagRoutes.toNamed(
        Routes.USER_EVALUATION_LEVEL,
      );

      await initData(showLoading: false);

    }
    
    GuideTaskController.to.continueGuide(AppRoutesCode.studyPlan, GuideWidgetIds.studyPlanAssessmentLevelButton);
  }

  /// 去今日任务页面
  Future<void> goTodayTaskPage() async{
    if(planList.isEmpty) return GuideTaskController.to.stop();
    int? assessmentTier = currentMemberInfo.value.assessmentTier;
    if(assessmentTier == null) {
      ToastUtils.showToast(text: "请先去评测");
      GuideTaskController.to.stop();
      return;
    }

    // 先判断有没有正在执行的计划
    bool isRunning = planList.any((element) {
      bool isRunning = element.courseStatus == StudyCourseStatusEnum.RUNNING;
      return isRunning;
    });
    if(!isRunning){
      ToastUtils.showToast(text: "请先设置计划");
      GuideTaskController.to.stop();
      return;
    }

    MissionControlCenterController? controller = TagRoutes.findLast<MissionControlCenterController>(Routes.MISSION_CONTROL_CENTER);
    if(controller == null) {
      await TagRoutes.toNamed(Routes.MISSION_CONTROL_CENTER);
      GuideTaskController.to.continueGuide(AppRoutesCode.studyPlan, GuideWidgetIds.studyPlanTodayTaskButton);
      return;
    }
    GuideTaskController.to.stop();
    Get.until((route) => route.settings.name == Routes.MISSION_CONTROL_CENTER);

  }

  /// 获取计划总时长 分钟
  int getPlanTotalDuration(bool isRest){
    int totalDuration = 0;
    for(PlanEntityPlanPathCourses? plan in planEntity.value.planPathCourses??[]){
      if(plan?.studyPlan == null) continue;
      List<PlanEntityPlanPathCoursesStudyPlanPlans?>? plans = plan?.studyPlan?.plans ?? [];
      for(PlanEntityPlanPathCoursesStudyPlanPlans? v in plans){
        if(v?.isRest != isRest) continue;
        totalDuration += (v?.dailyStudyDuration??0);
      }
    }
    return (totalDuration / 60).toInt();
  }
  



  @override
  void onClose() {
    super.onClose();
  }
}
