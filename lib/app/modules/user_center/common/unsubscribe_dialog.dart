import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/stores/user.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';

class UnsubscribeDialog{

  static Future<bool> show(BuildContext context) async{
    bool? res = await showCupertinoDialog<bool?>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return const UnsubscribeDialogWidget();
      },
    );
    return res??false;
  }

}

class UnsubscribeDialogWidget extends StatefulWidget {
  const UnsubscribeDialogWidget({super.key});

  @override
  State<UnsubscribeDialogWidget> createState() => _UnsubscribeDialogWidgetState();
}

class _UnsubscribeDialogWidgetState extends State<UnsubscribeDialogWidget> {
  Timer? timer;
  int countdown = 10;
  bool deleteButtonFlag = false;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      countdown--;
      if(mounted) setState(() {});
      if(countdown <= 0){
        timer.cancel();
        deleteButtonFlag = true;
      }
    });
  }
  

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.cOverlayBackground,
      child: Center(
        child: Container(
          width: 600.wMin,
          padding: EdgeInsets.all(32.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.wMin),
            color: AppTheme.cBgSecondary,
            border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          "assets/svg/public/icon_warning.svg",
                          width: 44.wMin,
                          height: 44.wMin,
                        ),
                        SizedBox(width: 12.wMin),
                        Expanded(
                          child: Text(
                            "您确定要注销账号吗？",
                            style: TextStyle(
                              fontSize: 28.wMin,
                              color: AppTheme.cTextPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TapScaleWidget(
                    sclae: 1.05,
                    onTap: () => Get.back(),
                    child: Container(
                      width: 42.wMin,
                      height: 42.wMin,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.cBgActive,
                      ),
                      child: SvgPicture.asset(
                        "assets/svg/public/x.svg",
                        width: 24.wMin,
                        height: 24.wMin,
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(height: 16.wMin),
              Obx((){
                UserInfoEntity userInfo = UserStore.to.userInfo.value;
                return Row(
                  spacing: 40.wMin,
                  children: [
                    Text(
                      "用户ID：${userInfo.userId??''}",
                      style: TextStyle(
                        fontSize: 20.wMin,
                        color: AppTheme.cTextSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      "用户名：${userInfo.nickname??''}",
                      style: TextStyle(
                        fontSize: 20.wMin,
                        color: AppTheme.cTextSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                );
              }),
              SizedBox(height: 16.wMin),
              Container(
                padding: EdgeInsets.all(24.wMin),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.wMin),
                  color: AppTheme.cFeedbackErrorBackground,
                ),
                child: Text(
                  "温馨提示：注销账户后，您的所有数据和账户余额将被全部丢弃。账户一旦注销不可恢复，为避免您的个人损失，谨慎操作。",
                  style: TextStyle(
                    fontSize: 20.wMin,
                    color: AppTheme.cFeedbackErrorText,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              SizedBox(height: 32.wMin),
              Row(
                spacing: 12.wMin,
                children: [
                  Expanded( 
                    child: ButtonWidget(
                      text: "取消",
                      height: 56.wMin,
                      borderRadius: 8.wMin,
                      color: AppTheme.cBgTertiary,
                      fontColor: AppTheme.cTextPrimary,
                      fontSize: 20.wMin,
                      fontWeight: FontWeight.w500,
                      sclae: 1.02,
                      onTap: () {
                        Get.back();
                      },
                    ),
                  ),
                  Expanded( 
                    child: ButtonWidget(  
                      text: "申请注销账户${countdown == 0 ? '' : '($countdown)'}",
                      height: 56.wMin,
                      borderRadius: 8.wMin,
                      color: countdown != 0 ? AppTheme.cFeedbackErrorBackground : AppTheme.cFeedbackErrorIcon,
                      fontColor: AppTheme.cStaticWhite,
                      fontSize: 20.wMin,
                      fontWeight: FontWeight.w500,
                      sclae: 1.02,
                      onTap: countdown != 0 ? null : () {
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