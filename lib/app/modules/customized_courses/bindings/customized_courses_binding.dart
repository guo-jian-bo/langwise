import 'package:get/get.dart';

import '../controllers/customized_courses_controller.dart';

class CustomizedCoursesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomizedCoursesController>(
      () => CustomizedCoursesController(),
    );
  }
}
