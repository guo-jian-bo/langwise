import 'package:get/get.dart';

import '../controllers/preparation_plan_list_controller.dart';

class PreparationPlanListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PreparationPlanListController>(
      () => PreparationPlanListController(),
    );
  }
}
