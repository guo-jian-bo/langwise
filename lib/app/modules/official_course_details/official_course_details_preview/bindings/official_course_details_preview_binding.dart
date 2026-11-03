import 'package:get/get.dart';

import '../controllers/official_course_details_preview_controller.dart';

class OfficialCourseDetailsPreviewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OfficialCourseDetailsPreviewController());
  }
}