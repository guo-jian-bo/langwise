import 'package:get/get.dart';

import '../controllers/manage_create_quiz_word_completion_controller.dart';

class ManageCreateQuizWordCompletionBinding extends Bindings {
  final String tag;
  ManageCreateQuizWordCompletionBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageCreateQuizWordCompletionController>(
      () => ManageCreateQuizWordCompletionController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
