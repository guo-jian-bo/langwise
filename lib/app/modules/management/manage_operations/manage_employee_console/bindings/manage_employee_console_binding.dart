import 'package:get/get.dart';

import '../controllers/manage_employee_console_controller.dart';

class ManageEmployeeConsoleBinding extends Bindings {
  final String tag;
  ManageEmployeeConsoleBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageEmployeeConsoleController>(
      () => ManageEmployeeConsoleController(tag: tag),
      tag: tag,
    );
  }
}
