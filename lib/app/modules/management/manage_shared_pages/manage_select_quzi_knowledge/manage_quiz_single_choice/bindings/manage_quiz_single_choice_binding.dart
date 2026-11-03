import 'package:get/get.dart';

import '../controllers/manage_quiz_single_choice_controller.dart';

class ManageQuizSingleChoiceBinding extends Bindings {
  final String tag;
  ManageQuizSingleChoiceBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageQuizSingleChoiceController>(
      () => ManageQuizSingleChoiceController(tag: tag),
      tag: tag,
    );
  }
}
