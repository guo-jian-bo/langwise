import 'package:get/get.dart';

import '../controllers/customized_courses_controller.dart';

class CustomizedCoursesBinding extends Bindings {
  final String tagText;
  CustomizedCoursesBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<CustomizedCoursesController>(
      () => CustomizedCoursesController(tagText: tagText),
      tag: tagText,
      fenix: true,
    );
  }
}
