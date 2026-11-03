import 'package:get/get.dart';

import '../controllers/official_course_details_unit_script_controller.dart';

class OfficialCourseDetailsUnitScriptBinding extends Bindings {
  final String tagText;
  OfficialCourseDetailsUnitScriptBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<OfficialCourseDetailsUnitScriptController>(
      () => OfficialCourseDetailsUnitScriptController(tagText: tagText),
      tag: tagText,
      fenix: true,
    );
  }
}
