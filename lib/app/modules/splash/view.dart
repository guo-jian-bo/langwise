import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import '../../../common/widgets/widgets.dart';
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
            backgroundColor: AppTheme.cBgPrimary.color,
            body: Container(
              alignment: Alignment.center,
              child: Obx((){

                if(controller.error.value){

                  return NotDataWidget(
                    message: "网络异常，请重新启动",
                    other: ButtonWidget(
                      text: "退出",
                      width: 200.wMin,
                      height: 50.wMin,
                      borderRadius: 10.wMin,
                      fontSize: 24.wMin,
                      sclae: 1.05,
                      onTap: () {
                        controller.onExitApp();
                      },
                    ),
                  );

                }

                return SpinKitFadingCircle(
                  color: AppTheme.cBgBrand,
                  size: 100.wMin,
                );
              }),
            ),
          );
        },
      );
    });
  }
}
