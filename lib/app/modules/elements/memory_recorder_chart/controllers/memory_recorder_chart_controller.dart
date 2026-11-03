import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../views/memory_recorder_tip.dart';

class MemoryRecorderChartController extends GetxController {
  
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  Future<void> showInfoTip(BuildContext context, int index, Rect? originRect) async{
    if(originRect == null) return;
    MemoryRecorderTip.show(context: context, offset: originRect.center);
  }

  @override
  void onClose() {
    super.onClose();
  }
}
