import 'package:get/get.dart';

import '../controllers/manage_edit_quiz_cloze_test_b_controller.dart';

class ManageEditQuizClozeTestBBinding extends Bindings {
  final String tag;
  ManageEditQuizClozeTestBBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageEditQuizClozeTestBController>(
      () => ManageEditQuizClozeTestBController(tag: tag),
      tag: tag,
    );
  }
}
