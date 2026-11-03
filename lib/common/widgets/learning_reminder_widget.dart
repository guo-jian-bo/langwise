import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../utils/utils.dart';
import 'date_time_picker_widget.dart';

class LearningReminderWeekData{
  int week;
  bool selected;
  LearningReminderWeekData({
    required this.week,
    this.selected = false,
  });
}

class LearningReminderDialog{
  static Future<void> show({
    required BuildContext context,
    List<DateTime>? initWorkDay,
    List<DateTime>? initHolidayDay,
    List<int>? initWerkWeeks,
    List<int>? initRestWeeks,
    bool? initHolidayAdjustment,
    void Function(List<DateTime> workDay, List<DateTime> holidayDay, List<int> werkWeeks, List<int> restWeeks, bool holidayAdjustment)? onTap,
  }) async{
    await showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return LearningReminderDialogBoxWidget(
          initRestWeeks: initRestWeeks,
          initWerkWeeks: initWerkWeeks,
          initWorkDay: initWorkDay,
          initHolidayDay: initHolidayDay,
          initHolidayAdjustment: initHolidayAdjustment,
          onTap: onTap,
        );
      },
    );
  }
}

class LearningReminderDialogBoxWidget extends StatefulWidget {
  final List<DateTime>? initWorkDay;
  final List<DateTime>? initHolidayDay;
  final List<int>? initWerkWeeks;
  final List<int>? initRestWeeks;
  final bool? initHolidayAdjustment;
  final void Function(
    List<DateTime> workDay, 
    List<DateTime> holidayDay, 
    List<int> werkWeeks, 
    List<int> restWeeks, 
    bool holidayAdjustment,
  )? onTap;
  const LearningReminderDialogBoxWidget({
    super.key,
    this.initWorkDay,
    this.initHolidayDay,
    this.initWerkWeeks,
    this.initRestWeeks,
    this.initHolidayAdjustment,
    this.onTap,
  });

  @override
  State<LearningReminderDialogBoxWidget> createState() => _LearningReminderDialogBoxWidgetState();
}

class _LearningReminderDialogBoxWidgetState extends State<LearningReminderDialogBoxWidget> {
  List<DateTime> initWorkDay = [];
  List<DateTime> initHolidayDay = [];
  List<int> initWerkWeeks = [];
  List<int> initRestWeeks = [];
  bool initHolidayAdjustment = false;

  @override
  void initState(){
    super.initState();
    initWorkDay = widget.initWorkDay ?? [];
    initHolidayDay = widget.initHolidayDay ?? [];
    initWerkWeeks = widget.initWerkWeeks ?? [];
    initRestWeeks = widget.initRestWeeks ?? [];
    initHolidayAdjustment = widget.initHolidayAdjustment ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return CardDialogBoxWidget(
      title: "学习提醒",
      onCancel: () {
        Navigator.pop(context);
      },
      onConfirm: () {
        widget.onTap?.call(initWorkDay, initHolidayDay, initWerkWeeks, initRestWeeks, initHolidayAdjustment);
        Navigator.pop(context);
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 24.wMin),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 40.wMin),
          child: LearningReminderWidget(
            initRestWeeks: initRestWeeks,
            initWerkWeeks: initWerkWeeks,
            initWorkDay: initWorkDay,
            initHolidayDay: initHolidayDay,
            initHolidayAdjustment: initHolidayAdjustment,
            onTap: (workDay, holidayDay, werkWeeks, restWeeks, holidayAdjustment) {
              initWorkDay = workDay;
              initHolidayDay = holidayDay;
              initWerkWeeks = werkWeeks;
              initRestWeeks = restWeeks;
              initHolidayAdjustment = holidayAdjustment;
            },
          ),
        ),
      ),
    );
  }
}

class LearningReminderWidget extends StatefulWidget {
  final List<DateTime>? initWorkDay;
  final List<DateTime>? initHolidayDay;
  final List<int>? initWerkWeeks;
  final List<int>? initRestWeeks;
  final bool? initHolidayAdjustment;
  final void Function(
    List<DateTime> workDay, 
    List<DateTime> holidayDay, 
    List<int> werkWeeks, 
    List<int> restWeeks, 
    bool holidayAdjustment,
  )? onTap;
  /// 学习提醒弹窗widget
  const LearningReminderWidget({
    super.key, 
    this.onTap,
    this.initWorkDay,
    this.initHolidayDay, 
    this.initWerkWeeks, 
    this.initRestWeeks,
    this.initHolidayAdjustment,
  });

