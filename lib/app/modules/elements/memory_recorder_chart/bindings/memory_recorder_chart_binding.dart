import 'package:get/get.dart';

import '../controllers/memory_recorder_chart_controller.dart';

class MemoryRecorderChartBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MemoryRecorderChartController>(
      () => MemoryRecorderChartController(),
    );
  }
}
