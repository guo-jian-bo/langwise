
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/home/controllers/home_controller.dart';
import 'package:langwise/app/modules/home/views/home_card_default_widget.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/utils/utils.dart';
import 'package:lib_common/utils/optimize_utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/widgets/guide_engine/guide_engine.dart';
import '../../../../theme/theme.dart';
import '../model/home_card_exam_blitz_model.dart';
import 'home_common_widget.dart';

class HomeExamBlitzCard extends GetView<HomeController> {
  /// 备考计划 卡片
  const HomeExamBlitzCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      HomeCardEntityItems data = controller.preparationPlanData.value;

      if (!controller.initPreparationPlanTab.value) {
        return HomeCardDefaultWidget(data: data);
      }

      if (data.list == null || (data.list?.isEmpty ?? true)) {
        return HomeCardDefaultWidget(data: data);
      }

      ThemeColorEntity? colors = StyleUtils.getCurrentThemeColors(data.bgColor);
      Color? borderColor = ColorUtils.parseColor(colors?.borderColor);
      LinearGradient? linearGradient = StyleUtils.parseCssLinearGradient(colors?.color);

      return Expanded(
        child: LayoutBuilder(
          builder: (context, constraints) {
            
            return GuideStepWidget(
              id: GuideWidgetIds.homePreparationPlanCard,
              onTap: () async{
                controller.toPreparationPlan(controller.preparationPlanTabIndex.value, context);
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.wMin),
                  border: borderColor == null ? null : Border.all(
                    width: 1.wMin, 
                    color: borderColor,
                  ),
                  gradient: linearGradient,
                ),
                child: buildHavePlan(context),
              ),
            );
          }
        ),
      );
    });
  }

  Widget buildHavePlan(BuildContext context) {
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
                  tabs: controller.preparationPlanList.map((e) => e.data.title).toList(),
                  selectIndex: controller.preparationPlanTabIndex.value,
                  onTap: (p0) {
                    controller.preparationPlanTabIndex.value = p0;
                    controller.preparationPlanTabController?.animateTo(p0);
                  },
                ),
              ),
              HelpIVideoIconWidget(
                padding: EdgeInsets.symmetric(horizontal: 20.wMin),
                helpVideoUrl: controller.preparationPlanData.value.helpVideoUrl,
              ), 
            ],
          );
        }),
        Expanded(
          child: TabBarView(
            controller: controller.preparationPlanTabController,
            // physics: const NeverScrollableScrollPhysics(),
            children: List.generate(controller.preparationPlanList.length, (index){
              return buildPlanItemWidget(controller.preparationPlanList[index], index, context);
            }),
          ),
        ),
      ],
    );
  }


  Widget buildPlanItemWidget(HomeCardExamBlitzListModel data, int index, BuildContext context){
    DateTime examDate = DateFormatUtil.tryParseDate(data.data.data?.examDate)??DateTime.now();
    String examDateStr = DateFormatUtil.formatStrtoStr(data.data.data?.examDate);
    DateTime now = DateTime.now();
    int day = examDate.difference(now).inDays;
    final List<String> weekList = ["一", "二", "三", "四", "五", "六", "日"];
    String week = weekList[examDate.weekday - 1];

    String name = data.data.data?.name??'';
    if(name.length > 10){
      name = "${name.substring(0, 10)}...";
    }

    List<PreparationPlanTimeSlots?> timeSlots = data.data.data?.timeSlots??[];
    PreparationPlanTimeSlots? nowDayData = timeSlots.firstWhereOrNull((element) {
      if(element?.date == null) return false;
      DateTime? date = DateFormatUtil.tryParseDate(element?.date);
      if(date == null) return false;
      return DateFormatUtil.isToday(now, date);
    });

    int nextDay = data.data.data?.nextDay??0;
    String buttonText = "距下次备考还有$nextDay天";

    // if(data.data.data?.isDoing == true){
    //   buttonText = "备考已结束";
    // }else{
      if(nowDayData?.isStart == true){
        if(nowDayData?.currentExerciseId == null){
          buttonText = "立即备考";
        }else{
          buttonText = "继续备考";
        }
      }
    // }

    return Container(
      padding: EdgeInsets.only(top: 0.wMin, right: 24.wMin, bottom: 12.wMin),
      child: Row(
        spacing: 16.wMin,
        children: [
          Expanded(
            flex: 65,
            child: Container(
              alignment: Alignment.centerLeft,
              child: HomeExamBlitzCalendarWidget(
                data: data,
                homeCardLenght: controller.bodyCardList.length,
              ),
            ),
          ),
          Expanded(
            flex: 35,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "距离 $name 考试还有",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18.wMin,
                    color: AppTheme.cTextPrimary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 8.wMin),
                Text(
                  "$day天",
                  style: TextStyle(
                    fontSize: 36.wMin,
                    color: AppTheme.cTextPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.wMin),
                Text(
                  "$examDateStr  周$week",
                  style: TextStyle(
                    fontSize: 18.wMin,
                    color: AppTheme.cTextPrimary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 8.wMin),
                
                ButtonWidget(
                  text: buttonText,
                  height: 48.wMin,
                  borderRadius: 8.wMin,
                  color: AppTheme.cBgBrand.color.withValues(alpha: nowDayData?.isStart == true  ? 1 : 0.5),
                  fontSize: nowDayData?.isStart == true ? 20.wMin : 16.wMin,
                  fontColor: AppTheme.cStaticWhite.color,
                  fontWeight: FontWeight.w500,
                  sclae: 1.05,
                  onTap: OptimizeUtils.noneThrottle(() {
                    if(nowDayData?.isStart != true) return;
                    controller.toPreparationPlanStartPractice(data, context, nowDayData?.currentExerciseId);
                  }, 300),
                ),
    
              ],
            ),
          ),
        ],
      ),
    );
  }
    
}

