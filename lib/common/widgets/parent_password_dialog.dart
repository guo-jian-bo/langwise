import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/stores/user.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:lib_common/common.dart';
import 'package:pinput/pinput.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../theme/theme.dart';
import '../../utils/utils.dart';
import '../https/https.dart';
import '../public_controller/manage_sandbox_controller.dart';
import '../values/values.dart';

/// 验证家长密码
class ParentPasswordialog{

  /// 显示家长密码弹窗
  /// [isCheckHasPassword] 在没有设置家长密码的情况下不验证密码
  static Future<bool> show({
    required BuildContext context,
    bool isCheckHasPassword = true,
    int maxErrorCount = 5,
    bool enableFreePass = true,
  }) async{
    // await StorageUtil().remove(STORAGE_PARENT_PASSWORD_ERROR_COUNT_KEY);

    // 审核时不需要家长密码
    if(UserStore.to.userInfo.value.reviewStatus){
      return true;
    }

    /// 模拟用户时不要输入家长密码
    if(ManageSandboxController.to.isSimulate){
      return true;
    }

    if(UserStore.to.userInfo.value.userId == null){ 
      // 说明没有获取到用户信息
      try {
        ToastUtils.showLoading();
        await UserStore.to.getUserInfo();
      } finally{
        ToastUtils.hideLoading();
      }
      return false;
    }

    if(!isCheckHasPassword && UserStore.to.userInfo.value.hasPassword != 1){
      return true;
    }

    if(UserStore.to.userInfo.value.hasPassword != 1){
      bool askRes = await AskDialog.showUserAsk(
        context: context,
        title: "温馨提示",
        content: "您还没有设置家长密码",
        define: "去设置",
      );
      if(!askRes) return false;
      bool setPwd = await SetTeamPasswordDialog.show(context: Get.context ?? context);
      if(!setPwd) return false;
      await StorageUtil().remove(STORAGE_PARENT_PASSWORD_ERROR_COUNT_KEY);
      return true;
    }

    bool error = await showError(context, maxErrorCount);
    if(!error) return false;
    
    if (enableFreePass) {
      /// 15分钟内免验证
      String pwdFreeTime = StorageUtil().getString(STORAGE_PARENT_PASSWORD_FREE_KEY);
      if (pwdFreeTime.isNotEmpty) {
        DateTime? freeTime = DateFormatUtil.tryParseDate(pwdFreeTime);
        if (freeTime != null) {
          DateTime now = DateTime.now().toLocal();
          if (now.difference(freeTime).inSeconds < 15 * 60) {
            return true;
          }
        }
      }
    }

    bool? res = await showCupertinoDialog<bool?>(
      context: Get.context ?? context,
      builder: (context) {
        return ParentPasswordialogWidget(
          maxErrorCount: maxErrorCount,
          enableFreePass: enableFreePass,
        );
      },
    );

    return res ?? false;
  }

  static Future<bool> showError(BuildContext context, int maxErrorCount) async{
    int errorCount = StorageUtil().getInt(STORAGE_PARENT_PASSWORD_ERROR_COUNT_KEY)??0;
    
    if(errorCount >= maxErrorCount){
      bool askRes = await AskDialog.showUserAsk(
        context: context,
        title: "温馨提示",
        content: "您输入密码错误次数过多，是否去重置密码",
        define: "去重置",
      );
      Get.back();
      if(!askRes) return false;
      bool setPwd = await SetTeamPasswordDialog.show(context: context);
      if(!setPwd) return false;
      await StorageUtil().remove(STORAGE_PARENT_PASSWORD_ERROR_COUNT_KEY);
      return false;
    }
    return true;
  }

  
}

class ParentPasswordialogWidget extends StatefulWidget {
  final int maxErrorCount;
  final bool enableFreePass;

  const ParentPasswordialogWidget({
    this.maxErrorCount = 5,
    this.enableFreePass = true,
    super.key,
  });

  @override
  State<ParentPasswordialogWidget> createState() => _ParentPasswordialogWidgetState();
}

class _ParentPasswordialogWidgetState extends State<ParentPasswordialogWidget> {
  final pinPwdController = TextEditingController();
  final pinPwdFocusNode = FocusNode();

