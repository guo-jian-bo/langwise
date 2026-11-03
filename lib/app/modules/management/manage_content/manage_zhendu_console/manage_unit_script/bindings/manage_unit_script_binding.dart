import 'package:get/get.dart';

import '../controllers/manage_unit_script_controller.dart';

class ManageUnitScriptBinding extends Bindings {
  final String tag;
  ManageUnitScriptBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageUnitScriptController>(
      () => ManageUnitScriptController(tag: tag),
      tag: tag,
    );
  }
}
