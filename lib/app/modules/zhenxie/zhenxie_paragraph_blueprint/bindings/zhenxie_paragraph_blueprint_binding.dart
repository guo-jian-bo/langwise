import 'package:get/get.dart';

import '../controllers/zhenxie_paragraph_blueprint_controller.dart';

class ZhenxieParagraphBlueprintBinding extends Bindings {
  final String tagText;
  ZhenxieParagraphBlueprintBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<ZhenxieParagraphBlueprintController>(
      () => ZhenxieParagraphBlueprintController(tagText: tagText),
      tag: tagText,
    );
  }
}
