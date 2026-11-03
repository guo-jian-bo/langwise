import 'package:get/get.dart';

import '../controllers/user_center_controller.dart';
import '../controllers/user_visual_style_controller.dart';

class UserCenterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserCenterController>(
      () => UserCenterController(),
    );
    Get.lazyPut<UserVisualStyleController>(
      () => UserVisualStyleController(),
    );
  }
}
