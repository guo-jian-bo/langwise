

import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/https/https.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../../../theme/theme.dart';
import '../../../../../utils/utils.dart';

/// 邀请好友弹窗
class InviteFriendsDialog{

    static Future<bool> show({
      required BuildContext context,
      bool isEdit = false,
    }) async{
      bool? res = await showCupertinoDialog(
        context: context,
        builder: (context) {
          return const InviteFriendsDialogWidget();
        },
      );

      return res ?? false;
    }

}


class InviteFriendsDialogWidget extends StatefulWidget {
  const InviteFriendsDialogWidget({super.key});

  @override
  State<InviteFriendsDialogWidget> createState() => _InviteFriendsDialogWidgetState();
}

class _InviteFriendsDialogWidgetState extends State<InviteFriendsDialogWidget> {

  String callingCode = "86";
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController codeController = TextEditingController();

  Timer? codeDownTimer;
  int codeDownTime = 60;
  bool isGetCode = false;

  @override
  void initState() {
    super.initState();
  }

  /// 选择国家区号码
  Future<void> onSelectCallingCode(BuildContext context) async{
    String? res = await InternationalAreaCodeDialog.show(
      context: context,
      initialSelectedCode: callingCode,
    );
    if(res == null) return;
    callingCode = res;
    if(mounted) setState(() {});
  }

  Future<void> getCode() async{
    if(isGetCode) return;
    FocusScope.of(context).requestFocus(FocusNode());

    if(phoneController.text.isEmpty){
      return ToastUtils.showToast(text: "请输入手机号");
    }

    if (!GetUtils.isPhoneNumber(phoneController.text.trim())) {
      ToastUtils.showToast(text: "手机号格式不正确");
      return;
    }
    
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "callingCode": callingCode,
        "phoneNumber": phoneController.text.trim(),
      };
      bool res = await ActivitiesRequest.referralSmsSend(reqData: reqData);
      if(!res) return;
      ToastUtils.showToast(text: "验证码发送成功", type: ToastType.success);
    } finally{
      ToastUtils.hideLoading();
    }
    
    isGetCode = true;
    if(mounted) setState(() {});
    codeDownTimer?.cancel();
    codeDownTimer = null;
    codeDownTimer = Timer.periodic(const Duration(seconds: 1), (timer) { 
      codeDownTime--;
      if(mounted) setState(() {});
      if(codeDownTime == 0){
        timer.cancel();
        codeDownTimer = null;
        codeDownTime = 60;
        isGetCode = false;
        if(mounted) setState(() {});
      }
    });
  }

  /// 提交
  Future<void> submit() async{

    if(phoneController.text.isEmpty){
      return ToastUtils.showToast(text: "请输入手机号");
    }

    if (!GetUtils.isPhoneNumber(phoneController.text.trim())) {
      ToastUtils.showToast(text: "手机号格式不正确");
      return;
    }

    if(codeController.text.isEmpty){
      ToastUtils.showToast(text: "请输入验证码");
      return;
    }

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "token": codeController.text,
        "callingCode": callingCode,
        "phoneNumber": phoneController.text.trim(),
      };
      bool res = await ActivitiesRequest.referralSmsTokenBind(reqData: reqData);
      if(!res) return;
      ToastUtils.showToast(text: "邀请成功", type: ToastType.success);
      Get.back(result: true);
    } finally{
      ToastUtils.hideLoading();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cOverlayBackground,
      body: Center(
        child: Container(
          width: 600.wMin,
          padding: EdgeInsets.all(32.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.wMin),
            color: AppTheme.cBgSecondary.color,
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
                      "邀请好友",
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
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.cSurfaceTertiary.color,
                      ),
                      child: SvgPicture.asset(
                        "assets/svg/public/x.svg",
                        width: 24.wMin,
                        height: 24.wMin,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24.wMin),

              CardInputWidget(
                title: "输入好友手机号发送邀请",
                controller: phoneController,
                hintText: "请输入好友手机号",
                keyboardType: TextInputType.phone,
                maxLength: 11,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onClean: () {
                  phoneController.clear();
                },
                prefixIcon: Container(
                  margin: EdgeInsets.only(right: 16.wMin),
                  child: TapScaleWidget(
                    onTap: () {
                      onSelectCallingCode(context);
                    },
                    sclae: 1,
                    child: Container(
                      height: 70.wMin,
                      padding: EdgeInsets.only(left: 16.wMin),
                      color: Colors.transparent,
                      child: Row(
                        spacing: 16.wMin,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "+$callingCode",
                            style: TextStyle(
                              color: AppTheme.cTextPrimary.color,
                              fontSize: 24.wMin,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SvgPicture.asset(
                            "assets/svg/public/icon_arrow_down.svg",
                            width: 24.wMin,
                            colorFilter: ColorFilter.mode(AppTheme.cTextPrimary.color, BlendMode.srcIn),
                          ),
                          Container(
                            width: 1.5.wMin,
                            height: 24.wMin,
                            color: AppTheme.cTextSecondary.color,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              

              SizedBox(height: 24.wMin),

              Row(
                spacing: 12.wMin,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: CardInputWidget(
                      title: "短信验证码",
                      hintText: "请输入6位验证码",
                      maxLength: 6,
                      keyboardType: const TextInputType.numberWithOptions(decimal: false),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      controller: codeController,
                      onClean: () {
                        codeController.clear();
                      },
                    ),
                  ),
                  ButtonWidget(
                    text: !isGetCode ? "获取验证码" : "$codeDownTime s",
                    height: 72.wMin,
                    width: 177.wMin,
                    borderRadius: 12.wMin,
                    color: isGetCode ? AppTheme.cBgTertiary : AppTheme.cFeedbackDefaultBackground,
                    fontColor: AppTheme.cFeedbackDefaultText,
                    fontSize: 24.wMin,
                    fontWeight: FontWeight.w400,
                    sclae: 1.02,
                    onTap: isGetCode ? null : () {
                      getCode();
                    },
                  ),
                ],
              ),

              SizedBox(height: 48.wMin),

              Row(
                spacing: 12.wMin,
                children: [
                  Expanded( 
                    child: ButtonWidget(
                      text: "取消",
                      height: 56.wMin,
                      borderRadius: 8.wMin,
                      color: AppTheme.cBgTertiary.color,
                      fontColor: AppTheme.cTextPrimary.color,
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
                      text: "确定",
                      height: 56.wMin,
                      borderRadius: 8.wMin,
                      color: AppTheme.cSurfaceBrand.color,
                      fontColor: AppTheme.cStaticWhite.color,
                      fontSize: 20.wMin,
                      fontWeight: FontWeight.w500,
                      sclae: 1.02,
                      onTap: () {
                        submit();
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