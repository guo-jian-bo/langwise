import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/painter/text_line_paint.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';
import '../../../../utils/utils.dart';
import '../super_memo_calender/controllers/super_memo_calender_controller.dart';

class TodayPlanCalenderWidget extends GetView<SuperMemoCalenderController> {
  const TodayPlanCalenderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 72.wMin),
        child: Row(
          children: [
            _buildTitleWidget(context),
            SizedBox(width: 16.wMin),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 16.wMin),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.wMin),
                  color: AppTheme.cBgSecondary.color,
                ),
                child: Column(
                  children: [
                    _buildHeaderWidget(),
                    SizedBox(height: 16.wMin),
                    Expanded(
                      child: Stack(
                        children: [
                          _buildCalendarWidget(),
                          Obx(() {
                            if (!controller.calendarLoading.value) return Container();
                            return Container(
                              alignment: Alignment.center,
                              color: Colors.transparent,
                              child: SpinKitFadingCircle(
                                color: AppTheme.cBgBrand,
                                size: 100.wMin,
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleWidget(BuildContext context) {
    return Container(
      width: 500.wMin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.wMin),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xffF97316).withValues(alpha: 0.2),
            const Color(0xffF97316).withValues(alpha: 0.1),
          ],
        ),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              SvgPicture.asset(
                "assets/svg/today_plan/memory_title.svg",
                width: 310.wMin,
              ),
              SizedBox(height: 20.wMin),
              Row(
                spacing: 12.wMin,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "安排计划学习时间",
                    style: TextStyle(
                      fontSize: 32.wMin,
                      color: AppTheme.cTextPrimary.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Builder(
                    builder: (ctx) {
                      return TapScaleWidget(
                        onTap: () {
                          controller.tapCalenderAllDuration(ctx);
                        },
                        sclae: 1.05,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 2.wMin),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.wMin),
                            border: Border.all(
                              width: 1.wMin,
                              color: AppTheme.cFeedbackWarningBorder.color,
                            ),
                          ),
                          child: Obx(() {
                            int allDuration = 0;
                            for (StudyPlanEntityPlanCourses item in controller.planCoursesList) {
                              allDuration += item.dailyStudyDuration ?? 0;
                            }

                            return Text(
                              (allDuration / 60).toInt().toString(),
                              style: TextStyle(
                                fontSize: 32.wMin,
                                color: AppTheme.cFeedbackWarningText.color,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          }),
                        ),
                      );
                    },
                  ),
                  Text(
                    "分钟",
                    style: TextStyle(
                      fontSize: 32.wMin,
                      color: AppTheme.cTextPrimary.color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32.wMin),
              CustomPaint(
                  size: Size(452.wMin, 1.wMin), painter: HorizontalDashedLinePainter(color: const Color(0x33FFFFFF), strokeWidth: 1.wMin, dashWidth: 8.wMin, dashGap: 6.wMin)),
              SizedBox(height: 32.wMin),
              _buildIconTextWidget("assets/svg/public/icon_out_fire.svg", "连续记忆", "${controller.studyPlanCalendar.value.continueMemoryDay ?? 0} 天"),
              SizedBox(height: 16.wMin),
              _buildIconTextWidget("assets/svg/public/icon_out_calendar.svg", "总记忆", "${controller.studyPlanCalendar.value.totalMemoryDay ?? 0} 天"),
              SizedBox(height: 16.wMin),
              _buildIconTextWidget("assets/svg/public/icon_out_memory.svg", "总复习", "${controller.studyPlanCalendar.value.totalMemoryContentCount ?? 0} 个"),
            ],
          ),
          Positioned(
            right: 12.wMin,
            top: 12.wMin,
            child: Builder(builder: (ctx) {
              return TapScaleWidget(
                onTap: () {
                  controller.showCalenderTip(ctx);
                },
                sclae: 1.05,
                child: SvgPicture.asset(
                  "assets/svg/public/icon_info.svg",
                  width: 44.wMin,
                  colorFilter: ColorFilter.mode(AppTheme.cFeedbackDefaultIcon.color, BlendMode.srcIn),
                ),
              );
            }),
          ),
          // Positioned(
          //   left: 16.wMin,
          //   top: 16.wMin,
          //   child: Builder(builder: (ctx) {
          //     return TapScaleWidget(
          //         onTap: () {
          //           controller.showWishDialog(ctx);
          //         },
          //         sclae: 1.05,
          //         child: Container(
          //           padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 8.wMin),
          //           decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.wMin), color: AppTheme.cFeedbackWarningBackground),
          //           child: Text("我的心愿",style: TextStyle(
          //             fontSize: 32.wMin,
          //             color: AppTheme.cFeedbackWarningText.color,
          //             fontWeight: FontWeight.w600
          //           ))
          //         ));
          //   }),
          // ),
        ],
      ),
    );
  }

  Widget _buildHeaderWidget() {
    return Row(
      spacing: 16.wMin,
      children: [
        Obx(() {
          return Text(
            DateFormatUtil.formatToYearMonth(controller.calendarCurrentDate.value, locale: Get.locale),
            style: TextStyle(
              fontSize: 24.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w600,
            ),
          );
        }),
        TapScaleWidget(
          child: _buildArrowWidget("assets/svg/public/icon_w_arrow_left.svg"),
          sclae: 1.1,
          onTap: () {
            controller.calendarController?.previousPage(
              duration: const Duration(milliseconds: 200),
              curve: Curves.linear,
            );
          },
        ),
        TapScaleWidget(
          child: _buildArrowWidget("assets/svg/public/icon_w_arrow_right.svg"),
          sclae: 1.1,
          onTap: () {
            controller.calendarController?.nextPage(
              duration: const Duration(milliseconds: 200),
              curve: Curves.linear,
            );
          },
        ),
        const Spacer()
      ],
    );
  }

  Widget _buildArrowWidget(String svg) {
    return Container(
      color: Colors.transparent,
      width: 64.wMin,
      height: 64.wMin,
      alignment: Alignment.center,
      child: SvgPicture.asset(
        svg,
        width: 38.wMin,
        colorFilter: ColorFilter.mode(AppTheme.cTextSecondary.color, BlendMode.srcIn),
      ),
    );
  }

  Widget _buildIconTextWidget(String svg, String text, String tailTxt) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.wMin),
      padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 21.wMin),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.wMin), color: Colors.white.withAlpha(13)),
      child: Row(
        children: [
          SvgPicture.asset(
            svg,
            width: 24.wMin,
          ),
          SizedBox(width: 4.wMin),
          Text(
            text,
            style: TextStyle(
              fontSize: 20.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w500,
            ),
          ),
          Spacer(),
          Text(
            tailTxt,
            style: TextStyle(
              fontSize: 20.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarWidget() {
    return TableCalendar(
      onCalendarCreated: (pageController) {
        controller.calendarController = pageController;
      },
      focusedDay: controller.calendarCurrentDate.value,
      firstDay: controller.calendarMinDate,
      onPageChanged: (focusedDay) {
        controller.calendarCurrentDate.value = focusedDay;
        controller.getPlanCalendarList();
      },
      lastDay: DateTime.now().add(const Duration(days: 365)),
      headerVisible: false,
      daysOfWeekHeight: 44.wMin,
      shouldFillViewport: true,
      sixWeekMonthsEnforced: true,
      daysOfWeekStyle: DaysOfWeekStyle(
        // 周的样式
        dowTextFormatter: (date, locale) {
          int week = date.weekday;
          return DateFormatUtil.getWeekStrForInt(week);
        },
        weekdayStyle: TextStyle(
          fontSize: 20.wMin,
          color: AppTheme.cTextTertiary.color,
          fontWeight: FontWeight.w500,
        ),
        weekendStyle: TextStyle(
          fontSize: 20.wMin,
          color: AppTheme.cTextTertiary.color,
          fontWeight: FontWeight.w500,
        ),
      ),
      calendarStyle: CalendarStyle(
        tableBorder: TableBorder.all(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
        markerMargin: EdgeInsets.zero,
        cellMargin: EdgeInsets.zero,
      ),
      calendarBuilders: CalendarBuilders(
        prioritizedBuilder: (context, day, focusedDay) {
          return _buildDayWidget(day);
        },
      ),
    );
  }

  Widget _buildDayWidget(DateTime date) {
    return Obx(() {
      List<StudyPlanCalendarEntityList> list = controller.calendarPlanList.toList();

      StudyPlanCalendarEntityList? thisDay = list.firstWhereOrNull((e) => DateFormatUtil.isToday(e.dayDate, date));

      DateTime now = DateTime.now();
      bool isToday = DateFormatUtil.isToday(date, now); //今天
      bool isAfter = date.isAfter(now); // 是否在今天之后
      DateTime current = controller.calendarCurrentDate.value;
      bool isOutside = date.year != current.year || date.month != current.month; //不是本月

      Widget child = Container();

      if (isToday) {
        child = _buildCalenderTodayWidget(thisDay);
      } else if (isAfter) {
        child = _buildCalenderAfterWidget(thisDay);
      } else {
        child = _buildCalenderSuccessWidget(thisDay, isOutside);
      }

      return TapScaleWidget(
        onTap: isAfter || isToday || ((thisDay?.contentList?.length ?? 0) == 0)
            ? null
            : () {
                controller.toMemoryCardList(thisDay);
              },
        sclae: 1,
        child: Container(
          padding: EdgeInsets.all(8.wMin),
          width: double.infinity,
          color: isOutside ? AppTheme.cBgTertiary.color : null,
          child: Opacity(
            opacity: isOutside ? 0.6 : 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "${date.day}",
                      style: TextStyle(
                        fontSize: 20.wMin,
                        color: AppTheme.cTextTertiary.color,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const Spacer(),
                    Visibility(
                      visible: (!isToday && !isAfter && (thisDay?.contentList?.length ?? 0) != 0) && (thisDay?.missionStarCount ?? 0) != 0,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "${thisDay?.missionStarCount ?? 0}",
                            style: TextStyle(
                              fontSize: 20.wMin,
                              color: AppTheme.cTextPrimary.color,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Image.asset(
                            "assets/images/public/icon_star.webp",
                            width: 24.wMin,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Container(alignment: Alignment.center, child: child),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildCalenderTodayWidget(StudyPlanCalendarEntityList? thisDay) {
    return Stack(
      children: [
        const SizedBox(
          width: double.infinity,
          height: double.infinity,
        ),
        Positioned(
          top: 30.wMin,
          child: Transform.rotate(
            angle: -0.5,
            child: Container(
              width: 114.wMin,
              height: 1.wMin,
              color: AppTheme.cBorderSecondary.color,
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          child: Text(
            thisDay?.exerciseAlreadyCount?.toString() ?? "0",
            style: TextStyle(
              fontSize: 28.wMin,
              color: AppTheme.cFeedbackWarningText.color,
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Text(
            thisDay?.exerciseCount?.toString() ?? "0",
            style: TextStyle(
              fontSize: 28.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalenderAfterWidget(StudyPlanCalendarEntityList? thisDay) {
    return Text(
      thisDay?.contentCount?.toString() ?? "0",
      style: TextStyle(
        fontSize: 32.wMin,
        color: AppTheme.cTextTertiary.color,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildCalenderSuccessWidget(StudyPlanCalendarEntityList? thisDay, bool isOutside) {
    if ((thisDay?.contentList?.length ?? 0) == 0) {
      return SvgPicture.asset(
        "assets/svg/public/x.svg",
        width: 32.wMin,
        colorFilter: ColorFilter.mode(AppTheme.cFeedbackErrorIcon.color, BlendMode.srcIn),
      );
    }
    return Text(
      thisDay?.contentCount?.toString() ?? "0",
      style: TextStyle(
        fontSize: 32.wMin,
        color: AppTheme.cFeedbackSuccessText.color,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
