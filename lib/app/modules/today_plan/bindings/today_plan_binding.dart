import 'package:get/get.dart';

import '../controllers/today_plan_controller.dart';

class TodayPlanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TodayPlanController>(
      () => TodayPlanController(),
    );
  }
}
