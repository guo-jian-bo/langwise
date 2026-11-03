import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../theme/theme.dart';
import '../common/manage_scaffold.dart';
import '../controllers/management_controller.dart';

/// 管理模块入口页面
/// 这个页面只是一个跳转页，控制器会在 onReady 中自动跳转到学习页面
class ManagementView extends GetView<ManagementController> {
  const ManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return ManageScaffold(
      showCollectButton: false,
      body: Center(
        child: Obx(() {
          int initStatus = controller.initStatus.value;
          if (initStatus == -1) {
            return SpinKitFadingCircle(
              color: AppTheme.cBgBrand.color,
              size: 100.wMin,
            );
          } else if (initStatus == 1) {
            return Container();
          } else if(initStatus == 2){
            return NotDataWidget(
              message: "无权限",
              other: ButtonWidget(
                text: "返回",
                width: 200.wMin,
                height: 60.wMin,
                borderRadius: 8.wMin,
                fontSize: 24.wMin,
                fontWeight: FontWeight.w600,
                sclae: 1.05,
                onTap: () {
                  Get.back();
                },
              ),
            );
          }
          return NotDataWidget(
            message: "初始化失败",
            other: ButtonWidget(
              text: "重试",
              width: 200.wMin,
              height: 60.wMin,
              borderRadius: 8.wMin,
              fontSize: 24.wMin,
              fontWeight: FontWeight.w600,
              sclae: 1.05,
              onTap: () {
                controller.initAuth();
              },
            ),
          );
          
        }),
      ),
    );
  }
}
