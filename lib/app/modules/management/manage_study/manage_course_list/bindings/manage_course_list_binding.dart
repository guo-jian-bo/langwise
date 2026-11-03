import 'package:get/get.dart';

import '../controllers/manage_course_list_controller.dart';

class ManageCourseListBinding extends Bindings {
  final String tag;
  ManageCourseListBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageCourseListController>(
      () => ManageCourseListController(tag: tag),
      tag: tag,
    );
  }
}
