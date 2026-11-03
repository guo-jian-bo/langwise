
import 'package:auto_size_text/auto_size_text.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/tag_routes.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/public_controller/config_controller.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../app/modules/home/controllers/home_controller.dart';
import '../../../app/modules/mission_control_center/controllers/mission_control_center_controller.dart';
import '../../../app/routes/routes.dart';
import '../../../utils/utils.dart';
import '../../enum/enum.dart';
import '../../https/https.dart';
import '../../values/values.dart';
import '../guide_engine/guide_engine.dart';
import '../widgets.dart';
import 'study_plan_card_swiper_widget.dart';
import 'study_plan_pageview_widget.dart';
import 'study_plan_widget.dart';

class StudyPlanCardWidgetIds{
  /// 页面code
  String? pageCode;

  /// 添加课程按钮
  String? studyPlanAddCourseButton;

  /// 开始计划按钮
  String? studyPlanStartPlanButton;

  /// 暂停计划按钮
  String? studyPlanPausePlanButton;

  /// 恢复计划按钮
  String? studyPlanResumePlanButton;

  /// 编辑计划按钮
  String? studyPlanEditPlanButton;

  /// 提前学习按钮
  String? studyPlanAdvanceStudyButton;

  /// 添加教材按钮
  String? studyPlanAddTextbookButton;

  StudyPlanCardWidgetIds({
    this.pageCode,
    this.studyPlanAddCourseButton,
    this.studyPlanStartPlanButton,
    this.studyPlanPausePlanButton,
    this.studyPlanResumePlanButton,
    this.studyPlanEditPlanButton,
    this.studyPlanAdvanceStudyButton,
    this.studyPlanAddTextbookButton,
  });
}

class StudyPlanCardController{
  _StudyPlanCardWidgetState? _state;

  /// 当前下标
  int get currentPage => _state?.pageCurrentPage?? 0;

  /// 计划对应的下标
  Map<int, int> get planCardIndexMap => _state?.planCardIndexMap??{};

  /// 改变计划下标
  void jumpToPage(int index){
    _state?.jumpToPage(index);
  }

  void animateToPage(int index){
    _state?.animateToPage(index);
  }
}

class StudyPlanCardWidget extends StatefulWidget {
  final int initPlanIndex;
  final List<StudyPlanCardModel> planList;
  /// 刷新回调
  final Future<void> Function()? onRefresh;
  /// 组件ID
  final StudyPlanCardWidgetIds? widgetIds;
  /// 蒙层的颜色
  final Color maskBgColor;
  /// 控制器
  final StudyPlanCardController? controller;

  /// 是否显示取消按钮 
  final bool isShowCancelButton;
  /// 完成执行后是否返回上级页面
  final bool isReturnToParent;

  /// 是否显示自动解锁按钮
  final bool isShowUnlockButton;

  /// 是否显示添加教材按钮
  final bool isShowAddTextbookButton;

  /// 是否显示课程计划状态
  final bool isShowCourseStatus;

  /// 是否优先展示计划的可执行卡片
  final bool isShowFirstRunningCard;
  
  const StudyPlanCardWidget({
    super.key, 
    this.initPlanIndex = 0, 
    required this.planList, 
    this.onRefresh, 
    this.widgetIds,
    this.maskBgColor = AppTheme.cBlackAlpha50,
    this.controller,
    this.isShowCancelButton = false,
    this.isReturnToParent = false,
    this.isShowUnlockButton = true,
    this.isShowAddTextbookButton = true,
    this.isShowCourseStatus = true,
    this.isShowFirstRunningCard = false,
  });

  @override
  State<StudyPlanCardWidget> createState() => _StudyPlanCardWidgetState();
}

class _StudyPlanCardWidgetState extends State<StudyPlanCardWidget> {
  final StudyPlanPageviewController _controller = StudyPlanPageviewController();

  /// 当前计划下标
  int pageCurrentPage = 0;

  /// 计划列表对应的卡片下标
  Map<int, int> planCardIndexMap = {};

