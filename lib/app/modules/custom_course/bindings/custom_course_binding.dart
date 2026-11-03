import 'package:get/get.dart';
import '../controllers/custom_course_controller.dart';

class CustomCourseBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomCourseController>(
      () => CustomCourseController(),
    );
  }
}
