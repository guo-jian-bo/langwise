import 'package:get/get.dart';

import '../controllers/guided_settings_controller.dart';

class GuidedSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GuidedSettingsController>(
      () => GuidedSettingsController(),
    );
  }
}
