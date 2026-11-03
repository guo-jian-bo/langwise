import 'package:get/get.dart';
import '../controllers/custom_course_controller.dart';

class CustomCourseBinding extends Bindings {
  final String tagText;
  CustomCourseBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<CustomCourseController>(
      () => CustomCourseController(tagText: tagText),
      tag: tagText,
      fenix: true,
    );
  }
}
