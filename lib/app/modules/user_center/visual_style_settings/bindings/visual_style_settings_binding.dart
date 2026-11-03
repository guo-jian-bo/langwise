import 'package:get/get.dart';

import '../controllers/visual_style_settings_controller.dart';

class VisualStyleSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VisualStyleSettingsController>(
      () => VisualStyleSettingsController(),
    );
  }
}
