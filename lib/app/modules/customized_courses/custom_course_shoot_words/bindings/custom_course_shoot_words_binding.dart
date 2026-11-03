import '../controllers/custom_course_shoot_words_controller.dart';
import 'package:get/get.dart';

class CustomCourseShootWordsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomCourseShootWordsController>(
      () => CustomCourseShootWordsController(),
    );
  }
}