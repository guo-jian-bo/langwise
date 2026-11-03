import 'package:get/get.dart';

import '../controllers/create_study_plan_controller.dart';

class CreateStudyPlanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateStudyPlanController>(
      () => CreateStudyPlanController(),
    );
  }
}
