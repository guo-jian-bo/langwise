import 'package:get/get.dart';

import '../controllers/custom_course_manage_grade_sort_controller.dart';

class CustomCourseManageGradeSortBinding extends Bindings {
  final String tagText;
  CustomCourseManageGradeSortBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<CustomCourseManageGradeSortController>(
      () => CustomCourseManageGradeSortController(tagText: tagText),
      tag: tagText,
      fenix: true,
    );
  }
}