class HomeExamBlitzCalendarWidget extends StatefulWidget {
  final HomeCardExamBlitzListModel data;
  final int homeCardLenght;
  const HomeExamBlitzCalendarWidget({super.key, required this.data, required this.homeCardLenght});

  @override
  State<HomeExamBlitzCalendarWidget> createState() => _HomeExamBlitzCalendarWidgetState();
}

class _HomeExamBlitzCalendarWidgetState extends State<HomeExamBlitzCalendarWidget> with AutomaticKeepAliveClientMixin{
  late final PageController calendarController;
  final DateTime now = DateTime.now();
  DateTime fistDate = DateTime(2025, 1, 1);
  List<DateTime> dates = [];
  List<PreparationPlanTimeSlots> timeSlotsList = [];

  @override
  void initState() {
    super.initState();

    List<PreparationPlanTimeSlots?> timeSlots = widget.data.data.data?.timeSlots??[];
    for(int i = 0; i < timeSlots.length; i++){
      PreparationPlanTimeSlots? timeSlot = timeSlots[i];
      if(timeSlot == null) continue;
      DateTime? date = DateFormatUtil.tryParseDate(timeSlot.date);
      if(date == null) continue;
      dates.add(date);
      timeSlotsList.add(timeSlot);
    }

    fistDate = dates.first;
    DateTime now = DateTime.now();
    int res = DateUtils.monthDelta(fistDate, now);
    calendarController = PageController(initialPage: res);
  }


  @override
  bool get wantKeepAlive => true;
  
