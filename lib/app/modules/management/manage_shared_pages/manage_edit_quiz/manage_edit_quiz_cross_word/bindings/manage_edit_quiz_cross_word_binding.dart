import 'package:get/get.dart';

import '../controllers/manage_edit_quiz_cross_word_controller.dart';

class ManageEditQuizCrossWordBinding extends Bindings {
  final String tag;
  ManageEditQuizCrossWordBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageEditQuizCrossWordController>(
      () => ManageEditQuizCrossWordController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
