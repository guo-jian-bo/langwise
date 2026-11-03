import 'package:get/get.dart';

import '../controllers/official_course_details_controller.dart';

class OfficialCourseDetailsBinding extends Bindings {
  final String tagText;
  OfficialCourseDetailsBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<OfficialCourseDetailsController>(
      () => OfficialCourseDetailsController(tagText: tagText),
      tag: tagText,
    );
  }
}
