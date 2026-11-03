import 'package:get/get.dart';

import '../controllers/manage_quiz_cloze_test_b_controller.dart';

class ManageQuizClozeTestBBinding extends Bindings {
  final String tag;
  ManageQuizClozeTestBBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageQuizClozeTestBController>(
      () => ManageQuizClozeTestBController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
