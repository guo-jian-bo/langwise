import 'package:get/get.dart';

import '../controllers/manage_unit_controller.dart';

class ManageUnitBinding implements Bindings {
  final String tag;
  ManageUnitBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageUnitController>(
      () => ManageUnitController(tag: tag),
      tag: tag,
    );
  }
}
