import 'package:get/get.dart';

import '../controllers/manage_pattern_blueprint_details_controller.dart';

class ManagePatternBlueprintDetailsBinding extends Bindings {
  final String tag;
  ManagePatternBlueprintDetailsBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManagePatternBlueprintDetailsController>(
      () => ManagePatternBlueprintDetailsController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
