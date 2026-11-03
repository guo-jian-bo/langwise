import 'package:get/get.dart';

import '../controllers/manage_edit_quiz_word_completion_controller.dart';

class ManageEditQuizWordCompletionBinding extends Bindings {
  final String tag;
  ManageEditQuizWordCompletionBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageEditQuizWordCompletionController>(
      () => ManageEditQuizWordCompletionController(tag: tag),
      tag: tag,
    );
  }
}