  @override
  void initState() {
    super.initState();
    widget.controller?._state = this;
    for(int i = 0; i < widget.planList.length; i++){
      planCardIndexMap[i] = 0;
    }
    initRunningRunningCard();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.animateToWidget(widget.initPlanIndex);
    });
  }

  /// 查找当前正在执行的计划卡片
  void initRunningRunningCard(){
    if(!widget.isShowFirstRunningCard) return;
    // 查找第一个正在执行的计划卡片
    for(int i = 0; i < widget.planList.length; i++){
      List<StudyPlanCardStepModel?> steps = widget.planList[i].steps;
      if(steps.isEmpty) continue;
      int findRuning = steps.indexWhere((element) => element?.statusEnum == StudyPlanStatusEnum.RUNNING);
      if(findRuning == -1) continue;
      planCardIndexMap[i] = findRuning;
    }
  }


  /// 改变计划下标
  void jumpToPage(int index){
    _controller.jumpToPage(index);
  }

  /// 改变计划下标
  void animateToPage(int index){
    _controller.animateToWidget(index);
  }

  /// 去编辑计划
  Future<void> _goEditPlan(StudyPlanCardModel plan, StudyPlanCardStepModel? step) async{
    bool isPwdRight = await ParentPasswordialog.show(context: context);
    if (!isPwdRight) return GuideTaskController.to.stop();

    int? phaseIndex = planCardIndexMap[pageCurrentPage];
    if(phaseIndex == null) return GuideTaskController.to.stop();
    // 判断phaseIndex是否是已完成的计划step
    if(step?.statusEnum == StudyPlanStatusEnum.EXECUTED){
      // 已完成的phaseIndex设置为正在执行的计划卡片的phaseIndex
      List<StudyPlanCardStepModel?> steps = widget.planList[pageCurrentPage].steps;
      for(int i = 0; i < steps.length; i++){
        if(steps[i]?.statusEnum == StudyPlanStatusEnum.RUNNING){
          phaseIndex = i;
          break;
        }
      }
    }

    dynamic result = await TagRoutes.toNamed(
      Routes.PLAN_DETAILS, 
      arguments: {
        "courseId": step?.courseId,
        "courseName": plan.courseName,
        "specialty": plan.specialty,
        "phaseIndex": phaseIndex,
        "assessmentId": plan.assessmentId,
        "pageType": 0,
      },
    );
    if(result != true) return GuideTaskController.to.stop();
    if(widget.widgetIds?.pageCode != null && widget.widgetIds?.studyPlanEditPlanButton != null){
      GuideTaskController.to.continueGuide(widget.widgetIds!.pageCode!, widget.widgetIds!.studyPlanEditPlanButton!);
    }
  }

  /// 添加自定义教材
  Future<void> addCustomBook(StudyPlanCardModel plan, StudyPlanCardStepModel? step) async{
    if (step?.courseId == null) return GuideTaskController.to.stop();
    bool isPwdRight = await ParentPasswordialog.show(context: context);
    if (!isPwdRight) return GuideTaskController.to.stop();

    await TagRoutes.toNamed(
      Routes.CUSTOM_COURSE,
      arguments: {
        'courseId': step?.courseId,
        'levelId': step?.levelId,
        'moduleId': step?.moduleId,
        'fromType': 4,
        'levelName': step?.levelName,
      },
    );
    widget.onRefresh?.call();
    if(widget.widgetIds?.pageCode != null && widget.widgetIds?.studyPlanAddTextbookButton != null){
      GuideTaskController.to.continueGuide(widget.widgetIds!.pageCode!, widget.widgetIds!.studyPlanAddTextbookButton!);
    }
  }

  /// 暂停恢复计划
  Future<void> _pauseResumePlan(StudyPlanCardModel plan, StudyPlanCardStepModel? step, String? widgetId) async{
    if (step?.courseId == null) return GuideTaskController.to.stop();
    Map<String, dynamic> reqData = {};
    if (plan.courseStatus == StudyCourseStatusEnum.PAUSED) {
      bool? askRes = await AskDialog.showUserAsk(
        context: context,
        title: "要恢复新内容的学习吗？",
        content: "恢复后，会更新今日任务，系统将恢复为您安排新任务学习，已学知识点的复习任务也会正常进行。您可以随时暂停新内容的学习。",
        define: "确认恢复",
        defineColor: AppTheme.cFeedbackSuccessText.color,
      );
      if (!askRes) return GuideTaskController.to.stop();
      reqData['pause'] = false;
    }else{
      // 是否全部暂停
      bool isAllPause = true;
      
      List<String> otherPlanNames = [];
      for(var item in widget.planList){
        if(item.steps.isEmpty) continue;
        if(step?.courseId != item.steps.first?.courseId){
          otherPlanNames.add(item.courseName ?? "");
          if (item.courseStatus == StudyCourseStatusEnum.PAUSED) {
            isAllPause = false;
          }
        }
      }

      int dailyStudyDuration = (step?.dailyStudyDuration ?? 0) ~/ 60;

      String planInfoText = "";
      if (isAllPause) {
        planInfoText = "并把本计划的$dailyStudyDuration分钟全部分配给复习。";
      } else {
        planInfoText = "并把本计划的$dailyStudyDuration分钟智能分配给复习和${otherPlanNames.join("、")}计划的新学。";
      }
      TodayPlanPauseDialogResult? res = await TodayPlanPauseDialog.show(context: context, planInfoText: planInfoText);
      if (res == null) return GuideTaskController.to.stop();
      reqData['pause'] = true;
      if (res.recoverDate != null) {
        reqData["resumeDate"] = DateFormatUtil.formatStr(res.recoverDate!);
      }

    }
    if(Get.context == null) return GuideTaskController.to.stop();
    bool isPwdRight = await ParentPasswordialog.show(context: Get.context!);
    if (!isPwdRight) return GuideTaskController.to.stop();

    try {
      ToastUtils.showLoading();
      bool reqRes = await StudyPlanRequest.pauseOrResumeStudyPlan(step!.courseId!, reqData);
      if (!reqRes) return GuideTaskController.to.stop();
      ToastUtils.showToast(text: "操作成功", type: ToastType.success);
      await widget.onRefresh?.call();
      if( widget.widgetIds?.pageCode != null && widgetId != null){
        GuideTaskController.to.continueGuide(widget.widgetIds!.pageCode!, widgetId);
      }
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().initHomeCardList();
      }
      final missionController = TagRoutes.findLast<MissionControlCenterController>(Routes.MISSION_CONTROL_CENTER);
      if (missionController != null) {
        missionController.getTaskMission(showLoading: false);
      }
    } finally {
      ToastUtils.hideLoading();
    }
  }

  /// 开始学习计划
  Future<void> _startPlan(StudyPlanCardModel plan, StudyPlanCardStepModel? step) async{
    if (step?.courseId == null) return GuideTaskController.to.stop();

    bool isPwdRight = await ParentPasswordialog.show(context: context);
    if (!isPwdRight) return GuideTaskController.to.stop();

    if(plan.specialty == SpecialtyEnum.EN_TEXTBOOK){
      if((step?.moduleId == null || step?.moduleId == 0) && step?.statusEnum != StudyPlanStatusEnum.RUNNING){
        dynamic res = await TagRoutes.toNamed(
          Routes.CUSTOM_COURSE,
          arguments: {
            'courseId': step?.courseId,
            'levelId': step?.levelId,
            'cefr': step?.name,
            'moduleId': step?.moduleId,
            'fromType': 4,
            'gradeIndex': step?.tierRange?.min,
            'levelName': step?.levelName,
          },
        );
        if(res == null) return GuideTaskController.to.stop();
      }
    }

    dynamic result = await TagRoutes.toNamed(
      Routes.PLAN_DETAILS, 
      arguments: {
        "courseId": step?.courseId,
        "courseName": plan.courseName,
        "tier": step?.tierRange?.min,
        "semester": step?.semester,
        "moduleId": step?.moduleId,
        "specialty": plan.specialty,
        "phaseIndex": planCardIndexMap[pageCurrentPage],
        "assessmentId": plan.assessmentId,
        "pageType": 1,
      },
    );
    if(result != true) return GuideTaskController.to.stop();
    if(widget.widgetIds?.pageCode != null && widget.widgetIds?.studyPlanStartPlanButton != null){
      GuideTaskController.to.continueGuide(widget.widgetIds!.pageCode!, widget.widgetIds!.studyPlanStartPlanButton!);
    }
    if(widget.isReturnToParent){
      Get.back(result: true);
    }
  }

  /// 添加课程到计划
  Future<void> _addCourseToPlan(StudyPlanCardModel plan) async{
    bool isPwdRight = await ParentPasswordialog.show(context: context);
    if (!isPwdRight) return GuideTaskController.to.stop();
    dynamic result = await TagRoutes.toNamed(
      Routes.PLAN_DETAILS, 
      arguments: {
        "courseId": plan.courseId,
        "courseName": plan.courseName,
        "specialty": plan.specialty,
        "assessmentId": plan.assessmentId,
        "pageType": 2,
      },
    );
    if(result != true) return GuideTaskController.to.stop();
    if(widget.widgetIds?.pageCode != null && widget.widgetIds?.studyPlanAddCourseButton != null){
      GuideTaskController.to.continueGuide(widget.widgetIds!.pageCode!, widget.widgetIds!.studyPlanAddCourseButton!);
    }
    
  }

  /// 提前学习计划
  Future<void> _advanceStudyPlan(StudyPlanCardModel plan, StudyPlanCardStepModel? step) async{
    bool isPwdRight = await ParentPasswordialog.show(context: context);
    if (!isPwdRight) return GuideTaskController.to.stop();
    
    if(plan.specialty == SpecialtyEnum.EN_TEXTBOOK){
      if((step?.moduleId == null || step?.moduleId == 0) && step?.statusEnum != StudyPlanStatusEnum.RUNNING){
        dynamic res = await TagRoutes.toNamed(
          Routes.CUSTOM_COURSE,
          arguments: {
            'courseId': step?.courseId,
            'levelId': step?.levelId,
            'cefr': step?.name,
            'moduleId': step?.moduleId,
            'fromType': 4,
            'gradeIndex': step?.tierRange?.min,
            'levelName': step?.levelName,
          },
        );
        if(res == null) return GuideTaskController.to.stop();
      }
    }

    dynamic result = await TagRoutes.toNamed(
      Routes.PLAN_DETAILS, 
      arguments: {
        "courseId": step?.courseId,
        "courseName": plan.courseName,
        "tier": step?.tierRange?.min,
        "semester": step?.semester,
        "moduleId": step?.moduleId,
        "specialty": plan.specialty,  
        "phaseIndex": planCardIndexMap[pageCurrentPage],
        "assessmentId": plan.assessmentId,
        "pageType": 1,
      },
    );
    if(result != true) return GuideTaskController.to.stop();
    if(widget.widgetIds?.pageCode != null && widget.widgetIds?.studyPlanAdvanceStudyButton != null){
      GuideTaskController.to.continueGuide(widget.widgetIds!.pageCode!, widget.widgetIds!.studyPlanAdvanceStudyButton!);
    }
    if(widget.isReturnToParent){
      Get.back(result: true);
    }
  }


  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final Size windowSize = MediaQuery.sizeOf(context);
        bool hasBoundedWidth = constraints.hasBoundedWidth && constraints.maxWidth.isFinite;
        final double viewportWidth = hasBoundedWidth ? constraints.maxWidth : windowSize.width;
        final double viewportHeight = 720.wMin;

        return Column(
          children: [
            StudyPlanPageviewWidget(
              controller: _controller,
              viewportWidth: viewportWidth,
              viewportHeight: viewportHeight,
              onPageChanged: (value) {
                pageCurrentPage = value;
                if (mounted) setState(() {});
              },
              children: List.generate(widget.planList.length, (index) {
                return _buildPlanItemWidget(widget.planList[index], index);
              }),
            ),
            Column(
              children: [
                _buildPlanDescWidget(),
                _buildButtonsWidget(),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildPlanItemWidget(StudyPlanCardModel plan, int pageIndex) {

    bool isDisabled = pageIndex != pageCurrentPage;
    return TapScaleWidget(
      onTap: () {
        if(!isDisabled) return;
        _controller.animateToWidget(pageIndex);
      },
      sclae: 1,
      child: IgnorePointer(
        ignoring: isDisabled,
        child: SizedBox(
          width: 440.wMin,
          child: Column(
            children: [
              StudyPlanCardsTitleWidget(
                specialty: plan.specialty,
                isShowCourseStatus: widget.isShowCourseStatus,
                stepsNotEmpty: plan.steps.isNotEmpty,
                courseStatus: plan.courseStatus,
              ),
              SizedBox(height: 10.wMin),
              Stack(
                children: [
                  StudyPlanCardSwiperWidget(
                    initIndex: planCardIndexMap[pageIndex] ?? 0,
                    layerOffsetStep: 90.wMin,
                    maxScale: 1,
                    minScale: plan.steps.length > 2 ? 0.94 : 0.97,
                    maxOpacity: 1,
                    minOpacity: plan.steps.length > 2 ? 0.4 : 0.6,
                    swipeThreshold: 24.wMin,
                    customEmptyCard: StudyPlanCardItemAddWidget(
                      plan: plan,
                      onTap: () {
                        _addCourseToPlan(plan);
                      },
                    ),
                    onIndexChanged: (index) {
                      planCardIndexMap[pageIndex] = index;
                      if (mounted) setState(() {});
                    },
                    cards: List.generate(plan.steps.length, (index) {
                      return StudyPlanCardItemWidget(
                        step: plan.steps[index], 
                        cardIndex: index,
                        stepCount: plan.steps.length,
                        specialty: plan.specialty,
                        studyPlan: plan.studyPlan,
                      );
                    }),
                  ),
                  Visibility(
                    visible: plan.courseStatus != StudyCourseStatusEnum.RUNNING && plan.courseStatus != StudyCourseStatusEnum.PENDING,
                    child: Positioned.fill(child: _buildMaskWidget(plan)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 蒙层
  Widget _buildMaskWidget(StudyPlanCardModel plan){
    
    String statusText = "PAUSED";
    Color statusColor = plan.courseColor.color1;
    String title = "${plan.courseName ?? ""}已暂停";
    String subTitle = "";
    String description = "";

    if(plan.courseStatus == StudyCourseStatusEnum.PAUSED){
      statusText = "PAUSED";
      statusColor = plan.courseColor.color1;
      title = "${plan.courseName ?? ""}已暂停";
      if((plan.resumeDate??"").isNotEmpty){
        title += "\n恢复时间：${plan.resumeDate}";
      }
      subTitle = "新内容暂停，复习继续";
      description = "每日时长不变，时间转给复习和其他课程恢复后从当前进度继续";
    }else if(plan.courseStatus == StudyCourseStatusEnum.EXECUTED){
      statusText = "COMPLETED";
      statusColor = AppTheme.cSurfaceSuccess.color;
      title = "${plan.courseName ?? ""}已学完";
    }else if(plan.courseStatus == StudyCourseStatusEnum.UNLOCKED){
      statusText = "LOCKED";
      statusColor = AppTheme.cTextPrimary.color.withValues(alpha: 0.6);
      
      if(plan.steps.isNotEmpty){
        String? triggerType = plan.steps.first?.trigger?.type;
        String? courseName = SpecialtyEnum.getCourseName("en_${triggerType ?? ""}".toUpperCase());
        if(courseName != null){
          title = "$courseName 达到 Level ${plan.steps.first?.trigger?.tier ?? "0"}";
          subTitle = "自动解锁";
        }
      }
    }

    return IgnorePointer(
      ignoring: true,
      child: Container(
        width: double.infinity,
        height: 438.wMin,
        padding: EdgeInsets.symmetric(horizontal: 70.wMin),
        decoration: BoxDecoration(
          color: widget.maskBgColor,
          borderRadius: BorderRadius.circular(16.wMin),
        ),
        child: Column(
          children: [
            SizedBox(height: 100.wMin),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.wMin, vertical: 6.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: statusColor.withValues(alpha: 0.12),
                border: Border.all(
                  color: statusColor.withValues(alpha: 0.2),
                  width: 0.8.wMin,
                ),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  fontSize: 14.wMin,
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 16.wMin),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              subTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.wMin,
                color: AppTheme.cTextSecondary.color,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 16.wMin),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.wMin,
                color: AppTheme.cTextTertiary.color,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanDescWidget(){
    if(widget.planList.isEmpty) return Container();
    StudyPlanCardModel plan = widget.planList[pageCurrentPage];

    return Container(
      height: 70.wMin,
      // color: Colors.yellow.withValues(alpha: 0.2),
      color: Colors.transparent,
      child: Column(
        children: [
          Visibility(
            visible: plan.currentUnitInfoText != null,
            child: Text(
              plan.currentUnitInfoText??"",
              style: TextStyle(
                fontSize: 18.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Visibility(
            visible: plan.nextUnitInfoText != null,
            child: Text(
              plan.nextUnitInfoText??"",
              style: TextStyle(
                fontSize: 18.wMin,
                color: AppTheme.cTextPrimary.color,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonsWidget(){
    if(widget.planList.isEmpty) return Container();
    int cardIndex = planCardIndexMap[pageCurrentPage] ?? 0;
    StudyPlanCardModel plan = widget.planList[pageCurrentPage];
    if(plan.steps.isEmpty){
      return _buildButtonItemWidget(
        text: "添加课程",
        width: 440.wMin,
        fontColor: plan.courseColor.color1,
        color: plan.courseColor.color1.withValues(alpha: 0.2),
        borderColor: plan.courseColor.color1.withValues(alpha: 0.12),
        widgetId: widget.widgetIds?.studyPlanAddCourseButton,
        onTap: () async{
          _addCourseToPlan(plan);
        },
      );
    }

    StudyPlanCardStepModel? step = plan.steps[cardIndex];
    if(step == null) return Container();

    if(plan.courseStatus == StudyCourseStatusEnum.UNLOCKED){
      if(plan.specialty == SpecialtyEnum.EN_TEXTBOOK){
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Visibility(
              visible: widget.isShowCancelButton,
              child: Container(
                margin: EdgeInsets.only(right: 12.wMin),
                child: _buildButtonItemWidget(
                  text: "取消",
                  width: !widget.isShowCancelButton ? 440.wMin : null,
                  fontColor: plan.courseColor.color1,
                  color: AppTheme.cSurfaceSecondary.color,
                  borderColor: AppTheme.cBorderDefault.color,
                  onTap: () async{
                    Get.back();
                  },
                ),
              ),
            ),
            _buildButtonItemWidget(
              text: "提前学习",
              fontColor: plan.courseColor.color1,
              color: plan.courseColor.color1.withValues(alpha: 0.2),
              borderColor: plan.courseColor.color1.withValues(alpha: 0.12),
              widgetId: widget.widgetIds?.studyPlanAdvanceStudyButton,
              onTap: () async{
                _advanceStudyPlan(plan, step);
              },
            ),
            Visibility(
              visible: widget.isShowAddTextbookButton,
              child: Container(
                margin: EdgeInsets.only(left: 12.wMin),
                child: _buildButtonItemWidget(
                  text: "添加教材",
                  fontColor: plan.courseColor.color1,
                  color: plan.courseColor.color1.withValues(alpha: 0.2),
                  borderColor: plan.courseColor.color1.withValues(alpha: 0.12),
                  widgetId: widget.widgetIds?.studyPlanAddTextbookButton,
                  onTap: () async{
                    addCustomBook(plan, step);
                  },
                ),
              ),
            ),
            Visibility(
              visible: widget.isShowUnlockButton,
              child: Container(
                margin: EdgeInsets.only(left: 12.wMin),
                child: MouseRegion(
                  cursor: SystemMouseCursors.disappearing,
                  child: _buildButtonItemWidget(
                    text: "等待自动解锁",
                    fontColor: AppTheme.cTextDisabled.color,
                    color: AppTheme.cSurfaceSecondary.color,
                    borderColor: Colors.transparent,
                  ),
                ),
              ),
            ),
          ],
        );
      }
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Visibility(
            visible: widget.isShowCancelButton,
            child: Container(
              margin: EdgeInsets.only(right: 12.wMin),
              child: _buildButtonItemWidget(
                text: "取消",
                width: !widget.isShowCancelButton ? 440.wMin : null,
                fontColor: plan.courseColor.color1,
                color: AppTheme.cSurfaceSecondary.color,
                borderColor: AppTheme.cBorderDefault.color,
                onTap: () async{
                  Get.back();
                },
              ),
            ),
          ),
          _buildButtonItemWidget(
            text: "提前学习",
            fontColor: plan.courseColor.color1,
            color: plan.courseColor.color1.withValues(alpha: 0.2),
            borderColor: plan.courseColor.color1.withValues(alpha: 0.12),
            widgetId: widget.widgetIds?.studyPlanAdvanceStudyButton,
            onTap: () async{
              _advanceStudyPlan(plan, step);
            },
          ),
          Visibility(
            visible: widget.isShowUnlockButton,
            child: Container(
              margin: EdgeInsets.only(left: 12.wMin),
              child: MouseRegion(
                cursor: SystemMouseCursors.disappearing,
                child: _buildButtonItemWidget(
                  text: "等待自动解锁",
                  fontColor: AppTheme.cTextDisabled.color,
                  color: AppTheme.cSurfaceSecondary.color,
                  borderColor: Colors.transparent,
                ),
              ),
            ),
          ),
        ],
      );
      
    }

    if(step.statusEnum == StudyPlanStatusEnum.RUNNING || plan.courseStatus == StudyCourseStatusEnum.PAUSED){

      String? widgetId = plan.courseStatus == StudyCourseStatusEnum.PAUSED ? widget.widgetIds?.studyPlanResumePlanButton : widget.widgetIds?.studyPlanPausePlanButton;
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Visibility(
            visible: widget.isShowCancelButton,
            child: Container(
              margin: EdgeInsets.only(right: 12.wMin),
              child: _buildButtonItemWidget(
                text: "取消",
                width: !widget.isShowCancelButton ? 440.wMin : null,
                fontColor: plan.courseColor.color1,
                color: AppTheme.cSurfaceSecondary.color,
                borderColor: AppTheme.cBorderDefault.color,
                onTap: () async{
                  Get.back();
                },
              ),
            ),
          ),
          _buildButtonItemWidget(
            text: plan.courseStatus == StudyCourseStatusEnum.PAUSED ? "恢复计划" : "暂停计划",
            fontColor: plan.courseColor.color1,
            color: AppTheme.cSurfaceSecondary.color,
            borderColor: AppTheme.cBorderDefault.color,
            widgetId: widgetId,
            onTap: () async{
              await _pauseResumePlan(plan, step, widgetId);
            },
          ),
          SizedBox(width: 12.wMin),
          _buildButtonItemWidget(
            text: "编辑计划",
            fontColor: plan.courseColor.color1,
            color: plan.courseColor.color1.withValues(alpha: 0.2),
            borderColor: plan.courseColor.color1.withValues(alpha: 0.12),
            widgetId: widget.widgetIds?.studyPlanEditPlanButton,
            onTap: () async{
              _goEditPlan(plan, step);
            },
          ),

        ],
      );
    } 

    if(step.statusEnum == StudyPlanStatusEnum.READY){
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Visibility(
            visible: widget.isShowCancelButton,
            child: Container(
              margin: EdgeInsets.only(right: 12.wMin),
              child: _buildButtonItemWidget(
                text: "取消",
                width: !widget.isShowCancelButton ? 440.wMin : null,
                fontColor: plan.courseColor.color1,
                color: AppTheme.cSurfaceSecondary.color,
                borderColor: AppTheme.cBorderDefault.color,
                onTap: () async{
                  Get.back();
                },
              ),
            ),
          ),
          _buildButtonItemWidget(
            text: "开始计划",
            width: !widget.isShowCancelButton ? 440.wMin : null,
            fontColor: plan.courseColor.color1,
            color: plan.courseColor.color1.withValues(alpha: 0.2),
            borderColor: plan.courseColor.color1.withValues(alpha: 0.12),
            widgetId: widget.widgetIds?.studyPlanStartPlanButton,
            onTap: () async{
              _startPlan(plan, step);
            },
          ),
        ],
      );
    } 

    if(step.statusEnum == StudyPlanStatusEnum.PENDING){
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Visibility(
            visible: widget.isShowCancelButton,
            child: Container(
              margin: EdgeInsets.only(right: 12.wMin),
              child: _buildButtonItemWidget(
                text: "取消",
                width: !widget.isShowCancelButton ? 440.wMin : null,
                fontColor: plan.courseColor.color1,
                color: AppTheme.cSurfaceSecondary.color,
                borderColor: AppTheme.cBorderDefault.color,
                onTap: () async{
                  Get.back();
                },
              ),
            ),
          ),
          _buildButtonItemWidget(
            text: "提前学习",
            width: !widget.isShowCancelButton ? 440.wMin : null,
            fontColor: plan.courseColor.color1,
            color: plan.courseColor.color1.withValues(alpha: 0.2),
            borderColor: plan.courseColor.color1.withValues(alpha: 0.12),
            widgetId: widget.widgetIds?.studyPlanAdvanceStudyButton,
            onTap: () async{
              _advanceStudyPlan(plan, step);
            },
          ),
        ],
      );
    } 
    
    if(step.statusEnum == StudyPlanStatusEnum.EXECUTED){
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Visibility(
            visible: widget.isShowCancelButton,
            child: Container(
              margin: EdgeInsets.only(right: 12.wMin),
              child: _buildButtonItemWidget(
                text: "取消",
                width: !widget.isShowCancelButton ? 440.wMin : null,
                fontColor: plan.courseColor.color1,
                color: AppTheme.cSurfaceSecondary.color,
                borderColor: AppTheme.cBorderDefault.color,
                onTap: () async{
                  Get.back();
                },
              ),
            ),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.disappearing,
            child: _buildButtonItemWidget(
              text: "计划完成",
              fontColor: AppTheme.cTextDisabled.color,
              color: AppTheme.cSurfaceSecondary.color,
              borderColor: Colors.transparent,
            ),
          ),
          SizedBox(width: 12.wMin),
          _buildButtonItemWidget(
            text: "编辑计划",
            fontColor: plan.courseColor.color1,
            color: plan.courseColor.color1.withValues(alpha: 0.2),
            borderColor: plan.courseColor.color1.withValues(alpha: 0.12),
            widgetId: widget.widgetIds?.studyPlanEditPlanButton,
            onTap: () async{
              _goEditPlan(plan, step);
            },
          ),
        ],
      );
    }

    return Container();
  }


  Widget _buildButtonItemWidget({
    required String text,
    required Color color,
    required Color fontColor,
    required Color borderColor,
    Future<void> Function()? onTap,
    double? width,
    String? widgetId,
  }){
    if(widgetId != null){
      return GuideStepWidget(
        id: widgetId,
        sclae: 1.02,
        onTap: onTap,
        child: ButtonWidget(
          text: text,
          height: 56.wMin,
          width: width ?? 314.wMin,
          borderRadius: 8.wMin,
          color: color,
          duration: Duration.zero,
          border: Border.all(
            color: borderColor,
            width: 0.8.wMin,
          ),
          fontSize: 24.wMin,
          fontColor: fontColor,
        ),
      );
    }
    return ButtonWidget(
      text: text,
      height: 56.wMin,
      width: width ?? 314.wMin,
      borderRadius: 8.wMin,
      color: color,
      duration: Duration.zero,
      border: Border.all(
        color: borderColor,
        width: 0.8.wMin,
      ),
      fontSize: 24.wMin,
      fontColor: fontColor,
      sclae: 1.02,
      onTap: onTap,
    );
  }

}


class StudyPlanCardItemWidget extends StatelessWidget {
  final StudyPlanCardStepModel? step;
  final String specialty;
  final int stepCount;
  final int cardIndex;
  final PlanEntityPlanPathCoursesStudyPlan? studyPlan;
  
  const StudyPlanCardItemWidget({
    super.key, 
    required this.step, 
    required this.stepCount, 
    required this.cardIndex,
    required this.specialty,
    this.studyPlan,
  });



  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: AppTheme.cSurfacePrimary.color,
      ),
      child: Container(
        width: 440.wMin,
        height: 438.wMin,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.wMin),
          border: Border.all(
            color: AppTheme.cBorderSubtle.color,
            width: 1.wMin,
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: getBgColors(),
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 16.wMin),
            _buildTitleWidget(),
            SizedBox(height: 10.wMin),
            Expanded(child: _buildListWidget()),
            _buildBottomWidget(),
          ],
        ),
      ),
    );
  }

  List<Color> getBgColors(){
    SpecialtyColor courseColor = SpecialtyEnum.getCourseColor(specialty);

    if(step?.statusEnum == StudyPlanStatusEnum.READY){
      return [
        courseColor.color1.withValues(alpha: 0.12),
        courseColor.color2.withValues(alpha: 0.12),
      ];
    }else if(step?.statusEnum == StudyPlanStatusEnum.PENDING){
      return [
        courseColor.color1.withValues(alpha: 0.12),
        courseColor.color2.withValues(alpha: 0.12),
      ];
    }else if(step?.statusEnum == StudyPlanStatusEnum.RUNNING){
      return [
        courseColor.color1,
        courseColor.color2,
      ];
    }else if(step?.statusEnum == StudyPlanStatusEnum.EXECUTED){
      return [
        AppTheme.cSurfacePrimary.color,
        AppTheme.cSurfacePrimary.color,
      ];
    }
    return [
      AppTheme.cSurfacePrimary.color,
      AppTheme.cSurfacePrimary.color,
    ];
  }

  Color getTextColor(){
    Color textColor = Colors.white; // 进行中状态颜色
    if(step?.statusEnum == StudyPlanStatusEnum.EXECUTED){
      textColor = AppTheme.cTextTertiary.color; // 已完成状态颜色
    } else if(step?.statusEnum == StudyPlanStatusEnum.READY){
      textColor = AppTheme.cTextPrimary.color; // 等待中状态颜色
    } else if(step?.statusEnum == StudyPlanStatusEnum.PENDING){
      textColor = AppTheme.cTextTertiary.color; // 等待中状态颜色
    }
    return textColor;
  }

  /// 标题
  Widget _buildTitleWidget(){
    String title = "进行中";
    Color textColor = getTextColor();
    if(step?.statusEnum == StudyPlanStatusEnum.EXECUTED){
      title = "已完成";
    } else if(step?.statusEnum == StudyPlanStatusEnum.READY){
      title = "可执行";
    } else if(step?.statusEnum == StudyPlanStatusEnum.PENDING){
      title = "等待中";
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.wMin),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20.wMin,
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(), 
          Text(
            "${cardIndex + 1} / $stepCount",
            style: TextStyle(
              fontSize: 20.wMin,
              color: textColor,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  /// 内容表表格
  Widget _buildListWidget(){
    if(specialty == SpecialtyEnum.EN_PHONICS){
      List<StudyPlanCardStepModelModuleInfoList?> moduleInfoList = step?.moduleInfoList??[];

      if(step?.statusEnum == StudyPlanStatusEnum.RUNNING && studyPlan != null){
        return _phonicsBodyWidget();
      }

      return GridView.builder(
        itemCount: moduleInfoList.length,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.wMin),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 8.wMin,
          crossAxisSpacing: 8.wMin,
        ),
        itemBuilder: (context, index) {
          return _buildListItemPhonicsWidget(moduleInfoList[index]);
        },
      );
    }

    List<LessonTypeEntityList?> directionList = step?.directionList??[];
    if(step?.statusEnum == StudyPlanStatusEnum.RUNNING){
      if((studyPlan?.directionList??[]).isNotEmpty){
        directionList = studyPlan?.directionList??[];
      }
    }

    return GridView.builder(
      itemCount: directionList.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.wMin),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8.wMin,
        crossAxisSpacing: 8.wMin,
        mainAxisExtent: 52.wMin,
      ),
      itemBuilder: (context, index) {
        return _buildListItemWidget(directionList[index]);
      },
    );
  }

  Widget _buildListItemPhonicsWidget(StudyPlanCardStepModelModuleInfoList? moduleInfo){
    Color textColor = getTextColor();
    SpecialtyColor courseColor = SpecialtyEnum.getCourseColor(specialty);
    bool isReady = step?.statusEnum == StudyPlanStatusEnum.READY;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: isReady ? courseColor.color1.withValues(alpha: 0.2) : AppTheme.cSurfaceLayerElevated.color,
        border: Border.all(
          color: AppTheme.cBorderSubtle.color,
          width: 1.wMin,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AutoSizeText(
            "/ ${moduleInfo?.topic??""} /",
            maxLines: 1,
            minFontSize: 6,
            style: TextStyle(
              fontSize: 28.wMin,
              color: textColor,
              fontWeight: FontWeight.w600,
              fontFamily: "LXGWWenKaiGBScreen",
            ),
          ),
          Text(
            moduleInfo?.contentInfo?.content??"",
            style: TextStyle(
              fontSize: 22.wMin,
              color: textColor,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListItemWidget(LessonTypeEntityList? direction){

    ConfigController configController = Get.find<ConfigController>();
    String lang = configController.userSetting.value.localLang;

    Color textColor = getTextColor();
    SpecialtyColor courseColor = SpecialtyEnum.getCourseColor(specialty);
    bool isReady = step?.statusEnum == StudyPlanStatusEnum.READY;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        color: isReady ? courseColor.color1.withValues(alpha: 0.2) : AppTheme.cSurfaceLayerElevated.color,
        border: Border.all(
          color: AppTheme.cBorderSubtle.color,
          width: 0.5.wMin,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 28.wMin,
            height: 28.wMin,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3.5.wMin),
              color: AppTheme.cSurfaceLayerElevated.color,
            ),
            child: CachedImageWidget(
              direction?.iconUrl??"",
              errorWidget: Container(),
              placeholder: Container(),
            ),
          ),
          SizedBox(width: 8.wMin),
          Text(
            direction?.title?.firstWhereOrNull((element) => element?.lang == lang)?.text ?? "",
            style: TextStyle(
              fontSize: 18.wMin,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Opacity(
            opacity: direction?.exclude == true ? 0.1 : 1,
            child: Container(
              width: 10.wMin,
              height: 10.wMin,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xff4ADE80).withValues(alpha: direction?.exclude == true ? 0 : 1),
                border: Border.all(
                  color: Colors.white,
                  width: 1.wMin,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _phonicsBodyWidget() {
    List<PronunciationsEntity?> pronunciations = studyPlan?.moduleContentInfo?.pronunciations ?? [];

    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.wMin),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            CachedImageWidget(
              studyPlan?.moduleContentInfo?.imageUrl ?? "",
              placeholder: buildEmptyWidget(),
              errorWidget: buildEmptyWidget(),
            ),
            Container(
              width: double.infinity,
              color: AppTheme.cBlackAlpha50.color,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PronunciationsPlayIpaTextWidget(
                    ipa: studyPlan?.startUnitInfo?.moduleTopic,
                    pronunciations: pronunciations,
                    national: LanguageServiceCode.US,
                    style: TextStyle(
                      fontSize: 80.wMin,
                      color: AppTheme.cInverseTextLight.color,
                      fontWeight: FontWeight.w700,
                      fontFamily: "AndikaRegular",
                    ),
                  ),
                  PronunciationsColorWidget(
                    content: studyPlan?.moduleContentInfo?.content,
                    ipa: studyPlan?.startUnitInfo?.moduleTopic,
                    pronunciations: pronunciations,
                    national: LanguageServiceCode.US,
                    style: TextStyle(
                      fontSize: 50.wMin,
                      color: AppTheme.cInverseTextLight.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 60.wMin),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(pronunciations.length, (index) {
                return PlayLottieIconWidget(
                  size: 60.wMin,
                  audioUrl: pronunciations[index]?.audioUrl,
                  backgroundImageUrl: pronunciations[index]?.nationalIconUrl,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomWidget(){

    Color textColor = getTextColor();

    String tierRangeText = "";
    if(step?.tierRange?.min != null){
      tierRangeText = "L${step?.tierRange?.min}";
    }
    if(step?.tierRange?.max != null && step?.tierRange?.max != step?.tierRange?.min){
      tierRangeText += " - L${step?.tierRange?.max}";
    }
    if(tierRangeText.isEmpty){
      tierRangeText = step?.description??"";
    }

    // 正在执行的计划 用studyPlan的时长
    int dailyStudyDuration = step?.dailyStudyDuration??0;
    if(studyPlan != null && step?.statusEnum == StudyPlanStatusEnum.RUNNING){
      dailyStudyDuration = studyPlan?.dailyStudyDuration??0;
    }

    return Container(
      padding: EdgeInsets.only(
        left: 16.wMin,
        right: 16.wMin,
        top: 10.wMin,
        bottom: 4.wMin,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppTheme.cBorderDefault.color,
            width: 1.wMin,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step?.name??"",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 24.wMin,
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      tierRangeText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16.wMin,
                        color: textColor.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.wMin),
              Row(
                children: [
                  Text(
                    (dailyStudyDuration / 60).toInt().toString(),
                    style: TextStyle(
                      fontSize: 48.wMin,
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "分钟",
                        style: TextStyle(
                          fontSize: 16.wMin,
                          color: textColor.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        "/天",
                        style: TextStyle(
                          fontSize: 16.wMin,
                          color: textColor.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }  




}


class StudyPlanCardsTitleWidget extends StatelessWidget {
  final String specialty;
  final bool isShowCourseStatus;
  final bool stepsNotEmpty;
  final StudyCourseStatusEnum? courseStatus;
  // 叠加在标题背景下的颜色
  final Color? titleBgColor2;
  const StudyPlanCardsTitleWidget({
    super.key, 
    required this.specialty, 
    this.isShowCourseStatus = true, 
    this.stepsNotEmpty = true,
    this.courseStatus,
    this.titleBgColor2,
  });

  @override
  Widget build(BuildContext context) {

    String? courseName = SpecialtyEnum.getCourseName(specialty);
    SpecialtyColor courseColor = SpecialtyEnum.getCourseColor(specialty);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        color: titleBgColor2,
      ),
      child: Container(
        width: 440.wMin,
        height: 76.wMin,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.wMin),
          color: AppTheme.cSurfaceLayerBase2.color,
          border: Border.all(
            color: AppTheme.cBorderSubtle.color,
            width: 1.wMin,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              courseName??"",
              style: TextStyle(
                fontSize: 28.wMin,
                color: courseColor.color1,
                fontWeight: FontWeight.w600,
              ),
            ),
            _buildPlanItemTitleStatusWidget(),
          ],
        ),
      ),
    );
  }

  /// 课程状态标签
  Widget _buildPlanItemTitleStatusWidget(){
    if(!isShowCourseStatus) return Container();

    String statusText = "未开始";
    Color statusTextColor = AppTheme.cTextPrimary.color;
    Color statusBgColor = AppTheme.cSurfaceLayerBase2.color;
    Color statusBorderColor = AppTheme.cBorderDefault.color;
    if(stepsNotEmpty){
      if(courseStatus == StudyCourseStatusEnum.RUNNING){
        statusText = "进行中";
        statusTextColor = AppTheme.cSurfaceSuccess.color;
        statusBgColor = AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.12);
        statusBorderColor = AppTheme.cSurfaceSuccess.color.withValues(alpha: 0.2);
      } else if(courseStatus == StudyCourseStatusEnum.EXECUTED){
        statusText = "已完成";
        statusTextColor = AppTheme.cSurfaceBrand.color;
        statusBgColor = AppTheme.cSurfaceBrand.color.withValues(alpha: 0.12);
        statusBorderColor = AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2);
      } else if(courseStatus == StudyCourseStatusEnum.PAUSED){
        statusText = "已暂停";
        statusTextColor = AppTheme.cTextTertiary.color;
        statusBgColor = AppTheme.cSurfaceLayerBase2.color;
        statusBorderColor = AppTheme.cBorderDefault.color;
      }
    }
    

    return Container(
      margin: EdgeInsets.only(left: 10.wMin),
      padding: EdgeInsets.symmetric(horizontal: 6.wMin, vertical: 2.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.wMin),
        color: statusBgColor,
        border: Border.all(
          color: statusBorderColor,
          width: 0.8.wMin,
        ),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: 16.wMin,
          color: statusTextColor,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}



class StudyPlanCardItemAddWidget extends StatelessWidget {
  final StudyPlanCardModel plan;
  /// 点击回调
  final void Function()? onTap;
  const StudyPlanCardItemAddWidget({super.key, required this.plan, this.onTap});

  @override
  Widget build(BuildContext context) {
    return TapScaleWidget(
      onTap: onTap,
      sclae: 1,
      child: Container(
        width: 440.wMin,
        height: 438.wMin,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.wMin),
          color: AppTheme.cSurfacePrimary.color,
        ),
        child: DottedBorder(
          borderType: BorderType.RRect,
          radius: Radius.circular(16.wMin),
          color: plan.courseColor.color1,
          strokeWidth: 1.wMin,
          dashPattern: [6.wMin, 4.wMin],
          padding: EdgeInsets.all(16.wMin),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                
                Container(
                  width: 120.wMin,
                  height: 120.wMin,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: plan.courseColor.color1.withValues(alpha: 0.12),
                  ),
                  child: SvgPicture.asset(
                    "assets/svg/public/icon_add.svg",
                    width: 40.wMin,
                    colorFilter: ColorFilter.mode(plan.courseColor.color1, BlendMode.srcIn),
                  ),
                ),
                SizedBox(height: 16.wMin),
                Text(
                  plan.courseName??"",
                  style: TextStyle(
                    fontSize: 24.wMin,
                    color: AppTheme.cTextPrimary.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 16.wMin),
                Text(
                  "这门课还没有加入当前方案",
                  style: TextStyle(
                    fontSize: 16.wMin,
                    color: AppTheme.cTextSecondary.color,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  "可以按需要把这门课加入方案",
                  style: TextStyle(
                    fontSize: 16.wMin,
                    color: plan.courseColor.color1,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 16.wMin),
                Text(
                  "点下方「添加课程」即可加入当前学习方案",
                  style: TextStyle(
                    fontSize: 14.wMin,
                    color: AppTheme.cTextTertiary.color,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}