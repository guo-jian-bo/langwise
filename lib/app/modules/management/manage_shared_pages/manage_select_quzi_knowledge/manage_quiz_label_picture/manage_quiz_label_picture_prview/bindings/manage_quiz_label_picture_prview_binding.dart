import 'package:get/get.dart';

import '../controllers/manage_quiz_label_picture_prview_controller.dart';

class ManageQuizLabelPicturePrviewBinding extends Bindings {
  final String tag;
  ManageQuizLabelPicturePrviewBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageQuizLabelPicturePrviewController>(
      () => ManageQuizLabelPicturePrviewController(tag: tag),
      tag: tag,
    );
  }
}
