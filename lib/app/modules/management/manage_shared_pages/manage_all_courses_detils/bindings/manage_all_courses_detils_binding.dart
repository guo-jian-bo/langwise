import 'package:get/get.dart';

import '../controllers/manage_all_courses_detils_controller.dart';

class ManageAllCoursesDetilsBinding extends Bindings {
  final String tag;
  ManageAllCoursesDetilsBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageAllCoursesDetilsController>(
      () => ManageAllCoursesDetilsController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
