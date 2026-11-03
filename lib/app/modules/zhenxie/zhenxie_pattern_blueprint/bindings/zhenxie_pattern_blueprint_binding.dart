import 'package:get/get.dart';

import '../controllers/zhenxie_pattern_blueprint_controller.dart';

class ZhenxiePatternBlueprintBinding extends Bindings {
  final String tagText;
  ZhenxiePatternBlueprintBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<ZhenxiePatternBlueprintController>(
      () => ZhenxiePatternBlueprintController(tagText: tagText),
      tag: tagText,
    );
  }
}
