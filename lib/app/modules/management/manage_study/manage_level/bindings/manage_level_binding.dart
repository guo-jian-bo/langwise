import 'package:get/get.dart';

import '../controllers/manage_level_controller.dart';

class ManageLevelBinding implements Bindings {
  final String tag;
  ManageLevelBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageLevelController>(
      () => ManageLevelController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
