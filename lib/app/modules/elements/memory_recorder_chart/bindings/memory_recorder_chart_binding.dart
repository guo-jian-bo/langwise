import 'package:get/get.dart';

import '../controllers/memory_recorder_chart_controller.dart';

class MemoryRecorderChartBinding extends Bindings {
  final String tagText;
  MemoryRecorderChartBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<MemoryRecorderChartController>(
      () => MemoryRecorderChartController(tagText: tagText),
      tag: tagText,
      fenix: true,
    );
  }
}
