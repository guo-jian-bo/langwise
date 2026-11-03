import 'package:get/get.dart';

import '../controllers/official_course_details_flash_notes_controller.dart';

class OfficialCourseDetailsFlashNotesBinding extends Bindings {
  final String tagText;
  OfficialCourseDetailsFlashNotesBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<OfficialCourseDetailsFlashNotesController>(
      () => OfficialCourseDetailsFlashNotesController(tagText: tagText),
      tag: tagText,
      fenix: true,
    );
  }
}
