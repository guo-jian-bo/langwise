import 'package:get/get.dart';

import '../controllers/manage_admin_console_controller.dart';

class ManageAdminConsoleBinding extends Bindings {
  final String tag;
  ManageAdminConsoleBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageAdminConsoleController>(
      () => ManageAdminConsoleController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
