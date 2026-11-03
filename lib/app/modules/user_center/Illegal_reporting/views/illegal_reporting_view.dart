import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';

import '../../../../../theme/theme.dart';
import '../../../../routes/routes.dart';
import '../bindings/illegal_reporting_binding.dart';
import '../controllers/illegal_reporting_controller.dart';

class IllegalReportingView extends GetView<IllegalReportingController> {
  final String tagText;
  const IllegalReportingView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      () => IllegalReportingView(tagText: tag),
      binding: IllegalReportingBinding(tagText: tag),
      routeName: Routes.ILLEGAL_REPORTING,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppTheme.cBgPrimary,
      body: Column(
        children: [
          const BreadcrumbWidget(),
          Expanded(
            child: Container(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: 1680.wMin,
                child: SizedBox(
                  width: 880.wMin,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 16.wMin),
                        _buildTitleWidget(),
                        SizedBox(height: 56.wMin),
                        _buildEmailWidget(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

  }


  Widget _buildTitleWidget(){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.wMin, vertical: 40.wMin),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.wMin),
        color: AppTheme.cFeedbackInfoBackground,
      ),
      child: Text(
        "为营造更好的学习环境，欢迎您通过邮箱形式向我们举报违法和不良信息",
        style: TextStyle(
          fontSize: 24.wMin,
          fontWeight: FontWeight.w600,
          color: AppTheme.cFeedbackInfoText,
        ),
      ),
    );
  }

  Widget _buildEmailWidget(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "违法和不良信息举报邮箱",
          style: TextStyle(
            fontSize: 28.wMin,
            fontWeight: FontWeight.w500,
            color: AppTheme.cTextPrimary,
          ),
        ),
        SizedBox(height: 8.wMin),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.wMin),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.wMin),
            color: AppTheme.cBgTertiary,
            border: Border.all(width: 1.wMin, color: AppTheme.cBorderPrimary),
          ),
          child: Obx((){
            String text = controller.email.value;
            return Text(
              text,
              style: TextStyle(
                fontSize: 24.wMin,
                fontWeight: FontWeight.w600,
                color: AppTheme.cTextPrimary,
              ),
            );
          }),
        ),
        SizedBox(height: 8.wMin),
        Text(
          "请在邮件中注明您的手机号、违法不良信息描述、违法不良信息截图及其他有消息，感谢配合",
          style: TextStyle(
            fontSize: 24.wMin,
            fontWeight: FontWeight.w400,
            color: AppTheme.cTextSecondary,
          ),
        )
      ],
    );
  } 

}
