import 'package:get/get.dart';

import '../controllers/manage_phonics_course_controller.dart';

class ManagePhonicsCourseBinding extends Bindings {
  final String tag;
  ManagePhonicsCourseBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManagePhonicsCourseController>(
      () => ManagePhonicsCourseController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
