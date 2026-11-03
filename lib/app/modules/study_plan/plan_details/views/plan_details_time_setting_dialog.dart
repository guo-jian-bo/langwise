import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/widgets/date_time_picker_widget.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../theme/theme.dart';
import '../../../../../utils/utils.dart';

class PlanDetailsTimeSettingData{
  /// 工作日的周数 1 - 7
  List<int>? workWeekList;
  /// 工作日的时间
  List<DateTime>? workReminderTimeList;
  /// 工作日 每日时长 分钟
  int? workDuration;

  /// 工作日推荐 每日时长 分钟
  int? workDurationRecommend;
  
  /// 休息日的周数 1 - 7
  List<int>? restWeekList;
  /// 休息日的时间
  List<DateTime>? restReminderTimeList;
  /// 休息日 每日时长 分钟
  int? restDuration;

  /// 休息日推荐 每日时长 分钟
  int? restDurationRecommend;

  /// 是否开启智能节假日
  bool isHolidaySwitch;

  PlanDetailsTimeSettingData({
    this.workWeekList,
    this.workReminderTimeList,
    this.restWeekList,
    this.restReminderTimeList,
    this.workDuration,
    this.restDuration,
    this.workDurationRecommend,
    this.restDurationRecommend,
    this.isHolidaySwitch = true,
  });
}

class PlanDetailsTimeSettingDialog{

  static Future<PlanDetailsTimeSettingData?> show({
    required BuildContext context,
    PlanDetailsTimeSettingData? initData,
  }) async{

    return await showCupertinoDialog<PlanDetailsTimeSettingData?>(
      context: context,
      builder: (context) {
        return PlanDetailsTimeSettingDialogWidget(initData: initData);
      },
    );

  }

}

class PlanDetailsTimeSettingDialogWidget extends StatefulWidget {
  /// 初始化数据
  final PlanDetailsTimeSettingData? initData;

  const PlanDetailsTimeSettingDialogWidget({super.key, this.initData});

  @override
  State<PlanDetailsTimeSettingDialogWidget> createState() => _PlanDetailsTimeSettingDialogWidgetState();
}

class _PlanDetailsTimeSettingDialogWidgetState extends State<PlanDetailsTimeSettingDialogWidget> {
  static const int _minDuration = 5;
  static const int _maxDuration = 60;

  List<String> weekList = DateFormatUtil.getWeekList();
  final List<IconDropdownCheckData> weekSystemList = [
    IconDropdownCheckData(title: "双休制"),
    IconDropdownCheckData(title: "自定义"),
  ];

  /// 学习时间安排索引
  int weekSysteIndex = 0;

  /// 工作日的周
  List<int> weekSelectList = [1,2,3,4,5];
  /// 工作日 每日时长
  TextEditingController weekDurationController = TextEditingController(text: "15");
  /// 工作日 提醒时间
  List<DateTime> weekReminderTimeList = [];

  /// 休息日的周
  List<int> restWeekSelectList = [6, 7];
  /// 休息日 每日时长
  TextEditingController restDurationController = TextEditingController(text: "15");
  /// 休息日 提醒时间
  List<DateTime> restReminderTimeList = [];

  /// 是否开启智能节假日
  bool isHolidaySwitch = true;

  @override
  void initState(){
    super.initState();
    if (widget.initData != null) {
      if(widget.initData!.workWeekList != null){
        weekSelectList = widget.initData!.workWeekList!;
      }
      if(widget.initData!.workReminderTimeList != null){
        weekReminderTimeList = widget.initData!.workReminderTimeList ?? [];
      }
      if(widget.initData!.restWeekList != null){
        restWeekSelectList = widget.initData!.restWeekList!;
      }
      if(widget.initData!.restReminderTimeList != null){
        restReminderTimeList = widget.initData!.restReminderTimeList ?? [];
      }
      if(widget.initData!.workDuration != null){
        weekDurationController.text = widget.initData!.workDuration!.toString();
      }
      if(widget.initData!.restDuration != null){
        restDurationController.text = widget.initData!.restDuration!.toString();
      }
      isHolidaySwitch = widget.initData!.isHolidaySwitch;
    }
  }


  /// 添加提醒时间
  Future<void> _addReminderTime(List<DateTime> timeList) async{
    final picked = await DateTimePickerUtils.showHM(context: context, initialDate: DateTime.now(), looping: true);
    if (picked == null) return;
    timeList.add(picked);
    if(mounted) setState(() {});
  }

