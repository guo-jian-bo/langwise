import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/enum/enum.dart';
import '../../../../common/widgets/guide_engine/guide_engine.dart';
import '../bindings/learning_setting_steps_binding.dart';
import '../controllers/learning_setting_steps_controller.dart';

class LearningSettingStepsView extends GetView<LearningSettingStepsController> {
  final String tagText;
  const LearningSettingStepsView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      LearningSettingStepsView(tagText: tag),
      binding: LearningSettingStepsBinding(tagText: tag),
      routeName: Routes.LEARNING_SETTING_STEPS,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cBgPrimary,
      body: Obx((){
        Color? color = ColorUtils.parseColor(controller.stepData.value.color);
        color??=Colors.transparent;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.topCenter,
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
          child: Stack(
            children: [
              Positioned.fill(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BreadcrumbWidget(),
                    Expanded(
                      child: Center(
                        child: _buildBodyWidget(),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).padding.bottom + 20.wMin + 56.wMin),
                  ],
                ),
              ),
              Positioned(
                left: 56.wMin,
                bottom: 50.wMin,
                child: CustomerServiceButtonWidget(
                  widgetId: GuideWidgetIds.learningSettingStepsCustomerServiceButton, 
                  pageCode: AppRoutesCode.learningSettingSteps,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildBodyWidget(){
    return Container(
      width: 1200.wMin,
      height: 674.wMin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.wMin),
        color: AppTheme.cSurfaceSecondary.color,
        border: Border.all(
          color: AppTheme.cBorderPrimary.color,
          width: 1.wMin,
        ),
      ),
      child: Column(
        children: [
          _buildTitleStepWidget(),
          Container(height: 1.wMin, color: AppTheme.cBorderSubtle.color),
          Expanded(child: _buildContentWidget()),
        ],
      ),
    );
  }

  Widget _buildTitleStepWidget(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32.wMin),
      height: 124.wMin,
      alignment: Alignment.centerLeft,
      child: SizedBox(
        height: 60.wMin,
        child: Obx((){
          List<LearningSettingStepEntityStepTitles?> stepTitles = controller.stepData.value.stepTitles??[];
          return ListView.separated(
            itemCount: stepTitles.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            scrollDirection: Axis.horizontal,
            separatorBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 4.wMin),
                child: SvgPicture.asset(
                  "assets/svg/public/icon_arrow_right_thin.svg",
                  width: 24.wMin,
                ),
              );
            },
            itemBuilder: (context, index) {
              return _buildTitleStepItemWidget(stepTitles[index]);
            },
          );
        }),
      ),
    );
  }

  Widget _buildTitleStepItemWidget(LearningSettingStepEntityStepTitles? step){
    return Obx((){
      bool isSelected = step?.stepIndex == controller.stepData.value.stepIndex;

      return Container(
        height: 60.wMin,
        padding: EdgeInsets.only(left: 12.wMin, right: 24.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: Colors.transparent,
          border: Border.all(
            color: isSelected ? AppTheme.cSurfaceBrand.color : AppTheme.cBorderDefault.color,
            width: 1.wMin,
          ),
        ),
        child: Row(
          spacing: 8.wMin,
          children: [
            Container(
              width: 36.wMin,
              height: 36.wMin,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppTheme.cSurfaceBrand.color : AppTheme.cSurfaceLayerElevated.color,
                border: Border.all(
                  color: isSelected ? AppTheme.cSurfaceBrand.color : AppTheme.cBorderSubtle.color,
                  width: 1.wMin,
                ),
              ),
              child: Text(
                step?.stepIndex?.toString()??"",
                style: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.cTextSecondary.color,
                  fontSize: 16.wMin,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            Text(
              step?.title??"",
              style: TextStyle(
                color: isSelected ? AppTheme.cTextPrimary.color : AppTheme.cTextTertiary.color,
                fontSize: 20.wMin,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildContentWidget(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 32.wMin, vertical: 24.wMin),
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
    );
  }

  Widget _buildContentLeftWidget(){
    return Obx((){
      Color? color = ColorUtils.parseColor(controller.stepData.value.color);
      color??=AppTheme.cSurfaceSuccess.color;

      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                controller.stepData.value.iconSvg??"",
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
                "STEP ${controller.stepData.value.stepIndex??''} / 4 · ${controller.stepData.value.title??""}",
                style: TextStyle(
                  color: AppTheme.cTextSecondary.color,
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(height: 10.wMin),
            Text(
              controller.stepData.value.stepTitle??"",
              style: TextStyle(
                color: AppTheme.cTextPrimary.color,
                fontSize: 40.wMin,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10.wMin),
            Text(
              controller.stepData.value.stepDescription??"",
              style: TextStyle(
                color: AppTheme.cTextSecondary.color,
                fontSize: 24.wMin,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildContentRightWidget(){
    return Column(
      children: [

        _buildContentRightSubButtonWidget(),

        _buildContentRightGuideItemsWidget(),
        
        _buildContentRightButtonWidget(),

        _buildContentRightCountdownWidget(),
      ],
    );
  }


  Widget _buildContentRightSubButtonWidget(){
    return Obx((){
      if(controller.stepData.value.subButton == null) return Container();
      PushMessageEntityJump? jump = controller.stepData.value.subButton?.jump;

      return Container(
        alignment: Alignment.centerRight,
        child: IgnorePointer(
          ignoring: jump == null,
          child: TapScaleWidget(
            onTap: controller.subButtonJump,
            sclae: 1.01,
            child: Container(
              color: Colors.transparent,
              padding: EdgeInsets.symmetric(vertical: 10.wMin),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    controller.stepData.value.subButton?.title??"",
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
    });
  }

  Widget _buildContentRightGuideItemsWidget(){
    return Obx((){
      List<String?> guideItems = controller.stepData.value.guideItems??[];
      if(guideItems.isEmpty) return Container();

      Color? color = ColorUtils.parseColor(controller.stepData.value.color);
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
    });
  }

  Widget _buildContentRightButtonWidget(){
    return Obx((){
      LearningSettingStepsEnum? currentStep = controller.stepData.value.currentStep;
      if(currentStep == LearningSettingStepsEnum.AI_PLAN) return Container();

      Color? color = ColorUtils.parseColor(controller.stepData.value.color);
      color??=AppTheme.cSurfaceSuccess.color;
      return Container(
        margin: EdgeInsets.only(top: 12.wMin),
        child: TapScaleWidget(
          onTap: () {
            controller.buttonJump();
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
                  controller.stepData.value.button?.title??"",
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
    });
  }


  /// 评测倒计时
  Widget _buildContentRightCountdownWidget(){
    return Obx((){
      LearningSettingStepsEnum? currentStep = controller.stepData.value.currentStep;
      if(currentStep != LearningSettingStepsEnum.AI_PLAN) return Container();

      Color? color = ColorUtils.parseColor(controller.stepData.value.color);
      color??=AppTheme.cSurfaceSuccess.color;
      int reportDuration = controller.reportDuration.value;

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
              visible: controller.reportMessage.isNotEmpty,
              child: Text(
                controller.reportMessage.value,
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
    });
  }


}
