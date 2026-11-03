import 'package:get/get.dart';

import '../controllers/official_course_details_dictation_check_controller.dart';

class OfficialCourseDetailsDictationCheckBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OfficialCourseDetailsDictationCheckController());
  }
}
