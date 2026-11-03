import '../controllers/custom_course_shoot_words_controller.dart';
import 'package:get/get.dart';

class CustomCourseShootWordsBinding extends Bindings {
  final String tagText;
  CustomCourseShootWordsBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<CustomCourseShootWordsController>(
      () => CustomCourseShootWordsController(tagText: tagText),
      tag: tagText,
    );
  }
}
