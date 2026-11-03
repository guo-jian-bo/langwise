import 'package:get/get.dart';

import '../controllers/manage_quiz_cloze_test_controller.dart';

class ManageQuizClozeTestBinding extends Bindings {
  final String tag;
  ManageQuizClozeTestBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageQuizClozeTestController>(
      () => ManageQuizClozeTestController(tag: tag),
      tag: tag,
    );
  }
}
