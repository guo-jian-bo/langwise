import 'package:get/get.dart';

import '../controllers/manage_quiz_label_picture_controller.dart';

class ManageQuizLabelPictureBinding extends Bindings {
  final String tag;
  ManageQuizLabelPictureBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageQuizLabelPictureController>(
      () => ManageQuizLabelPictureController(tag: tag),
      tag: tag,
    );
  }
}
