import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';
import '../../../../common/entities/entities.dart';
import '../../../../common/widgets/hero_widget.dart';
import '../../../../common/widgets/line_chart_widget.dart';
import '../../../../theme/theme.dart';
import '../controllers/today_plan_controller.dart';

class TodayPlanPlan extends GetView<TodayPlanController> {
  final StudyPlanEntityPlanCourses data;
  final int index;
  const TodayPlanPlan({super.key, required this.data, required this.index});

  @override
  Widget build(BuildContext context) {

    return LayoutBuilder(
      builder: (context, constraints) {
        return CardNeatBoxWidget(
          height: 923.wMin,
          borderRadius: 16.wMin,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _buildTitleWidget(context),
              // SizedBox(height: 8.wMin),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 24.wMin),
                      child: Column(
                        children: [
                          buildLineChart(),
                          SizedBox(height: 16.wMin),
                          buildSetUp(),
                          SizedBox(height: 16.wMin),
                          ListAnimationWidget(
                            index: controller.todayPlanPageIndex == index? 1 : 0,
                            delay: const Duration(milliseconds: 1000),
                            child: Column(
                              spacing: 8.wMin,
                              children: [
                                Text(
                                  "继续努力，预计 ${data.nextUnitDay??0}天后到达你的下一个级别",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 24.wMin,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.cTextPrimary,
                                  ),
                                ),
                                Visibility(
                                  visible: data.nextUnit != null,
                                  child: Text(
                                    "下一个级别:${data.nextUnit??""}",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 18.wMin,
                                      fontWeight: FontWeight.w400,
                                      color: AppTheme.cTextBrand,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 24.wMin),
                        ],
                      ),
                    ),

                    Visibility(
                      visible: data.pause == true,
                      child: _buildPauseOverlayWidget(context),
                    ),

                  ],
                ),
              ),
              
            ],
          ),
        );
      }
    );
  }
  

  /// 暂停蒙层
  Widget _buildPauseOverlayWidget(BuildContext context){
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.cBlackAlpha70.color.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16.wMin),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "该计划已暂停",
            style: TextStyle(
              fontSize: 32.wMin,
              fontWeight: FontWeight.w600,
              color: AppTheme.cTextSecondary.color,
            ),
          ),
          SizedBox(height: 16.wMin),
          ButtonWidget(
            text: "立即恢复",
            color: AppTheme.cFeedbackSuccessBackground.color,
            borderRadius: 12.wMin,
            width: 144.wMin,
            height: 56.wMin,
            fontColor: AppTheme.cFeedbackSuccessText.color,
            fontSize: 24.wMin,
            fontWeight: FontWeight.w600,
            sclae: 1.05,
            onTap: () {
              controller.pauseRecoverPlan(context, data);
            },
          ),
          SizedBox(height: 16.wMin),
          Visibility(
            visible: data.resumeDate != null,
            child: Text(
              "计划将于${data.resumeDate??""}恢复",
              style: TextStyle(
                fontSize: 24.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextSecondary.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleWidget(BuildContext context){
    
    String? planStartStr;
    if(data.currentUnitInfo?.levelName != null && data.currentUnitInfo?.moduleName != null && data.currentUnitInfo?.unitName != null){
      planStartStr = "${data.currentUnitInfo?.levelName} / ${data.currentUnitInfo?.moduleName} / ${data.currentUnitInfo?.unitName}";
    }

    return Container(
      padding: EdgeInsets.only(left: 24.wMin, right: 24.wMin, top: 24.wMin),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(bottom: 8.wMin),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4.wMin,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        data.courseName??"",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 28.wMin,
                          color: AppTheme.cTextPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 8.wMin),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 4.wMin),
                        decoration: BoxDecoration(
                          color: data.pause == true ? AppTheme.cFeedbackWarningBackground.color : AppTheme.cFeedbackSuccessBackground.color,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          data.pause == true ? "已暂停" : "进行中",
                          style: TextStyle(
                            fontSize: 22.wMin,
                            color: data.pause == true ? AppTheme.cFeedbackWarningText.color : AppTheme.cFeedbackSuccessText.color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    planStartStr??"",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 24.wMin,
                      color: AppTheme.cTextPrimary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 8.wMin),
          ButtonWidget(
            text: data.pause == true ? "恢复" : "暂停",
            color: data.pause == true ? AppTheme.cFeedbackSuccessBackground.color : AppTheme.cFeedbackWarningBackground.color,
            borderRadius: 8.wMin,
            padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 6.wMin),
            fontColor: data.pause == true ? AppTheme.cFeedbackSuccessText.color : AppTheme.cFeedbackWarningText.color,
            fontSize: 24.wMin,
            fontWeight: FontWeight.w400,
            sclae: 1.05,
            onTap: () {
              controller.pauseRecoverPlan(context, data);
            },
          ),
          SizedBox(width: 12.wMin),
          ButtonWidget(
            text: "编辑",
            color: AppTheme.cFeedbackInfoBackground,
            borderRadius: 8.wMin,
            padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 6.wMin),
            fontColor: AppTheme.cFeedbackInfoText,
            fontSize: 24.wMin,
            fontWeight: FontWeight.w400,
            sclae: 1.05,
            onTap: () {
              controller.toEditPlan(data, context,-1);
            },
          ),
        ],
      ),
    );
  }

  Size? _getTextSize(String? text) {
    if(text == null) return null;
    final TextStyle textStyle = TextStyle(
      fontSize: 18.wMin,
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
    if(width < 100.wMin) width = 100.wMin;
    if(width > 200.wMin) width = 200.wMin;
    return Size(width, 43.wMin);
  }

  Widget buildLineChart(){
    Size? size = _getTextSize(data.nextUnit);
    return HeroWidget(
      tag: "HomeStudyPlanChart$index",
      child: Container(
        width: 538.wMin,
        height: 330.wMin,
        padding: EdgeInsets.all(16.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.wMin),
          color: AppTheme.cBgTertiary,
        ),
        child: LineChartWidget(
          nextText: data.nextUnit,
          duration: Duration(milliseconds: controller.todayPlanPageIndex == index ? 500 : 0),
          delay: Duration(milliseconds: controller.todayPlanPageIndex == index ? 300 : 0),
          width: 538.wMin - 32.wMin,
          height: 330.wMin - 32.wMin,
          strokeWidth: 4.wMin,
          strokeColor: AppTheme.cTextPrimary.withValues(alpha: 0.2),
          padding: EdgeInsets.only(top: 90.wMin, left: 40.wMin, right: 42.wMin, bottom: 20.wMin),
          dotSize: 20.wMin,
          nowSize: Size(73.wMin, 43.wMin),
          nextSize: size??Size(93.wMin, 43.wMin),
          bubbleFontSize: 18.wMin,
          lineData: [],
        ),
      ),
    );
  }

  Widget buildSetUpTimes(String name, List<String> list){
    return CardMinBox1Widget(
      padding: EdgeInsets.zero,
      child: Container(
        padding: EdgeInsets.all(10.wMin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AutoSizeText(
              name,
              minFontSize: 4,
              maxLines: 1,
              style: TextStyle(
                fontSize: 20.wMin,
                fontWeight: FontWeight.w400,
                color: AppTheme.cTextPrimary,
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: list.length,
                padding: EdgeInsets.symmetric(vertical: 10.wMin),
                separatorBuilder: (context, index) => SizedBox(height: 7.68.wMin),
                itemBuilder: (context, index) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.wMin),
                    width: double.infinity,
                    height: 40.wMin,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.wMin),
                      color: AppTheme.cBgQuaternary,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SvgPicture.asset("assets/svg/today_plan/icon_clock.svg", width: 18.wMin),
                        Text(
                          list[index],
                          style: TextStyle(
                            fontSize: 18.wMin,
                            fontWeight: FontWeight.w400,
                            color: AppTheme.cTextPrimary,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSetUp(){
    List<StudyPlanEntityPlanCoursesPlans?> plans = data.plans??[];
    List<String> workList = [];
    List<String> restList = [];
    for(int i = 0; i < plans.length; i++){
      if(plans[i] == null) continue;
      if(plans[i]!.type == null) continue;

      List<StudyPlanEntityPlanCoursesPlansTimes?> times = plans[i]!.times??[];
      for(int j = 0; j < times.length; j++){
        if(times[j] == null) continue;
        int hour = times[j]!.hour??0;
        int minute = times[j]!.minute??0;
        String time = DateFormatUtil.hsToLocaleTime(hour, minute, locale: Get.locale);
        
        if(plans[i]!.type == "work"){
          workList.add(time);
        }else if(plans[i]!.type == "rest"){
          restList.add(time);
        }
      }
    }

    return Expanded(
      child: Row(
        spacing: (workList.isNotEmpty || restList.isNotEmpty) ? 16.wMin : 0,
        children: [
          Expanded(
            child: CardMinBox1Widget(
              padding: EdgeInsets.zero,
              child: SizedBox(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${(data.dailyStudyDuration??0) ~/ 60}",
                      style: TextStyle(
                        fontSize: 64.wMin,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.cTextPrimary,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      "分钟",
                      style: TextStyle(
                        fontSize: 18.wMin,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.cTextSecondary,
                      ),
                    ),
                    Text(
                      "每日计划时长",
                      style: TextStyle(
                        fontSize: 18.wMin,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.cTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Visibility(
            visible: workList.isNotEmpty,
            child: Expanded(
              child: buildSetUpTimes("工作日", workList),
            ),
          ),
          Visibility(
            visible: restList.isNotEmpty,
            child: Expanded(
              child: buildSetUpTimes("休息日", restList),
            ),
          ),
        ],
      ),
    );
  }
}
