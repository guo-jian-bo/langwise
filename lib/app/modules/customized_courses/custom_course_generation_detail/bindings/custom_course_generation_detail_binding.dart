import 'package:get/get.dart';

import '../controllers/custom_course_generation_detail_controller.dart';

class CustomCourseGenerationDetailBinding extends Bindings {
  final String tagText;
  CustomCourseGenerationDetailBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<CustomCourseGenerationDetailController>(
      () => CustomCourseGenerationDetailController(tagText: tagText),
      tag: tagText,
      fenix: true,
    );
  }
}
