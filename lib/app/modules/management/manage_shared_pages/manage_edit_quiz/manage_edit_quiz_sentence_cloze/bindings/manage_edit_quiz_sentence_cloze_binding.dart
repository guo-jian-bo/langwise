import 'package:get/get.dart';

import '../controllers/manage_edit_quiz_sentence_cloze_controller.dart';

class ManageEditQuizSentenceClozeBinding extends Bindings {
  final String tag;
  ManageEditQuizSentenceClozeBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageEditQuizSentenceClozeController>(
      () => ManageEditQuizSentenceClozeController(tag: tag),
      tag: tag,
    );
  }
}
