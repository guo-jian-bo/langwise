import 'package:get/get.dart';
import '../../../custom_course/custom_course_manage_grade/controllers/custom_course_manage_grade_controller.dart';

import '../controllers/official_course_details_level_controller.dart';

class OfficialCourseDetailsLevelBinding extends Bindings {
  final String tagText;
  OfficialCourseDetailsLevelBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<OfficialCourseDetailsLevelController>(
      () => OfficialCourseDetailsLevelController(tagText: tagText),
      tag: tagText,
    );
    Get.lazyPut<CustomCourseManageGradeController>(
      () => CustomCourseManageGradeController(tagText: tagText),
      tag: tagText,
    );
  }
}
