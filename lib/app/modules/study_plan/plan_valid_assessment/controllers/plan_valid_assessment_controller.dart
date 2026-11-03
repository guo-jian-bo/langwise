import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/app/routes/routes_breadcrumb_utils.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/widgets/guide_engine/guide_engine.dart';
import '../../../../../common/widgets/study_plan_widgets/study_plan_widget.dart';
import '../../../../../utils/utils.dart';

class PlanValidAssessmentController extends GetxController with RoutesBreadcrumbMixin {
  final String tagText;
  PlanValidAssessmentController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.PLAN_VALID_ASSESSMENT;

  @override
  String get breadcrumbTitle => "评测规划";

  /// 传进来的参数 计划对应的下标
  int planIndex = 0;
  int? lastAssessmentId;

  final Rx<AiAssessmentResultDetailEntity> detailData = AiAssessmentResultDetailEntity(base: AssessmentResultDetailEntity()).obs;

  /// 计划列表
  final RxList<StudyPlanCardModel> planList = <StudyPlanCardModel>[].obs;

  /// 计划卡片控制器
  final StudyPlanCardController studyPlanCardController = StudyPlanCardController();

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
    if(Get.arguments != null){
      lastAssessmentId = Get.arguments["lastAssessmentId"];
      planIndex = Get.arguments["planIndex"] ?? 0;
    }
    getRecommendPlan(init: true);
  }

  // 获取推荐计划
  Future<void> getRecommendPlan({bool init = false}) async{
    try {
      ToastUtils.showLoading();
      AiAssessmentResultDetailEntity? detail;
      if(lastAssessmentId == null){
        if(!HttpAuthUtils.instance.isAuth(HttpAuthCodes.studyMemberCourseAssessmentDetailPlanV2)) return;
        detail = await PracticeQuestionsReqest.getUserAiAssessmentResultDetail();
      }else{
        if(!HttpAuthUtils.instance.isAuth(HttpAuthCodes.studyMemberCourseAssessmentResultPlanV2)) return;
        detail = await PracticeQuestionsReqest.getAiAssessmentResultDetail(lastAssessmentId!);
      }
      if (detail == null) return Get.back();
      detailData.value = detail;
      if(detailData.value.base.planPathCourses == null) return Get.back();
      setPlanData();

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        studyPlanCardController.jumpToPage(planIndex);
      });

      if(HttpAuthUtils.instance.isAuth(HttpAuthCodes.memberAssessmentShowUpdateStatus)){
        // 告诉服务端已经推荐过计划
        await PracticeQuestionsReqest.updateAssessmentStatus(lastAssessmentId ?? 0);
      }

      if(init){
        await Future.delayed(const Duration(milliseconds: 300));
        GuideTaskController.to.start(AppRoutesCode.studyPlan);
      }

    } finally {
      ToastUtils.hideLoading();
    }
  }

  // 组装计划数据
  void setPlanData(){
    planList.clear();
    List<PlanEntityPlanPathCourses?> planPathCourses = detailData.value.base.planPathCourses??[];
    for(PlanEntityPlanPathCourses? v in planPathCourses){
      if(v?.specialty == null || v?.courseId == null) continue;
      List<StudyPlanCardStepModel?> steps = v?.steps??[];

      StudyCourseStatusEnum courseStatus = getCourseStatus(v);

      StudyPlanCardModel cardModel = StudyPlanCardModel(
        courseId: v!.courseId!,
        assessmentId: detailData.value.base.assessmentId,
        specialty: v.specialty!,
        steps: steps,
        courseStatus: courseStatus,
        studyPlan: v.studyPlan,
      );
      planList.add(cardModel);
    }
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

  @override
  void onClose() {
    super.onClose();
  }
}
