import 'package:get/get.dart';

import '../controllers/manage_quiz_contrast_cloze_controller.dart';

class ManageQuizContrastClozeBinding extends Bindings {
  final String tag;
  ManageQuizContrastClozeBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageQuizContrastClozeController>(
      () => ManageQuizContrastClozeController(tag: tag),
      tag: tag,
    );
  }
}