  @override
  State<LearningReminderWidget> createState() => _LearningReminderWidgetState();
}

class _LearningReminderWidgetState extends State<LearningReminderWidget> {
  final List<String> weekTextList = ["一", "二", "三", "四", "五", "六", "日"];
  final List<IconDropdownCheckData> weekSystemList = [
    IconDropdownCheckData(title: "双休制"),
    IconDropdownCheckData(title: "自定义"),
  ];
  int weekSysteIndex = 0;

  List<LearningReminderWeekData> weekSeelctList = [];
  /// 工作日
  final List<int> initWorkWeekList = [1,2,3,4,5];
  /// 休息日
  final List<int> initRestWeekList = [6,7];
  
  List<int> workWeekList = [];
  List<int> restWeekList = [];

  /// 节假日开关
  bool holidaySwitch = false;

  List<DateTime> workDay = [];
  List<DateTime> holidayDay = [];

  @override
  void initState() {
    super.initState();
    holidaySwitch = widget.initHolidayAdjustment??false;
    if(widget.initWerkWeeks != null && widget.initWerkWeeks!.isNotEmpty){
      workWeekList = widget.initWerkWeeks??[];
    }else{
      workWeekList = initWorkWeekList.toList();
    }
    if(widget.initRestWeeks != null && widget.initRestWeeks!.isNotEmpty){
      restWeekList = widget.initRestWeeks??[];
    }else{
      restWeekList = initRestWeekList.toList();
    }
    selectSetting(true);
    if(isAllWeekdaysSelected()){
      weekSysteIndex = 0;
    }else{
      weekSysteIndex = 1;
    }
    if(widget.initWorkDay != null){
      workDay = widget.initWorkDay??[];
    }
    if(widget.initHolidayDay != null){
      holidayDay = widget.initHolidayDay??[];
    }
  }

  void selectSetting([bool init = false]){
    if(weekSysteIndex == 0){
      if(!init){
        workWeekList = initWorkWeekList.toList();
        restWeekList = initRestWeekList.toList();
      }
      weekSeelctList.clear();
      weekSeelctList.add(LearningReminderWeekData(week: 7));
      for(int i = 1; i <= 6; i++){
        if(workWeekList.contains(i)){
          weekSeelctList.add(LearningReminderWeekData(week: i, selected: true));
        }else{
          weekSeelctList.add(LearningReminderWeekData(week: i));
        }
      }
    }
    if(!init)widget.onTap?.call(workDay, holidayDay, workWeekList, restWeekList, holidaySwitch);
    if(mounted) setState(() {});
  }

  void selectWeekItem(int index){
    weekSeelctList[index].selected = !weekSeelctList[index].selected;
    if(isAllWeekdaysSelected()){
      weekSysteIndex = 0;
    }else{
      weekSysteIndex = 1;
    }
    workWeekList.clear();
    restWeekList.clear();
    for(int i = 0; i < weekSeelctList.length; i++){
      if(weekSeelctList[i].selected){
        workWeekList.add(weekSeelctList[i].week);
      }else{
        restWeekList.add(weekSeelctList[i].week);
      }
    }
    if(workWeekList.isEmpty){
      workDay.clear();
    }
    if(restWeekList.isEmpty){
      holidayDay.clear();
    }
    if(mounted) setState(() {});
    widget.onTap?.call(workDay, holidayDay, workWeekList, restWeekList, holidaySwitch);
  }


  bool isAllWeekdaysSelected() {
    // 判断周一到周五是否都被选中
    bool allWeekdaysSelected = true;
    for (int i = DateTime.monday; i <= DateTime.friday; i++) {
      var dayData = weekSeelctList.firstWhere((data) => data.week == i);
      if (!dayData.selected) {
        allWeekdaysSelected = false;
        break;
      }
    }

    // 判断是否有选中周六或周日
    bool hasWeekendSelected = weekSeelctList.any((data) => (data.week == DateTime.saturday || data.week == DateTime.sunday) && data.selected);

    // 如果周一到周五全选且没有选中周六或周日，则返回 true
    return allWeekdaysSelected && !hasWeekendSelected;
  }


