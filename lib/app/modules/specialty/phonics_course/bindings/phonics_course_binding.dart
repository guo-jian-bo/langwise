import 'package:get/get.dart';

import '../controllers/phonics_course_controller.dart';

class PhonicsCourseBinding extends Bindings {
  final String tagText;
  PhonicsCourseBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<PhonicsCourseController>(
      () => PhonicsCourseController(tagText: tagText),
      tag: tagText,
    );
  }
}
