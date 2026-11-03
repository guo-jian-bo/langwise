import 'package:get/get.dart';

import '../controllers/official_course_details_dictation_controller.dart';

class OfficialCourseDetailsDictationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OfficialCourseDetailsDictationController());
  }
}