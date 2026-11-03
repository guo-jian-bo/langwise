import 'package:get/get.dart';

import '../controllers/manage_edit_quiz_contrast_cloze_controller.dart';

class ManageEditQuizContrastClozeBinding extends Bindings {
  final String tag;
  ManageEditQuizContrastClozeBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageEditQuizContrastClozeController>(
      () => ManageEditQuizContrastClozeController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
