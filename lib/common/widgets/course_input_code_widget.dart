import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../theme/theme.dart';
import 'widgets.dart';

class CourseInputCodePop {
  static Future<String?> show({
    required BuildContext context,
    int codeLength = 6,
    String title = "",
    String hintText = "",
    void Function(String text)? onCompleted,
  }) async {
    return await showCupertinoDialog<String?>(
      context: context,
      builder: (context) {
        return CourseInputCodeWidget(
          title: title,
          hintText: hintText,
          codeLength: codeLength,
          onCompleted: onCompleted,
        );
      },
    );
  }
}

class CourseInputCodeWidget extends StatefulWidget {
  final String title;
  final String hintText;
  final int codeLength;
  final void Function(String text)? onCompleted;

  const CourseInputCodeWidget({
    super.key, 
    this.title = "", 
    this.hintText = "",
    this.onCompleted, 
    this.codeLength = 6, 
  });

  @override
  State<CourseInputCodeWidget> createState() => CourseInputCodeWidgetState();
}

class CourseInputCodeWidgetState extends State<CourseInputCodeWidget> {
  String code = "";

  @override
  Widget build(BuildContext context) {
    return CardDialogBoxWidget(
      onCancel: () => Get.back(),
      onConfirm: () {
        if(code.length != widget.codeLength){
          return;
        }
        Get.back(result: code);
      },
      title: widget.title,
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom / 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.hintText,
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: AppTheme.cTextPrimary,
                  fontSize: 36.wMin,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 40.wMin),
              Pinput(
                length: widget.codeLength,
                pinAnimationType: PinAnimationType.fade,
                autofocus: true,
                keyboardAppearance: Brightness.dark,
                keyboardType: TextInputType.text,
                focusedPinTheme: PinTheme(
                  width: 80.wMin,
                  height: 64.wMin,
                  textStyle: TextStyle(
                    fontSize: 24.wMin,
                    color: AppTheme.cTextPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.cBgSecondary,
                    borderRadius: BorderRadius.circular(16.wMin),
                    border: Border.all(width: 1.wMin, color: AppTheme.cBorderFocus),
                  ),
                ),
                defaultPinTheme: PinTheme(
                  width: 80.wMin,
                  height: 64.wMin,
                  textStyle: TextStyle(
                    fontSize: 24.wMin,
                    color: AppTheme.cTextPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.cBgSecondary,
                    borderRadius: BorderRadius.circular(16.wMin),
                    border: Border.all(width: 1.wMin, color: Colors.transparent),
                  ),
                ),
                cursor: Container(
                  alignment: Alignment.bottomCenter,
                  padding: EdgeInsets.only(bottom: 7.5.wMin),
                  child: Container(
                    width: 19.wMin,
                    height: 1.5.wMin,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2.wMin),
                      color: AppTheme.cBorderFocus,
                    ),
                  ),
                ),
                onChanged: (value) {
                  code = value;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  
}
