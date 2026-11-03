import 'package:get/get.dart';

import '../controllers/manage_permission_create_controller.dart';

class ManagePermissionCreateBinding extends Bindings {
  final String tag;
  ManagePermissionCreateBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManagePermissionCreateController>(
      () => ManagePermissionCreateController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}

