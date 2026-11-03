import 'package:get/get.dart';

import '../controllers/manage_create_quiz_sentence_cloze_controller.dart';

class ManageCreateQuizSentenceClozeBinding extends Bindings {
  final String tag;
  ManageCreateQuizSentenceClozeBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageCreateQuizSentenceClozeController>(
      () => ManageCreateQuizSentenceClozeController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
