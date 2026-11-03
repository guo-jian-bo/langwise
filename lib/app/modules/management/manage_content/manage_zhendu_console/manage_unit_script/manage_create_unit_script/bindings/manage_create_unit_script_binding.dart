import 'package:get/get.dart';

import '../controllers/manage_create_unit_script_controller.dart';

class ManageCreateUnitScriptBinding extends Bindings {
  final String tag;
  ManageCreateUnitScriptBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageCreateUnitScriptController>(
      () => ManageCreateUnitScriptController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
