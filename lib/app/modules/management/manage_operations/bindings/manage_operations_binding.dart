import 'package:get/get.dart';

import '../controllers/manage_operations_controller.dart';

class ManageOperationsBinding extends Bindings {
  final String tag;
  ManageOperationsBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageOperationsController>(
      () => ManageOperationsController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
