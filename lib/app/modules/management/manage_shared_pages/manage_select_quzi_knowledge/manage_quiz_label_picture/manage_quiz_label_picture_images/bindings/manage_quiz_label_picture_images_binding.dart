import 'package:get/get.dart';

import '../controllers/manage_quiz_label_picture_images_controller.dart';

class ManageQuizLabelPictureImagesBinding extends Bindings {
  final String tag;
  ManageQuizLabelPictureImagesBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageQuizLabelPictureImagesController>(
      () => ManageQuizLabelPictureImagesController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
