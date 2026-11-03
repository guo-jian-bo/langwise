import 'package:get/get.dart';

import '../controllers/today_plan_controller.dart';

class TodayPlanBinding extends Bindings {
  final String tagText;
  TodayPlanBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<TodayPlanController>(
      () => TodayPlanController(tagText: tagText),
      tag: tagText,
      fenix: true,
    );
  }
}
