import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:langwise/utils/utils.dart';

import '../../../../../common/entities/entities.dart';
import '../../../../../common/https/https.dart';
import '../../../../../common/widgets/guide_engine/guide_engine.dart';
import '../../../../../common/widgets/study_plan_widgets/study_plan_widget.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../utils/mqtt_utils/mqtt_message_services_code.dart';
import '../../../../routes/routes.dart';
import '../../../../routes/routes_breadcrumb_utils.dart';
import '../../../../routes/tag_routes.dart';
import '../common/user_evaluation_level_share_dialog.dart';

class UserEvaluationLevelController extends GetxController with RoutesBreadcrumbMixin {
  final String tagText;
  UserEvaluationLevelController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.USER_EVALUATION_LEVEL;

  @override
  String get breadcrumbTitle => "英语评测结果";

  /// 传进来的参数 评测id
  int? assessmentId;

  final ScrollController scrollController = ScrollController();

  final Rx<AssessmentResultDetailEntity> resultDetail = AssessmentResultDetailEntity().obs;
  final Rx<List<AssessmentHistoryItemEntity>> assessmentHistory = Rx<List<AssessmentHistoryItemEntity>>([]);
  final Rx<CurrentMemberInfoEntity?> currentMemberInfo = Rx<CurrentMemberInfoEntity?>(null);
  final Rx<AiAssessmentResultDetailEntity?> aiResultDetail = Rx<AiAssessmentResultDetailEntity?>(null);

  /// 计划列表
  final RxList<StudyPlanCardModel> planList = <StudyPlanCardModel>[].obs;

  /// 生成图片页面key
  final GlobalKey sharePageKey = GlobalKey();

  Uint8List? shareImage;

  /// 计划卡片控制器
  final StudyPlanCardController studyPlanCardController = StudyPlanCardController();

  final RxInt reportDurationSec = 0.obs;
  Timer? _reportTimer;
  bool _reportCountdownTriggeredRefresh = false;

