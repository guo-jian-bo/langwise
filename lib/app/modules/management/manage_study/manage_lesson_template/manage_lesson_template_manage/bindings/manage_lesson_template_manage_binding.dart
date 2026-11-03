import 'package:get/get.dart';

import '../controllers/manage_lesson_template_manage_controller.dart';

class ManageLessonTemplateManageBinding extends Bindings {
  final String tag;
  ManageLessonTemplateManageBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageLessonTemplateManageController>(
      () => ManageLessonTemplateManageController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
