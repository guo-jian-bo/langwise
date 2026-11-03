import 'package:get/get.dart';

import '../controllers/manage_script_allocation_group_controller.dart';

class ManageScriptAllocationGroupBinding extends Bindings {
  final String tag;
  ManageScriptAllocationGroupBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageScriptAllocationGroupController>(
      () => ManageScriptAllocationGroupController(tag: tag),
      tag: tag,
    );
  }
}
