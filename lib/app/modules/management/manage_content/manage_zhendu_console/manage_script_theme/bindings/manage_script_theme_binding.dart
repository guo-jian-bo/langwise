import 'package:get/get.dart';

import '../controllers/manage_script_theme_controller.dart';

class ManageScriptThemeBinding extends Bindings {
  final String tag;
  ManageScriptThemeBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageScriptThemeController>(
      () => ManageScriptThemeController(tag: tag),
      tag: tag,
    );
  }
}
