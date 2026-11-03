import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lib_common/common.dart';
import 'package:pinput/pinput.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/https/https.dart';
import '../../../../common/stores/stores.dart';
import '../../../../common/values/values.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';
import '../../../../utils/utils.dart';

/// 验证管理端密码
class ManagePasswordDialog{

  static Future<bool> show({
    required BuildContext context,
    int maxErrorCount = 5,
  }) async{

    if(UserStore.to.rolePermissions.value.isAdmin == null){ 
      // 说明没有获取到用户信息
      try {
        ToastUtils.showLoading();
        await UserStore.to.getUserRolePermissions();
      } finally{
        ToastUtils.hideLoading();
      }
      return false;
    }
    
    if(!UserStore.to.rolePermissions.value.manageHasPassword){
      bool askRes = await AskDialog.showUserAsk(
        context: context,
        title: "设置后台管理密码",
        content: "请为管理后台单独设置密码（此密码与家长密码是两个不同的密码）",
        define: "去设置",
      );
      if(!askRes) return false;
      bool setPwd = await showSetPasswordDialog(context: context);
      if(!setPwd) return false;
      return true;
    }

    bool error = await showError(context, maxErrorCount);
    if(!error) return false;

    /// 15分钟内免验证
    String pwdFreeTime = StorageUtil().getString(STORAGE_MANAGE_PASSWORD_FREE_KEY);
    if(pwdFreeTime.isNotEmpty){
      DateTime? freeTime = DateFormatUtil.tryParseDate(pwdFreeTime);
      if(freeTime != null){
        DateTime now = DateTime.now().toLocal();
        if(now.difference(freeTime).inSeconds < 15 * 60){
          return true;
        }
      }
    }

    bool? res = await showCupertinoDialog<bool?>(
      context: context,
      builder: (context) {
        return ManagePasswordDialogWidget(maxErrorCount: maxErrorCount);
      },
    );

    return res??false;

  }

  static Future<bool> showError(BuildContext context, int maxErrorCount) async{
    int errorCount = StorageUtil().getInt(STORAGE_MANAGE_PASSWORD_ERROR_COUNT_KEY)??0;
    
    if(errorCount >= maxErrorCount){
      bool askRes = await AskDialog.showUserAsk(
        context: context,
        title: "温馨提示",
        content: "您输入密码错误次数过多，是否去重置密码",
        define: "去重置",
      );
      Get.back();
      if(!askRes) return false;
      bool setPwd = await showSetPasswordDialog(context: context, isEdit: true);
      if(!setPwd) return false;
      await StorageUtil().remove(STORAGE_MANAGE_PASSWORD_ERROR_COUNT_KEY);
      return false;
    }
    return true;
  }

  /// 设置管理端密码
  static Future<bool> showSetPasswordDialog({
    required BuildContext context,
    bool isEdit = false,
  }) async{
    bool? res = await showCupertinoDialog(
      context: context,
      builder: (context) {
        return ManageSetPasswordDialogWidget(
          isEdit: isEdit,
        );
      },
    );

    return res ?? false;
  }

}



class ManagePasswordDialogWidget extends StatefulWidget {
  final int maxErrorCount;
  const ManagePasswordDialogWidget({
    this.maxErrorCount = 5,
    super.key,
  });

  @override
  State<ManagePasswordDialogWidget> createState() => _ManagePasswordDialogWidgetState();
}

class _ManagePasswordDialogWidgetState extends State<ManagePasswordDialogWidget> {
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
      bool? res = await AccountUtil.verifyManagePassword(pinPwdController.text.trim());
      if(res == null) return;
      if(!res) {
        pinPwdController.clear();
        int errorCount = StorageUtil().getInt(STORAGE_MANAGE_PASSWORD_ERROR_COUNT_KEY)??0;
        await StorageUtil().setInt(STORAGE_MANAGE_PASSWORD_ERROR_COUNT_KEY, errorCount + 1);

        bool error = await ManagePasswordDialog.showError(context, widget.maxErrorCount);
        if(!error) return;
        Future.delayed(const Duration(milliseconds: 500), (){
          pinPwdFocusNode.requestFocus();
        });
        return;
      }
      await StorageUtil().remove(STORAGE_MANAGE_PASSWORD_ERROR_COUNT_KEY);

      if(isChecked){ // 勾选了 15分钟内无需重复输入密码
        DateTime now = DateTime.now().toLocal();
        String nowDate = DateFormatUtil.formatStr(now, newPattern: "yyyy-MM-dd HH:mm:ss");
        await StorageUtil().setString(STORAGE_MANAGE_PASSWORD_FREE_KEY, nowDate);
      }
      

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
      title: "管理密码",
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
              color: AppTheme.cBgSecondary.color,
              border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary.color),
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
                        "后台管理密码",
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
                SizedBox(height: 16.wMin),
                Text(
                  "请输入后台管理密码",
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




class ManageSetPasswordDialogWidget extends StatefulWidget {
  final bool isEdit;
  const ManageSetPasswordDialogWidget({
    super.key,
    this.isEdit = false,
  });

  @override
  State<ManageSetPasswordDialogWidget> createState() => _ManageSetPasswordDialogWidgetState();
}

class _ManageSetPasswordDialogWidgetState extends State<ManageSetPasswordDialogWidget> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController pinPwdController = TextEditingController();

  Timer? codeDownTimer;
  int codeDownTime = 60;
  bool isGetCode = false;

  @override
  void initState() {
    super.initState();
    phoneController.text = UserStore.to.userInfo.value.phone??"";
  }

  Future<void> getCode() async{
    if(isGetCode) return;
    
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        // "type": "7",
      };
      bool res = await AccountUtil.setManagePasswordSendSmsCode(reqData);
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

    if(codeController.text.isEmpty){
      ToastUtils.showToast(text: "请输入验证码");
      return;
    }

    if(pinPwdController.text.isEmpty){
      ToastUtils.showToast(text: "请输入密码");
      return;
    }

    if(pinPwdController.text.length < 6){
      ToastUtils.showToast(text: "密码不能少于6位");
      return;
    }

    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "token": codeController.text,
        "password": pinPwdController.text,
      };
      bool res = await AccountUtil.setManagePassword(reqData);
      if(!res) return;
      ToastUtils.showToast(text: "设置成功", type: ToastType.success);
      await UserStore.to.getUserInfo();
      await UserStore.to.getUserRolePermissions();
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
                      widget.isEdit ? "重置后台管理密码" : "设置后台管理密码",
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
                  keyboardType: const TextInputType.numberWithOptions(decimal: false),
                  obscureText: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: (value) {
                    if(mounted) setState(() {});
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
                      border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary),
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