  /// 确定
  void _confirm(){
    FocusScope.of(context).unfocus();

    if(weekDurationController.text.isEmpty || restDurationController.text.isEmpty){
      ToastUtils.showToast(text: "请输入每日时长");
      return;
    }

    int workDuration = int.tryParse(weekDurationController.text) ?? 10;
    int restDuration = int.tryParse(restDurationController.text) ?? 10;

    if(workDuration < _minDuration || workDuration > _maxDuration){
      ToastUtils.showToast(text: "学习时长必须在 $_minDuration - $_maxDuration 之间");
      return;
    }
    if(restDuration < _minDuration || restDuration > _maxDuration){
      ToastUtils.showToast(text: "学习时长必须在 $_minDuration - $_maxDuration 之间");
      return;
    }

    PlanDetailsTimeSettingData result = PlanDetailsTimeSettingData(
      workWeekList: weekSelectList,
      workReminderTimeList: weekReminderTimeList,
      restWeekList: restWeekSelectList,
      restReminderTimeList: restReminderTimeList,
      workDuration: int.tryParse(weekDurationController.text),
      restDuration: int.tryParse(restDurationController.text),
      isHolidaySwitch: isHolidaySwitch,
    );

    Get.back(result: result);
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: DialogUserWidget(
        physics: const ClampingScrollPhysics(),
        width: 960.wMin,
        title: "调整时间安排",
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 32.wMin),
          child: Column(
            children: [
          
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.wMin),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.wMin),
                  color: AppTheme.cSurfaceLayerElevated2.color,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWeekSettingWidget(),
                    SizedBox(height: 24.wMin),
                    _buildCustomWeekSettingWidget(),
                    SizedBox(height: 24.wMin),
                    _buildHolidayWidget(),
                  ],
                ),
              ),
      
              SizedBox(height: 16.wMin),
      
              Row(
                spacing: 16.wMin,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTimesItemWidget(
                    title: "工作日",
                    weeks: weekSelectList,
                    durationController: weekDurationController,
                    times: weekReminderTimeList,
                    durationDesc: widget.initData?.workDurationRecommend??15,
                  ),
                  _buildTimesItemWidget(
                    title: "休息日",
                    weeks: restWeekSelectList,
                    durationController: restDurationController,
                    times: restReminderTimeList,
                    durationDesc: widget.initData?.restDurationRecommend??15,
                  ),
                ],
              ),

              SizedBox(height: 16.wMin),

              ButtonWidget(
                text: "完成",
                width: double.infinity,
                height: 56.wMin,
                borderRadius: 8.wMin,
                color: AppTheme.cSurfaceBrand.color,
                fontSize: 24.wMin,
                fontWeight: FontWeight.w500,
                sclae: 1.01,
                onTap: _confirm,
              ),
      
              SizedBox(height: 32.wMin),
          
            ],
          ),
        ),
      ),
    );
  }

  int _normalizeDurationValue(String value) {
    final int duration = int.tryParse(value) ?? _minDuration;
    return duration.clamp(_minDuration, _maxDuration);
  }

  void _updateDurationController(TextEditingController controller, int value) {
    final String nextValue = value.clamp(_minDuration, _maxDuration).toString();
    if (controller.text == nextValue) return;
    controller.value = TextEditingValue(
      text: nextValue,
      selection: TextSelection.collapsed(offset: nextValue.length),
    );
  }

  void _adjustDuration(TextEditingController controller, int delta) {
    final int currentValue = _normalizeDurationValue(controller.text);
    _updateDurationController(controller, currentValue + delta);
  }

  /// 学习时间安排
  Widget _buildWeekSettingWidget(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "学习时间安排",
          style: TextStyle(
            color: AppTheme.cTextPrimary.color,
            fontSize: 18.wMin,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 6.wMin),
        IconDropdownCheckWidget(
          sclae: 1,
          selectIndex: weekSysteIndex,
          onTap: (data, index) {
            weekSysteIndex = index;
            if (mounted) {
              setState(() {
                if (weekSysteIndex == 0) {
                  weekSelectList.clear();
                  weekSelectList.addAll({1, 2, 3, 4, 5});
                  restWeekSelectList.clear();
                  restWeekSelectList.addAll({6, 7});
                } 
              });
            }
          },
          items: weekSystemList,
          child: CardMinBoxWidget(
            title: weekSystemList[weekSysteIndex].title,
            backColor: AppTheme.cSurfaceLayerBase2.color,
            borderColor: AppTheme.cBorderPrimary.color,
            child: SvgPicture.asset(
              "assets/svg/public/icon_arrow_down.svg", 
              width: 24.wMin,
              colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
            ),
          ),
        ),
      ],
    );
  }

  /// 自定义工作日
  Widget _buildCustomWeekSettingWidget(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "学习时间安排",
          style: TextStyle(
            color: AppTheme.cTextPrimary.color,
            fontSize: 18.wMin,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 6.wMin),
        Row(
          spacing: 10.wMin,
          children: List.generate(weekList.length, (index){
            return _buildCustomWeekSettingItemWidget(index);
          }),
        ),

      ],
    );
  }

  Widget _buildCustomWeekSettingItemWidget(int index){
    bool isSelected = weekSelectList.contains(index + 1);
    return Expanded(
      child: TapScaleWidget(
        onTap: () {
          
          if (weekSelectList.contains(index + 1)) {
            weekSelectList.remove(index + 1);
            restWeekSelectList.add(index + 1);
          } else {
            if(restWeekSelectList.length == 1){
              ToastUtils.showToast(text: "至少保留一个休息日");
              return;
            }
            weekSelectList.add(index + 1);
            restWeekSelectList.remove(index + 1);
          }
          if (!weekSelectList.contains(6) && !weekSelectList.contains(7) && weekSelectList.length == 5) {
            weekSysteIndex = 0;
          } else {
            weekSysteIndex = 1;
          }
          weekSelectList.sort();
          restWeekSelectList.sort();
          setState(() {});
        },
        sclae: 1.02,
        child: Container(
          height: 52.wMin,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.wMin),
            color: isSelected ? AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2) : AppTheme.cSurfaceLayerBase2.color,
            border: Border.all(
              color: isSelected ? AppTheme.cSurfaceBrand.color.withValues(alpha: 0.6) : AppTheme.cBorderSubtle.color,
              width: 0.8.wMin,
            ),
          ),
          child: Text(
            weekList[index],
            style: TextStyle(
              color: isSelected ? AppTheme.cTextBrand.color : AppTheme.cTextSecondary.color,
              fontSize: 20.wMin,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  /// 智能节假日
  Widget _buildHolidayWidget(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "智能节假日",
              style: TextStyle(
                color: AppTheme.cTextPrimary.color,
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(width: 8.wMin),
            Text(
              "只支持中国法定节假日",
              style: TextStyle(
                color: AppTheme.cTextSecondary.color,
                fontSize: 18.wMin,
                fontWeight: FontWeight.w400,
              ),
            ),
            const Spacer(),
            CardSwitchWidget(
              value: isHolidaySwitch,
              switchActiveColor: AppTheme.cSurfaceBrand.color,
              switchInactiveColor: AppTheme.cSurfaceLayerBase2.color,
              onChanged: (value){
                isHolidaySwitch = value;
                setState(() {});
              },
            ),

          ],
        ),
        Text(
          "节假日（春节、国庆等）当作休息日提醒，同时调休上班日当作工作日提醒",
          style: TextStyle(
            color: AppTheme.cTextTertiary.color,
            fontSize: 18.wMin,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildTimesItemWidget({
    required String title,
    required List<int> weeks,
    required TextEditingController durationController,
    required List<DateTime> times,
    required int durationDesc, // 推荐时长 分钟
  }){
    String weekStr = "";
    try {
      weekStr = weeks.map((e) => weekList[e - 1]).join("、");
    } catch (_) {}
    

    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.wMin),
          color: AppTheme.cSurfaceLayerElevated2.color,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.cTextPrimary.color,
                    fontSize: 18.wMin,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  weekStr,
                  style: TextStyle(
                    color: AppTheme.cTextBrand.color,
                    fontSize: 14.wMin,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            Container(
              height: 1.wMin,
              width: double.infinity,
              color: AppTheme.cBorderSubtle.color,
              margin: EdgeInsets.symmetric(vertical: 12.wMin),
            ),
            Row(
              children: [
                Text(
                  "每日时长",
                  style: TextStyle(
                    color: AppTheme.cTextSecondary.color,
                    fontSize: 16.wMin,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Spacer(),
                Text(
                  "推荐 $durationDesc 分钟/天",
                  style: TextStyle(
                    color: AppTheme.cTextSecondary.color,
                    fontSize: 16.wMin,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.wMin),
            _buildTimesItemDurationWidget(
              durationController,
              durationDesc,
            ),
            SizedBox(height: 4.wMin),
            Text(
              "范围 $_minDuration-$_maxDuration 分钟",
              style: TextStyle(
                color: AppTheme.cTextSecondary.color,
                fontSize: 16.wMin,
                fontWeight: FontWeight.w400,
              ),
            ),
            Container(
              height: 1.wMin,
              width: double.infinity,
              color: AppTheme.cBorderSubtle.color,
              margin: EdgeInsets.symmetric(vertical: 12.wMin),
            ),
            _buildTimesItemTimeListWidget(
              timeList: times,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimesItemDurationWidget(
    TextEditingController durationController,
    int durationDesc,
  ){
    return Container(
      padding: EdgeInsets.all(8.wMin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        color: AppTheme.cSurfaceLayerBase2.color,
      ),
      child: Row(
        children: [
          _buildTimesItemDurationButtonWidget(
            icon: Icons.remove,
            onTap: (){
              _adjustDuration(durationController, -5);
            },
          ),
          Expanded(
            child: SizedBox(
              height: 40.wMin,
              child: TextField(
                controller: durationController,
                style: TextStyle(
                  color: AppTheme.cTextBrand.color,
                  fontSize: 28.wMin,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLength: 2,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  counterText: "",
                  isDense: true,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                ),
              ),
            ),
          ),
          _buildTimesItemDurationButtonWidget(
            icon: Icons.add,
            onTap: (){
              _adjustDuration(durationController, 5);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimesItemDurationButtonWidget({
    required IconData icon,
    void Function()? onTap,
  }){
    return TapScaleWidget(
      onTap: onTap,
      sclae: 1.1,
      child: Container(
        width: 40.wMin,
        height: 40.wMin,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.wMin),
          color: AppTheme.cSurfaceBrand.color.withValues(alpha: 0.2),
        ),
        child: Icon(
          icon,
          color: AppTheme.cTextBrand.color,
          size: 28.wMin,
        ),
      ),
    );
  }


  /// 时间列表
  Widget _buildTimesItemTimeListWidget({
    required List<DateTime> timeList,
  }){
    return SizedBox(
      height: 250.wMin,
      child: Column(
        spacing: 10.wMin,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxHeight: 250.wMin - 10.wMin - 38.wMin,
            ),
            child: SingleChildScrollView(
              child: Column(
                spacing: 10.wMin,
                children: List.generate(timeList.length, (index){
                  return _buildTimesItemTimeListItemWidget(timeList, index);
                }),
              ),
            ),
          ),
          TapScaleWidget(
            onTap: () {
              _addReminderTime(timeList);
            },
            sclae: 1,
            child: _buildTimesItemTimeListAddWidget(),
          ),
        ],
      ),
    );
  }

  Widget _buildTimesItemTimeListItemWidget(List<DateTime> timeList, int index){
    return Row(
      spacing: 8.wMin,
      children: [
        TapScaleWidget(
          onTap: () {
            timeList.removeAt(index);
            if(mounted) setState(() {});
          },
          sclae: 1,
          child: Container(
            width: 38.wMin,
            height: 38.wMin,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.cSurfaceError.color.withValues(alpha: 0.2),
            ),
            child: Icon(
              Icons.remove,
              color: AppTheme.cSurfaceError.color,
              size: 24.wMin,
            ),
          ),
        ),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 8.wMin),
            height: 40.wMin,
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.wMin),
              color: AppTheme.cSurfaceLayerElevated2.color,
            ),
            child: Text(
              DateFormatUtil.formatStr(timeList[index], newPattern: "HH:mm"),
              style: TextStyle(
                color: AppTheme.cTextPrimary.color,
                fontSize: 18.wMin,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimesItemTimeListAddWidget(){
    return Container(
      color: Colors.transparent,
      child: Row(
        spacing: 8.wMin,
        children: [
          Container(
            width: 38.wMin,
            height: 38.wMin,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.cSurfaceSuccess.color,
            ),
            child: Icon(
              Icons.add,
              color: Colors.white,
              size: 20.wMin,
            ),
          ),
          Text(
            "添加提醒",
            style: TextStyle(
              color: AppTheme.cTextPrimary.color,
              fontSize: 18.wMin,
              fontWeight: FontWeight.w400,
            ),
          ),
      
        ],
      ),
    );
  }





}
