import 'package:get/get.dart';

import '../controllers/manage_zhenxie_console_controller.dart';

class ManageZhenxieConsoleBinding extends Bindings {
  final String tag;
  ManageZhenxieConsoleBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageZhenxieConsoleController>(
      () => ManageZhenxieConsoleController(tag: tag),
      tag: tag,
    );
  }
}
