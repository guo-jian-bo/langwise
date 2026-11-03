



import 'package:bubble_box/bubble_box.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/home/controllers/home_controller.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:themed/themed.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/widgets/guide_engine/guide_engine.dart';
import '../../../../common/widgets/line_chart_widget.dart';
import '../../../../utils/utils.dart';
import '../model/home_card_study_play_model.dart';
import 'home_card_default_widget.dart';
import 'home_common_widget.dart';

class HomeStudyPlanCard extends GetView<HomeController> {
  /// 学习计划 卡片
  const HomeStudyPlanCard({super.key});

  @override
  Widget build(BuildContext context) {

    return Obx(() {
      HomeCardEntityItems data = controller.studyPlanData.value;
      if(!controller.initStudyPlanTab.value){
        return HomeCardDefaultWidget(data: data);
      }

      if(controller.studyPlanList.isEmpty){
        return HomeCardDefaultWidget(data: data);
      }

      ThemeColorEntity? colors = StyleUtils.getCurrentThemeColors(data.bgColor);
      Color? borderColor = ColorUtils.parseColor(colors?.borderColor);
      LinearGradient? linearGradient = StyleUtils.parseCssLinearGradient(colors?.color);

      return Expanded(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return GuideStepWidget(
              id: GuideWidgetIds.homePlanCard,
              onTap: () async{
                controller.toStudyPlan(context);
              },
              sclae: 1,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.wMin),
                  border: borderColor == null ? null : Border.all(
                    width: 1.wMin, 
                    color: borderColor,
                  ),
                  gradient: linearGradient,
                ),
                child: buildHavePlanWidget(context),
              ),
            );
          }
        ),
      );
    });
  }

  Widget buildHavePlanWidget(BuildContext context){
    HomeCardStudyPlayModelData? firstData = controller.studyPlanList.first.data;
    // 每日学习时长 (分钟)
    int dailyDuration = (firstData?.dailyDuration??0) ~/ 60;
    // 总学习时长 (小时)
    double totalDuration = (firstData?.totalStudyDuration??0) / 60 / 60;
    // 连胜天数 (天)
    int consecutiveStudyStreak = firstData?.consecutiveStudyStreak??0;
    // 连续学习(周)
    // int consecutiveStudyWeek = (firstData?.totalStudyDay??0) ~/ 7;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24.wMin),
        Obx((){
          return Row(
            children: [
              Expanded(
                child: HomeCardTabbarWidget(
                  padding: EdgeInsets.symmetric(horizontal: 24.wMin),
                  tabs: controller.studyPlanList.map((e) => e.title).toList(),
                  selectIndex: controller.studyPlanTabIndex.value,
                  onTap: (p0) {
                    controller.studyPlanTabIndex.value = p0;
                    controller.studyPlanTabController?.animateTo(p0);
                  },
                ),
              ),
              // HelpIVideoIconWidget(
              //   padding: EdgeInsets.symmetric(horizontal: 20.wMin),
              //   helpVideoUrl: controller.studyPlanData.value.helpVideoUrl,
              // ), 
            ],
          );
        }),
        SizedBox(height: 16.wMin),
        Expanded(
          child: Container(
            padding: EdgeInsets.only(top: 24.wMin, left: 24.wMin, right: 24.wMin),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 6,
                  child: TabBarView(
                    controller: controller.studyPlanTabController,
                    // clipBehavior: Clip.none,
                    children: List.generate(controller.studyPlanList.length, (index){
                      return lineChartItem(index);
                    }),
                  ),
                ),
                SizedBox(width: 12.wMin),
                Expanded(
                  flex: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          textItem(dailyDuration.toString(), "分钟", "今日学习时长"),
                          textItem(totalDuration.toStringAsFixed(1), "小时", "总学习时长"),
                        ],
                      ),
                      SizedBox(height: 20.wMin),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          textItem(consecutiveStudyStreak.toString(), "天", "连续"),
                          // textItem(consecutiveStudyWeek.toString(), "周", "总学习"),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 24.wMin),
      ],
    );
  }

  Widget textItem(String val, String name, String name1){
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                val,
                style: TextStyle(
                  fontSize: 24.wMin,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.cTextPrimary,
                  height: 1.1,
                ),
              ),
              Text(
                name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.wMin,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.cTextPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 5.wMin),
          Text(
            name1,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextPrimary.addOpacity(0.4),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Size? _getTextSize(String? text) {
    if(text == null) return null;
    final TextStyle textStyle = TextStyle(
      fontSize: 10.wMin,
      fontWeight: FontWeight.w400,
      color: AppTheme.cStaticBlack,
    );

    // 获取文字的宽度
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    double width = textPainter.size.width + 10.wMin;
    if(width < 51.wMin) width = 51.wMin;
    if(width > 120.wMin) width = 120.wMin;
    return Size(width, 21.wMin);
  }

  Widget lineChartItem(int index){
    String? nextUnit = controller.studyPlanList[index].data?.nextUnit;
    Size? textSize = _getTextSize(nextUnit??"下一级别");

    return Container(
      alignment: Alignment.topCenter,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return HeroWidget(
            tag: "HomeStudyPlanChart$index",
            child: LineChartWidget(
              nextText: nextUnit,
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              strokeWidth: 3.wMin,
              strokeColor: AppTheme.cTextPrimary.withValues(alpha: 0.2),
              padding: EdgeInsets.only(
                top: 40.wMin, 
                left: 20.wMin, 
                right: 10.wMin + (textSize?.width??0) / 2, 
                bottom: 20.wMin,
              ),
              dotSize: 10.wMin,
              nowSize: Size(31.wMin, 21.wMin),
              nextSize: textSize??Size(51.wMin, 21.wMin),
              bubbleFontSize: 10.wMin,
              shape: BubbleShapeBorder(
                direction: BubbleDirection.bottom,
                arrowQuadraticBezierLength: 4.wMin,
                radius: BorderRadius.circular(4.wMin),
                arrowHeight: 8.wMin,
                arrowAngle: 4.wMin,
                smooth: 0,
              ),
              lineData: [],
            ),
          );
        },
      ),
    );
  }

}

