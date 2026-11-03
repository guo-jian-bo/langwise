import 'package:get/get.dart';

import '../controllers/zhenxie_pattern_blueprint_details_controller.dart';

class ZhenxiePatternBlueprintDetailsBinding extends Bindings {
  final String tagText;
  ZhenxiePatternBlueprintDetailsBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<ZhenxiePatternBlueprintDetailsController>(
      () => ZhenxiePatternBlueprintDetailsController(tagText: tagText),
      tag: tagText,
      fenix: true,
    );
  }
}
