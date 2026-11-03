import 'package:flutter/material.dart';
import 'package:ui_essentials/ui_essentials.dart';
import 'package:get/get.dart';
import 'package:langwise/app/routes/routes.dart';

import '../../../../common/widgets/widgets.dart';
import '../../application/controllers/application_controller.dart';
import '../controllers/specialty_controller.dart';
import 'speciaity_card_body_widget.dart';

class SpecialtyView extends GetView<SpecialtyController> {
  const SpecialtyView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom,
        ),
        child: Obx((){
          Widget bodyWidget = Container();
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
  }


  Widget _buildBodyWidget(){
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 50.wMin, vertical: 24.wMin),
      child: Obx((){
        return Row(
          spacing: 40.wMin,
          children: List.generate(controller.cardEntityItems.length, (index) {
            return SpeciaityCardBodyWidget(data: controller.cardEntityItems[index]);
          }),
        );
      }),
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
    if(controller.homeReqError.value == 4){
      errText = "暂无数据！";
    }
    return NotDataWidget(
      key: const ValueKey("specialtyErrorWidget"),
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
            Get.find<ApplicationController>(tag: Routes.APPLICATION).refreshData();
          }
        },
      ),
    );
  }


}
