import 'package:get/get.dart';

import '../controllers/practice_questions_controller.dart';

class PracticeQuestionsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PracticeQuestionsController>(
      () => PracticeQuestionsController(),
    );
  }
}
