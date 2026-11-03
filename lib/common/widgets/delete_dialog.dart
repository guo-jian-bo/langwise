import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../theme/theme.dart';

class DeleteDialog {
  static Future<bool> show({
    required BuildContext context,
    required String title,
    String? subTitle,
    String? content,
    String? subContent,
    List<String>? subContentList,
    String confirmText = "确认删除",
    bool showCountdown = true,
  }) async {
    bool? res = await showCupertinoDialog<bool?>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return DeleteDialogWidget(
          title: title,
          subTitle: subTitle,
          content: content,
          subContent: subContent,
          subContentList: subContentList,
          confirmText: confirmText,
          showCountdown: showCountdown,
        );
      },
    );
    return res ?? false;
  }
}

class DeleteDialogWidget extends StatefulWidget {
  final String title;
  final String? subTitle;
  final String? content;
  final String? subContent;
  final List<String>? subContentList;
  final String confirmText;
  final bool showCountdown;
  const DeleteDialogWidget({
    super.key,
    required this.title,
    required this.subTitle,
    required this.content,
    this.subContent,
    this.subContentList,
    this.showCountdown = true,
    this.confirmText = "确认删除",
  });

  @override
  State<DeleteDialogWidget> createState() => _DeleteDialogWidgetState();
}

class _DeleteDialogWidgetState extends State<DeleteDialogWidget> {
  Timer? timer;
  int countdown = 3;
  bool deleteButtonFlag = false;

  @override
  void initState() {
    super.initState();
    if(!widget.showCountdown){
      countdown = 0;
      deleteButtonFlag = true;
    }else{
      timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        countdown--;
        if (mounted) setState(() {});
        if (countdown <= 0) {
          timer.cancel();
          deleteButtonFlag = true;
        }
      });
    }
    
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
          width: 640.wMin,
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
                          width: 48.wMin,
                          height: 48.wMin,
                        ),
                        SizedBox(width: 12.wMin),
                        Expanded(
                          child: Text(
                            widget.title,
                            style: TextStyle(
                              fontSize: 32.wMin,
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
              Visibility(
                visible: widget.subTitle != null,
                child: Text(
                  widget.subTitle ?? "",
                  style: TextStyle(
                    fontSize: 28.wMin,
                    color: AppTheme.cTextPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: 8.wMin),
              Visibility(
                visible: widget.content != null || widget.subContent != null,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24.wMin),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.wMin),
                    color: AppTheme.cFeedbackErrorBackground,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Visibility(
                        visible: widget.content != null,
                        child: Text(
                          widget.content ?? "",
                          style: TextStyle(
                            fontSize: 24.wMin,
                            color: AppTheme.cFeedbackErrorText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Visibility(
                        visible: widget.subContent != null,
                        child: Container(
                          margin: EdgeInsets.only(top: 12.wMin),
                          child: Text(
                            widget.subContent ?? "",
                            style: TextStyle(
                              fontSize: 24.wMin,
                              color: AppTheme.cFeedbackErrorText,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (widget.subContentList != null && widget.subContentList!.isNotEmpty)
                Container(
                  margin: EdgeInsets.only(top: 12.wMin),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var element in widget.subContentList!)
                        Text(
                          element,
                          style: TextStyle(
                            fontSize: 22.wMin,
                            color: AppTheme.cTextSecondary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                    ],
                  ),
                ),
              SizedBox(height: 32.wMin),
              Row(
                spacing: 24.wMin,
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
                      text: "${widget.confirmText}${countdown == 0 ? '' : '(${countdown}s)'}",
                      height: 56.wMin,
                      borderRadius: 8.wMin,
                      color: countdown != 0 ? AppTheme.cFeedbackErrorBackground : AppTheme.cFeedbackErrorIcon,
                      fontColor: AppTheme.cStaticWhite,
                      fontSize: 20.wMin,
                      fontWeight: FontWeight.w500,
                      sclae: 1.02,
                      onTap: countdown != 0
                          ? null
                          : () {
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
