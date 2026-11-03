import 'package:get/get.dart';

import '../controllers/course_unit_grammar_details_controller.dart';

class CourseUnitGrammarDetailsBinding extends Bindings {
  final String tagText;
  CourseUnitGrammarDetailsBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<CourseUnitGrammarDetailsController>(
      () => CourseUnitGrammarDetailsController(tagText: tagText),
      tag: tagText,
    );
  }
}
