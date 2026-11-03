import 'package:get/get.dart';

import '../controllers/manage_edit_quiz_cloze_test_a_controller.dart';

class ManageEditQuizClozeTestABinding extends Bindings {
  final String tag;
  ManageEditQuizClozeTestABinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageEditQuizClozeTestAController>(
      () => ManageEditQuizClozeTestAController(tag: tag),
      tag: tag,
    );
  }
}
