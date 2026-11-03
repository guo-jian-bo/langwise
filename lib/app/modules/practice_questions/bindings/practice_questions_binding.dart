import 'package:get/get.dart';

import '../controllers/practice_questions_controller.dart';

class PracticeQuestionsBinding extends Bindings {
  final String tagText;
  PracticeQuestionsBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<PracticeQuestionsController>(
      () => PracticeQuestionsController(tagText: tagText),
      tag: tagText,
    );
  }
}
