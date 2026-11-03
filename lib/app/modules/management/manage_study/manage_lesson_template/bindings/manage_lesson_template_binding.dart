import 'package:get/get.dart';

import '../controllers/manage_lesson_template_controller.dart';

class ManageLessonTemplateBinding implements Bindings {
  final String tag;
  ManageLessonTemplateBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageLessonTemplateController>(
      () => ManageLessonTemplateController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
