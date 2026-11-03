import 'package:get/get.dart';

import '../controllers/official_course_details_level_controller.dart';

class OfficialCourseDetailsLevelBinding extends Bindings {
  final String tagText;
  OfficialCourseDetailsLevelBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<OfficialCourseDetailsLevelController>(
      () => OfficialCourseDetailsLevelController(tagText: tagText),
      tag: tagText,
      fenix: true,
    );
  }
}
