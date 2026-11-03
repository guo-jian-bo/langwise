import 'package:get/get.dart';

import '../controllers/official_course_details_preview_controller.dart';

class OfficialCourseDetailsPreviewBinding extends Bindings {
  final String tagText;
  OfficialCourseDetailsPreviewBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<OfficialCourseDetailsPreviewController>(
      () => OfficialCourseDetailsPreviewController(tagText: tagText),
      tag: tagText,
      fenix: true,
    );
  }
}
