import 'package:get/get.dart';

import '../controllers/official_course_details_dictation_check_controller.dart';

class OfficialCourseDetailsDictationCheckBinding extends Bindings {
  final String tagText;
  OfficialCourseDetailsDictationCheckBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<OfficialCourseDetailsDictationCheckController>(
      () => OfficialCourseDetailsDictationCheckController(tagText: tagText),
      tag: tagText,
      fenix: true,
    );
  }
}
