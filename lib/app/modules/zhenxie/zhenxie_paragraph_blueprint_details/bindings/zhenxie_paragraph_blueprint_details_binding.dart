import 'package:get/get.dart';

import '../controllers/zhenxie_paragraph_blueprint_details_controller.dart';

class ZhenxieParagraphBlueprintDetailsBinding extends Bindings {
  final String tagText;
  ZhenxieParagraphBlueprintDetailsBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<ZhenxieParagraphBlueprintDetailsController>(
      () => ZhenxieParagraphBlueprintDetailsController(tagText: tagText),
      tag: tagText,
    );
  }
}
