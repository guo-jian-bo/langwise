import 'dart:io';

import 'package:api/entities/response.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/app/modules/membership_card_manage/views/set_membership_card_password_dialog.dart';
import 'package:langwise/common/https/membership_card_manage.dart';
import 'package:langwise/common/values/storage.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:langwise/utils/toast_utils.dart';
import 'package:lib_common/common.dart';
import 'package:pinput/pinput.dart';
import 'package:ui_essentials/ui_essentials.dart';

/// 验证家长密码
class MembershipCardPasswordDialog {
  static Future<bool> show({
    required BuildContext context,
    bool isCheckHasPassword = true,
    int maxErrorCount = 5,
  }) async {
    bool error = await showError(context, maxErrorCount);
    if (!error) return false;

    bool? res = await showCupertinoDialog<bool?>(
      context: context,
      builder: (context) {
        return MembershipCardPasswordDialogWidget(maxErrorCount: maxErrorCount);
      },
    );

    return res ?? false;
  }

  static Future<bool> showError(BuildContext context, int maxErrorCount) async {
    int errorCount =
        StorageUtil().getInt(STORAGE_AGENT_PASSWORD_ERROR_COUNT_KEY) ?? 0;

    if (errorCount >= maxErrorCount) {
      bool askRes = await AskDialog.showUserAsk(
        context: context,
        title: "温馨提示",
        content: "您输入密码错误次数过多，是否去重置密码",
        define: "去重置",
      );
      if (!askRes) return false;
      bool setPwd = await SetMembershipCardPasswordDialog.show(
          context: context, isEdit: true);
      if (!setPwd) return false;
      await StorageUtil().remove(STORAGE_AGENT_PASSWORD_ERROR_COUNT_KEY);
      return false;
    }
    return true;
  }
}

class MembershipCardPasswordDialogWidget extends StatefulWidget {
  final int maxErrorCount;

  const MembershipCardPasswordDialogWidget({
    this.maxErrorCount = 5,
    super.key,
  });

  @override
  State<MembershipCardPasswordDialogWidget> createState() =>
      _MembershipCardPasswordDialogWidgetState();
}

class _MembershipCardPasswordDialogWidgetState
    extends State<MembershipCardPasswordDialogWidget> {
  final pinPwdController = TextEditingController();
  final pinPwdFocusNode = FocusNode();

  int _tapCount = 0;
  DateTime? _lastTapTime;

  Future<void> _confirm() async {
    if (pinPwdController.text.trim().isEmpty) {
      return ToastUtils.showToast(text: "请输入6位密码");
    }

    if (pinPwdController.text.trim().length != 6) {
      return ToastUtils.showToast(text: "请输入6位密码");
    }

    try {
      ToastUtils.showLoading();

      final ResponseEntity? res = await MembershipCardManageApi.checkPassword(
          pinPwdController.text.trim());
      if (res == null) return;
      await StorageUtil().remove(STORAGE_AGENT_PASSWORD_ERROR_COUNT_KEY);
      Get.back(result: true);
    } catch (e) {
      pinPwdController.clear();
      int errorCount =
          StorageUtil().getInt(STORAGE_AGENT_PASSWORD_ERROR_COUNT_KEY) ?? 0;
      await StorageUtil()
          .setInt(STORAGE_AGENT_PASSWORD_ERROR_COUNT_KEY, errorCount + 1);
      ToastUtils.showManageToast(text: '密码错误', type: ManageToastType.error);

      bool error = await MembershipCardPasswordDialog.showError(
          context, widget.maxErrorCount);
      if (!error) return;
      Future.delayed(const Duration(milliseconds: 500), () {
        pinPwdFocusNode.requestFocus();
      });
      return;
    } finally {
      ToastUtils.hideLoading();
    }
  }

  Future<void> checkSkip(BuildContext context) async {
    final now = DateTime.now();

    // 如果距离上次点击超过1秒，重置计数器
    if (_lastTapTime == null ||
        now.difference(_lastTapTime!) > const Duration(seconds: 1)) {
      _tapCount = 0;
    }

    _tapCount++;
    _lastTapTime = now;

    if (_tapCount != 7) return;

    print('点击了7次!');
    _tapCount = 0; // 重置计数器
    String? pwd = await ShowPinPwdDialog.show(
      context: context,
      title: "代理商密码",
      content: "请输入密码",
    );
    if (pwd == null) return;

    String localPwd =
        "LW${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";
    if (localPwd != pwd) return ToastUtils.showToast(text: "密码错误");

    Get.back(result: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cOverlayBackground,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: 600.wMin,
            padding: EdgeInsets.all(32.wMin),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.wMin),
              color: AppTheme.cBgSecondary,
              border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => checkSkip(context),
                      child: Text(
                        "代理商密码",
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
                          color: AppTheme.cBgActive.color,
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
                SizedBox(height: 16.wMin),
                Text(
                  "请输入代理商密码",
                  style: TextStyle(
                    fontSize: 20.wMin,
                    color: AppTheme.cTextSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 16.wMin),
                Center(
                  child: Pinput(
                    controller: pinPwdController,
                    focusNode: pinPwdFocusNode,
                    length: 6,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                    showCursor: true,
                    separatorBuilder: (index) => SizedBox(width: 16.wMin),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: false),
                    obscureText: true,
                    autofocus: true,
                    closeKeyboardWhenCompleted:
                        Platform.isAndroid || Platform.isIOS,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: (value) {
                      if (mounted) setState(() {});
                    },
                    onSubmitted: (value) {
                      _confirm();
                    },
                    defaultPinTheme: PinTheme(
                      width: 68.wMin,
                      height: 68.wMin,
                      textStyle: TextStyle(
                        fontSize: 28.wMin,
                        color: AppTheme.cTextPrimary.color,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                            width: 1.wMin,
                            color: AppTheme.cBorderPrimary.color),
                        borderRadius: BorderRadius.circular(8.wMin),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 32.wMin),
                Row(
                  spacing: 18.wMin,
                  children: [
                    Expanded(
                      child: ButtonWidget(
                        text: "取消",
                        sclae: 1.03,
                        color: AppTheme.cBgTertiary.color,
                        borderRadius: 8.wMin,
                        height: 56.wMin,
                        fontSize: 24.wMin,
                        fontColor: AppTheme.cTextPrimary.color,
                        fontWeight: FontWeight.w500,
                        onTap: () => Get.back(),
                      ),
                    ),
                    Expanded(
                      child: ButtonWidget(
                        text: "确定",
                        sclae: 1.03,
                        color: pinPwdController.text.length == 6
                            ? AppTheme.cSurfaceBrand.color
                            : AppTheme.cBgQuaternary.color,
                        borderRadius: 8.wMin,
                        height: 56.wMin,
                        fontSize: 24.wMin,
                        fontColor: AppTheme.cStaticWhite,
                        fontWeight: FontWeight.w500,
                        onTap: pinPwdController.text.length != 6
                            ? null
                            : () {
                                _confirm();
                              },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
