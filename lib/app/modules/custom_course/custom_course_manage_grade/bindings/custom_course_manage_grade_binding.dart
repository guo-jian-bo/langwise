import 'package:get/get.dart';

import '../controllers/custom_course_manage_grade_controller.dart';

class CustomCourseManageGradeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomCourseManageGradeController>(
      () => CustomCourseManageGradeController(),
    );
  }
}
