import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../theme/theme.dart';

class DeleteStudentDialog{
  static Future<bool> show(BuildContext context, {required int memberId, String? nickname}) async{
    dynamic res = await showCupertinoDialog<bool?>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return DeleteStudentDialogWidegt(memberId: memberId, nickname: nickname);
      },
    );
    return res??false;
  }
}

class DeleteStudentDialogWidegt extends StatefulWidget {
  final int memberId;
  final String? nickname;
  const DeleteStudentDialogWidegt({super.key, required this.memberId, this.nickname});


  @override
  State<DeleteStudentDialogWidegt> createState() => _DeleteStudentDialogWidegtState();
}

class _DeleteStudentDialogWidegtState extends State<DeleteStudentDialogWidegt> {
  Timer? timer;
  int countdown = 3;
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
                            "删除学员",
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
              Text.rich(TextSpan(
                style: TextStyle(
                  fontSize: 20.wMin,
                  color: AppTheme.cTextSecondary,
                  fontWeight: FontWeight.w400,
                ),
                children: [
                  const TextSpan(text: "你确定要删除学员"),
                  TextSpan(
                   text: widget.nickname?.isEmpty ?? true ? "" : " ${widget.nickname} ",
                   style: const TextStyle(
                     color: AppTheme.cTextPrimary,
                   ),
                  ),
                  const TextSpan(text: "吗？"),
                ],
              )),
              SizedBox(height: 8.wMin),

              Container(
                padding: EdgeInsets.all(24.wMin),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.wMin),
                  color: AppTheme.cFeedbackErrorBackground,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8.wMin,
                  children: [
                    Text(
                      "警告：此操作不可逆！",
                      style: TextStyle(
                        fontSize: 20.wMin,
                        color: AppTheme.cFeedbackErrorIcon,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "删除后，该学员的所有学习数据和记录将被永久删除，且无法恢复。",
                      style: TextStyle(
                        fontSize: 20.wMin,
                        color: AppTheme.cFeedbackErrorIcon,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                  ],
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
                      text: "确认删除${countdown == 0 ? '' : '($countdown)'}",
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