  @override
  Widget build(BuildContext context) {
    super.build(context);

    DateTime examDate = DateFormatUtil.tryParseDate(widget.data.data.data?.examDate)??DateTime.now();
    
    double aspectRatio = 308 / 235;
    if(widget.homeCardLenght == 2){
      aspectRatio = 308 / 120;
    }
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 24.wMin),
          child: Obx((){
            return Text(
              DateFormatUtil.formatToYearMonth(widget.data.calendarCurrentMonth.value, locale: Get.locale),
              style: TextStyle(
                fontSize: widget.homeCardLenght != 1 ? 14.wMin : 26.wMin,
                color: AppTheme.cTextPrimary,
                fontWeight: FontWeight.w400,
              ),
            );
          }),
        ),
        AspectRatio(
          aspectRatio: aspectRatio,
          child: Container(
            alignment: Alignment.center,
            child: Theme(
              data: ThemeData().copyWith(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
              child: CalendarDatePicker2(
                displayedMonthDate: widget.data.calendarCurrentMonth.value,
                value: dates,
                onDisplayedMonthChanged: (value) {
                  widget.data.calendarCurrentMonth.value = value;
                },
                config: CalendarDatePicker2Config(
                  calendarType: CalendarDatePicker2Type.multi,
                  currentDate: DateTime.now(),
                  dayViewController: calendarController,
                  firstDate: fistDate,
                  lastDate: examDate,
                  disableMonthPicker: true,
                  disableModePicker: true,
                  disableVibration: true,
                  allowSameValueSelection: true,
                  hideLastMonthIcon: true,
                  hideNextMonthIcon: true,
                  dayMaxWidth: 80.wMin,
                  hideYearPickerDividers: true,
                  hideScrollViewMonthWeekHeader: true,
                  controlsHeight: 0,
                  daySplashColor: Colors.transparent,
                  selectedDayHighlightColor: Colors.transparent,
                  selectedRangeHighlightColor: Colors.transparent,
                  selectableDayPredicate: (day) => false,
                  dayBuilder: ({required date, decoration, isDisabled, isSelected, isToday, textStyle}) {
                    Color borderColor = Colors.transparent;
                    Color backColor = Colors.transparent;
                    Color textColor = AppTheme.cTextPrimary;
                    bool showBottom = false;
                    
                    if(isToday??false){
                      borderColor = AppTheme.cSurfaceBrand;
                    }
            
                    if(dates.contains(date)){
                      int index = dates.indexOf(date);
                      if(timeSlotsList[index].isWaiting){// 没到复习时间
                        showBottom = true;
                      }else if(timeSlotsList[index].isFinish){ // 复习过了
                        backColor = AppTheme.cFeedbackSuccessBackground.color;
                        textColor = AppTheme.cTextTertiary;
                      }else if(timeSlotsList[index].isStart){ // 未复习
                        if(date.isBefore(now)){ // 已经过了今天
                          backColor = AppTheme.cFeedbackErrorBackground.color;
                          textColor = AppTheme.cFeedbackErrorText;
                        }
                      }
                    }

                    if(date.year == examDate.year && date.month == examDate.month && date.day == examDate.day){
                      backColor = AppTheme.cFeedbackSuccessBackground.color;
                    }
              
                    return Center(
                      child: Container(
                        width: widget.homeCardLenght != 1 ? 35.wMin : 45.wMin,
                        height: widget.homeCardLenght != 1 ? 35.wMin : 45.wMin,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: backColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: borderColor, width: 1.wMin),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Visibility(
                              visible: showBottom,
                              child: Positioned(
                                bottom: 0,
                                child: Container(
                                  width: 16.wMin,
                                  height: 1.wMin,
                                  color: AppTheme.cSurfaceBrand,
                                ),
                              ),
                            ),
                            Text(
                              "${date.day}",
                              style: textStyle?.copyWith(color: textColor),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  weekdayLabelTextStyle: TextStyle(
                    color: AppTheme.cTextTertiary,
                    fontSize: widget.homeCardLenght != 1 ? 14.wMin : 16.wMin,
                    fontWeight: FontWeight.w500,
                  ),
                  dayTextStyle: TextStyle(
                    color: AppTheme.cTextPrimary,
                    fontSize: widget.homeCardLenght != 1 ? 16.wMin : 24.wMin,
                    fontWeight: FontWeight.w500,
                  ),
                  todayTextStyle: TextStyle(
                    color: AppTheme.cTextPrimary,
                    fontSize: widget.homeCardLenght != 1 ? 16.wMin : 24.wMin,
                    fontWeight: FontWeight.w500,
                  ),
                  selectedDayTextStyle: TextStyle(
                    color: AppTheme.cTextPrimary,
                    fontSize: widget.homeCardLenght != 1 ? 16.wMin : 24.wMin,
                    fontWeight: FontWeight.w500,
                  ),
                  disabledDayTextStyle: TextStyle(
                    color: AppTheme.cTextPrimary,
                    fontSize: widget.homeCardLenght != 1 ? 16.wMin : 24.wMin,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                
              ),
            ),
          ),
        ),
      ],
    );
  }
  
}
