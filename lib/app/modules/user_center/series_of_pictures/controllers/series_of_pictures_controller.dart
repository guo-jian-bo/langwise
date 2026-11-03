import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../model/visual_style_model.dart';


class SeriesOfPicturesController extends GetxController {
  VisualStyleModel? styleData;
  int showIndex = 0;


  late final PageController pageController;
  final RxDouble currentPageIndex = 0.0.obs;


  @override
  void onInit() {
    super.onInit();
    if(Get.arguments != null){
      styleData = Get.arguments["styleData"];
      showIndex = Get.arguments['showIndex']??0;
      currentPageIndex.value = showIndex.toDouble();
    }

    pageController = PageController(viewportFraction: 0.5, initialPage: showIndex);
    pageController.addListener((){
      currentPageIndex.value = pageController.page??0.0;
    });
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
