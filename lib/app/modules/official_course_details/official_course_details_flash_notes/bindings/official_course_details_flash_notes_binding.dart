import 'package:get/get.dart';

import '../controllers/official_course_details_flash_notes_controller.dart';

class OfficialCourseDetailsFlashNotesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OfficialCourseDetailsFlashNotesController());
  }
}