
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';

class MemberUpdateComfirmationDialog{

  static Future<bool> show({
    required BuildContext context,
    String? currentLevel,
    String? needLevel,
    Color? currentColor,
    Color? needColor,
  }) async{
    bool? res = await showCupertinoDialog<bool?>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return MemberUpdateComfirmationDialogWidget(
          currentLevel: currentLevel,
          needLevel: needLevel,
          currentColor: currentColor,
          needColor: needColor,
        );
      },
    );

    return res??false;
  }

}

class MemberUpdateComfirmationDialogWidget extends StatefulWidget {
  final String? currentLevel;
  final String? needLevel;
  final Color? currentColor;
  final Color? needColor;
  const MemberUpdateComfirmationDialogWidget({super.key, this.currentLevel, this.needLevel, this.currentColor, this.needColor});

  @override
  State<MemberUpdateComfirmationDialogWidget> createState() => _MemberUpdateComfirmationDialogWidgetState();
}

class _MemberUpdateComfirmationDialogWidgetState extends State<MemberUpdateComfirmationDialogWidget> {
  @override
  Widget build(BuildContext context) {

    return Material(
      color: AppTheme.cOverlayBackground,
      child: Center(
        child: Container(
          width: 640.wMin,
          padding: EdgeInsets.all(40.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.wMin),
            color: AppTheme.cBgSecondary,
            border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "会员等级不足",
                style: TextStyle(
                  fontSize: 28.wMin,
                  color: AppTheme.cTextPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16.wMin),
              Container(
                padding: EdgeInsets.all(24.wMin),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.wMin),
                  color: AppTheme.cSurfaceTertiary,
                ),
                child: Column(
                  spacing: 14.wMin,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "当前会员等级：",
                          style: TextStyle(
                            fontSize: 18.wMin,
                            color: AppTheme.cTextTertiary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          widget.currentLevel??"",
                          style: TextStyle(
                            fontSize: 20.wMin,
                            color: widget.currentColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "需要会员等级：",
                          style: TextStyle(
                            fontSize: 18.wMin,
                            color: AppTheme.cTextTertiary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          widget.needLevel??"",
                          style: TextStyle(
                            fontSize: 20.wMin,
                            color: widget.needColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8.wMin),
              Container(
                width: double.infinity,
                alignment: Alignment.center,
                child: Text(
                  "您需要升级会员才能使用此视觉风格",
                  style: TextStyle(
                    fontSize: 20.wMin,
                    color: AppTheme.cTextSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              SizedBox(height: 40.wMin),
              Row(
                spacing: 18.wMin,
                children: [
                  Expanded(
                    child: ButtonWidget(
                      text: "取消",
                      sclae: 1.03,
                      color: AppTheme.cWhiteAlpha10,
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
                      text: "升级会员",
                      sclae: 1.03,
                      color: widget.needColor??AppTheme.cSurfaceBrand,
                      borderRadius: 8.wMin,
                      height: 56.wMin,
                      fontSize: 20.wMin,
                      fontColor: AppTheme.cTextPrimary,
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