import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:get/get.dart';
import 'package:langwise/common/widgets/widgets.dart';
import 'package:langwise/app/routes/routes.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../../../../theme/theme.dart';
import '../../application/controllers/application_controller.dart';
import '../controllers/home_controller.dart';
import 'home_card_list_widget.dart';
import 'home_fist_card.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          backgroundColor: AppTheme.cBgPrimary,
          body: Container(
            width: double.infinity,
            height: double.infinity,
            alignment: Alignment.center,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom,
            ),
            child: Obx((){
              Widget bodyWidget = Container(
                alignment: Alignment.center,
                child: SpinKitFadingCircle(
                  color: AppTheme.cBgBrand,
                  size: 100.wMin,
                ),
              );
              if(controller.homeReqError.value != -1){
                bodyWidget = _buildErrorWidget();
              }
              if(controller.homeReqError.value == 0){
                bodyWidget = _buildBodyWidget();
              }

              return bodyWidget;
              
            }),
          ),
        );
      },
    );
  }

  Widget _buildBodyWidget(){
    return SingleChildScrollView(
      key: const ValueKey("homeBodyWidget"),
      padding: EdgeInsets.zero,
      child: SingleChildScrollView(
        padding: EdgeInsets.zero,
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Visibility(
              visible: controller.homeFistCardTabData.isNotEmpty,
              child: Container(
                margin: EdgeInsets.only(right: 40.wMin),
                width: 619.wMin,
                height: 800.wMin,
                child: const HomeFistCard(),
              ),
            ),
            SizedBox(
              width: 530.wMin * 2 + 41.wMin,
              height: 800.wMin,
              child: const HomeCardListWidget(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(){
    String errText = "";
    if(controller.homeReqError.value == 1){
      errText = "网络链接不稳定，请检查网络后重试";
    }
    if(controller.homeReqError.value == 2){
      errText = "网络连接超时，请检查网络后重试";
    }
    if(controller.homeReqError.value == 3){
      errText = "请求失败，请刷新重试";
    }
    if(controller.homeReqError.value == 4){
      errText = "暂无数据";
    }
    return NotDataWidget(
      key: const ValueKey("homeErrorWidget"),
      message: errText,
      other: ButtonWidget(
        text: "刷新",
        width: 300.wMin,
        height: 56.wMin,
        borderRadius: 8.wMin,
        sclae: 1.01,
        fontSize: 24.wMin,
        onTap: () {
          controller.homeReqError.value = -1;
          if (Get.isRegistered<ApplicationController>(tag: Routes.APPLICATION)) {
            Get.find<ApplicationController>(tag: Routes.APPLICATION).refreshData(isLoading: false);
          }
        },
      ),
    );
  }
}
