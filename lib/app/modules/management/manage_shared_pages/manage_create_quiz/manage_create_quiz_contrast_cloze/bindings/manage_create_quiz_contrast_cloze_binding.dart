import 'package:get/get.dart';

import '../controllers/manage_create_quiz_contrast_cloze_controller.dart';

class ManageCreateQuizContrastClozeBinding extends Bindings {
  final String tag;
  ManageCreateQuizContrastClozeBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageCreateQuizContrastClozeController>(
      () => ManageCreateQuizContrastClozeController(tag: tag),
      tag: tag,
    );
  }
}
