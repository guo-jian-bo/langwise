import 'package:get/get.dart';

import '../controllers/manage_module_detils_controller.dart';

class ManageModuleDetilsBinding extends Bindings {
  final String tag;
  ManageModuleDetilsBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageModuleDetilsController>(
      () => ManageModuleDetilsController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
