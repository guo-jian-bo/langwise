import 'package:get/get.dart';

import '../controllers/course_level_select_unit_controller.dart';

class CourseLevelSelectUnitBinding extends Bindings {
  final String tagText;
  CourseLevelSelectUnitBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<CourseLevelSelectUnitController>(
      () => CourseLevelSelectUnitController(tagText: tagText),
      tag: tagText,
      fenix: true,
    );
  }
}
