import 'package:get/get.dart';

import '../controllers/new_create_study_plan_controller.dart';

class NewCreateStudyPlanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NewCreateStudyPlanController>(
      () => NewCreateStudyPlanController(),
    );
  }
}
