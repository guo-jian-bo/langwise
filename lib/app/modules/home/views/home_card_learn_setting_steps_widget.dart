
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/enum/enum.dart';
import '../../../../common/widgets/guide_engine/guide_engine.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';
import '../../../../utils/utils.dart';
import '../../../routes/routes.dart';
import '../controllers/home_controller.dart';

class HomeCardLearnSettingStepsWidget extends StatefulWidget {
  final HomeController controller;
  final LearningSettingStepEntity stepData;
  const HomeCardLearnSettingStepsWidget({super.key, required this.controller, required this.stepData});

  @override
  State<HomeCardLearnSettingStepsWidget> createState() => _HomeCardLearnSettingStepsWidgetState();
}

class _HomeCardLearnSettingStepsWidgetState extends State<HomeCardLearnSettingStepsWidget> with SingleTickerProviderStateMixin {

  /// 正在AI规划的剩余时间 秒
  int reportDuration = 0;
  /// 倒计时定时器
  Timer? _reportTimer;

  String? _reportMessage;

  late final AnimationController _buttonScaleController;
  late final Animation<double> _buttonScaleAnimation;

  @override
  void initState(){
    super.initState();

    _buttonScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _buttonScaleAnimation = Tween<double>(
      begin: 1,
      end: 1.06,
    ).animate(CurvedAnimation(
      parent: _buttonScaleController,
      curve: Curves.easeInOut,
    ));

    updateReportDuration();

  }

  @override
  void didUpdateWidget(covariant HomeCardLearnSettingStepsWidget oldWidget){
    super.didUpdateWidget(oldWidget);
    updateReportDuration();
  }


  @override
  void dispose(){
    _reportTimer?.cancel();
    _buttonScaleController.dispose();
    super.dispose();
  }

  /// 正在AI规划的剩余时间 秒
  void updateReportDuration(){
    if(widget.stepData.currentStep == LearningSettingStepsEnum.AI_PLAN){
      reportDuration = widget.stepData.params?['reportDuration'] ?? 0;
      _reportMessage = widget.stepData.params?['message'] ;
      startCountdown();
    }else{
      reportDuration = 0;
      _reportTimer?.cancel();
    }
  }

  /// 开始倒计时
  void startCountdown(){
    _reportTimer?.cancel();
    if(reportDuration <= 0) return;
    _reportTimer = Timer.periodic(Duration(seconds: 1), (timer){
      reportDuration--;
      if(reportDuration <= 0){
        widget.controller.initHomeCardList();
        _reportTimer?.cancel();
      }
      if(mounted) setState(() {});
    });
  }

  void subButtonJump(){
    if(widget.stepData.subButton?.jump == null) return;
    JumpPageUtils.jumpPage(PushMessageEntity(
      category: JumpPageUtils.userType,
      jump: widget.stepData.subButton?.jump,
    ));
  }

  Future<void> buttonJump() async{
    if(widget.stepData.button?.jump == null) return GuideTaskController.to.stop();
    bool lock = await LockUtils.checkLock(widget.controller.homeFistCardData.value.rights, context);
    if (lock) return GuideTaskController.to.stop();

    await JumpPageUtils.jumpPage(PushMessageEntity(
      category: JumpPageUtils.userType,
      jump: widget.stepData.button?.jump,
    ));

    GuideTaskController.to.continueGuide(AppRoutesCode.home, GuideWidgetIds.homeGuideButton);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 10.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStepTitleWidget(),
          _buildBottomWidget(),
        ],
      ),
    );
  }

  Widget _buildStepTitleWidget(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
    );
  }


  Widget _buildBottomWidget(){
    return Column(
      children: [

        _buildBottomSubButtonWidget(),

        _buildBottomGuideItemsWidget(),
        
        _buildBottomButtonWidget(),

        _buildBottomCountdownWidget(),
      ],
    );
  }

  Widget _buildBottomSubButtonWidget(){
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

  Widget _buildBottomGuideItemsWidget(){
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
              maxHeight: widget.stepData.currentStep == LearningSettingStepsEnum.AI_PLAN ? 200.wMin : 300.wMin,
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

  Widget _buildBottomButtonWidget(){
    LearningSettingStepsEnum? currentStep = widget.stepData.currentStep;
    if(currentStep == LearningSettingStepsEnum.AI_PLAN) return Container();

    Color? color = ColorUtils.parseColor(widget.stepData.color);
    color??=AppTheme.cSurfaceSuccess.color;

    return Container(
      margin: EdgeInsets.only(top: 12.wMin),
      child: ScaleTransition(
        scale: _buttonScaleAnimation,
        child: GuideStepWidget(
          id: GuideWidgetIds.homeGuideButton,
          onTap: () async{
            buttonJump();
          },
          sclae: 1,
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
      ),
    );
  }

  /// 评测倒计时
  Widget _buildBottomCountdownWidget(){
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
      margin: EdgeInsets.only(top: 10.wMin),
      padding: EdgeInsets.only(
        left: 12.wMin,
        right: 12.wMin,
        bottom: 12.wMin,
      ),
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
            visible: _reportMessage != null,
            child: Text(
              _reportMessage??"",
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
