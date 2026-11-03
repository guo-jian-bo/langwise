import 'package:get/get.dart';

import '../controllers/user_center_controller.dart';
import '../controllers/user_visual_style_controller.dart';

class UserCenterBinding extends Bindings {
  final String tagText;
  UserCenterBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<UserCenterController>(
      () => UserCenterController(tagText: tagText),
      tag: tagText,
    );
    Get.lazyPut<UserVisualStyleController>(
      () => UserVisualStyleController(tagText: tagText),
      tag: tagText,
    );
  }
}
