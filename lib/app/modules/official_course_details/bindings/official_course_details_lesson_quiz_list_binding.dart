import 'package:get/get.dart';

import '../controllers/official_course_details_lesson_quiz_list_controller.dart';

class OfficialCourseDetailsLessonQuizListBinding extends Bindings {
  final String tagText;
  OfficialCourseDetailsLessonQuizListBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<OfficialCourseDetailsLessonQuizListController>(
      () => OfficialCourseDetailsLessonQuizListController(tagText: tagText),
      tag: tagText,
      fenix: true,
    );
  }
}
