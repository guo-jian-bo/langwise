import 'package:get/get.dart';
import 'package:langwise/app/modules/customized_courses/custom_course_check_knowledge/controllers/custom_course_check_knowledge_controller.dart';

class CustomCourseCheckKnowledgeBinding extends Bindings {
  final String tagText;
  CustomCourseCheckKnowledgeBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<CustomCourseCheckKnowledgeController>(
      () => CustomCourseCheckKnowledgeController(tagText: tagText),
      tag: tagText,
      fenix: true,
    );
  }
}
