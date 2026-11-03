import 'package:get/get.dart';

import '../controllers/official_course_details_dictation_controller.dart';

class OfficialCourseDetailsDictationBinding extends Bindings {
  final String tagText;
  OfficialCourseDetailsDictationBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<OfficialCourseDetailsDictationController>(
      () => OfficialCourseDetailsDictationController(tagText: tagText),
      tag: tagText,
      fenix: true,
    );
  }
}
