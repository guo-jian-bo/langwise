import 'package:get/get.dart';

import '../controllers/manage_english_course_usage_controller.dart';

class ManageEnglishCourseUsageBinding extends Bindings {
  final String tag;
  ManageEnglishCourseUsageBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageEnglishCourseUsageController>(
      () => ManageEnglishCourseUsageController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
