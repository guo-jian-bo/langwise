import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../config.dart';
import '../../utils/utils.dart';

class PrivacyDialog {
  static Future<bool> show() async {
    bool? result = await Get.dialog<bool?>(
      const PrivacyDialogWidget(),
      barrierDismissible: false,
      barrierColor: AppTheme.cOverlayBackground,
    );
    return result ?? false;
  }
}

class PrivacyDialogWidget extends StatefulWidget {
  const PrivacyDialogWidget({super.key});

  @override
  State<PrivacyDialogWidget> createState() => _PrivacyDialogWidgetState();
}

class _PrivacyDialogWidgetState extends State<PrivacyDialogWidget> {
  /// 跳转至协议
  void toProtocol(String url) {
    WebViewUtils.openWebView(url: url);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Material(
        type: MaterialType.transparency,
        child: Center(
          child: Container(
            width: 800.wMin,
            decoration: BoxDecoration(
              color: AppTheme.cSurfaceSecondary,
              borderRadius: BorderRadius.circular(24.wMin),
              border: Border.all(
                color: AppTheme.cBorderFocus,
                width: 1.wMin,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.cShadowDark,
                  blurRadius: 10.wMin,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 64.wMin),
                Text(
                  "服务条款与隐私协议",
                  style: TextStyle(
                    fontSize: 32.wMin,
                    color: AppTheme.cTextPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 64.wMin),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 64.wMin),
                  child: Text.rich(TextSpan(
                    style: TextStyle(
                      fontSize: 20.wMin,
                      color: AppTheme.cTextPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      const TextSpan(text: "感谢您选择${Config.appName}！\n\n我们非常重视您的个人信息和隐私保护。为了更好地保证您的个人权益，在您使用我们的产品前，请您认真阅读"),
                      TextSpan(
                        text: "《隐私协议》",
                        style: const TextStyle(color: AppTheme.cTextBrand),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            print("隐私协议");
                            toProtocol(Config.userPrivacyProtocol);
                          },
                      ),
                      const TextSpan(text: "和"),
                      TextSpan(
                        text: "《服务条款》",
                        style: const TextStyle(color: AppTheme.cTextBrand),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            print("服务条款");
                            toProtocol(Config.userProtocol);
                          },
                      ),
                      const TextSpan(text: "的全部内容，同意并接受全部条款后开始使用我们的产品和服务。如果您是未满18周岁的未成年人，请您通知您的监护人共同阅读我们的"),
                      TextSpan(
                        text: "《未成年人个人信息保护规则及监护人须知》",
                        style: const TextStyle(color: AppTheme.cTextBrand),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            print("未成年人个人信息保护规则及监护人须知");
                            toProtocol(Config.childPrivacyProtocol);
                          },
                      ),
                      const TextSpan(text: "，并在您使用我们的产品、提交个人信息之前，务必寻求他们的同意和指导。 \n\n点按“同意并继续”，即表示您和您的监护人同意并接受全部条款。"),
                    ],
                  )),
                ),
                SizedBox(height: 52.wMin),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24.wMin),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(width: 0.5.wMin, color: AppTheme.cBorderPrimary),
                    ),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppTheme.cBlackAlpha10,
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      ButtonWidget(
                        text: "同意并继续",
                        height: 64.wMin,
                        width: 480.wMin,
                        sclae: 1.01,
                        borderRadius: 12.wMin,
                        color: AppTheme.cBgBrand,
                        fontColor: AppTheme.cStaticWhite,
                        fontSize: 28.wMin,
                        fontWeight: FontWeight.w600,
                        onTap: () {
                          Get.back(result: true);
                        },
                      ),
                      SizedBox(height: 26.wMin),
                      TapScaleWidget(
                        onTap: () {
                          if (Platform.isIOS || Platform.isWindows) {
                            exit(0);
                          } else {
                            SystemNavigator.pop();
                          }
                        },
                        sclae: 1.05,
                        child: Text(
                          "不同意",
                          style: TextStyle(
                            fontSize: 18.wMin,
                            color: AppTheme.cTextTertiary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      SizedBox(height: 16.wMin),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
