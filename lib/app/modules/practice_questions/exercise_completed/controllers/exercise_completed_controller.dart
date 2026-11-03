import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExerciseCompletedController extends GetxController with GetSingleTickerProviderStateMixin{
  
  final PageController pageController = PageController(viewportFraction: 0.4);
  final RxInt currentPageIndex = 0.obs;
  bool isButtonClickable = true;

  @override
  void onInit() {
    super.onInit();
  }


  Future<void> switchPage() async{
    if(currentPageIndex.value > 3) return;
    if(!isButtonClickable) return;
    isButtonClickable = false;
    currentPageIndex.value ++;
    pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.linear);
    Future.delayed(const Duration(milliseconds: 500), (){
      isButtonClickable = true;
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
