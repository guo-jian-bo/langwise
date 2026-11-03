import 'dart:async';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker_plus/picker.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:intl/intl.dart';

import '../../utils/utils.dart';

class DateTimePickerUtils{

  static Future<DateTime?> showYMD({
    required BuildContext context,
    String? title,
    DateTime? minDate,
    DateTime? maxDate,
    DateTime? initialDate,
    double? width,
    bool looping = false,
    void Function(DateTime date)? onTap,
  }) async{
    return await showCupertinoDialog<DateTime?>(
      context: context,
      builder: (BuildContext context) {
        return DateTimePickerYMD(
          title: title,
          minDate: minDate,
          maxDate: maxDate,
          initialDate: initialDate,
          width: width,
          looping: looping,
          onTap: onTap,
        );
      },
    );
  }

  static Future<DateTime?> showHM({
    required BuildContext context,
    String? title,
    DateTime? minDate,
    DateTime? maxDate,
    DateTime? initialDate,
    double? width,
    bool looping = false,
    int minuteInterval = 1,
    bool showAP = false,
    void Function(DateTime date)? onTap,
  }) async{
    return await showCupertinoDialog<DateTime?>(
      context: context,
      builder: (BuildContext context) {
        return DateTimePickerHM(
          title: title,
          minDate: minDate,
          maxDate: maxDate,
          initialDate: initialDate,
          width: width,
          looping: looping,
          minuteInterval: minuteInterval,
          showAP: showAP,
          onTap: onTap,
        );
      },
    );
  }

  /// 选择时长(小时分钟)
  static Future<Duration?> showDuration({
    required BuildContext context,
    String? title,
    double? width,
    bool looping = false,
    int minuteInterval = 1,
    Duration? maxDuration,
    Duration? minDuration,
    Duration? initDuration,
    void Function(Duration date)? onTap,
  }) async{
    return await showCupertinoDialog<Duration?>(
      context: context,
      builder: (BuildContext context) {
        return DateTimePickerDuration(
          title: title,
          width: width,
          looping: looping,
          minuteInterval: minuteInterval,
          minDuration: minDuration,
          maxDuration: maxDuration,
          initDuration: initDuration,
          onTap: onTap,
        );
      },
    );
  }

  static void showDateCalender({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? minDate,
    DateTime? maxDate,
    void Function(DateTime date)? onTap,
  }) async{

    BotToast.showAttachedWidget(
      targetContext: context,
      preferDirection: PreferDirection.bottomRight,
      allowClick: false,
      onlyOne: true,
      verticalOffset: 10.wMin,
      attachedBuilder: (cancelFunc) {
        return DateTimePickerCalenderWidget(
          initialDate: initialDate,
          minDate: minDate,
          maxDate: maxDate,
          cancelFunc: cancelFunc,
          onTap: onTap,
        );
      },
    );
  }

  static void showStartEndCalender({
    required BuildContext context,
    DateTime? initialStartDate,
    DateTime? initialEndDate,
    DateTime? minDate,
    DateTime? maxDate,
    void Function(DateTime start, DateTime end)? onTap,
  }) async{
    BotToast.showAttachedWidget(
      targetContext: context,
      preferDirection: PreferDirection.bottomRight,
      allowClick: false,
      onlyOne: true,
      verticalOffset: 10.wMin,
      attachedBuilder: (cancelFunc) {
        return DateTimePickerStartEndCalender(
          cancelFunc: cancelFunc,
          initialStartDate: initialStartDate,
          initialEndDate: initialEndDate,
          minDate: minDate,
          maxDate: maxDate,
          onTap: onTap,
        );
      },
    );
  }

}


class DateTimePickerStartEndCalender extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final DateTime? minDate;
  final DateTime? maxDate;
  final void Function() cancelFunc; 
  final void Function(DateTime start, DateTime end)? onTap;
  /// 未完成
  const DateTimePickerStartEndCalender({
    super.key, 
    required this.cancelFunc,
    this.initialStartDate, 
    this.initialEndDate, 
    this.minDate, 
    this.maxDate, 
    this.onTap,
  });

  @override
  State<DateTimePickerStartEndCalender> createState() => _DateTimePickerStartEndCalenderState();
}

class _DateTimePickerStartEndCalenderState extends State<DateTimePickerStartEndCalender> {
  final List<String> menuList = ["昨天", "今天","最近3天" ,"最近7天", "最近15天","最近30天","上周","本月"];
  int selectedIndex = -1;
  int hoverIndex = -1;

  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  DateTime minDate = DateTime(2025, 1, 1);
  DateTime maxDate = DateTime(2030, 12, 31);

  PageController viewController1 = PageController();
  PageController viewController2 = PageController();

  DateTime startDateMonth = DateTime.now();
  DateTime endDateMonth = DateTime.now();

