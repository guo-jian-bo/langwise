import 'package:get/get.dart';

import '../controllers/custom_course_manage_grade_controller.dart';

class CustomCourseManageGradeBinding extends Bindings {
  final String tagText;
  CustomCourseManageGradeBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<CustomCourseManageGradeController>(
      () => CustomCourseManageGradeController(tagText: tagText),
      tag: tagText,
      fenix: true,
    );
  }
}
