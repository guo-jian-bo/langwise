import 'package:get/get.dart';

import '../controllers/manage_quiz_label_picture_setting_controller.dart';

class ManageQuizLabelPictureSettingBinding extends Bindings {
  final String tag;
  ManageQuizLabelPictureSettingBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageQuizLabelPictureSettingController>(
      () => ManageQuizLabelPictureSettingController(tag: tag),
      tag: tag,
    );
  }
}
