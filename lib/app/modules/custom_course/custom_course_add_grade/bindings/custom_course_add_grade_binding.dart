import 'package:get/get.dart';

import '../controllers/custom_course_add_grade_controller.dart';

class CustomCourseAddGradeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomCourseAddGradeController>(
      () => CustomCourseAddGradeController(),
    );
  }
}
