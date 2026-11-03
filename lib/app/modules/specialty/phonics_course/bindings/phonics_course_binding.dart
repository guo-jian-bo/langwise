import 'package:get/get.dart';

import '../controllers/phonics_course_controller.dart';

class PhonicsCourseBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PhonicsCourseController>(
      () => PhonicsCourseController(),
    );
  }
}
