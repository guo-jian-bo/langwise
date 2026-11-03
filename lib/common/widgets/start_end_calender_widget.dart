import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import 'widgets.dart';

class StartEndCalenderData{
  final List<StartEndCalenderType> typeList;
  final List<StartEndCalenderType> valueList;
  String? initiType;
  String? initValue;

  StartEndCalenderData({
    required this.typeList,
    required this.valueList,
    this.initiType,
    this.initValue,
  });
}

class StartEndCalenderType{
  String value;
  String name;

  StartEndCalenderType({
    required this.value,
    required this.name,
  });
}


class StartEndMinButtonWidget extends StatefulWidget {
  final StartEndCalenderData data;
  final int? count;
  final void Function(StartEndCalenderData data)? onConfirm;
  const StartEndMinButtonWidget({super.key, required this.data, this.count, this.onConfirm});

  @override
  State<StartEndMinButtonWidget> createState() => _StartEndMinButtonWidgetState();
}

class _StartEndMinButtonWidgetState extends State<StartEndMinButtonWidget> {
  String selectType = "";
  String selectValue= "";

  @override
  void initState() {
    super.initState();
    if(widget.data.initiType != null){
      selectType = widget.data.initiType!;
    }
    
    if(widget.data.initValue != null){
      selectValue = widget.data.initValue!;
    }
  }

