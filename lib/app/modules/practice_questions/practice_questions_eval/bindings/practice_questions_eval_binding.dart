import 'package:get/get.dart';

import '../controllers/practice_questions_eval_controller.dart';

class PracticeQuestionsEvalBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PracticeQuestionsEvalController>(
      () => PracticeQuestionsEvalController(),
    );
  }
}
