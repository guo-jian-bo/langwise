import 'package:get/get.dart';
import '../controllers/custom_course_manage_photos_controller.dart';

class CustomCourseManagePhotosBinding extends Bindings {
  final String tagText;
  CustomCourseManagePhotosBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<CustomCourseManagePhotosController>(
      () => CustomCourseManagePhotosController(tagText: tagText),
      tag: tagText,
    );
  }
}
