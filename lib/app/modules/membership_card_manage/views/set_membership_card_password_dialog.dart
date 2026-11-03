import 'dart:async';

import 'package:api/entities/response.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/https/membership_card_manage.dart';
import 'package:langwise/common/https/user.dart';
import 'package:langwise/common/stores/user.dart';
import 'package:langwise/common/widgets/button_widgets.dart';
import 'package:langwise/common/widgets/card_public_widgets.dart';
import 'package:langwise/common/widgets/tap_scale_widget.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/toast_utils.dart';
import 'package:pinput/pinput.dart';
import 'package:ui_essentials/ui_essentials.dart';

/// 设置会员卡管理密码
class SetMembershipCardPasswordDialog {
  static Future<bool> show({
    required BuildContext context,
    bool isEdit = false,
  }) async {
    bool? res = await showCupertinoDialog(
      context: context,
      builder: (context) {
        return SetMembershipCardPasswordDialogWidget(
          isEdit: isEdit,
        );
      },
    );

    return res ?? false;
  }
}

class SetMembershipCardPasswordDialogWidget extends StatefulWidget {
  final bool isEdit;
  const SetMembershipCardPasswordDialogWidget({
    super.key,
    this.isEdit = false,
  });

  @override
  State<SetMembershipCardPasswordDialogWidget> createState() =>
      _SetMembershipCardPasswordDialogWidgetState();
}

class _SetMembershipCardPasswordDialogWidgetState
    extends State<SetMembershipCardPasswordDialogWidget> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController pinPwdController = TextEditingController();

  Timer? codeDownTimer;
  int codeDownTime = 60;
  bool isGetCode = false;

  @override
  void initState() {
    super.initState();
    phoneController.text = UserStore.to.userInfo.value.phone ?? "";
  }

  Future<void> getCode() async {
    if (isGetCode) return;

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "type": "8",
      };
      bool res = await UserRequest.setParentPasswordSendSmsCode(reqData);
      if (!res) return;
      ToastUtils.showToast(text: "验证码发送成功", type: ToastType.success);
    } finally {
      ToastUtils.hideLoading();
    }

    isGetCode = true;
    if (mounted) setState(() {});
    codeDownTimer?.cancel();
    codeDownTimer = null;
    codeDownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      codeDownTime--;
      if (mounted) setState(() {});
      if (codeDownTime == 0) {
        timer.cancel();
        codeDownTimer = null;
        codeDownTime = 60;
        isGetCode = false;
        if (mounted) setState(() {});
      }
    });
  }

  /// 提交
  Future<void> submit() async {
    if (codeController.text.isEmpty) {
      ToastUtils.showToast(text: "请输入验证码");
      return;
    }

    if (pinPwdController.text.isEmpty) {
      ToastUtils.showToast(text: "请输入密码");
      return;
    }

    if (pinPwdController.text.length < 6) {
      ToastUtils.showToast(text: "密码不能少于6位");
      return;
    }

    try {
      ToastUtils.showLoading();

      final ResponseEntity? res = await MembershipCardManageApi.setPassword(
        data: {
          'password': pinPwdController.text,
          'token': codeController.text,
        },
      );
      if (res == null) return;
      ToastUtils.showToast(text: "设置成功", type: ToastType.success);
      await UserStore.to.getUserInfo();
      Get.back(result: true);
    } finally {
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
                      widget.isEdit ? "重置代理商密码" : "设置代理商密码",
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
                  ),
                ],
              ),
              SizedBox(height: 24.wMin),
              CardInputWidget(
                title: "手机号",
                controller: phoneController,
                enabled: false,
              ),
              SizedBox(height: 24.wMin),
              Row(
                spacing: 12.wMin,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: CardInputWidget(
                      title: "短信验证码",
                      hintText: "请输入验证码",
                      maxLength: 6,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: false),
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
                    color: isGetCode
                        ? AppTheme.cBgTertiary
                        : AppTheme.cFeedbackDefaultBackground,
                    fontColor: AppTheme.cFeedbackDefaultText,
                    fontSize: 24.wMin,
                    fontWeight: FontWeight.w400,
                    sclae: 1.02,
                    onTap: isGetCode
                        ? null
                        : () {
                            getCode();
                          },
                  ),
                ],
              ),
              SizedBox(height: 24.wMin),
              Text(
                " 密码",
                style: TextStyle(
                  fontSize: 24.wMin,
                  color: AppTheme.cTextPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 16.wMin),
              Center(
                child: Pinput(
                  controller: pinPwdController,
                  length: 6,
                  pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  showCursor: true,
                  separatorBuilder: (index) => SizedBox(width: 16.wMin),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: false),
                  obscureText: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: (value) {
                    if (mounted) setState(() {});
                  },
                  defaultPinTheme: PinTheme(
                    width: 68.wMin,
                    height: 68.wMin,
                    textStyle: TextStyle(
                      fontSize: 28.wMin,
                      color: AppTheme.cTextPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                          width: 1.wMin, color: AppTheme.cBorderPrimary),
                      borderRadius: BorderRadius.circular(8.wMin),
                    ),
                  ),
                ),
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
                      text: "确定",
                      height: 56.wMin,
                      borderRadius: 8.wMin,
                      color: AppTheme.cSurfaceBrand,
                      fontColor: AppTheme.cStaticWhite,
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
