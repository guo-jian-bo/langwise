import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';


/// 确认会员信息弹窗
class ConfirmUpgradeDialog{

  static Future<bool> show({
    required BuildContext context,
    String? needLevel,
    String? needDuration,
    Color? needColor,
  }) async{
    bool? res = await showCupertinoDialog<bool?>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return ConfirmUpgradeDialogWidget(
          needLevel: needLevel,
          needDuration: needDuration,
          needColor: needColor,
        );
      },
    );

    return res??false;
  }

}

class ConfirmUpgradeDialogWidget extends StatefulWidget {
  final String? needLevel;
  final String? needDuration;
  final Color? needColor;
  const ConfirmUpgradeDialogWidget({super.key, this.needLevel, this.needDuration, this.needColor});

  @override
  State<ConfirmUpgradeDialogWidget> createState() => _ConfirmUpgradeDialogWidgetState();
}

class _ConfirmUpgradeDialogWidgetState extends State<ConfirmUpgradeDialogWidget> {


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
                "请确认您的升级信息",
                style: TextStyle(
                  fontSize: 28.wMin,
                  color: AppTheme.cTextPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 40.wMin),
              Column(
                spacing: 24.wMin,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "会员等级",
                        style: TextStyle(
                          fontSize: 24.wMin,
                          color: AppTheme.cTextPrimary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        widget.needLevel??"",
                        style: TextStyle(
                          fontSize: 28.wMin,
                          color: widget.needColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "会员有效期",
                        style: TextStyle(
                          fontSize: 24.wMin,
                          color: AppTheme.cTextPrimary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        widget.needDuration??"",
                        style: TextStyle(
                          fontSize: 28.wMin,
                          color: widget.needColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 64.wMin),
              Row(
                spacing: 18.wMin,
                children: [
                  Expanded(
                    child: ButtonWidget(
                      text: "取消",
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
                      text: "确认升级",
                      sclae: 1.03,
                      color: AppTheme.cSurfaceBrand,
                      borderRadius: 8.wMin,
                      height: 56.wMin,
                      fontSize: 20.wMin,
                      fontColor: AppTheme.cStaticWhite,
                      fontWeight: FontWeight.w500,
                      onTap: () {
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
}