  @override
  void initState(){
    super.initState();
    startDateMonth = DateTime.now();
    endDateMonth = DateTime.now();
    
    if(widget.minDate != null){
      minDate = widget.minDate!;
    }
    if(widget.maxDate != null){
      maxDate = widget.maxDate!;
    }

    _selectedStartDate = _dateOnly(widget.initialStartDate ?? DateTime.now());
    _selectedEndDate = _dateOnly(widget.initialEndDate ?? DateTime.now());
    _normalizeRange();

    startDateMonth = DateTime(_selectedStartDate!.year, _selectedStartDate!.month);
    endDateMonth = DateTime(_selectedEndDate!.year, _selectedEndDate!.month);

    viewController1 = PageController(initialPage: DateUtils.monthDelta(minDate, startDateMonth));
    viewController2 = PageController(initialPage: DateUtils.monthDelta(minDate, endDateMonth));
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.wMin),
        child: Container(
          width: 800.wMin,
          height: 400.wMin,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.wMin),
            color: AppTheme.cBgSecondary,
            border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
            boxShadow: [
              BoxShadow(
                color: AppTheme.cShadowDark.color,
                offset: Offset(2.wMin, 4.wMin),
                blurRadius: 5.wMin,
              ),
            ],
          ),
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    _buildLeftMenuWidget(),
                    Container(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
                    Expanded(
                      child: _buildCalenderWidget(
                        viewController: viewController1,
                        currentMonth: startDateMonth,
                        isStartCalendar: true,
                        onMonthChange: (p0) {
                          setState(() {
                            startDateMonth = p0;
                          });
                        },
                      ),
                    ),
                    Container(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
                    Expanded(
                      child: _buildCalenderWidget(
                        viewController: viewController2,
                        currentMonth: endDateMonth,
                        isStartCalendar: false,
                        onMonthChange: (p0) {
                          setState(() {
                            endDateMonth = p0;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Container(height: 1.wMin, color: AppTheme.cBorderPrimary.color),
              _buildBottomActionBar(),
            ],
          ),
        ),
      ),
    );
  }

  DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

  bool _isSameDay(DateTime? a, DateTime? b) => DateUtils.isSameDay(a, b);

  bool _isInRange(DateTime date) {
    if (_selectedStartDate == null || _selectedEndDate == null) return false;
    final d = _dateOnly(date);
    return !d.isBefore(_selectedStartDate!) && !d.isAfter(_selectedEndDate!);
  }

  void _normalizeRange() {
    if (_selectedStartDate == null) _selectedStartDate = _dateOnly(DateTime.now());
    if (_selectedEndDate == null) _selectedEndDate = _dateOnly(DateTime.now());

    _selectedStartDate = _clampDate(_selectedStartDate!);
    _selectedEndDate = _clampDate(_selectedEndDate!);
    if (_selectedEndDate!.isBefore(_selectedStartDate!)) {
      final tmp = _selectedStartDate;
      _selectedStartDate = _selectedEndDate;
      _selectedEndDate = tmp;
    }
  }

  DateTime _clampDate(DateTime date) {
    final d = _dateOnly(date);
    final minD = _dateOnly(minDate);
    final maxD = _dateOnly(maxDate);
    if (d.isBefore(minD)) return minD;
    if (d.isAfter(maxD)) return maxD;
    return d;
  }

  void _applyPreset(int index) {
    final today = _clampDate(DateTime.now());
    DateTime start;
    DateTime end;

    if (index == 1) {
      // 今天
      start = today;
      end = today;
    } else if (index == 0) {
      // 昨天：start=昨天 end=今天
      start = _clampDate(today.subtract(const Duration(days: 1)));
      end = start;
    } else if (index == 2) {
      start = _clampDate(today.subtract(const Duration(days: 2)));
      end = today;
    } else if (index == 3) {
      start = _clampDate(today.subtract(const Duration(days: 6)));
      end = today;
    } else if (index == 4) {
      start = _clampDate(today.subtract(const Duration(days: 14)));
      end = today;
    } else if (index == 5) {
      start = _clampDate(today.subtract(const Duration(days: 29)));
      end = today;
    } else if (index == 6) {
      final thisWeekStart = _dateOnly(today.subtract(Duration(days: today.weekday - 1)));
      final lastWeekStart = _clampDate(thisWeekStart.subtract(const Duration(days: 7)));
      final lastWeekEnd = _clampDate(thisWeekStart.subtract(const Duration(days: 1)));
      start = lastWeekStart;
      end = lastWeekEnd;
    } else if (index == 7) {
      start = _clampDate(DateTime(today.year, today.month, 1));
      end = today;
    } else {
      start = today;
      end = today;
    }

    setState(() {
      selectedIndex = index;
      _selectedStartDate = start;
      _selectedEndDate = end;
      _normalizeRange();
      _syncMonthControllers();
    });
  }

  void _syncMonthControllers() {
    if (_selectedStartDate == null) return;
    startDateMonth = DateTime(_selectedStartDate!.year, _selectedStartDate!.month);
    if (_selectedEndDate != null) {
      endDateMonth = DateTime(_selectedEndDate!.year, _selectedEndDate!.month);
    }

    final p1 = DateUtils.monthDelta(minDate, startDateMonth);
    final p2 = DateUtils.monthDelta(minDate, endDateMonth);
    if (viewController1.hasClients) {
      viewController1.jumpToPage(p1);
    }
    if (viewController2.hasClients) {
      viewController2.jumpToPage(p2);
    }
  }

  Widget _buildBottomActionBar() {
    return Container(
      height: 64.wMin,
      padding: EdgeInsets.symmetric(horizontal: 16.wMin),
      child: Row(
        children: [
          Text(
            "${DateFormat('yyyy-MM-dd').format(_selectedStartDate ?? DateTime.now())} ~ ${DateFormat('yyyy-MM-dd').format(_selectedEndDate ?? DateTime.now())}",
            style: TextStyle(
              color: AppTheme.cTextPrimary,
              fontSize: 18.wMin,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          TapScaleWidget(
            onTap: () {
              widget.cancelFunc();
            },
            child: Container(
              height: 40.wMin,
              padding: EdgeInsets.symmetric(horizontal: 16.wMin),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.wMin),
                color: AppTheme.cBgTertiary.color,
              ),
              child: Text(
                '取消',
                style: TextStyle(
                  color: AppTheme.cTextPrimary,
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.wMin),
          TapScaleWidget(
            onTap: () {
              _normalizeRange();
              final start = _selectedStartDate ?? _dateOnly(DateTime.now());
              final end = _selectedEndDate ?? _dateOnly(DateTime.now());
              widget.onTap?.call(start, end);
              widget.cancelFunc();
            },
            child: Container(
              height: 40.wMin,
              padding: EdgeInsets.symmetric(horizontal: 16.wMin),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.wMin),
                color: AppTheme.cBgBrand.color,
              ),
              child: Text(
                '确定',
                style: TextStyle(
                  color: AppTheme.cTextPrimary,
                  fontSize: 18.wMin,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftMenuWidget(){
    return SizedBox(
      width: 150.wMin,
      height: double.infinity,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 24.wMin),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: List.generate(menuList.length, (index){
            return _buildLeftMenuItemWidget(index);
          }),
        ),
      ),
    );
  }

  Widget _buildLeftMenuItemWidget(int index){
    return MouseRegion(
      onEnter: (event) {
        setState(() {
          hoverIndex = index;
        });
      },
      onExit: (event) {
        setState(() {
          hoverIndex = -1;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.wMin),
          color: selectedIndex == index ? AppTheme.cBgTertiary.color : Colors.transparent,
        ),
        child: TapScaleWidget(
          onTap: () {
            _applyPreset(index);
          },
          sclae: 1,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 8.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.wMin),
              color: hoverIndex == index ? AppTheme.cBgQuaternary.color : Colors.transparent,
            ),
            child: Text(
              menuList[index],
              style: TextStyle(
                fontSize: 20.wMin,
                color: AppTheme.cTextPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalenderWidget({
    required PageController viewController,
    required DateTime currentMonth,
    required bool isStartCalendar,
    void Function(DateTime)? onMonthChange,
  }){
    return Column(
      children: [
        buildCalenderArrowWidget(
          viewController: viewController,
          currentMonth: currentMonth,
        ),
        Container(height: 1.wMin, color: AppTheme.cBorderPrimary.color),
        Expanded(
          child: CalendarDatePicker2(
              value: [
                isStartCalendar ? _selectedStartDate : _selectedEndDate,
              ],
              onValueChanged: (dates) {
                final DateTime? picked = dates.isNotEmpty ? dates[0] : null;
                if (picked == null) return;

                setState(() {
                  if (isStartCalendar) {
                    _selectedStartDate = _dateOnly(picked);
                    if (_selectedEndDate != null && _selectedEndDate!.isBefore(_selectedStartDate!)) {
                      _selectedEndDate = _selectedStartDate;
                    }
                  } else {
                    _selectedEndDate = _dateOnly(picked);
                    if (_selectedStartDate != null && _selectedEndDate!.isBefore(_selectedStartDate!)) {
                      _selectedStartDate = _selectedEndDate;
                    }
                  }
                  _normalizeRange();
                  selectedIndex = -1;
                });
              },
              onDisplayedMonthChanged: onMonthChange,
              config: CalendarDatePicker2Config(
                currentDate: DateTime.now(),
                dayViewController: viewController,
                calendarType: CalendarDatePicker2Type.single,
                dayMaxWidth: 100.wMin,
                firstDate: widget.minDate,
                lastDate: widget.maxDate,
                disableMonthPicker: true,
                disableModePicker: true,
                disableVibration: true,
                allowSameValueSelection: true,
                hideLastMonthIcon: true,
                hideNextMonthIcon: true,
                hideYearPickerDividers: true,
                hideScrollViewMonthWeekHeader: true,
                controlsHeight: 0,
                daySplashColor: Colors.transparent,
                selectedDayHighlightColor: AppTheme.cBgBrand.color,
                dayBuilder: ({required date, decoration, isDisabled, isSelected, isToday, textStyle}) {
                  final DateTime d = _dateOnly(date);
                  final bool disabled = isDisabled ?? false;

                  final bool isStart = _isSameDay(d, _selectedStartDate);
                  final bool isEnd = _isSameDay(d, _selectedEndDate);
                  final bool inRange = !disabled && _isInRange(d);
                  final bool today = isToday ?? false;

                  BoxDecoration? rangeDecoration;
                  if (inRange) {
                    BorderRadius borderRadius = BorderRadius.zero;
                    if (isStart && isEnd) {
                      borderRadius = BorderRadius.circular(999);
                    } else if (isStart) {
                      borderRadius = BorderRadius.horizontal(
                        left: Radius.circular(999.wMin),
                        right: Radius.circular(0.wMin),
                      );
                    } else if (isEnd) {
                      borderRadius = BorderRadius.horizontal(
                        left: Radius.circular(0.wMin),
                        right: Radius.circular(999.wMin),
                      );
                    }
                    rangeDecoration = BoxDecoration(
                      color: AppTheme.cBgBrand.color.withOpacity(0.18),
                      borderRadius: borderRadius,
                    );
                  }

                  BoxDecoration? anchorDecoration;
                  if (!disabled && (isStart || isEnd)) {
                    anchorDecoration = BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.cBgBrand.color,
                    );
                  } else if (today) {
                    anchorDecoration = BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        width: 1.wMin,
                        color: AppTheme.cBgBrand.color,
                      ),
                    );
                  }

                  final TextStyle? dayStyle = (!disabled && (isStart || isEnd))
                      ? (textStyle?.copyWith(color: AppTheme.cTextPrimary))
                      : textStyle;

                  return Container(
                    decoration: rangeDecoration,
                    alignment: Alignment.center,
                    child: Container(
                      decoration: anchorDecoration,
                      alignment: Alignment.center,
                      child: Text(
                        "${date.day}",
                        style: dayStyle,
                      ),
                    ),
                  );
                },
                dayTextStyle: TextStyle(
                  color: AppTheme.cTextPrimary,
                  fontSize: 20.wMin,
                  fontWeight: FontWeight.w500,
                ),
                todayTextStyle: TextStyle(
                  color: AppTheme.cTextPrimary,
                  fontSize: 20.wMin,
                  fontWeight: FontWeight.w500,
                ),
                selectedDayTextStyle: TextStyle(
                  color: AppTheme.cTextPrimary,
                  fontSize: 20.wMin,
                  fontWeight: FontWeight.w500,
                ),
                weekdayLabelTextStyle: TextStyle(
                  color: AppTheme.cTextTertiary,
                  fontSize: 16.wMin,
                  fontWeight: FontWeight.w400,
                ),
                disabledDayTextStyle: TextStyle(
                  color: AppTheme.cTextDisabled,
                  fontSize: 20.wMin,
                  fontWeight: FontWeight.w500,
                ),
              ),
              
            ),
        ),
      ],
    );
  }

  Widget buildCalenderArrowWidget({
    required PageController viewController,
    required DateTime currentMonth,
  }){
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TapScaleWidget(
            onTap: (){
              viewController.previousPage(
                duration: const Duration(milliseconds: 100), 
                curve: Curves.linear,
              );
            },
            child: Container(
              padding: EdgeInsets.all(11.wMin),
              color: Colors.transparent,
              child: SvgPicture.asset("assets/svg/public/icon_w_arrow_left.svg", width: 26.wMin),
            ),
          ),
          Text(
            "${currentMonth.year}-${currentMonth.month}",
            style: TextStyle(
              fontSize: 24.wMin,
              color: AppTheme.cTextPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          TapScaleWidget(
            onTap: (){
              viewController.nextPage(
                duration: const Duration(milliseconds: 100), 
                curve: Curves.linear,
              );
            },
            child: Container(
              padding: EdgeInsets.all(11.wMin),
              color: Colors.transparent,
              child: SvgPicture.asset("assets/svg/public/icon_w_arrow_right.svg", width: 26.wMin),
            ),
          ),
        ],
      );
    }


}





class DateTimePickerCalenderWidget extends StatefulWidget {
  final DateTime? initialDate;
  final DateTime? minDate;
  final DateTime? maxDate;
  final void Function(DateTime date)? onTap;
  final void Function()? cancelFunc;
  const DateTimePickerCalenderWidget({
    super.key, 
    this.initialDate, 
    this.minDate, 
    this.maxDate, 
    this.onTap, 
    this.cancelFunc, 
  });

  @override
  State<DateTimePickerCalenderWidget> createState() => _DateTimePickerCalenderWidgetState();
}

class _DateTimePickerCalenderWidgetState extends State<DateTimePickerCalenderWidget> {
  DateTime? minDate;
  DateTime? maxDate;
  DateTime currentMonth = DateTime.now();
  DateTime selectDate = DateTime.now();
  PageController? calendarController;
  bool showYM = false;

  StreamController<DateTime> currentMonthSteam = StreamController<DateTime>();

  @override
  void initState() {
    super.initState();
    selectDate = widget.initialDate??DateTime.now();
    initCalender();
  }

  @override
  void dispose() {
    currentMonthSteam.close();
    super.dispose();
  }

  void initCalender(){
    DateTime now = DateTime.now();
    minDate = widget.minDate??DateTime(now.year, 1, 1);
    maxDate = widget.maxDate??DateTime(now.year, 12, 31);

    currentMonth = widget.initialDate??DateTime.now();
    selectDate = widget.initialDate??DateTime.now();


    int res = DateUtils.monthDelta(minDate!, currentMonth);
    calendarController = PageController(initialPage: res);
  }

  @override
  Widget build(BuildContext context) {

    Widget buildCalenderWidget(){
      return CalendarDatePicker2(
        key: const ValueKey(false),
        displayedMonthDate: currentMonth,
        value: [
          selectDate,
        ],
        onValueChanged: (dates) {
          selectDate = dates.first;
          if(mounted) setState(() {});
          widget.cancelFunc?.call();
          widget.onTap?.call(selectDate);
        },
        onDisplayedMonthChanged: (value) {
          currentMonth = value;
          currentMonthSteam.sink.add(currentMonth);
        },
        config: CalendarDatePicker2Config(
          currentDate: DateTime.now(),
          dayViewController: calendarController,
          calendarType: CalendarDatePicker2Type.single,
          dayMaxWidth: 100.wMin,
          firstDate: minDate,
          lastDate: maxDate,
          disableMonthPicker: true,
          disableModePicker: true,
          disableVibration: true,
          allowSameValueSelection: true,
          hideLastMonthIcon: true,
          hideNextMonthIcon: true,
          hideYearPickerDividers: true,
          hideScrollViewMonthWeekHeader: true,
          controlsHeight: 0,
          daySplashColor: Colors.transparent,
          selectedDayHighlightColor: AppTheme.cBgBrand,
          dayBuilder: ({required date, decoration, isDisabled, isSelected, isToday, textStyle}) {
            BoxDecoration boxDecoration = decoration??const BoxDecoration();
            if(isToday??false){
              boxDecoration = BoxDecoration(
                shape: BoxShape.circle,
                color: (isSelected??false) ? AppTheme.cBgBrand : Colors.transparent,
              );
            }
            return Container(
              decoration: boxDecoration,
              alignment: Alignment.center,
              child: Text(
                "${date.day}",
                style: textStyle,
              ),
            );
          },
          dayTextStyle: TextStyle(
            color: AppTheme.cTextPrimary,
            fontSize: 20.wMin,
            fontWeight: FontWeight.w500,
          ),
          todayTextStyle: TextStyle(
            color: AppTheme.cTextPrimary,
            fontSize: 20.wMin,
            fontWeight: FontWeight.w500,
          ),
          selectedDayTextStyle: TextStyle(
            color: AppTheme.cTextPrimary,
            fontSize: 20.wMin,
            fontWeight: FontWeight.w500,
          ),
          weekdayLabelTextStyle: TextStyle(
            color: AppTheme.cTextTertiary,
            fontSize: 16.wMin,
            fontWeight: FontWeight.w400,
          ),
          disabledDayTextStyle: TextStyle(
            color: AppTheme.cTextDisabled,
            fontSize: 20.wMin,
            fontWeight: FontWeight.w500,
          ),
        ),
        
      );
    }

    Widget buildCalenderArrowWidget(){
      return Row(
        children: [
          TapScaleWidget(
            onTap: (){
              calendarController?.previousPage(
                duration: const Duration(milliseconds: 200), 
                curve: Curves.linear,
              );
            },
            child: Container(
              padding: EdgeInsets.all(11.wMin),
              color: Colors.transparent,
              child: SvgPicture.asset("assets/svg/public/icon_w_arrow_left.svg", width: 26.wMin),
            ),
          ),
          TapScaleWidget(
            onTap: (){
              calendarController?.nextPage(
                duration: const Duration(milliseconds: 200), 
                curve: Curves.linear,
              );
            },
            child: Container(
              padding: EdgeInsets.all(11.wMin),
              color: Colors.transparent,
              child: SvgPicture.asset("assets/svg/public/icon_w_arrow_right.svg", width: 26.wMin),
            ),
          ),
        ],
      );
    }

    Widget buildSelectYMWidget(){
      return Column(
        children: [
          Container(
            key: const ValueKey(true),
            color: AppTheme.cBgSecondary,
            child: Picker(
              height: 315.wMin,
              itemExtent: 50.wh,
              hideHeader: true,
              containerColor: Colors.transparent,
              textStyle: TextStyle(
                fontSize: 20.wMin,
                color: AppTheme.cTextPrimary,
                fontWeight: FontWeight.w700,
              ),
              selectedTextStyle: TextStyle(
                fontSize: 20.wMin,
                color: AppTheme.cTextPrimary,
                fontWeight: FontWeight.w700,
              ),
              adapter: DateTimePickerAdapter(
                type: PickerDateTimeType.kYM,
                value: currentMonth,
                isNumberMonth: true,
                maxValue: maxDate,
                minValue: minDate,
              ),
              onSelect: (picker, index, selected) {
                DateTime pick = DateTime.tryParse(picker.adapter.text)??DateTime.now();
                currentMonth = DateTime(pick.year, pick.month, pick.day);
                currentMonthSteam.sink.add(currentMonth);
              },
            ).makePicker(),
          ),
          ButtonWidget(
            text: "确定",
            height: 35.wMin,
            width: 150.wMin,
            borderRadius: 6.wMin,
            color: AppTheme.cBgBrand,
            fontSize: 18.wMin,
            fontColor: AppTheme.cStaticWhite,
            sclae: 1.03,
            onTap: () {
              showYM = false;
              int res = DateUtils.monthDelta(minDate!, currentMonth);
              calendarController = PageController(initialPage: res);
              if(mounted) setState(() {});
            },
          ),
        ],
      );
    }


    return Material(
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.wMin),
        child: Container(
          width: 400.wMin,
          height: 416.wMin,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.wMin),
            color: AppTheme.cBgSecondary,
            border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary),
            boxShadow: [
              BoxShadow(
                color: AppTheme.cShadowDark,
                offset: Offset(2.wMin, 4.wMin),
                blurRadius: 5.wMin,
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                height: 56.wMin,
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 16.wMin),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TapScaleWidget(
                      onTap: () {
                        if(!showYM) {
                          showYM = true;
                        }else{
                          showYM = false;
                          int res = DateUtils.monthDelta(minDate!, currentMonth);
                          calendarController = PageController(initialPage: res);
                          if(mounted) setState(() {});
                        }
                        if(mounted) setState(() {});
                      },
                      sclae: 1.05,
                      child: Row(
                        children: [
                          StreamBuilder<DateTime>(
                            initialData: currentMonth,
                            stream: currentMonthSteam.stream,
                            builder: (context, snapshot) {
                              return Text(
                                DateFormatUtil.formatToYearMonth(snapshot.data!, locale: Get.locale),
                                style: TextStyle(
                                  fontSize: 18.wMin,
                                  color: showYM ? AppTheme.cTextBrand : AppTheme.cTextPrimary,
                                  fontWeight: FontWeight.w400,
                                ),
                              );
                            },
                          ),
                          Transform.rotate(
                            angle: showYM ? 1.6 : 0,
                            child: SvgPicture.asset(
                              "assets/svg/public/icon_w_arrow_right.svg", 
                              width: 18.wMin,
                              colorFilter: showYM ? const ColorFilter.mode(AppTheme.cTextBrand, BlendMode.srcIn) : null,
                            ),
                          ),
                        ],
                      ),
                    ),
        
                    IgnorePointer(
                      ignoring: showYM,
                      child: AnimatedOpacity(
                        opacity: showYM ? 0 : 1,
                        duration: const Duration(milliseconds: 200),
                        child: buildCalenderArrowWidget(),
                      ),
                    ),
        
                  ],
                ),
              ),
              Expanded(
                // child: buildCalenderWidget(),buildSelectYMWidget()
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: showYM ? buildSelectYMWidget() : buildCalenderWidget(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DateTimePickerDuration extends StatefulWidget {
  final double? width;
  final bool looping;
  final int minuteInterval;
  final String? title;
  final Duration? maxDuration;
  final Duration? minDuration;
  final Duration? initDuration;
  final void Function(Duration date)? onTap;
  const DateTimePickerDuration({
    super.key, 
    this.width, 
    required this.looping, 
    required this.minuteInterval, 
    this.title, 
    this.onTap, 
    this.maxDuration, 
    this.minDuration, 
    this.initDuration,
  });

  @override
  State<DateTimePickerDuration> createState() => _DateTimePickerDurationState();
}

class _DateTimePickerDurationState extends State<DateTimePickerDuration> {
  Duration selectDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    if(widget.initDuration != null){
      selectDuration = widget.initDuration!;
    }
  }

  DateTime getDate(Duration duration){
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.minute, int.tryParse(hours)??0, int.tryParse(minutes)??0);
  }

  @override
  Widget build(BuildContext context) {
    Picker picker = Picker(
      height: 670.wMin,
      itemExtent: 70.wMin,
      hideHeader: true,
      looping: widget.looping,
      diameterRatio: 1.5,
      squeeze: 1.3,
      containerColor: Colors.transparent,
      textStyle: TextStyle(
        fontSize: 26.wMin,
        color: Colors.white.withValues(alpha: 0.5),
        fontWeight: FontWeight.w700,
      ),
      selectedTextStyle: TextStyle(
        fontSize: 26.wMin,
        color: Colors.white,
        fontWeight: FontWeight.w700,
      ),
      adapter: DateTimePickerAdapter(
        type: PickerDateTimeType.kHM,
        value: getDate(selectDuration),
        minValue: getDate(widget.minDuration??Duration.zero),
        maxValue: getDate(widget.maxDuration??const Duration(hours: 23, minutes: 59)),
        minuteInterval: widget.minuteInterval,
      ),
      onSelect: (picker, index, selected) {
        DateTime pick = DateTime.tryParse(picker.adapter.text)??DateTime.now();
        
        selectDuration = Duration(hours: pick.hour, minutes: pick.minute);
        print(selectDuration);
      },
    );

    return CardDialogBoxWidget(
      title: widget.title??"",
      child: picker.makePicker(),
      onCancel: () => Get.back(),
      onConfirm: () {
        widget.onTap?.call(selectDuration);
        Get.back(result: selectDuration);
      },
    );
  }
}

class DateTimePickerHM extends StatefulWidget {
  final String? title;
  final DateTime? minDate;
  final DateTime? maxDate;
  final DateTime? initialDate;
  final void Function(DateTime date)? onTap;
  final double? width;
  final bool looping;
  final int minuteInterval;
  final bool showAP;
  const DateTimePickerHM({
    super.key, 
    this.title, 
    this.minDate, 
    this.maxDate, 
    this.initialDate, 
    this.onTap, 
    this.width, 
    required this.looping, 
    required this.minuteInterval, 
    required this.showAP,
  });

  @override
  State<DateTimePickerHM> createState() => _DateTimePickerHMState();
}

class _DateTimePickerHMState extends State<DateTimePickerHM> {
  DateTime selectDateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    if(widget.initialDate != null){
      DateTime init = widget.initialDate!;
      selectDateTime = DateTime(init.year, init.month, init.day, init.hour, init.minute);
    }
  }

  List<String> getAPStr(){
    final localizations = CupertinoLocalizations.of(context);
    return [localizations.anteMeridiemAbbreviation, localizations.postMeridiemAbbreviation];
  }

  @override
  Widget build(BuildContext context) {
    
    Picker picker = Picker(
      height: 670.wMin,
      itemExtent: 70.wMin,
      hideHeader: true,
      looping: widget.looping,
      diameterRatio: 1.5,
      squeeze: 1.3,
      containerColor: Colors.transparent,
      textStyle: TextStyle(
        fontSize: 26.wMin,
        color: AppTheme.cTextPrimary,
        fontWeight: FontWeight.w700,
      ),
      selectedTextStyle: TextStyle(
        fontSize: 26.wMin,
        color: AppTheme.cTextPrimary,
        fontWeight: FontWeight.w700,
      ),
      adapter: DateTimePickerAdapter(
        type: widget.showAP ? PickerDateTimeType.kHM_AP : PickerDateTimeType.kHM,
        strAMPM: getAPStr(),
        value: selectDateTime,
        maxValue: widget.maxDate,
        minValue: widget.minDate,
        minuteInterval: widget.minuteInterval,
      ),
      onSelect: (picker, index, selected) {
        DateTime pick = DateTime.tryParse(picker.adapter.text)??DateTime.now();
        selectDateTime = DateTime(pick.year, pick.month, pick.day, pick.hour, pick.minute);
      },
    );

    return CardDialogBoxWidget(
      title: widget.title??"",
      // width: widget.width,
      child: picker.makePicker(),
      onCancel: () => Get.back(),
      onConfirm: () {
        widget.onTap?.call(selectDateTime);
        Get.back(result: selectDateTime);
      },
    );
  }
}


class DateTimePickerYMD extends StatefulWidget {
  final String? title;
  final DateTime? minDate;
  final DateTime? maxDate;
  final DateTime? initialDate;
  final void Function(DateTime date)? onTap;
  final double? width;
  final bool looping;
  const DateTimePickerYMD({
    super.key, 
    this.title, 
    this.minDate, 
    this.maxDate, 
    this.initialDate, 
    this.onTap, 
    this.width,
    required this.looping,
  });

  @override
  State<DateTimePickerYMD> createState() => _DateTimePickerYMDState();
}

class _DateTimePickerYMDState extends State<DateTimePickerYMD> {

  DateTime selectDateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    if(widget.initialDate != null){
      DateTime init = widget.initialDate!;
      selectDateTime = DateTime(init.year, init.month, init.day);
    }

    if(widget.minDate != null){
      DateTime min = widget.minDate!;
      if(selectDateTime.isBefore(min)){
        selectDateTime = min;
      }
    }
  }


  /// 根据国家代码 获取年月日的顺序
  int getDateTimeTypeByLocale(Locale? locale) {
    if(locale == null) return PickerDateTimeType.kYMD;
    String? dateFormatPattern = DateFormat.yMd(locale.toString()).add_jm().pattern;
    // 分析日期格式模式，确定日期部分的顺序
    if(dateFormatPattern == null || dateFormatPattern == ""){
      return PickerDateTimeType.kYMD;
    }else if (dateFormatPattern.contains('y') &&
        dateFormatPattern.indexOf('y') < dateFormatPattern.indexOf('M') &&
        dateFormatPattern.indexOf('y') < dateFormatPattern.indexOf('d')) {
      return PickerDateTimeType.kYMD;
    } else if (dateFormatPattern.contains('M') &&
        dateFormatPattern.indexOf('M') < dateFormatPattern.indexOf('d') &&
        dateFormatPattern.indexOf('M') < dateFormatPattern.indexOf('y')) {
      return PickerDateTimeType.kMDY;
    } else if (dateFormatPattern.contains('d') &&
        dateFormatPattern.indexOf('d') < dateFormatPattern.indexOf('M') &&
        dateFormatPattern.indexOf('d') < dateFormatPattern.indexOf('y')) {
      return PickerDateTimeType.kDMY;
    } else {
      // 对于无法确定的情况，可以使用默认的年-月-日顺序
      return PickerDateTimeType.kYMD;
    }
  }


  @override
  Widget build(BuildContext context) {

    Picker picker = Picker(
      height: 300.wMin,
      itemExtent: 50.wMin,
      hideHeader: true,
      looping: widget.looping,
      containerColor: Colors.transparent,
      textStyle: TextStyle(
        fontSize: 24.wMin,
        color: AppTheme.cTextPrimary.color,
        fontWeight: FontWeight.w400,
      ),
      selectedTextStyle: TextStyle(
        fontSize: 24.wMin,
        color: AppTheme.cTextPrimary.color,
        fontWeight: FontWeight.w400,
      ),
      adapter: DateTimePickerAdapter(
        type: getDateTimeTypeByLocale(Get.locale),
        value: selectDateTime,
        isNumberMonth: true,
        maxValue: widget.maxDate,
        minValue: widget.minDate,
      ),
      onSelect: (picker, index, selected) {
        DateTime pick = DateTime.tryParse(picker.adapter.text)??DateTime.now();
        selectDateTime = DateTime(pick.year, pick.month, pick.day);
      },
    );

    return DateTimePickerBox(
      title: widget.title,
      width: widget.width,
      child: picker.makePicker(),
      onTap: () {
        widget.onTap?.call(selectDateTime);
        Get.back(result: selectDateTime);
      },
    );
  }
}


class DateTimePickerBox extends StatelessWidget {
  final String? title;
  final double? width;
  final void Function()? onTap;
  final Widget child;
  const DateTimePickerBox({super.key, this.title, this.width, this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.cOverlayBackground.color,
      child: Center(
        child: Container(
          width: width??500.wMin,
          padding: EdgeInsets.symmetric(horizontal: 20.wMin, vertical: 24.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.wMin),
            color: AppTheme.cBgSecondary.color,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AutoSizeText(
                title??"",
                maxLines: 1,
                minFontSize: 4,
                style: TextStyle(
                  fontSize: 26.wMin,
                  color: AppTheme.cTextPrimary.color,
                  fontWeight: FontWeight.w600,
                ),
              ),

              child,
              
              SizedBox(height: 8.wMin),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                spacing: 24.wMin,
                children: [
                  Expanded(
                    child: TapScaleWidget(
                      onTap: () => Get.back(),
                      sclae: 1.03,
                      child: Container(
                        width: 180.wMin,
                        height: 50.wMin,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppTheme.cBgTertiary.color,
                          borderRadius: BorderRadius.circular(6.wMin),
                        ),
                        child: Text(
                          "取消",
                          style: TextStyle(
                            fontSize: 24.wMin,
                            color: AppTheme.cTextPrimary.color,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TapScaleWidget(
                      sclae: 1.03,
                      onTap: onTap,
                      child: Container(
                        width: 180.wMin,
                        height: 50.wMin,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                        color: AppTheme.cBgBrand.color,
                          borderRadius: BorderRadius.circular(6.wMin),
                        ),
                        child: Text(
                          "确定",
                          style: TextStyle(
                            fontSize: 24.wMin,
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}