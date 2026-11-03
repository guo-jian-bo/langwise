import 'package:get/get.dart';

import '../controllers/official_course_details_level_controller.dart';

class OfficialCourseDetailsLevelBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OfficialCourseDetailsLevelController>(
      () => OfficialCourseDetailsLevelController(),
    );
  }
}
