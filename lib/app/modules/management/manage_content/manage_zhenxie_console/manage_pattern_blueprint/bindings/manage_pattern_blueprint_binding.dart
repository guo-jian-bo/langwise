import 'package:get/get.dart';

import '../controllers/manage_pattern_blueprint_controller.dart';

class ManagePatternBlueprintBinding extends Bindings {
  final String tag;
  ManagePatternBlueprintBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManagePatternBlueprintController>(
      () => ManagePatternBlueprintController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