  void _showCalender(BuildContext ctx) {
    // DateTimePickerUtils.showStartEndCalender(
    //   context: ctx,
    // );

    BotToast.showAttachedWidget(
      targetContext: context,
      preferDirection: PreferDirection.leftBottom,
      allowClick: false,
      onlyOne: true,
      // verticalOffset: 10.wMin,
      attachedBuilder: (cancelFunc) {
        return StartEndCalenderMenuWidget(
          data: widget.data,
          cancelFunc: cancelFunc,
          onConfirm: (data) {
            selectType = data.initiType??"";
            selectValue = data.initValue??"";
            if(mounted) setState(() {});
            
            widget.onConfirm?.call(data);

          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    String value = "";
    if(selectType.isNotEmpty){
      value = widget.data.valueList.firstWhere((element) => element.value == selectValue).name;
    }

    return Builder(
      builder: (context) {
        return TapScaleWidget(
          onTap: () {
            _showCalender(context);
          },
          sclae: 1,
          child: Container(
            height: 40.wMin,
            padding: EdgeInsets.symmetric(horizontal: 4.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.wMin),
              color: AppTheme.cBgQuaternary.color,
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  "assets/svg/public/icon_caret_down.svg",
                  width: 24.wMin,
                ),
                Text(
                  "$value ",
                  style: TextStyle(
                    color: AppTheme.cTextSecondary.color,
                    fontSize: 20.wMin,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  widget.count?.toString()??"",
                  style: TextStyle(
                    color: AppTheme.cFeedbackErrorText.color,
                    fontSize: 20.wMin,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


class StartEndCalenderWidget extends StatefulWidget {
  final StartEndCalenderData data;
  final void Function(StartEndCalenderData data)? onConfirm;
  /// 选择开始和结束时间的按钮
  const StartEndCalenderWidget({
    super.key,
    required this.data,
    this.onConfirm,
  });

  @override
  State<StartEndCalenderWidget> createState() => _StartEndCalenderWidgetState();
}

class _StartEndCalenderWidgetState extends State<StartEndCalenderWidget> {

  String selectType = "";
  String selectValue= "";

  @override
  void initState() {
    super.initState();
    if(widget.data.initiType != null){
      selectType = widget.data.initiType!;
    }
    
    if(widget.data.initValue != null){
      selectValue = widget.data.initValue!;
    }
  }

  void _showCalender(BuildContext ctx) {
    // DateTimePickerUtils.showStartEndCalender(
    //   context: ctx,
    // );

    BotToast.showAttachedWidget(
      targetContext: context,
      preferDirection: PreferDirection.bottomLeft,
      allowClick: false,
      onlyOne: true,
      verticalOffset: 10.wMin,
      attachedBuilder: (cancelFunc) {
        return StartEndCalenderMenuWidget(
          data: widget.data,
          cancelFunc: cancelFunc,
          onConfirm: (data) {
            selectType = data.initiType??"";
            selectValue = data.initValue??"";
            if(mounted) setState(() {});
            widget.onConfirm?.call(data);

          },
        );
      },
    );
  }
  
  
  @override
  Widget build(BuildContext context) {

    String name = "";
    String value = "";
    if(selectType.isNotEmpty){
      name = widget.data.typeList.firstWhere((element) => element.value == selectType).name;
    }
    if(selectValue.isNotEmpty){
      value = widget.data.valueList.firstWhere((element) => element.value == selectValue).name;
    }

    return Builder(
      builder: (ctx) {
        return TapScaleWidget(
          onTap: () {
            _showCalender(ctx);
          },
          sclae: 1,
          child: Container(
            width: 350.wMin,
            height: 54.wMin,
            padding: EdgeInsets.all(5.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999.wMin),
              color: AppTheme.cBgTertiary.color,
            ),
            child: Row(
              children: [
                Container(
                  height: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 12.wMin),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999.wMin),
                    color: AppTheme.cFeedbackDefaultBackground.color,
                  ),
                  child: Row(
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 24.wMin,
                          color: AppTheme.cTextPrimary.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SvgPicture.asset(
                        "assets/svg/public/icon_arrow_down.svg",
                        width: 24.wMin,
                        colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
                      )
                    ],
                  ),
                ),

                Expanded(
                  child: Center(
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 24.wMin,
                        color: AppTheme.cTextPrimary.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),


              ],
            ),
          ),
        );
      }
    );
  }
}


class StartEndCalenderMenuWidget extends StatefulWidget {
  final void Function() cancelFunc;
  final StartEndCalenderData data;
  final void Function(StartEndCalenderData data)? onConfirm;
  const StartEndCalenderMenuWidget({
    super.key,
    required this.cancelFunc,
    required this.data,
    this.onConfirm,
  });

  @override
  State<StartEndCalenderMenuWidget> createState() => _StartEndCalenderMenuWidgetState();
}

class _StartEndCalenderMenuWidgetState extends State<StartEndCalenderMenuWidget> {

  String selectType = "";
  String selectValue = "";

  @override
  void initState() {
    super.initState();
    if(widget.data.initiType != null){
      selectType = widget.data.initiType!;
    }
    
    if(widget.data.initValue != null){
      selectValue = widget.data.initValue!;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 400.wMin,
        height: 475.wMin,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.wMin),
          color: AppTheme.cBgTertiary.color,
          boxShadow: [
            BoxShadow(
              color: AppTheme.cDark.color,
              blurRadius: 4.wMin,
              offset: Offset(0, 2.wMin),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      alignment: Alignment.topCenter,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(6.wMin),
                        child: Column(
                          children: List.generate(widget.data.typeList.length, (index){
                            return _buildButtonWidget(
                              title: widget.data.typeList[index].name,
                              isSelected: widget.data.typeList[index].value == selectType,
                              onTap: (){
                                setState(() {
                                  selectType = widget.data.typeList[index].value;
                                });
                              },
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.topCenter,
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(6.wMin),
                        child: Column(
                          children: List.generate(widget.data.valueList.length, (index){
                            return _buildButtonWidget(
                              title: widget.data.valueList[index].name,
                              isSelected: widget.data.valueList[index].value == selectValue,
                              onTap: (){
                                setState(() {
                                  selectValue = widget.data.valueList[index].value;
                                });
                              },
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(12.wMin),
              child: Row(
                spacing: 12.wMin,
                children: [
                  Expanded( 
                    child: ButtonWidget(
                      text: "取消",
                      height: 56.wMin,
                      borderRadius: 8.wMin,
                      color: AppTheme.cBgQuaternary.color,
                      fontColor: AppTheme.cTextPrimary,
                      fontSize: 20.wMin,
                      fontWeight: FontWeight.w500,
                      sclae: 1.02,
                      onTap: () {
                        widget.cancelFunc();
                      },
                    ),
                  ),
                  Expanded( 
                    child: ButtonWidget(
                      text: "确定",
                      height: 56.wMin,
                      borderRadius: 8.wMin,
                      color: AppTheme.cSurfaceBrand,
                      fontColor: AppTheme.cStaticWhite,
                      fontSize: 20.wMin,
                      fontWeight: FontWeight.w500,
                      sclae: 1.02,
                      onTap: () {
                        widget.data.initiType = selectType;
                        widget.data.initValue = selectValue;
                        widget.onConfirm?.call(widget.data);
                        widget.cancelFunc();
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

  Widget _buildButtonWidget({
    required String title,
    bool isSelected = false,
    void Function()? onTap,
  }){
    return TapScaleWidget(
      onTap: onTap,
      sclae: 1,
      child: Container(
        width: double.infinity,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(vertical: 10.wMin, horizontal: 10.wMin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.wMin),
          color: isSelected ? AppTheme.cBgQuaternary.color : Colors.transparent,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 24.wMin,
            color: AppTheme.cTextPrimary.color,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

}