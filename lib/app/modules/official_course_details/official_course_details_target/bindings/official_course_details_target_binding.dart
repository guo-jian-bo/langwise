import 'package:get/get.dart';

import '../controllers/official_course_details_target_controller.dart';

class OfficialCourseDetailsTargetBinding extends Bindings {
  final String? tagText;
  OfficialCourseDetailsTargetBinding({this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<OfficialCourseDetailsTargetController>(
      () => OfficialCourseDetailsTargetController(),
      tag: tagText,
    );
  }
}
