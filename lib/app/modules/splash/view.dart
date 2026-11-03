import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import '../../../theme/theme.dart';
import 'index.dart';
import 'package:ui_essentials/ui_essentials.dart';

class SplashPage extends GetView<SplashController> {
  const SplashPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx((){
      controller.login.value;
      return LayoutBuilder(
        builder: (context, constraints) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            body: Container(
              alignment: Alignment.center,
              child: SpinKitFadingCircle(
                color: AppTheme.cBgBrand,
                size: 100.wMin,
              ),
            ),
          );
        },
      );
    });
  }
}
