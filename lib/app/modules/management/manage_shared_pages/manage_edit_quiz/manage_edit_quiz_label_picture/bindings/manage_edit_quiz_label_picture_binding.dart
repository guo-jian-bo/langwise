import 'package:get/get.dart';

import '../controllers/manage_edit_quiz_label_picture_controller.dart';

class ManageEditQuizLabelPictureBinding extends Bindings {
  final String tag;
  ManageEditQuizLabelPictureBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageEditQuizLabelPictureController>(
      () => ManageEditQuizLabelPictureController(tag: tag),
      tag: tag,
    );
  }
}