  StreamSubscription<PushMessageServiceEnitiy>? _assessmentPlanCompletedSubscription;

  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);

    GuideTaskController.to.loadTasks(pageCode: AppRoutesCode.userEvaluationLevelResult);

    if (Get.arguments != null) {
      assessmentId = Get.arguments["assessmentId"];
    }
    initData(isInit: true);
    
    _assessmentPlanCompletedSubscription = MqttNotificationMessage.instance.listenByCode(
      codes: [MqttMessageServicesCode.assessmentPlanCompleted], 
      onData: (value){
        getAssessmentResultDetail();
      },
    );
  }

  Future<void> initData({bool isInit = false, int? aId}) async {
    if(aId != null) {
      assessmentId = aId;
      scrollController.jumpTo(0);
    }
    await getAssessmentResultDetail();
    getAssessmentHistory();
    
    await getCurrentMemberInfo();

    if(isInit){
      GuideTaskController.to.start(AppRoutesCode.userEvaluationLevelResult);
    }
  }

  Future<void> getCurrentMemberInfo() async {
    final info = await UserRequest.getCurrentMemberInfo();
    if (info == null) return;
    currentMemberInfo.value = info;
  }

  Future<void> getAssessmentResultDetail() async {
    try {
      shareImage = null;
      ToastUtils.showLoading();
      AiAssessmentResultDetailEntity? resp;
      if (assessmentId != null) {
        resp = await PracticeQuestionsReqest.getAiAssessmentResultDetail(assessmentId!);
      } else {
        resp = await PracticeQuestionsReqest.getUserAiAssessmentResultDetail();
      }
      if (resp == null) return;
      aiResultDetail.value = resp;
      resultDetail.value = resp.base;
      setPlanData();
      _syncReportCountdown();
    } finally {
      ToastUtils.hideLoading();
    }
  }

  void _syncReportCountdown() {
    final seconds = resultDetail.value.reportDuration ?? 0;
    _startReportCountdown(seconds);
  }

  void _startReportCountdown(int seconds) {
    _reportTimer?.cancel();
    _reportTimer = null;

    final s = seconds < 0 ? 0 : seconds;
    reportDurationSec.value = s;
    if (s <= 0) return;

    _reportCountdownTriggeredRefresh = false;
    _reportTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final next = reportDurationSec.value - 1;
      if (next <= 0) {
        reportDurationSec.value = 0;
        timer.cancel();
        _reportTimer = null;

        if (!_reportCountdownTriggeredRefresh) {
          _reportCountdownTriggeredRefresh = true;
          getAssessmentResultDetail();
        }
      } else {
        reportDurationSec.value = next;
      }
    });
  }

  Future<void> assessmentPay(BuildContext context) async {
    if (reportDurationSec.value > 0) {
      ToastUtils.showToast(text: '上一次评测结果正在生成中，无法开始新一次的评测');
      GuideTaskController.to.stop();
      return;
    }
    
    try {
      ToastUtils.showLoading();
      AssessmentLastResponseEntity? assessmentLastResponseEntity = await PracticeQuestionsReqest.getLastAssessment();
      if (assessmentLastResponseEntity == null) return;

      // 如果assessmentId==null 说明没有评测
      int? assessmentId = assessmentLastResponseEntity.assessmentId;
      if (assessmentId != null) {
        // 说明有评测 那么调用继续评测接口
        bool? askRes = await AskDialog.showUserCancelAsk(
          context: context,
          title: "温馨提示",
          content: "您有未完成的评测，是否继续上次的评测？",
          cancel: "重新开始",
          define: "继续评测",
        );
        if (askRes == null) return; // 点击关闭按钮
        if (!askRes) {
          // 点击取消
          assessmentId = null;
        }
      }

      if (assessmentId == null) { // 没有评测
        TagRoutes.toNamed(Routes.USER_EVALUATION, arguments: {'pageType': 0});
        return;
      }

      TagRoutes.offAndToNamed(
        Routes.PRACTICE_QUESTIONS_EVAL,
        arguments: {
          "assessmentId": assessmentId,
          "pageType": 0,
        },
      );

    } finally{
      ToastUtils.hideLoading();
    }

    GuideTaskController.to.continueGuide(AppRoutesCode.userEvaluationLevelResult, GuideWidgetIds.userEvaluationLevelTestButton);
  }

  Future<void> getAssessmentHistory() async {
    final resp = await PracticeQuestionsReqest.getAssessmentHistory(0, 3);
    if (resp == null) return;
    assessmentHistory.value = resp.datas;
  }

  /// 组装计划数据
  void setPlanData(){
    planList.clear();
    List<PlanEntityPlanPathCourses?> planPathCourses = aiResultDetail.value?.base.planPathCourses??[];
    for(PlanEntityPlanPathCourses? v in planPathCourses){
      if(v?.specialty == null || v?.courseId == null) continue;
      List<StudyPlanCardStepModel?> steps = v?.steps??[];

      StudyCourseStatusEnum courseStatus = getCourseStatus(v);

      StudyPlanCardModel cardModel = StudyPlanCardModel(
        courseId: v!.courseId!,
        assessmentId: aiResultDetail.value?.base.assessmentId,
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


  Future<void> selectLevel(BuildContext context) async {
    SelectUserLanguageLevelDialog.show(
      context: context,
    );
  }
  

  /// 重新评测
  Future<void> reEvaluation(BuildContext context) async {
    if (reportDurationSec.value > 0) {
      ToastUtils.showToast(text: '上一次评测结果正在生成中，无法开始新一次的评测');
      GuideTaskController.to.stop();
      return;
    }
    await TagRoutes.toNamed(Routes.USER_EVALUATION, arguments: {'pageType': 0});

    GuideTaskController.to.continueGuide(AppRoutesCode.userEvaluationLevelResult, GuideWidgetIds.userEvaluationLevelTestButton);
  }

  /// 弹出分享弹窗
  Future<void> showShareDialog(BuildContext context) async {
    final int prevPageIndex = studyPlanCardController.currentPage;
    try {
      ToastUtils.showLoading();
      if (studyPlanCardController.currentPage != 1) {
        studyPlanCardController.jumpToPage(1);
        await WidgetsBinding.instance.endOfFrame;
        await Future<void>.delayed(const Duration(milliseconds: 16));
        shareImage = null;
      }

      if (shareImage == null) {
        RenderRepaintBoundary? boundary = sharePageKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
        if (boundary == null) return;
        ui.Image image = await boundary.toImage(pixelRatio: 2.0); // 像素比率，值越大图片越清晰
        ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        shareImage = byteData?.buffer.asUint8List();
        if (shareImage == null) return;
      }

      await UserEvaluationLevelShareDialog.show(
        context: context,
        imageBytes: shareImage!,
      );
    } catch (e) {
      print('Error capturing widget: $e');
    } finally {
      if (prevPageIndex != 1) {
        studyPlanCardController.jumpToPage(prevPageIndex);
      }
      ToastUtils.hideLoading();
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    _reportTimer?.cancel();
    _reportTimer = null;
    _assessmentPlanCompletedSubscription?.cancel();
    super.onClose();
  }
}
