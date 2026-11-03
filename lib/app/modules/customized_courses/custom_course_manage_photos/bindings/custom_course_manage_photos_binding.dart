import 'package:get/get.dart';
import '../controllers/custom_course_manage_photos_controller.dart';

class CustomCourseManagePhotosBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CustomCourseManagePhotosController());
  }
}
