import 'package:get/get.dart';

import '../controllers/practice_questions_eval_controller.dart';

class PracticeQuestionsEvalBinding extends Bindings {
  final String tagText;
  PracticeQuestionsEvalBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<PracticeQuestionsEvalController>(
      () => PracticeQuestionsEvalController(tagText: tagText),
      tag: tagText,
    );
  }
}
