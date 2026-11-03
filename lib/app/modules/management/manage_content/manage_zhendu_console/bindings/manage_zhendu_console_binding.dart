import 'package:get/get.dart';

import '../controllers/manage_zhendu_console_controller.dart';

class ManageZhenduConsoleBinding extends Bindings {
  final String tag;
  ManageZhenduConsoleBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageZhenduConsoleController>(
      () => ManageZhenduConsoleController(tag: tag),
      tag: tag,
    );
  }
}
