import 'package:get/get.dart';

import '../controllers/manage_permission_controller.dart';

class ManagePermissionBinding extends Bindings {
  final String tag;
  ManagePermissionBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManagePermissionController>(
      () => ManagePermissionController(tag: tag),
      tag: tag,
    );
  }
}
