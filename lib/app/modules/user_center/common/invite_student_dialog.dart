

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../theme/theme.dart';

class InviteStudentDialog{

  static Future<void> show(BuildContext context) async{
    await showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return const InviteStudentDialogWidget();
      },
    );
  }

}

class InviteStudentDialogWidget extends StatefulWidget {
  const InviteStudentDialogWidget({super.key});

  @override
  State<InviteStudentDialogWidget> createState() => _InviteStudentDialogWidgetState();
}

class _InviteStudentDialogWidgetState extends State<InviteStudentDialogWidget> {

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController inviteCodeController = TextEditingController();


  Future<void> sendInviteCode() async{
    
  }

  @override
  void dispose() {
    phoneController.dispose();
    inviteCodeController.dispose();
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
                    child: Text(
                      "邀请学员",
                      style: TextStyle(
                        fontSize: 28.wMin,
                        color: AppTheme.cTextPrimary,
                        fontWeight: FontWeight.w600,
                      ),
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
              CardInputWidget(
                title: "手机号码",
                hintText: "请输入手机号码",
                controller: phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onClean: () {
                  phoneController.clear();
                },
              ),
              SizedBox(height: 4.wMin),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "激活码",
                    style: TextStyle(
                      fontSize: 20.wMin,
                      color: AppTheme.cTextPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TapScaleWidget(
                    sclae: 1.03,
                    onTap: () {
                      sendInviteCode();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12.wMin),
                      color: Colors.transparent,
                      child: Text(
                        "发送激活码",
                        style: TextStyle(
                          fontSize: 16.wMin,
                          color: AppTheme.cBorderFocus,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              CardInputWidget(
                hintText: "请输入激活码",
                controller: inviteCodeController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onClean: () {
                  inviteCodeController.clear();
                },
              ),
              Text(
                "激活码已发送至该手机号，有效期为10分钟",
                style: TextStyle(
                  fontSize: 16.wMin,
                  color: AppTheme.cTextDisabled,
                  fontWeight: FontWeight.w400,
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
                      text: "邀请学员",
                      height: 56.wMin,
                      borderRadius: 8.wMin,
                      color: AppTheme.cFeedbackSuccessBackground,
                      fontColor: AppTheme.cStaticWhite,
                      fontSize: 20.wMin,
                      fontWeight: FontWeight.w500,
                      sclae: 1.02,
                      onTap: () {
                        Get.back();
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