import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';

class ConfirmMemberOrderModel{
  final String name;
  final String? value;

  ConfirmMemberOrderModel({
    required this.name,
    this.value,
  });
}

class ConfirmMemberOrderDialog{
  static Future<bool> show({
    required BuildContext context,
    required List<ConfirmMemberOrderModel> datas,
    String? kindReminder,
    Color? valueTextColor,
  }) async {
    bool? res = await showCupertinoDialog<bool?>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return ConfirmMemberOrderDialogWidget(
          datas: datas,
          valueTextColor: valueTextColor,
          kindReminder: kindReminder,
        );
      },
    );

    return res??false;
  }
}

class ConfirmMemberOrderDialogWidget extends StatefulWidget {
  final List<ConfirmMemberOrderModel> datas;
  final Color? valueTextColor;
  final String? kindReminder;
  const ConfirmMemberOrderDialogWidget({super.key, required this.datas, this.valueTextColor, this.kindReminder});

  @override
  State<ConfirmMemberOrderDialogWidget> createState() => _ConfirmMemberOrderDialogWidgetState();
}

class _ConfirmMemberOrderDialogWidgetState extends State<ConfirmMemberOrderDialogWidget> {
  Timer? timer;
  int countdown = 5;
  bool buttonFlag = true;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      countdown--;
      if(mounted) setState(() {});
      if(countdown <= 0){
        timer.cancel();
        buttonFlag = false;
        if(mounted) setState(() {});
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    
    return Material(
      color: AppTheme.cOverlayBackground,
      child: Center(
        child: Container(
          width: 640.wMin,
          padding: EdgeInsets.all(32.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.wMin),
            color: AppTheme.cBgSecondary,
            border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "请确认您的会员订单",
                style: TextStyle(
                  fontSize: 28.wMin,
                  color: AppTheme.cTextPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 40.wMin),
              Column(
                spacing: 16.wMin,
                children: List.generate(widget.datas.length, (index){
                  return _buildRowWidget(widget.datas[index]);
                }),
              ),

              SizedBox(height: 24.wMin),

              Visibility(
                visible: widget.kindReminder != null && widget.kindReminder!.isNotEmpty,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 16.wMin, vertical: 24.wMin),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.wMin),
                    color: AppTheme.cFeedbackWarningBackground,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "温馨提示",
                        style: TextStyle(
                          fontSize: 24.wMin,
                          color: AppTheme.cFeedbackWarningText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 12.wMin),
                      Text(
                        widget.kindReminder??"",
                        style: TextStyle(
                          fontSize: 24.wMin,
                          color: AppTheme.cFeedbackWarningText,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 32.wMin),
              Row(
                spacing: 18.wMin,
                children: [
                  Expanded(
                    child: ButtonWidget(
                      text: "去调整",
                      sclae: 1.03,
                      color: AppTheme.cBgTertiary,
                      borderRadius: 8.wMin,
                      height: 56.wMin,
                      fontSize: 20.wMin,
                      fontColor: AppTheme.cTextPrimary,
                      fontWeight: FontWeight.w500,
                      onTap: () => Get.back(result: false),
                    ),
                  ),
                  Expanded(
                    child: ButtonWidget(
                      text: "确认无误${!buttonFlag ? '' : '(${countdown}s)'}",
                      sclae: 1.03,
                      color: AppTheme.cSurfaceBrand.withValues(alpha: buttonFlag ? 0.3 : 1),
                      borderRadius: 8.wMin,
                      height: 56.wMin,
                      fontSize: 20.wMin,
                      fontColor: AppTheme.cTextPrimary,
                      fontWeight: FontWeight.w500,
                      onTap: buttonFlag ? null : () {
                        Get.back(result: true);
                      },
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


  Widget _buildRowWidget(ConfirmMemberOrderModel data){
    if(data.value == null) return Container();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          data.name,
          style: TextStyle(
            fontSize: 24.wMin,
            color: AppTheme.cTextPrimary,
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          data.value??"",
          style: TextStyle(
            fontSize: 28.wMin,
            color: widget.valueTextColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}