import 'package:get/get.dart';

import '../controllers/manage_module_controller.dart';

class ManageModuleBinding implements Bindings {
  final String tag;
  ManageModuleBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageModuleController>(
      () => ManageModuleController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
