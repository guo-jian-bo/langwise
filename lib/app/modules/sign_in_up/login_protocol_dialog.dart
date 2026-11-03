import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../common/widgets/widgets.dart';
import '../../../config.dart';
import '../../../theme/theme.dart';
import '../../../utils/utils.dart';

class LoginProtocolDialog{

  static Future<bool> show(BuildContext context) async{
    bool? res = await showCupertinoDialog(
      context: context,
      builder: (context) {
        return LoginProtocolDialogWidget();
      },
    );
    return res ?? false;
  }

}

class LoginProtocolDialogWidget extends StatefulWidget {
  const LoginProtocolDialogWidget({super.key});

  @override
  State<LoginProtocolDialogWidget> createState() => _LoginProtocolDialogWidgetState();
}

class _LoginProtocolDialogWidgetState extends State<LoginProtocolDialogWidget> {

  /// 跳转至用户协议
  Future<void> jumpToUserProtocol() async {
    await WebViewUtils.openWebView(url: Config.userProtocol);
  }

  /// 跳转至隐私协议
  Future<void> jumpToPrivacyProtocol() async {
    await WebViewUtils.openWebView(url: Config.userPrivacyProtocol);
  }
  
  @override
  Widget build(BuildContext context) {
    return DialogUserWidget(
      title: "是否同意以下协议？",
      width: 720.wMin,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 32.wMin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Text.rich(TextSpan(
              style: TextStyle(
                fontSize: 24.wMin,
                color: AppTheme.cTextSecondary.color,
                fontWeight: FontWeight.w500,
              ),
              children: [
                TextSpan(text: "请您仔细阅读"),
                TextSpan(
                  text: "《用户协议》",
                  style: TextStyle(
                    color: AppTheme.cTextBrand.color,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = () {
                    jumpToUserProtocol();
                  },
                ),
                TextSpan(text: "和"),
                TextSpan(
                  text: "《隐私协议》",
                  style: TextStyle(
                    color: AppTheme.cTextBrand.color,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = () {
                    jumpToPrivacyProtocol();
                  },
                ),
                TextSpan(text: "，点击“同意”即表示您已接受全部条款。"),
              ],
            )),

            SizedBox(height: 48.wMin),

            _buildButtonsWidget(),

            SizedBox(height: 32.wMin),

          ],
        ),
      ),
    );
  }


  Widget _buildButtonsWidget(){
    return Row(
      spacing: 12.wMin,
      children: [
        Expanded(
          child: ButtonWidget(
            text: "取消",
            height: 56.wMin,
            borderRadius: 8.wMin,
            color: AppTheme.cSurfaceLayerElevated.color,
            fontSize: 24.wMin,
            fontColor: AppTheme.cTextSecondary.color,
            fontWeight: FontWeight.w500,
            sclae: 1.03,
            onTap: () {
              Get.back(result: false);
            },
          ),
        ),
        Expanded(
          child: ButtonWidget(
            text: "同意",
            height: 56.wMin,
            borderRadius: 8.wMin,
            color: AppTheme.cSurfaceBrand.color,
            fontSize: 24.wMin,
            fontWeight: FontWeight.w500,
            sclae: 1.03,
            onTap: () {
              Get.back(result: true);
            },
          ),
        ),
      ],
    );
  }

}