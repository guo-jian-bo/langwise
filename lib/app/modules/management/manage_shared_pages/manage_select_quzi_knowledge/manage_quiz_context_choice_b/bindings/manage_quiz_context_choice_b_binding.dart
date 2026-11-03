import 'package:get/get.dart';

import '../controllers/manage_quiz_context_choice_b_controller.dart';

class ManageQuizContextChoiceBBinding extends Bindings {
  final String tag;
  ManageQuizContextChoiceBBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageQuizContextChoiceBController>(
      () => ManageQuizContextChoiceBController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
