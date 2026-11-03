import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ui_essentials/ui_essentials.dart';

import '../controllers/home_controller.dart';

class HomeCardListWidget extends GetView<HomeController> {
  const HomeCardListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx((){
      // ignore: invalid_use_of_protected_member
      List<Widget> bodyCardList = controller.bodyCardList.value;

      return LayoutBuilder(
        builder: (context, constraints) {
        if(bodyCardList.isEmpty) return const SizedBox();
          if(bodyCardList.length == 1){
            return Flex(
              direction: Axis.vertical,
              children: [
                bodyCardList[0],
              ],
            );
          }else if(bodyCardList.length == 2){
            return Column(
              children: [
                bodyCardList[0],
                SizedBox(height: 41.wMin),
                bodyCardList[1],
              ],
            );
          }else if(bodyCardList.length == 3){
            return Column(
              children: [
                bodyCardList[0],
                SizedBox(height: 41.wMin),
                Expanded(
                  child: Row(
                    children: [
                      bodyCardList[1],
                      SizedBox(width: 39.wMin),
                      bodyCardList[2],
                    ],
                  ),
                ),
              ],
            );
          }else if(bodyCardList.length == 4){
            return Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      bodyCardList[0],
                      SizedBox(width: 39.wMin),
                      bodyCardList[1],
                    ],
                  ),
                ),
                SizedBox(height: 41.wMin),
                Expanded(
                  child: Row(
                    children: [
                      bodyCardList[2],
                      SizedBox(width: 39.wMin),
                      bodyCardList[3],
                    ],
                  ),
                ),
              ],
            );
          }
          return Container();
        },
      );
    });
  }
}