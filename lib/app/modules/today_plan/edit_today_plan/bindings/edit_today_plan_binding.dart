import 'package:get/get.dart';

import '../controllers/edit_today_plan_controller.dart';

class EditTodayPlanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditTodayPlanController>(
      () => EditTodayPlanController(),
    );
  }
}
