import 'package:get/get.dart';

import '../controllers/custom_course_generation_detail_controller.dart';

class CustomCourseGenerationDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomCourseGenerationDetailController>(
      () => CustomCourseGenerationDetailController(),
    );
  }
}