  void selectHM(List<DateTime> list) async{
    if(list.length >= 5){
      ToastUtils.showToast(text: "最多可添加5个提醒！");
      return;
    }
    DateTimePickerUtils.showHM(
      context: context,
      title: "选择时间",
      onTap: (date) {

        for(int i = 0; i < list.length; i++){
          int hour = list[i].hour;
          int minute = list[i].minute;
          if(hour == date.hour && minute == date.minute){
            ToastUtils.showToast(text: "当前时间已存在");
            return;
          }
        }

        list.add(date);
        if(mounted) setState(() {});

        widget.onTap?.call(workDay, holidayDay, workWeekList, restWeekList, holidaySwitch);
      },
    );
  }


  @override
  Widget build(BuildContext context) {

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "重复",
              style: TextStyle(
                fontSize: 24.wMin,
                color: AppTheme.cTextPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12.wMin),
            IconDropdownCheckWidget(
              sclae: 1.01,
              selectIndex: weekSysteIndex,
              onTap: (data, index) {
                weekSysteIndex = index;
                selectSetting();
                if(mounted) setState(() {});
              },
              items: [
                IconDropdownCheckData(title: "双休制"),
                IconDropdownCheckData(title: "自定义"),
              ], 
              child: CardMinBoxWidget(
                title: weekSystemList[weekSysteIndex].title,
                backColor: AppTheme.cBgTertiary.color,
                borderColor: AppTheme.cBorderPrimary.color,
                child: SvgPicture.asset("assets/svg/public/icon_code.svg", width: 24.wMin),
              ),
            ),
          ],
        ),
    
        SizedBox(height: 24.wMin),
        
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "什么时间？",
              style: TextStyle(
                fontSize: 24.wMin,
                color: AppTheme.cTextPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12.wMin),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CardLearningReminderListWidget(
                    title: "工作日",
                    weeks: workWeekList,
                    list: workDay,
                    onRemove: (index) {
                      workDay.removeAt(index);
                      if(mounted) setState(() {});
                      widget.onTap?.call(workDay, holidayDay, workWeekList, restWeekList, holidaySwitch);
                    },
                    onAdd: () {
                      if(workWeekList.isEmpty){
                        ToastUtils.showToast(text: "请先选择工作日周期");
                        return;
                      }
                      selectHM(workDay);
                    },
                  ),
                ),
                SizedBox(width: 16.wMin),
                Expanded(
                  child: CardLearningReminderListWidget(
                    title: "休息日",
                    weeks: restWeekList,
                    list: holidayDay,
                    onRemove: (index) {
                      holidayDay.removeAt(index);
                      if(mounted) setState(() {});
                      widget.onTap?.call(workDay, holidayDay, workWeekList, restWeekList, holidaySwitch);
                    },
                    onAdd: () {
                      if(restWeekList.isEmpty){
                        ToastUtils.showToast(text: "请先选择休息日周期");
                        return;
                      }
                      selectHM(holidayDay);
                    },
                  ),
                ),
              ],
            ),
                
          ],
        ),
      
        SizedBox(height: 24.wMin),
      
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "自定义提醒周期",
              style: TextStyle(
                fontSize: 24.wMin,
                color: AppTheme.cTextPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 12.wMin),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.wMin, vertical: 16.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.wMin),
                color: AppTheme.cBgTertiary.color,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(weekSeelctList.length, (index){
                      return TapScaleWidget(
                        onTap: () => selectWeekItem(index),
                        sclae: 1.1,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 100),
                          width: 48.wMin,
                          height: 48.wMin,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              width: 1.wMin,
                              color: weekSeelctList[index].selected ? AppTheme.cBorderBrand : Colors.transparent,
                            ),
                          ),
                          child: AutoSizeText(
                            weekTextList[weekSeelctList[index].week - 1],
                            maxLines: 1,
                            minFontSize: 3,
                            style: TextStyle(
                              fontSize: 24.wMin,
                              fontWeight: FontWeight.w500,
                              color: weekSeelctList[index].selected ? AppTheme.cTextBrand : AppTheme.cTextSecondary,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  SizedBox(height: 16.wMin),
                  CardTitleSwitchWidget(
                    title: "智能把节假日当作休息日",
                    subContent: "节假日（春节、国庆等）当做休息日提醒，同时调休上班日当做工作日提醒",
                    value: holidaySwitch,
                    onChanged: (value) {
                      holidaySwitch = value;
                      if(mounted) setState(() {});
                      widget.onTap?.call(workDay, holidayDay, workWeekList, restWeekList, holidaySwitch);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
          
      ],
    );
  }
}
