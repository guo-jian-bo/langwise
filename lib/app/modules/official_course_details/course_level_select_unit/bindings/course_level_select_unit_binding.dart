import 'package:get/get.dart';

import '../controllers/course_level_select_unit_controller.dart';

class CourseLevelSelectUnitBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CourseLevelSelectUnitController>(
      () => CourseLevelSelectUnitController(),
    );
  }
}
