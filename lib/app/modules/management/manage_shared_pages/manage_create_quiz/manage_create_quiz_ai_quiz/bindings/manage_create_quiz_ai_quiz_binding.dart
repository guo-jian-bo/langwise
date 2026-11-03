import 'package:get/get.dart';

import '../controllers/manage_create_quiz_ai_quiz_controller.dart';

class ManageCreateQuizAiQuizBinding extends Bindings {
  final String tag;
  ManageCreateQuizAiQuizBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageCreateQuizAiQuizController>(
      () => ManageCreateQuizAiQuizController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
