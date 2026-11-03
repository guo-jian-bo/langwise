import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../bindings/zhenxie_binding.dart';
import '../controllers/zhenxie_controller.dart';

class ZhenxieView extends GetView<ZhenxieController> {
  final String tagText;
  const ZhenxieView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      ZhenxieView(tagText: tag),
      binding: ZhenxieBinding(tagText: tag),
      routeName: Routes.ZHENXIE,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cBgPrimary,
      body: Container(
        alignment: Alignment.topCenter,
        child: Container(
          width: 1680.wMin,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 40.wMin,
            left: 40.wMin,
            right: 40.wMin,
            bottom: 10.wMin + MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            children: [
              const BackWidget(title: "甄写"),
              Expanded(
                child: Center(
                  child: Text(
                    "甄写",
                    style: TextStyle(
                      fontSize: 28.wMin,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.cTextPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
