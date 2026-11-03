
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/enum/enum.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../utils/utils.dart';
import '../controllers/study_plan_controller.dart';

class StudyPlanAiMaskWidget extends StatefulWidget {
  final StudyPlanController controller;
  final LearningSettingStepEntity stepData;
  const StudyPlanAiMaskWidget({super.key, required this.controller, required this.stepData});

  @override
  State<StudyPlanAiMaskWidget> createState() => _StudyPlanAiMaskWidgetState();
}

class _StudyPlanAiMaskWidgetState extends State<StudyPlanAiMaskWidget> {

  int reportDuration = 0;
  String reportMessage = "";
  Timer? _reportTimer;


  @override
  void initState(){
    super.initState();
    updateReportDuration();
  }

  @override
  void didUpdateWidget(covariant StudyPlanAiMaskWidget oldWidget){
    super.didUpdateWidget(oldWidget);
    updateReportDuration();
  }

  /// 更新时长
  void updateReportDuration(){
    if(widget.stepData.currentStep != LearningSettingStepsEnum.AI_PLAN) return;
    if(widget.stepData.params == null) return;
    int serverDuration = widget.stepData.params?['reportDuration'] ?? 0;
    if(serverDuration == reportDuration) return;
    reportDuration = serverDuration;
    if(mounted) setState(() {});
    reportMessage = widget.stepData.params?['message'] ?? "";
    if(reportDuration <= 0) return;
    startCountdown();
  }

    /// 开始倒计时
  void startCountdown(){
    _reportTimer?.cancel();
    if(reportDuration <= 0) return;
    _reportTimer = Timer.periodic(Duration(seconds: 1), (timer){
      reportDuration--;
      if(reportDuration <= 0){
        widget.controller.getPlanList();
        _reportTimer?.cancel();
      }
      if(mounted) setState(() {});
    });
  }


  /// subButton 跳转页面
  void subButtonJump(){
    if(widget.stepData.subButton?.jump == null) return;
    JumpPageUtils.jumpPage(PushMessageEntity(
      category: JumpPageUtils.userType,
      jump: widget.stepData.subButton?.jump,
    ));
  }

  /// Button 跳转页面
  Future<void> buttonJump() async{
    if(widget.stepData.button?.jump == null) return;
    await JumpPageUtils.jumpPage(PushMessageEntity(
      category: JumpPageUtils.userType,
      jump: widget.stepData.button?.jump,
    ));
  }

