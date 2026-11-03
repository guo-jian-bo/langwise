import 'package:get/get.dart';

import '../controllers/manage_quiz_context_choice_controller.dart';

class ManageQuizContextChoiceBinding extends Bindings {
  final String tag;
  ManageQuizContextChoiceBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageQuizContextChoiceController>(
      () => ManageQuizContextChoiceController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
