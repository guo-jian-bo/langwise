import 'package:get/get.dart';

import '../controllers/manage_quiz_word_completion_controller.dart';

class ManageQuizWordCompletionBinding extends Bindings {
  final String tag;
  ManageQuizWordCompletionBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageQuizWordCompletionController>(
      () => ManageQuizWordCompletionController(tag: tag),
      tag: tag,
    );
  }
}
