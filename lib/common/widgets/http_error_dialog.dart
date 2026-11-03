import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import 'widgets.dart';

/// http请求错误弹窗
class HttpErrorDialog{

  static Future<bool> show({
    String title = "网络错误",
    String message = "请确认当前网络畅通后重试",
  }) async{
    return await Get.dialog<bool>(
      HttpErrorDialogWidget(message: message, title: title),
      barrierDismissible: false,
    ) ?? false;
  }

}

class HttpErrorDialogWidget extends StatefulWidget {
  final String title;
  final String message;
  const HttpErrorDialogWidget({super.key, required this.message, required this.title});

  @override
  State<HttpErrorDialogWidget> createState() => _HttpErrorDialogWidgetState();
}

class _HttpErrorDialogWidgetState extends State<HttpErrorDialogWidget> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Material(
        type: MaterialType.transparency,
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.wMin),
            child: Container(
              width: 640.wMin,
              padding: EdgeInsets.all(40.wMin),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.wMin),
                color: AppTheme.cBgSecondary,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    children: [
                      Container(
                        alignment: Alignment.center,
                        child: Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 28.wMin,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.cTextPrimary.color,
                          ),
                        ),
                      ),
                      SizedBox(height: 26.wMin),
                      Container(
                        constraints: BoxConstraints(
                          minHeight: 60.wMin,
                        ),
                        child: Text(
                          widget.message,
                          style: TextStyle(
                            fontSize: 24.wMin,
                            color: AppTheme.cTextPrimary.color,
                            fontWeight: FontWeight.w500,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 38.wMin),
                  ButtonWidget(
                    text: "重试",
                    height: 64.wMin,
                    fontColor: AppTheme.cStaticWhite.color,
                    fontSize: 24.wMin,
                    color: AppTheme.cSurfaceBrand.color,
                    borderRadius: 12.wMin,
                    sclae: 1.01,
                    onTap: () {
                      Get.back(result: true);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}