  @override
  Widget build(BuildContext context) {
    if(widget.stepData.currentStep != LearningSettingStepsEnum.AI_PLAN) return Container();

    Color? color = ColorUtils.parseColor(widget.stepData.color);
    color??=Colors.transparent;

    return Container(
      color: AppTheme.cOverlayBackground.color,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 100.wMin,
        children: [
          Container(
            width: 1200.wMin,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.wMin),
              border: Border.all(color: AppTheme.cBorderPrimary.color, width: 1.wMin),
              color: AppTheme.cSurfaceSecondary.color,
            ),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 32.wMin, vertical: 24.wMin),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  stops: [0.0, 0.4],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    color.withValues(alpha: 0.3), 
                    color.withValues(alpha: 0),
                  ],
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 40.wMin,
                children: [
                  Expanded(
                    child: _buildContentLeftWidget(),
                  ),
                  SizedBox(
                    width: 508.wMin,
                    child: _buildContentRightWidget(),
                  ),
                ],
              ),
            ),
          ),

          _buildButtonsWidget(),

        ],
      ),
    );
  }

  Widget _buildButtonsWidget(){
    return Row(
      spacing: 12.wMin,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ButtonWidget(
          text: "查看评测结果",
          width: 314.wMin,
          height: 56.wMin,
          borderRadius: 8.wMin,
          buttonBackColor: AppTheme.cBgSolid.color,
          color: AppTheme.cSurfaceSecondary.color,
          border: Border.all(color: AppTheme.cBorderDefault.color, width: 0.8.wMin),
          fontSize: 24.wMin,
          fontColor: AppTheme.cTextBrand.color,
          fontWeight: FontWeight.w500,
          sclae: 1.03,
          onTap: () {
            widget.controller.goAssessmentResultPage(context);
          },
        ),
        ButtonWidget(
          text: "返回",
          width: 314.wMin,
          height: 56.wMin,
          borderRadius: 8.wMin,
          buttonBackColor: AppTheme.cBgSolid.color,
          color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.15),
          border: Border.all(color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2), width: 0.8.wMin),
          fontSize: 24.wMin,
          fontColor: AppTheme.cSurfaceBrand.color,
          fontWeight: FontWeight.w500,
          sclae: 1.03,
          onTap: () {
            Get.back();
          },
        ),
      ],
    );
  }


  Widget _buildContentLeftWidget(){
    Color? color = ColorUtils.parseColor(widget.stepData.color);
    color??=AppTheme.cSurfaceSuccess.color;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88.wMin,
            height: 88.wMin,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.wMin),
              color: color,
            ),
            child: SvgPicture.string(
              widget.stepData.iconSvg??"",
              height: 44.wMin,
              colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
          ),
          SizedBox(height: 10.wMin),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 4.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(99),
              color: AppTheme.cSurfaceLayerBase.color,
              border: Border.all(
                color: AppTheme.cBorderSubtle.color,
                width: 0.8.wMin,
              ),
            ),
            child: Text(
              "STEP ${widget.stepData.stepIndex??''} / 4 · ${widget.stepData.title??""}",
              style: TextStyle(
                color: AppTheme.cTextSecondary.color,
                fontSize: 18.wMin,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: 10.wMin),
          Text(
            widget.stepData.stepTitle??"",
            style: TextStyle(
              color: AppTheme.cTextPrimary.color,
              fontSize: 40.wMin,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10.wMin),
          Text(
            widget.stepData.stepDescription??"",
            style: TextStyle(
              color: AppTheme.cTextSecondary.color,
              fontSize: 24.wMin,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentRightWidget(){
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [

        _buildContentRightSubButtonWidget(),

        _buildContentRightGuideItemsWidget(),
        
        _buildContentRightButtonWidget(),

        _buildContentRightCountdownWidget(),
      ],
    );
  }

  Widget _buildContentRightSubButtonWidget(){
    if(widget.stepData.subButton == null) return Container();
    PushMessageEntityJump? jump = widget.stepData.subButton?.jump;

    return Container(
      alignment: Alignment.centerRight,
      child: IgnorePointer(
        ignoring: jump == null,
        child: TapScaleWidget(
          onTap: subButtonJump,
          sclae: 1.01,
          child: Container(
            color: Colors.transparent,
            padding: EdgeInsets.symmetric(vertical: 10.wMin),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.stepData.subButton?.title??"",
                  style: TextStyle(
                    color: AppTheme.cTextSecondary.color,
                    fontSize: 18.wMin,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Visibility(
                  visible: jump != null,
                  child: Container(
                    margin: EdgeInsets.only(left: 6.wMin),
                    child: SvgPicture.asset(
                      "assets/svg/public/icon_arrow_right_thin.svg",
                      width: 24.wMin,
                      colorFilter: ColorFilter.mode(AppTheme.cTextSecondary.color, BlendMode.srcIn),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentRightGuideItemsWidget(){
    List<String?> guideItems = widget.stepData.guideItems??[];
    if(guideItems.isEmpty) return Container();

    Color? color = ColorUtils.parseColor(widget.stepData.color);
    color??=AppTheme.cSurfaceSuccess.color;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.wMin),
        color: AppTheme.cSurfaceLayerElevated2.color,
        border: Border.all(
          color: AppTheme.cBorderSubtle.color,
          width: 1.wMin,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 12.wMin),
            child: Text(
              "这一步会完成什么",
              style: TextStyle(
                color: AppTheme.cTextPrimary.color,
                fontSize: 20.wMin,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(height: 1.wMin, color: AppTheme.cBorderDefault.color),
          Container(
            constraints: BoxConstraints(
              maxHeight: 300.wMin,
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 12.wMin),
              child: Column(
                spacing: 16.wMin,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(guideItems.length, (index){
                  return Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 24.wMin,
                        color: color,
                      ),
                      SizedBox(width: 8.wMin),
                      Expanded(
                        child: Text(
                          guideItems[index]??"",
                          style: TextStyle(
                            color: AppTheme.cTextSecondary.color,
                            fontSize: 20.wMin,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentRightButtonWidget(){
    LearningSettingStepsEnum? currentStep = widget.stepData.currentStep;
    if(currentStep == LearningSettingStepsEnum.AI_PLAN) return Container();

    Color? color = ColorUtils.parseColor(widget.stepData.color);
    color??=AppTheme.cSurfaceSuccess.color;
    return Container(
      margin: EdgeInsets.only(top: 12.wMin),
      child: TapScaleWidget(
        onTap: () {
          buttonJump();
        },
        sclae: 1.01,
        child: Container(
          width: double.infinity,
          height: 68.wMin,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.wMin),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                color.withValues(alpha: 0.8),
                color,
              ],
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.stepData.button?.title??"",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 6.wMin),
              SvgPicture.asset(
                "assets/svg/public/icon_arrow_right.svg",
                width: 24.wMin,
                colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
            ],
          ),
        ),
      ),
    );
  }


  /// 评测倒计时
  Widget _buildContentRightCountdownWidget(){
    LearningSettingStepsEnum? currentStep = widget.stepData.currentStep;
    if(currentStep != LearningSettingStepsEnum.AI_PLAN) return Container();

    Color? color = ColorUtils.parseColor(widget.stepData.color);
    color??=AppTheme.cSurfaceSuccess.color;

    if(reportDuration <= 0){
      return Text(
        "评测延迟或失败，请重新评测或联系助教老师",
        style: TextStyle(
          color: AppTheme.cSurfaceError.color,
          fontSize: 20.wMin,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    return Container(
      margin: EdgeInsets.only(top: 12.wMin),
      padding: EdgeInsets.all(12.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.wMin),
        color: AppTheme.cSurfaceLayerElevated2.color,
        border: Border.all(
          color: AppTheme.cBorderSubtle.color,
          width: 1.wMin,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 12.wMin,
                height: 12.wMin,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
              ),
              SizedBox(width: 8.wMin),
              Text(
                "预计剩余",
                style: TextStyle(
                  color: AppTheme.cTextPrimary.color,
                  fontSize: 20.wMin,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 8.wMin),
              Text(
                DateFormatUtil.convertSecondsToMinSec(reportDuration),
                style: TextStyle(
                  color: color,
                  fontSize: 48.wMin,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Visibility(
            visible: reportMessage.isNotEmpty,
            child: Text(
              reportMessage,
              style: TextStyle(
                color: AppTheme.cTextSecondary.color,
                fontSize: 20.wMin,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }



}