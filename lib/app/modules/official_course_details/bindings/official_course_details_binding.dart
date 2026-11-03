import 'package:get/get.dart';

import '../controllers/official_course_details_controller.dart';

class OfficialCourseDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OfficialCourseDetailsController>(
      () => OfficialCourseDetailsController(),
    );
  }
}
