import 'package:get/get.dart';

import '../controllers/manage_lesson_controller.dart';

class ManageLessonBinding implements Bindings {
  final String tag;
  ManageLessonBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageLessonController>(
      () => ManageLessonController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
