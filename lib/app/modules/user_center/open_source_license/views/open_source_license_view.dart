import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:langwise/theme/theme.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../../common/widgets/widgets.dart';
import '../controllers/open_source_license_controller.dart';

class OpenSourceLicenseView extends GetView<OpenSourceLicenseController> {
  const OpenSourceLicenseView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cBgPrimary.color,
      body: Container(
        alignment: Alignment.topCenter,
        child: Container(
          width: 1680.wMin,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 40.wMin,
          ),
          child: Column(
            children: [
              const BackWidget(title: "致谢与开源许可"),
              Expanded(
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
            ],
          ),
        ),
      ),
    );
  }


}
