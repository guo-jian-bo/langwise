import 'package:get/get.dart';

import '../controllers/course_unit_target_controller.dart';
import '../controllers/course_unit_target_knowledge_controller.dart';
import '../controllers/course_unit_target_manage_controller.dart';
import '../controllers/course_unit_target_syntax_controller.dart';

class CourseUnitTargetBinding extends Bindings {
  final String tagText;
  CourseUnitTargetBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<CourseUnitTargetController>(
      () => CourseUnitTargetController(tagText: tagText),
      tag: tagText,
    );
    Get.lazyPut<CourseUnitTargetKnowledgeController>(
      () => CourseUnitTargetKnowledgeController(tagText: tagText),
      tag: tagText,
    );
    Get.lazyPut<CourseUnitTargetManageController>(
      () => CourseUnitTargetManageController(tagText: tagText),
      tag: tagText,
    );
    Get.lazyPut<CourseUnitTargetSyntaxController>(
      () => CourseUnitTargetSyntaxController(tagText: tagText),
      tag: tagText,
    );
  }
}
