import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../routes/routes.dart';
import '../../../../routes/routes_breadcrumb_utils.dart';

import '../views/memory_recorder_tip.dart';

class MemoryRecorderChartController extends GetxController with RoutesBreadcrumbMixin {
  final String tagText;
  MemoryRecorderChartController({required this.tagText});

  @override
  String get breadcrumbRoute => Routes.MEMORY_RECORDER_CHART;

  @override
  String get breadcrumbTitle => '超级记忆记录';
  
  @override
  void onInit() {
    super.onInit();
    initBreadcrumb(tagText);
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
