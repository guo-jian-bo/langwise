import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/entities/entities.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/utils.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../controllers/mission_control_center_study_plan_calendar_controller.dart';

class MissionControlCenterStudyPlanCalendarView extends GetView<MissionControlCenterStudyPlanCalendarController> {
  final String tagText;
  const MissionControlCenterStudyPlanCalendarView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Padding(
        padding: EdgeInsets.fromLTRB(90.wMin, 0, 90.wMin, 15.wMin),
        child: Column(
          children: [
            _buildSummaryBar(),
            SizedBox(height: 16.wMin),
            _buildHeader(),
            SizedBox(height: 16.wMin),
            Expanded(
              child: Column(
                children: [
                  
             
                  Expanded(
                    child: Stack(
                      children: [
                        _buildCalendar(),
                        if (controller.calendarLoading.value)
                          Positioned.fill(
                            child: Container(
                              color: AppTheme.cBgPrimary.color.withValues(alpha: 0.24),
                              alignment: Alignment.center,
                              child: SpinKitFadingCircle(
                                color: AppTheme.cBgBrand,
                                size: 72.wMin,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSummaryBar() {
    final totalKnowledge = controller.studyPlanCalendar.value.totalMemoryContentCount ?? 0;
    final totalDuration = ((controller.studyPlanCalendar.value.totalDuration ?? 0) / 60).round();
    final totalStars = controller.studyPlanCalendar.value.totalStars ?? 0;
    final totalDiamond = controller.studyPlanCalendar.value.totalDiamond ?? 0;
    final totalMemoryDay = controller.studyPlanCalendar.value.totalMemoryDay ?? 0;
    final continueMemoryDay = controller.studyPlanCalendar.value.continueMemoryDay ?? 0;

    return Container(
      height: 80.wMin,
      padding: EdgeInsets.symmetric(horizontal: 12.wMin, vertical: 12.wMin),
      decoration: BoxDecoration(
        

        borderRadius: BorderRadius.circular(16.wMin),
        border: Border.all(
          color: AppTheme.cBgTertiary.color,
          width: 1.wMin,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryItem(
              label: '总知识',
              value: '$totalKnowledge',
              unit: '个',
              color: const Color(0xFF38BDF8),
              icon: SvgPicture.asset(
                'assets/svg/mission/icon_calendar_konw.svg',
                width: 16.wMin,
                height: 16.wMin,
              ),
            ),
          ),
          _buildSummaryDivider(),
          Expanded(
            child: _buildSummaryItem(
              label: '总时长',
              value: '$totalDuration',
              unit: '分钟',
              color: const Color(0xFF60A5FA),
              icon: SvgPicture.asset(
                'assets/svg/mission/icon_calendar_time.svg',
                width: 16.wMin,
                height: 16.wMin,
              ),
            ),
          ),
          _buildSummaryDivider(),
          Expanded(
            child: _buildSummaryItem(
              label: '总星星',
              value: '$totalStars',
              unit: '个',
              color: const Color(0xFFFBBF24),
              icon: SvgPicture.asset(
                'assets/svg/mission/icon_calendar_star.svg',
                width: 16.wMin,
                height: 16.wMin,
              ),
            ),
          ),
          _buildSummaryDivider(),
          Expanded(
            child: _buildSummaryItem(
              label: '总钻石',
              value: '$totalDiamond',
              unit: '个',
              color: const Color(0xFFC084FC),
              icon: SvgPicture.asset(
                'assets/svg/mission/icon_calendar_diamond.svg',
                width: 16.wMin,
                height: 16.wMin,
              ),
            ),
          ),
          _buildSummaryDivider(),
          Expanded(
            child: _buildSummaryItem(
              label: '总记忆',
              value: '$totalMemoryDay',
              unit: '天',
              color: const Color(0xFF00D492),
              icon: SvgPicture.asset(
                'assets/svg/mission/icon_calendar_memory.svg',
                width: 16.wMin,
                height: 16.wMin,
              ),
            ),
          ),
          _buildSummaryDivider(),
          Expanded(
            child: _buildSummaryItem(
              label: '连续记忆',
              value: '$continueMemoryDay',
              unit: '天',
              color: const Color(0xFFFB7185),
              icon: SvgPicture.asset(
                'assets/svg/mission/icon_calendar_hot.svg',
                width: 16.wMin,
                height: 16.wMin,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required String label,
    required String value,
    required String unit,
    required Color color,
    required Widget icon,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.wMin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SizedBox(
                width: 16.wMin,
                height: 16.wMin,
                child: icon,
              ),
              SizedBox(width: 4.wMin),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16.wMin,
                  color: AppTheme.cTextSecondary.color,
           
                ),
              ),
            ],
          ),

          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontSize: 24.wMin,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: ' $unit',
                  style: TextStyle(
                    fontSize: 18.wMin,
                    color: AppTheme.cTextTertiary.color,
          
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryDivider() {
    return Container(
      width: 1.wMin,
      margin: EdgeInsets.symmetric(vertical: 14.wMin),
      color: AppTheme.cBgTertiary.color,
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        TapScaleWidget(
          onTap: () {
            controller.calendarController?.previousPage(
              duration: const Duration(milliseconds: 220),
              curve: Curves.linear,
            );
          },
          sclae: 1.02,
          child: _buildMonthArrow(
            'assets/svg/public/icon_w_arrow_left.svg',
          ),
        ),
        SizedBox(width: 8.wMin),
        Obx(() {
          return Text(
            DateFormatUtil.formatToYearMonth(controller.calendarCurrentDate.value, locale: Get.locale),
            style: TextStyle(
              fontSize: 24.wMin,
              color: AppTheme.cTextPrimary.color,
              fontWeight: FontWeight.w700,
            ),
          );
        }),
        SizedBox(width: 8.wMin),
        TapScaleWidget(
          onTap: () {
            controller.calendarController?.nextPage(
              duration: const Duration(milliseconds: 220),
              curve: Curves.linear,
            );
          },
          sclae: 1.02,
          child: _buildMonthArrow(
            'assets/svg/public/icon_w_arrow_right.svg',
          ),
        ),
        const Spacer(),
        _buildLegendItem(
          label: '知识点',
          color: const Color(0xFF38BDF8),
          icon: SvgPicture.asset(
            'assets/svg/mission/icon_calendar_konw.svg',
            width: 16.wMin,
            height: 16.wMin,
          ),
        ),
        SizedBox(width: 14.wMin),
        _buildLegendItem(
          label: '星星',
          color: const Color(0xFFFBBF24),
          icon: SvgPicture.asset(
            'assets/svg/mission/icon_calendar_star.svg',
            width: 16.wMin,
            height: 16.wMin,
          ),
        ),
        SizedBox(width: 14.wMin),
        _buildLegendItem(
          label: '钻石',
          color: const Color(0xFFC084FC),
          icon: SvgPicture.asset(
            'assets/svg/mission/icon_calendar_diamond.svg',
            width: 16.wMin,
            height: 16.wMin,
          ),
        ),
        SizedBox(width: 14.wMin),
        _buildCompletionLegend(),
      ],
    );
  }

  Widget _buildMonthArrow(String asset) {
    return Container(
      width: 34.wMin,
      height: 34.wMin,
      decoration: BoxDecoration(
        color: AppTheme.cSurfaceLayerBase.color,
        borderRadius: BorderRadius.circular(8.wMin),
        border: Border.all(
          color: AppTheme.cBgTertiary.color,
          width: 1.wMin,
        ),
      ),
      child: Center(
        child: SvgPicture.asset(
          asset,
          width: 16.wMin,
          height: 16.wMin,
          colorFilter: ColorFilter.mode(AppTheme.cTextSecondary.color, BlendMode.srcIn),
        ),
      ),
    );
  }

  Widget _buildLegendItem({
    required String label,
    required Color color,
    required Widget icon,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 16.wMin,
          height: 16.wMin,
          child: icon,
        ),
        SizedBox(width: 4.wMin),
        Text(
          label,
          style: TextStyle(
            fontSize: 14.wMin,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionLegend() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14.wMin,
          height: 14.wMin,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.wMin),
            border: Border.all(
              color: const Color(0xFF00E38C),
              width: 1.5,
            ),
          ),
        ),
        SizedBox(width: 4.wMin),
        Text(
          '边框：计划完成度',
          style: TextStyle(
            fontSize: 14.wMin,
            color: AppTheme.cTextSecondary.color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionLegendTag(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.wMin, vertical: 3.wMin),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999.wMin),
        border: Border.all(
          color: color.withValues(alpha: 0.32),
          width: 1.wMin,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.wMin,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      onCalendarCreated: (pageController) {
        controller.calendarController = pageController;
      },
      focusedDay: controller.calendarCurrentDate.value,
      firstDay: controller.calendarMinDate,
      lastDay: DateTime.now().add(const Duration(days: 365)),
      onPageChanged: (focusedDay) {
        controller.onCalendarPageChanged(focusedDay);
      },
      headerVisible: false,
      shouldFillViewport: true,
      sixWeekMonthsEnforced: true,
      rowHeight: 168.wMin,
      availableGestures: AvailableGestures.horizontalSwipe,
      daysOfWeekHeight: 44.wMin,
      daysOfWeekStyle: DaysOfWeekStyle(
        dowTextFormatter: (date, locale) {
          return DateFormatUtil.getWeekStrForInt(date.weekday);
        },
        weekdayStyle: TextStyle(
          fontSize: 18.wMin,
          color: AppTheme.cTextPrimary.color,
          fontWeight: FontWeight.w600,
        ),
        weekendStyle: TextStyle(
          fontSize: 18.wMin,
          color: AppTheme.cTextPrimary.color,
          fontWeight: FontWeight.w600,
        ),
      ),
      calendarStyle: CalendarStyle(
        outsideDaysVisible: true,
        markerMargin: EdgeInsets.zero,
        cellMargin: EdgeInsets.zero,
        todayDecoration: const BoxDecoration(),
        selectedDecoration: const BoxDecoration(),
        defaultDecoration: const BoxDecoration(),
        weekendDecoration: const BoxDecoration(),
        outsideDecoration: const BoxDecoration(),
      ),
      calendarBuilders: CalendarBuilders(
        prioritizedBuilder: (context, day, focusedDay) {
          return _buildCalendarCell(day);
        },
      ),
    );
  }

  Widget _buildCalendarCell(DateTime date) {
    final data = _findDayData(date);
    final currentMonth = controller.calendarCurrentDate.value;
    final isCurrentMonthDataReady = controller.isMonthDataReady(currentMonth);
    final isOutside = date.year != currentMonth.year || date.month != currentMonth.month;
    final today = DateTime.now();
    final dayDate = DateTime(date.year, date.month, date.day);
    final todayDate = DateTime(today.year, today.month, today.day);
    final isToday = dayDate == todayDate;
    final isFuture = dayDate.isAfter(todayDate);
    final isHistory = !isFuture && !isToday;
    final percent = _completionPercent(data);
    final hasKnowledge = (data?.contentList?.isNotEmpty ?? false);
    final studyType = data?.studyType;
    final showDateOnlyCell = isCurrentMonthDataReady && data == null;
    final hideHistoryContent = isCurrentMonthDataReady && isHistory && studyType == -1;
    final isInterrupted = isHistory
        ? (isCurrentMonthDataReady
            ? (data == null ? false : (studyType == null ? !hasKnowledge : studyType == 0))
            : false)
        : false;
    final showLoadingPlaceholder = !isCurrentMonthDataReady && !isOutside && data == null;
    final progress = ((percent ?? 0).clamp(0, 1)).toDouble();
    final interruptedAccent = const Color(0xFFF43F5E);
    final interruptedBorderColor = interruptedAccent.withValues(alpha: 0.2);
    final interruptedBackgroundColor = interruptedAccent.withValues(alpha: 0.07);
    final progressBorderColor = isFuture || hideHistoryContent || showDateOnlyCell
        ? Colors.transparent
        : isInterrupted
            ? Colors.transparent
            : _resolveCompletionBorderColor(progress);
    final percentText = percent == null ? '' : '${(percent * 100).round()}%';
    final percentColor = isFuture ? AppTheme.cTextTertiary.color : progressBorderColor;
    final backgroundColor = isInterrupted
        ? interruptedBackgroundColor
        : hideHistoryContent || showDateOnlyCell
            ? AppTheme.cSurfaceSoildBg.color
            : AppTheme.cSurfaceSoildBg.color;
    final baseBorderColor = isInterrupted
        ? interruptedBorderColor
        : AppTheme.cSurfaceLayerElevated.color;

    return SizedBox.expand(
      child: Padding(
        padding: EdgeInsets.all(3.wMin),
        child: Opacity(
          opacity: isOutside ? 0.72 : 1,
          child: CustomPaint(
            foregroundPainter: _CalendarProgressBorderPainter(
              progress: isInterrupted ? 0 : progress,
              baseBorderColor: baseBorderColor,
              highlightColor: progressBorderColor,
              borderRadius: 16.wMin,
              borderWidth: 1.wMin,
            ),
            child: Container(
              padding: EdgeInsets.fromLTRB(10.wMin, 8.wMin, 10.wMin, 8.wMin),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(16.wMin),
              ),
              child: showLoadingPlaceholder
                  ? _buildMetricCalendarCell(
                      date: date,
                      data: null,
                      isFuture: true,
                      percentText: '',
                      percentColor: AppTheme.cTextTertiary.color,
                    )
                  : showDateOnlyCell || hideHistoryContent
                  ? _buildHistoryEmptyCell(date)
                  : isInterrupted
                      ? _buildInterruptedCell(date)
                      : _buildMetricCalendarCell(
                          date: date,
                          data: data,
                          isFuture: isFuture,
                          percentText: percentText,
                          percentColor: percentColor,
                        ),
            ),
          ),
        ),
      ),
    );
  }

  Color _resolveCompletionBorderColor(double progress) {
    if (progress >= 1) {
      return const Color(0xFF00E38C);
    }
    if (progress >= 0.85) {
      return const Color(0xFFFACC15);
    }
    if (progress >= 0.70) {
      return const Color(0xFFF59E0B);
    }
    if (progress >= 0.50) {
      return const Color(0xFFF97316);
    }
    return const Color(0xFFEF476F);
  }

  Widget _buildHistoryEmptyCell(DateTime date) {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        width: 30.wMin,
        height: 30.wMin,
        alignment: Alignment.center,
        child: Text(
          '${date.day}',
          style: TextStyle(
            fontSize: 16.wMin,
            color: AppTheme.cTextTertiary.color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  StudyPlanCalendarEntityList? _findDayData(DateTime date) {
    for (final item in controller.calendarPlanList.whereType<StudyPlanCalendarEntityList>()) {
      if (DateFormatUtil.isToday(item.dayDate, date)) {
        return item;
      }
    }
    return null;
  }

  double? _completionPercent(StudyPlanCalendarEntityList? data) {
    final total = data?.firstTaskExerciseCount ?? 0;
    final done = data?.exerciseAlreadyCount ?? 0;
    if (total <= 0) return null;
    return done / total;
  }

  Widget _buildMetricCalendarCell({
    required DateTime date,
    required StudyPlanCalendarEntityList? data,
    required bool isFuture,
    required String percentText,
    required Color percentColor,
  }) {
    const knowledgeMetricColor = Color(0xFF38BDF8);
    final today = DateTime.now();
    final isToday = date.year == today.year && date.month == today.month && date.day == today.day;
    final dayColor = isFuture
        ? AppTheme.cTextTertiary.color
        : isToday
            ? AppTheme.cEditBookBackground
            : AppTheme.cTextPrimary.color;
    final metricTextColor = isFuture ? AppTheme.cTextDisabled2.color : AppTheme.cTextPrimary.color;
    final knowledgeCount = data?.contentList?.length ?? 0;
    final starCount = data?.missionStarCount ?? 0;
    final diamondCount = data?.diamondCount ?? 0;
    final durationMinutes = _durationMinutes(data);
    final headerFontSize = 16.wMin;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 30.wMin,
                  height: 30.wMin,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isToday ? AppTheme.cTextPrimary : Colors.transparent,
                  ),
                  child: Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: headerFontSize,
                      color: dayColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: !isFuture && durationMinutes > 0
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            'assets/svg/mission/icon_calendar_time.svg',
                            width: 14.wMin,
                            height: 14.wMin,
                          ),
                          SizedBox(width: 4.wMin),
                          Text(
                            '${durationMinutes}min',
                            style: TextStyle(
                              fontSize: headerFontSize,
                              color: AppTheme.cTextPrimary.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: !isFuture && percentText.isNotEmpty
                    ? Text(
                        percentText,
                        style: TextStyle(
                          fontSize: headerFontSize,
                          color: percentColor,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
        const Spacer(),
        if (isFuture)
          Center(
            child: _buildCalendarMetricItem(
              value: '$knowledgeCount',
              iconPath: 'assets/svg/mission/icon_calendar_konw.svg',
              iconColor: AppTheme.cTextDisabled2.color,
              valueColor: metricTextColor,
            ),
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: _buildCalendarMetricItem(
                  value: '$starCount',
                  iconPath: 'assets/svg/mission/icon_calendar_star.svg',
                  iconColor: const Color(0xFFFBBF24),
                  valueColor: metricTextColor,
                ),
              ),
              Expanded(
                child: _buildCalendarMetricItem(
                  value: '$knowledgeCount',
                  iconPath: 'assets/svg/mission/icon_calendar_konw.svg',
                  iconColor: knowledgeMetricColor,
                  valueColor: metricTextColor,
                ),
              ),
              Expanded(
                child: _buildCalendarMetricItem(
                  value: '$diamondCount',
                  iconPath: 'assets/svg/mission/icon_calendar_diamond.svg',
                  iconColor: const Color(0xFFC084FC),
                  valueColor: metricTextColor,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildInterruptedCell(DateTime date) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          child: Text(
            '${date.day}',
            style: TextStyle(
              fontSize: 18.wMin,
              color: const Color(0xFFF43F5E),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/svg/public/x.svg',
                width: 34.wMin,
                height: 34.wMin,
                colorFilter: const ColorFilter.mode(Color(0xFFF43F5E), BlendMode.srcIn),
              ),
              SizedBox(height: 8.wMin),
              Text(
                '中断',
                style: TextStyle(
                  fontSize: 22.wMin,
                  color: const Color(0xFFF43F5E),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarMetricItem({
    required String value,
    required String iconPath,
    required Color iconColor,
    required Color valueColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 25.wMin,
            color: valueColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 4.wMin),
        SvgPicture.asset(
          iconPath,
          width: 16.wMin,
          height: 16.wMin,
          colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
        ),
      ],
    );
  }

  int _durationMinutes(StudyPlanCalendarEntityList? data) {
    final seconds = data?.exerciseLearnedDuration ?? 0;
    if (seconds <= 0) return 0;
    return ((seconds + 30) ~/ 60);
  }
}

class _CalendarProgressBorderPainter extends CustomPainter {
  final double progress;
  final Color baseBorderColor;
  final Color highlightColor;
  final double borderRadius;
  final double borderWidth;

  const _CalendarProgressBorderPainter({
    required this.progress,
    required this.baseBorderColor,
    required this.highlightColor,
    required this.borderRadius,
    required this.borderWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect.deflate(borderWidth / 2),
      Radius.circular(borderRadius),
    );

    final basePaint = Paint()
      ..color = baseBorderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
    canvas.drawRRect(rrect, basePaint);

    if (progress <= 0 || highlightColor == Colors.transparent) return;

    final highlightPaint = Paint()
      ..color = highlightColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final path = _buildTopLeftStartPath(rrect);
    final metric = path.computeMetrics().firstOrNull;
    if (metric == null) return;

    final highlightPath = metric.extractPath(0, metric.length * progress.clamp(0, 1));
    canvas.drawPath(highlightPath, highlightPaint);
  }

  Path _buildTopLeftStartPath(RRect rrect) {
    final rect = rrect.outerRect;
    final radius = rrect.tlRadiusX;
    final left = rect.left;
    final right = rect.right;
    final top = rect.top;
    final bottom = rect.bottom;

    return Path()
      ..moveTo(left + radius, top)
      ..lineTo(right - radius, top)
      ..arcToPoint(
        Offset(right, top + radius),
        radius: Radius.circular(radius),
        clockwise: true,
      )
      ..lineTo(right, bottom - radius)
      ..arcToPoint(
        Offset(right - radius, bottom),
        radius: Radius.circular(radius),
        clockwise: true,
      )
      ..lineTo(left + radius, bottom)
      ..arcToPoint(
        Offset(left, bottom - radius),
        radius: Radius.circular(radius),
        clockwise: true,
      )
      ..lineTo(left, top + radius)
      ..arcToPoint(
        Offset(left + radius, top),
        radius: Radius.circular(radius),
        clockwise: true,
      );
  }

  @override
  bool shouldRepaint(covariant _CalendarProgressBorderPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.baseBorderColor != baseBorderColor ||
        oldDelegate.highlightColor != highlightColor ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.borderWidth != borderWidth;
  }
}
