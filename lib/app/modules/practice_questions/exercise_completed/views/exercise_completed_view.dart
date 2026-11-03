

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:langwise/common/widgets/list_animation_widget.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../theme/theme.dart';
import '../controllers/exercise_completed_controller.dart';
import 'exercise_completed_cardbox.dart';

class ExerciseCompletedView extends GetView<ExerciseCompletedController> {
  const ExerciseCompletedView({super.key});
  @override
  Widget build(BuildContext context) {

    Widget buildAccuracyItem(String name, String val, int index){

      return ListAnimationWidget(
        index: index,
        child: Container(
          width: 494.wMin,
          padding: EdgeInsets.symmetric(horizontal: 20.wMin, vertical: 20.wMin),
          decoration: BoxDecoration(
            color: AppTheme.cBgTertiary,
            borderRadius: BorderRadius.circular(12.wMin),
            border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 24.wMin,
                  color: AppTheme.cTextPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: [
                  Text(
                    val,
                    style: TextStyle(
                      fontSize: 24.wMin,
                      color: AppTheme.cTextPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(width: 6.wMin),
                  ShadowStarWidget(size: 28.wMin),
                ],
              ),
            ],
          ),
        ),
      );
    }

    /// 正确率
    Widget buildAccuracy(){
      return IgnorePointer(
        ignoring: controller.currentPageIndex.value > 0,
        child: ExerciseCompletedCardbox(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 80.wMin),
                      width: 144.wMin,
                      height: 150.wMin,
                      child: Image.asset("assets/images/practice_questions/applaud.png"),
                    ),
                    SizedBox(height: 40.wMin),
                    Text(
                      "太棒了，琪琪尼",
                      style: TextStyle(
                        fontSize: 36.wMin,
                        color: AppTheme.cTextPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8.wMin),
                    Text(
                      "你做到了！你完成了你的英语学习第一课。感觉是不是很棒！",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20.wMin,
                        color: AppTheme.cTextSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 40.wMin),
                    FutureBuilder(
                      initialData: false,
                      future: Future.delayed(const Duration(milliseconds: 500), (){
                        return true;
                      }),
                      builder: (context, snapshot) {
                        if(!snapshot.data!) return Container();
                        return AnimationLimiter(
                          child: Column(
                            spacing: 8.wMin,
                            children: [
                              buildAccuracyItem("星数", "+10", 0),
                              buildAccuracyItem("正确率", "90%", 1),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
        
              Container(
                padding: EdgeInsets.symmetric(vertical: 45.wMin),
                child: ContinueButtonWidget(
                  width: 400.wMin,
                  onTap: () {
                    controller.switchPage();
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget buildTodayChallengeItem(String name, int progress, int total, int index){
      return ListAnimationWidget(
        index: index,
        child: Container(
          width: 512.wMin,
          padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 12.wMin),
          decoration: BoxDecoration(
            color: AppTheme.cBgTertiary,
            borderRadius: BorderRadius.circular(16.wMin),
            border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary),
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                "assets/svg/practice_questions/icon_diamond.svg",
                width: 64.wMin,
                height: 64.wMin,
              ),
              SizedBox(width: 16.wMin),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 20.wMin,
                        color: AppTheme.cTextPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8.wMin),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20.wMin),
                          child: Container(
                            width: 320.wMin,
                            height: 8.wMin,
                            alignment: Alignment.centerLeft,
                            color: AppTheme.cWhiteAlpha10,
                            child: Container(
                              width: (progress / total) * 320.wMin,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.wMin),
                                color: AppTheme.cBgBrand,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            alignment: Alignment.centerRight,
                            child: AutoSizeText(
                              "$progress/$total",
                              minFontSize: 6,
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 18.wMin,
                                color: AppTheme.cTextPrimary,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    /// 今日挑战
    Widget buildTodayChallenge(){
      return IgnorePointer(
        ignoring: controller.currentPageIndex.value > 1,
        child: ExerciseCompletedCardbox(
          show: controller.currentPageIndex.value > 0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                children: [
                  Text(
                    "今日挑战",
                    style: TextStyle(
                      fontSize: 36.wMin,
                      color: AppTheme.cTextPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 16.wMin),
                  Text(
                    "你在不断取得进步！",
                    style: TextStyle(
                      fontSize: 28.wMin,
                      color: AppTheme.cTextSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 32.wMin),
                  AnimationLimiter(
                    child: Column(
                      spacing: 16.wMin,
                      children: [
                        buildTodayChallengeItem("赢取20颗能量球", 10, 20, 0),
                        buildTodayChallengeItem("完成接下来的3个单元", 1, 3, 1),
                        buildTodayChallengeItem("完成3个完美无错单元", 1, 2, 2),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32.wMin),
              Container(
                padding: EdgeInsets.symmetric(vertical: 45.wMin),
                child: ContinueButtonWidget(
                  width: 400.wMin,
                  onTap: () {
                    controller.switchPage();
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }

    

    /// 连续学习
    Widget buildContinuousLearning(){
      final itemWidth = (494.wMin - 48.wMin) / 7;
      final circleWidth = 40.wMin;

      Widget buildContinuousLearningWeekItem(String week, int day, int type){
        Widget contentWidget = Container();
        if(type == 0){ // 日期
          contentWidget = Text(
            "$day",
            style: TextStyle(
              fontSize: 16.wMin,
              color: AppTheme.cTextSecondary,
              fontWeight: FontWeight.w500,
            ),
          );
        }else if(type == 1){ // 空选择
          contentWidget = SvgPicture.asset("assets/svg/practice_questions/icon_week_check.svg", width: 23.wMin);
        }else if(type == 2){ // 选择
          contentWidget = SvgPicture.asset("assets/svg/practice_questions/icon_week_checkbox.svg", width: 40.wMin);
        }else if(type == 3){ // 礼物
          contentWidget = SvgPicture.asset("assets/svg/practice_questions/icon_week_gift.svg", width: 40.wMin);
        }
        return Container(
          width: itemWidth,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: circleWidth,
                height: circleWidth,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: type == 0 ? AppTheme.cWhiteAlpha10 : Colors.transparent,
                ),
                child: contentWidget,
              ),
              SizedBox(height: 8.wMin),
              AutoSizeText(
                week,
                style: TextStyle(
                  fontSize: 16.wMin,
                  color: AppTheme.cTextPrimary,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        );
      }

      return IgnorePointer(
        ignoring: controller.currentPageIndex.value > 2,
        child: ExerciseCompletedCardbox(
          show: controller.currentPageIndex.value > 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Image.asset("assets/images/practice_questions/fire.png", height: 160.wMin),
              SizedBox(height: 32.wMin),
              AnimationLimiter(
                child: Column(
                  children: [
                    ListAnimationWidget(
                      index: 0,
                      child: Container(
                        width: 494.wMin,
                        padding: EdgeInsets.symmetric(vertical: 20.wMin, horizontal: 24.wMin),
                        decoration: BoxDecoration(
                          color: AppTheme.cBgTertiary,
                          borderRadius: BorderRadius.circular(16.wMin),
                        ),
                        child: Stack(
                          children: [
                            Container(
                              width: itemWidth * 3 - ((itemWidth - circleWidth) / 2) * 2,
                              height: 40.wMin,
                              margin: EdgeInsets.only(left: (itemWidth + (itemWidth - circleWidth) / 2) * 1),
                              decoration: BoxDecoration(
                                color: AppTheme.cTransparentBrand2.withValues(alpha: 1),
                                borderRadius: BorderRadius.circular(50.wMin),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                buildContinuousLearningWeekItem("周日", 6, 0),
                                buildContinuousLearningWeekItem("周一", 7, 1),
                                buildContinuousLearningWeekItem("周二", 8, 1),
                                buildContinuousLearningWeekItem("周三", 9, 2),
                                buildContinuousLearningWeekItem("周四", 10, 0),
                                buildContinuousLearningWeekItem("周五", 11, 0),
                                buildContinuousLearningWeekItem("周六", 12, 3),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24.wMin),
                    ListAnimationWidget(
                      index: 1,
                      child: Text.rich(TextSpan(
                        style: TextStyle(
                          fontSize: 36.wMin,
                          color: AppTheme.cTextSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                        children: const [
                          TextSpan(text: "你连续学习了"),
                          TextSpan(
                            text: " 3 ",
                            style: TextStyle(
                              color: AppTheme.cTextBrand,
                            ),
                          ),
                          TextSpan(text: "天!"),
                        ],
                      )),
                    ),
                    SizedBox(height: 8.wMin),
                    ListAnimationWidget(
                      index: 2,
                      child: AutoSizeText(
                        "继续努力，如果明天不学，你连续学习的记录会被重置。",
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        minFontSize: 6,
                        style: TextStyle(
                          fontSize: 20.wMin,
                          color: AppTheme.cTextSecondary,
                          fontWeight: FontWeight.w500,
                          height: 1.27,
                        ),
                      ),
                    ),
                    SizedBox(height: 60.wMin),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 45.wMin),
                      child: ContinueButtonWidget(
                        width: 400.wMin,
                        onTap: () {
                          controller.switchPage();
                        },
                      ),
                    ),
                  ],
                ),
              ),
        
            ],
          ),
        ),
      );
    }

    /// 开始下一课
    Widget buildNext(){
      return IgnorePointer(
        ignoring: controller.currentPageIndex.value > 3,
        child: ExerciseCompletedCardbox(
          show: controller.currentPageIndex.value > 2,
          child: AnimationLimiter(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                LessonCircleWidget(
                  child: Container(
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 24.wh),
                ListAnimationWidget(
                  index: 0,
                  child: Text(
                    "开始下一课",
                    style: TextStyle(
                      fontSize: 36.wMin,
                      color: AppTheme.cTextPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: 16.wMin),
                ListAnimationWidget(
                  index: 1,
                  child: Text(
                    "主要学习日常生活中基础描述性的句型",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24.wMin,
                      color: AppTheme.cTextPrimary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                SizedBox(height: 4.wMin),
                ListAnimationWidget(
                  index: 2,
                  child: Text(
                    "主题涉及日常活动、数字、颜色",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20.wMin,
                      color: AppTheme.cTextTertiary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                SizedBox(height: 30.wMin),
                ListAnimationWidget(
                  index: 3,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset("assets/svg/practice_questions/icon_clock.svg", width: 24.wMin),
                      SizedBox(width: 8.wMin),
                      Text(
                        "时长：6分钟",
                        style: TextStyle(
                          fontSize: 20.wMin,
                          color: AppTheme.cTextBrand,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 45.wMin),
                  child: ContinueButtonWidget(
                    width: 400.wMin,
                    text: "开始学习",
                    onTap: () {
                      controller.switchPage();
                      // Get.back(result: true);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget buildCompletedWidget(){

      Widget buildCompletedItemWidget(String name, String val, int index){

        return ListAnimationWidget(
          index: index,
          child: Container(
            width: 494.wMin,
            padding: EdgeInsets.symmetric(horizontal: 20.wMin, vertical: 20.wMin),
            decoration: BoxDecoration(
              color: AppTheme.cBgTertiary,
              borderRadius: BorderRadius.circular(12.wMin),
              border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 24.wMin,
                    color: AppTheme.cTextPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      val,
                      style: TextStyle(
                        fontSize: 24.wMin,
                        color: AppTheme.cTextPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 6.wMin),
                    ShadowStarWidget(size: 28.wMin),
                  ],
                ),
              ],
            ),
          ),
        );
      }


      return ExerciseCompletedCardbox(
        show: controller.currentPageIndex.value > 3,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              "课时已完成",
              style: TextStyle(
                fontSize: 36.wMin,
                color: AppTheme.cTextPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 40.wMin),
            buildCompletedItemWidget("星数", "+10", 0),
            SizedBox(height: 16.wMin),
            buildCompletedItemWidget("正确率", "95%", 1),
            SizedBox(height: 160.wMin),
            Container(
              padding: EdgeInsets.symmetric(vertical: 45.wMin),
              child: Row(
                spacing: 12.wMin,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ButtonWidget(
                      text: "超额学习",
                      height: 64.wMin,
                      borderRadius: 12.wMin,
                      color: AppTheme.cWhiteAlpha10,
                      fontSize: 24.wMin,
                      fontWeight: FontWeight.w500,
                      fontColor: AppTheme.cTextBrand,
                      sclae: 1.02,
                      onTap: () {
                        Get.back(result: true);
                      },
                    ),
                  ),
                  Expanded(
                    child: ContinueButtonWidget(
                      text: "完成",
                      sclae: 1.02,
                      onTap: () {
                        Get.back(result: true);
                      },
                    ),
                  ),
                ],
              ),
            ),

          ],
        ),
      );
    }


    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          backgroundColor: AppTheme.cBgPrimary,
          body: Center(
            child: Obx((){
              return PageView(
                controller: controller.pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  buildAccuracy(),
                  buildTodayChallenge(),
                  buildContinuousLearning(),
                  buildNext(),
                  buildCompletedWidget(),
                ],
              );
            }),
          ),
        );
      }
    );
  }
}
