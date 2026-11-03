import 'dart:ui';

import 'package:bubble_box/bubble_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:langwise/app/routes/app_pages.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';

import '../../../../common/stores/stores.dart';
import '../../../../common/widgets/widgets.dart';
import '../controllers/today_plan_controller.dart';

class TodayPlanView extends GetView<TodayPlanController> {
  const TodayPlanView({super.key});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return AnimationLimiter(
        child: Scaffold(
          backgroundColor: AppTheme.cBgPrimary,
          body: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: Column(
                  children: [
                    _buildTitleWidget(context),
                    SizedBox(height: 16.wMin),
                    Expanded(
                      child: Obx(() {
                        // if (controller.courseBaseList.isEmpty) return const TodayPlanCalenderWidget();
                        List<PersonalizedLearningPlanPageData> pages = controller.learningPlanPages.toList();
                        if (pages.isEmpty) return const SizedBox.shrink();
                        return Center(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                            width: 1700.wMin,
                            alignment: Alignment.center,
                            child: PersonalizedLearningPlanWidget(
                              showTitle: false,
                              pages: pages,
                              isFromPlan: true,
                              controller: controller.personalizedLearningPlanController,
                            ),
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: MediaQuery.of(context).padding.bottom + 16.wMin),
                  ],
                ),
              ),
              Positioned(
                bottom: 100.wMin + MediaQuery.of(context).padding.bottom,
                right: 24.wMin,
                child: _buildFloatButtonsWidget(context),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildTitleWidget(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10.wMin, left: 70.wMin, right: 70.wMin),
      child: Row(
        children: [
          const BackWidget(title: ""),
          const Spacer(),
          Builder(builder: (ctx) {
            return TapScaleWidget(
              onTap: () {
                controller.showIntroductionTip(ctx);
              },
              sclae: 1.05,
              child: SvgPicture.asset(
                "assets/svg/public/icon_info.svg",
                width: 44.wMin,
                colorFilter: ColorFilter.mode(AppTheme.cFeedbackDefaultIcon.color, BlendMode.srcIn),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFloatButtonsWidget(BuildContext context){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      spacing: 16.wMin,
      children: [
        
        Obx((){
          int? assessmentTier = UserStore.to.userInfo.value.assessmentTier;
          Color textColor = AppTheme.cTextPrimary.color;
          if(assessmentTier == null){
            textColor = AppTheme.cSurfaceWarning.color;
          }

          return TapScaleWidget(
            onTap: () {
              if(assessmentTier == null){
                Get.toNamed(Routes.USER_EVALUATION);
              }else{
                controller.toUserEvaluationResult(context);
              }
            },
            sclae: 1.01,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4.wMin, sigmaY: 4.wMin),
                child: Container(
                  height: 64.wMin,
                  padding: EdgeInsets.symmetric(horizontal: 20.wMin),
                  decoration: BoxDecoration(
                    color: textColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      width: 1.wMin, 
                      color: textColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        assessmentTier == null ? "去评测" : "当前: Level ${UserStore.to.userInfo.value.assessmentTier ?? 0}",
                        style: TextStyle(
                          fontSize: 28.wMin,
                          color: textColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),


        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [

            TapScaleWidget(
              onTap: () {
                controller.toSuperMemoCalender(context);
              },
              sclae: 1.01,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4.wMin, sigmaY: 4.wMin),
                  child: Container(
                    height: 64.wMin,
                    padding: EdgeInsets.only(left: 16.wMin, right: 20.wMin),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(width: 1.wMin, color: AppTheme.cSurfaceWarning.color.withValues(alpha: 0.2)),
                      color: AppTheme.cSurfaceWarning.color.withValues(alpha: 0.15),
                    ),
                    child: Row(
                      spacing: 4.wMin,
                      children: [
                        SvgPicture.asset(
                          "assets/svg/public/icon_calendar.svg",
                          width: 28.wMin,
                          colorFilter: ColorFilter.mode(AppTheme.cSurfaceWarning.color, BlendMode.srcIn),
                        ),
                        Text(
                          '超记日历',
                          style: TextStyle(
                            fontSize: 28.wMin,
                            color: AppTheme.cSurfaceWarning.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),


            Positioned(
              left: -210.wMin,
              child: Obx((){
                return Visibility(
                  visible: controller.showSuperMemoCalenderPrompt.value,
                  child: SizedBox(
                    width: 200.wMin,
                    child: BubbleBox(
                      backgroundColor: AppTheme.cSurfaceBrand.color,
                      padding: EdgeInsets.all(8.wMin),
                      elevation: 1,
                      shadowColor: AppTheme.cOverlayBackground.color,
                      shape: BubbleShapeBorder(
                        direction: BubbleDirection.right,
                        arrowQuadraticBezierLength: 1,
                        radius: BorderRadius.circular(8.wMin),
                        arrowHeight: 10.wMin,
                        arrowAngle: 10.wMin,
                        smooth: 0,
                      ),
                      child: Text(
                        "超记日历可以查看学习记录",
                        style: TextStyle(
                          fontSize: 24.wMin,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),


          ],
        ),

      ],
    );
  }

}
