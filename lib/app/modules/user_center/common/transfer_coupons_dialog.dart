import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/https/https.dart';
import 'package:langwise/utils/utils.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../common/entities/entities.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../theme/theme.dart';

/// 转送朋友
class TransferCouponsDialog{
  static Future<bool> show({
    required BuildContext context,
    required CouponEntityDatas data,
  }) async{
    bool? res = await showCupertinoDialog<bool?>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return TransferCouponsDialogWidget(data: data);
      },
    );
    return res??false;
  }
}

class TransferCouponsDialogWidget extends StatefulWidget {
  final CouponEntityDatas data;
  const TransferCouponsDialogWidget({super.key, required this.data});

  @override
  State<TransferCouponsDialogWidget> createState() => _TransferCouponsDialogWidgetState();
}

class _TransferCouponsDialogWidgetState extends State<TransferCouponsDialogWidget> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController codeController = TextEditingController();

  /// 国家区号码
  String callingCode = "86";

  Timer? codeDownTimer;
  int codeDownTime = 60;
  bool isGetCode = false;

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
    if(phoneController.text.isEmpty){
      return ToastUtils.showToast(text: "请输入手机号");
    }
    if(!GetUtils.isPhoneNumber(phoneController.text)){
      return ToastUtils.showToast(text: "手机号格式不正确");
    }
    
    try {
      ToastUtils.showLoading();
      Map<String, dynamic> reqData = {
        "callingCode": callingCode,
        "phoneNumber": phoneController.text,
      };
      bool res = await CouponsRequest.transferCouponsSendCode(reqData);
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

  /// 立即使用
  Future<void> transferCoupons() async{
    if(phoneController.text.isEmpty){
      return ToastUtils.showToast(text: "请输入手机号");
    }
    if(!GetUtils.isPhoneNumber(phoneController.text)){
      return ToastUtils.showToast(text: "手机号格式不正确");
    }
    if(codeController.text.isEmpty){
      return ToastUtils.showToast(text: "请输入验证码");
    }
    
    try {
      Map<String, dynamic> reqData = {
        "callingCode": callingCode,
        "phoneNumber": phoneController.text,
        "token": codeController.text,
        "couponId": widget.data.couponId,
      };
      ToastUtils.showLoading();
      bool res = await CouponsRequest.transferCouponsSubmit(reqData);
      if(!res) return;
      ToastUtils.showToast(text: "转送成功", type: ToastType.success);
      Get.back(result: true);
    } finally{
      ToastUtils.hideLoading();
    }
  }

  @override
  void dispose() {
    codeDownTimer?.cancel();
    codeDownTimer = null;
    phoneController.dispose();
    codeController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color couponColor = StatusUtils.getCouponColor(widget.data.type);

    String? expired = widget.data.expired;
    String expiredText = "";
    if(expired != null){
      expiredText = DateFormatUtil.formatStrtoStr(expired);
    }


    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Material(
        color: AppTheme.cOverlayBackground,
        child: Center(
          child: Container(
            width: 632.wMin,
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
                        "转送朋友",
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
                SizedBox(height: 32.wMin),
                Row(
                  children: [
                    Text(
                      "您正在转送 ",
                      style: TextStyle(
                        fontSize: 24.wMin,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.cTextSecondary,
                      ),
                    ),
                    Text(
                      widget.data.title??"",
                      style: TextStyle(
                        fontSize: 24.wMin,
                        fontWeight: FontWeight.w600,
                        color: couponColor,
                      ),
                    ),
                  ],
                ),
                Visibility(
                  visible: expiredText.isNotEmpty,
                  child: Row(
                    children: [
                      Text(
                        "有效期至: ",
                        style: TextStyle(
                          fontSize: 20.wMin,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.cTextSecondary,
                        ),
                      ),
                      Text(
                        expiredText,
                        style: TextStyle(
                          fontSize: 20.wMin,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.cFeedbackErrorText,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.wMin),
                CardInputWidget(
                  title: "朋友手机号",
                  hintText: "请输入朋友的手机号",
                  controller: phoneController,
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
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24.wMin),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.wMin),
                    color: AppTheme.cBgTertiary,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "转送说明",
                        style: TextStyle(
                          fontSize: 24.wMin,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.cTextPrimary,
                        ),
                      ),
                      SizedBox(height: 8.wMin),
                      _buildDirectionsWidget("转送后不支持退回"),
                      _buildDirectionsWidget("转送后的券不支持再次转送"),
                      _buildDirectionsWidget("当朋友用券购买会员后会返还给你 10% 的实际支付乃币"),
                    ],
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
                        text: "确认转送",
                        height: 56.wMin,
                        borderRadius: 8.wMin,
                        color: AppTheme.cFeedbackWarningIcon,
                        fontColor: AppTheme.cStaticWhite,
                        fontSize: 20.wMin,
                        fontWeight: FontWeight.w500,
                        sclae: 1.02,
                        onTap: () {
                          transferCoupons();
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

  Widget _buildDirectionsWidget(String value){
    return Row(
      spacing: 8.wMin,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "·",
          style: TextStyle(
            fontSize: 28.wMin,
            fontWeight: FontWeight.w600,
            color: AppTheme.cFeedbackErrorIcon,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 20.wMin,
              fontWeight: FontWeight.w400,
              color: AppTheme.cTextSecondary,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

}