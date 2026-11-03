import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:langwise/app/modules/today_plan/views/today_plan_page.dart';
import 'package:langwise/app/routes/app_pages.dart';
import 'package:langwise/common/enum/specialty_enum.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/stores/stores.dart';
import '../../../../common/widgets/widgets.dart';
import '../controllers/today_plan_controller.dart';
import 'today_plan_calender.dart';

class TodayPlanView extends GetView<TodayPlanController> {
  const TodayPlanView({super.key});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return AnimationLimiter(
        child: Scaffold(
          backgroundColor: AppTheme.cBgPrimary,
          body: Column(
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
      );
    });
  }

  Widget _buildTitleWidget(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10.wMin, left: 40.wMin, right: 56.wMin),
      child: Row(
        children: [
          const BackWidget(title: ""),
          const Spacer(),
          Obx(() {
            int? assessmentTier = UserStore.to.userInfo.value.assessmentTier;
            if (assessmentTier == null) {
              return Row(
                children: [
                  Text(
                    "推荐您去评测，获取官方推荐学习计划",
                    style: TextStyle(
                      fontSize: 24.wMin,
                      color: AppTheme.cTextPrimary.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 16.wMin),
                  ButtonWidget(
                    text: "去评测",
                    height: 60.wMin,
                    padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                    borderRadius: 8.wMin,
                    color: AppTheme.cFeedbackWarningBackground.color,
                    fontColor: AppTheme.cFeedbackWarningText.color,
                    fontSize: 24.wMin,
                    fontWeight: FontWeight.w600,
                    sclae: 1.05,
                    onTap: () {
                      Get.toNamed(Routes.USER_EVALUATION);
                    },
                  ),
                  SizedBox(width: 16.wMin),
                  TapScaleWidget(
                      onTap: () {
                        controller.toSuperMemoCalender(context);
                      },
                      sclae: 1,
                      child: Container(
                        height: 60.wMin,
                        padding: EdgeInsets.only(left: 12.wMin, right: 8.wMin),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.wMin),
                          color: AppTheme.cBgTertiary.color,
                        ),
                        child: Row(children: [
                          Text(
                            '超记日历',
                            style: TextStyle(
                              fontSize: 22.wMin,
                              color: AppTheme.cTextSecondary.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SvgPicture.asset(
                            "assets/svg/public/icon_w_arrow_right.svg",
                            width: 24.wMin,
                          ),
                        ]),
                      )),
                  SizedBox(width: 22.wMin),
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
              );
            }
            return Row(
              children: [
                TapScaleWidget(
                  onTap: () {
                    controller.toUserEvaluationResult(context);
                  },
                  sclae: 1,
                  child: Container(
                    height: 60.wMin,
                    padding: EdgeInsets.only(left: 12.wMin, right: 8.wMin),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.wMin),
                      color: AppTheme.cBgTertiary.color,
                    ),
                    child: Row(
                      spacing: 4.wMin,
                      children: [
                        Text(
                          "当前等级:",
                          style: TextStyle(
                            fontSize: 22.wMin,
                            color: AppTheme.cTextSecondary.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "Level ${UserStore.to.userInfo.value.assessmentTier ?? 0}",
                          style: TextStyle(
                            fontSize: 22.wMin,
                            color: AppTheme.cTextSecondary.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SvgPicture.asset(
                          "assets/svg/public/icon_w_arrow_right.svg",
                          width: 24.wMin,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 16.wMin),
                TapScaleWidget(
                    onTap: () {
                      controller.toSuperMemoCalender(context);
                    },
                    sclae: 1.03,
                    child: Container(
                      height: 60.wMin,
                      padding: EdgeInsets.only(left: 12.wMin, right: 8.wMin),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.wMin),
                        color: AppTheme.cBgTertiary.color,
                      ),
                      child: Row(children: [
                        Text(
                          '超记日历',
                          style: TextStyle(
                            fontSize: 22.wMin,
                            color: AppTheme.cTextSecondary.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SvgPicture.asset(
                          "assets/svg/public/icon_w_arrow_right.svg",
                          width: 24.wMin,
                          colorFilter: ColorFilter.mode(AppTheme.cTextSecondary.color, BlendMode.srcIn),
                        ),
                      ]),
                    )),
                SizedBox(width: 22.wMin),
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
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRecommendedStartingPointWidget() {
    return Row(
      spacing: 8.wMin,
      children: List.generate(controller.recommendedStartingPointList.length, (index) {
        StudyPlanStartUnitEntity data = controller.recommendedStartingPointList[index];
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 6.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.wMin),
            color: AppTheme.cFeedbackInfoBackground.color,
          ),
          child: Row(
            children: [
              Container(
                width: 6.wMin,
                height: 6.wMin,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.cFeedbackInfoIcon.color,
                ),
              ),
              SizedBox(width: 8.wMin),
              Text(
                "${data.courseName ?? ""}推荐起点：${data.levelName ?? ""}",
                style: TextStyle(
                  color: AppTheme.cFeedbackInfoText.color,
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildAddPlanFlotButton() {
    return Obx(() {
      if (controller.showAddPlanButton.value) return Container();
      return TapScaleWidget(
        onTap: () => controller.toTimeSetUp(),
        sclae: 1.03,
        child: Container(
          width: 184.wMin,
          height: 72.wMin,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: AppTheme.cBgBrand.color,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                "assets/svg/public/icon_add.svg",
                width: 40.wMin,
                colorFilter: ColorFilter.mode(AppTheme.cStaticWhite.color, BlendMode.srcIn),
              ),
              Text(
                "添加计划",
                style: TextStyle(
                  color: AppTheme.cStaticWhite.color,
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w600,
                ),
              )
            ],
          ),
        ),
      );
    });
  }

  Widget buildTitleMenu(BuildContext context) {
    return Obx(() {
      return TapScaleWidget(
        onTap: () {
          controller.editSetting(context);
        },
        sclae: 1,
        child: Container(
          alignment: Alignment.centerRight,
          color: Colors.transparent,
          child: Row(
            children: [
              Text(
                "每日复习题数量",
                style: TextStyle(
                  color: AppTheme.cTextPrimary.color,
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 14.wMin),
              Text(
                controller.reviewLimit.value == 0 ? "无限制" : "${controller.reviewLimit.value}",
                style: TextStyle(
                  color: AppTheme.cTextPrimary.color,
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 48.wMin),
              SizedBox(
                width: 190.wMin,
                child: CardTitleSwitchWidget(
                  title: "黄金学练",
                  // tips: StaticData.goldRatioDesc,
                  value: controller.goldRatioSwitch.value,
                  // onChanged: (val){
                  //   controller.modifyPlan(val, controller.superMemo.value);
                  // },
                ),
              ),
              SizedBox(width: 48.wMin),
              SizedBox(
                width: 190.wMin,
                child: CardTitleSwitchWidget(
                  title: "超级记忆",
                  // tips: StaticData.superMemoDesc,
                  value: controller.superMemo.value,
                  // onChanged: (val){
                  //   controller.modifyPlan(controller.goldRatioSwitch.value, val);
                  // },
                ),
              ),
              SizedBox(width: 24.wMin),
              TapScaleWidget(
                onTap: () {
                  controller.editSetting(context);
                },
                sclae: 1.1,
                child: Container(
                  color: Colors.transparent,
                  padding: EdgeInsets.all(10.wMin),
                  child: SvgPicture.asset(
                    "assets/svg/public/icon_setting.svg",
                    width: 32.wMin,
                    colorFilter: ColorFilter.mode(AppTheme.cFeedbackDefaultIcon.color, BlendMode.srcIn),
                  ),
                ),
              ),
              SizedBox(width: 48.wMin),
            ],
          ),
        ),
      );
    });
  }
}