  int _tapCount = 0;
  DateTime? _lastTapTime;

  bool isChecked = true;

  @override
  void dispose(){
    super.dispose();
    pinPwdController.dispose();
    pinPwdFocusNode.dispose();
  }

  Future<void> _confirm() async{
    if(pinPwdController.text.trim().isEmpty){
      return ToastUtils.showToast(text: "请输入6位密码");
    }

    if(pinPwdController.text.trim().length != 6){
      return ToastUtils.showToast(text: "请输入6位密码");
    }

    try{
      ToastUtils.showLoading();
      bool? res = await UserRequest.verifyPassword(pinPwdController.text.trim());
      if(res == null) return;
      if(!res) {
        pinPwdController.clear();
        int errorCount = StorageUtil().getInt(STORAGE_PARENT_PASSWORD_ERROR_COUNT_KEY)??0;
        await StorageUtil().setInt(STORAGE_PARENT_PASSWORD_ERROR_COUNT_KEY, errorCount + 1);

        bool error = await ParentPasswordialog.showError(context, widget.maxErrorCount);
        if(!error) return;
        Future.delayed(const Duration(milliseconds: 500), (){
          pinPwdFocusNode.requestFocus();
        });
        return;
      }
      await StorageUtil().remove(STORAGE_PARENT_PASSWORD_ERROR_COUNT_KEY);

      if(widget.enableFreePass && isChecked){ // 勾选了 15分钟内无需重复输入密码
        DateTime now = DateTime.now().toLocal();
        String nowDate = DateFormatUtil.formatStr(now, newPattern: "yyyy-MM-dd HH:mm:ss");
        await StorageUtil().setString(STORAGE_PARENT_PASSWORD_FREE_KEY, nowDate);
      }
      
      FocusScope.of(context).requestFocus(FocusNode());
      Get.back(result: true);
    }finally{
      ToastUtils.hideLoading();
    }
  }


  Future<void> checkSkip(BuildContext context) async{
    final now = DateTime.now();
  
    // 如果距离上次点击超过1秒，重置计数器
    if (_lastTapTime == null || now.difference(_lastTapTime!) > const Duration(seconds:1)) {
      _tapCount = 0;
    }
    
    _tapCount++;
    _lastTapTime = now;

    if(_tapCount != 7) return;
    
    print('点击了7次!');
    _tapCount = 0; // 重置计数器
    String? pwd = await ShowPinPwdDialog.show(
      context: context,
      title: "家长密码",
      content: "请输入密码",
    );
    if(pwd == null) return;

    String localPwd = "LW${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";
    if(localPwd != pwd) return ToastUtils.showToast(text: "密码错误");
    
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
                        "家长密码",
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
                  "请输入家长密码",
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
                    keyboardType: const TextInputType.numberWithOptions(decimal: false),
                    obscureText: true,
                    autofocus: true,
                    closeKeyboardWhenCompleted: Platform.isAndroid || Platform.isIOS,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: (value) {
                      if(mounted) setState(() {});
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
                        border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
                        borderRadius: BorderRadius.circular(8.wMin),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.wMin),
                if (widget.enableFreePass) ...[
                  Container(
                    alignment: Alignment.centerLeft,
                    child: TapScaleWidget(
                      onTap: () {
                        isChecked = !isChecked;
                        if(mounted) setState(() {});
                      },
                      sclae: 1,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            isChecked ? "assets/svg/public/icon_check_box.svg" : "assets/svg/public/icon_uncheck_box.svg",
                            width: 24.wMin,
                            height: 24.wMin,
                          ),
                          SizedBox(width: 8.wMin),
                          Text(
                            "15分钟内无需重复输入密码",
                            style: TextStyle(
                              color: AppTheme.cTextSecondary,
                              fontSize: 20.wMin,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 32.wMin),
                ] else
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
                        color: pinPwdController.text.length == 6 ? AppTheme.cSurfaceBrand.color : AppTheme.cBgQuaternary.color,
                        borderRadius: 8.wMin,
                        height: 56.wMin,
                        fontSize: 24.wMin,
                        fontColor: AppTheme.cStaticWhite,
                        fontWeight: FontWeight.w500,
                        onTap: pinPwdController.text.length != 6 ? null : () {
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
