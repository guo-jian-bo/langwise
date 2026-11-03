import 'package:get/get.dart';

import '../controllers/official_course_details_target_controller.dart';

class OfficialCourseDetailsTargetBinding extends Bindings {
  final String tagText;
  OfficialCourseDetailsTargetBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<OfficialCourseDetailsTargetController>(
      () => OfficialCourseDetailsTargetController(tagText: tagText),
      tag: tagText,
    );
  }
}
