import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../routes/routes.dart';
import '../bindings/open_source_license_binding.dart';
import '../controllers/open_source_license_controller.dart';

class OpenSourceLicenseView extends GetView<OpenSourceLicenseController> {
  final String tagText;
  const OpenSourceLicenseView({super.key, required this.tagText});

  @override
  String? get tag => tagText;

  static Future<T?> to<T>({dynamic arguments, required String tag}) async {
    return await Get.to<T>(
      () => OpenSourceLicenseView(tagText: tag),
      binding: OpenSourceLicenseBinding(tagText: tag),
      routeName: Routes.OPEN_SOURCE_LICENSE,
      arguments: arguments,
      preventDuplicates: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cBgPrimary.color,
      body: Column(
        children: [
          const BreadcrumbWidget(),
          Expanded(
            child: Container(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: 1680.wMin,
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 70.wMin),
                  child: SizedBox(
                    width: double.infinity,
                    child: Obx((){
                      return Text(
                        controller.openSourceLicense.value,
                        style: TextStyle(
                          fontSize: 24.wMin,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.cTextPrimary.color,
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


}
