import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import 'package:pinput/pinput.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../utils/utils.dart';
import 'widgets.dart';

class ShowPinPwdDialog{

  static Future<String?> show({
    required BuildContext context,
    String? title,
    String? content,
    String clearText = "取消",
    String confirmText = "确定",
  }) async{
    return await showCupertinoDialog<String?>(
      context: context,
      builder: (context) {
        return ShowPinPwdDialogWidget(
          title: title,
          content: content,
          clearText: clearText,
          confirmText: confirmText,
        );
      },
    );
  }

}

class ShowPinPwdDialogWidget extends StatefulWidget {
  final String? title;
  final String? content;
  final String clearText;
  final String confirmText;
  const ShowPinPwdDialogWidget({
    this.title,
    this.content,
    required this.clearText,
    required this.confirmText,
    super.key,
  });

  @override
  State<ShowPinPwdDialogWidget> createState() => _ShowPinPwdDialogWidgetState();
}

class _ShowPinPwdDialogWidgetState extends State<ShowPinPwdDialogWidget> {
  final pinPwdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cOverlayBackground,
      body: Center(
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
                widget.title??"",
                style: TextStyle(
                  fontSize: 28.wMin,
                  color: AppTheme.cTextPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16.wMin),
              Text(
                widget.content??"",
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
                  length: 6,
                  pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                  showCursor: true,
                  separatorBuilder: (index) => SizedBox(width: 16.wMin),
                  keyboardType: TextInputType.text,
                  closeKeyboardWhenCompleted: Platform.isAndroid || Platform.isIOS,
                  onChanged: (value) {
                    if(mounted) setState(() {});
                  },
                  onSubmitted: (value) {
                    if(pinPwdController.text.trim().isEmpty){
                      return ToastUtils.showToast(text: "请输入密码");
                    }
                    Get.back(result: pinPwdController.text);
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
              SizedBox(height: 32.wMin),
              Row(
                spacing: 18.wMin,
                children: [
                  Expanded(
                    child: ButtonWidget(
                      text: widget.clearText,
                      sclae: 1.03,
                      color: AppTheme.cBgTertiary,
                      borderRadius: 8.wMin,
                      height: 56.wMin,
                      fontSize: 24.wMin,
                      fontColor: AppTheme.cTextPrimary,
                      fontWeight: FontWeight.w500,
                      onTap: () => Get.back(),
                    ),
                  ),
                  Expanded(
                    child: ButtonWidget(
                      text: widget.confirmText,
                      sclae: 1.03,
                      color: pinPwdController.text.length == 6 ? AppTheme.cSurfaceBrand : AppTheme.cBgQuaternary,
                      borderRadius: 8.wMin,
                      height: 56.wMin,
                      fontSize: 24.wMin,
                      fontColor: AppTheme.cStaticWhite,
                      fontWeight: FontWeight.w500,
                      onTap: pinPwdController.text.length != 6 ? null : () {
                        if(pinPwdController.text.trim().isEmpty){
                          return ToastUtils.showToast(text: "请输入密码");
                        }
                        Get.back(result: pinPwdController.text);
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