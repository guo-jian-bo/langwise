import 'package:get/get.dart';

import '../controllers/zhenxie_article_blueprint_details_controller.dart';

class ZhenxieArticleBlueprintDetailsBinding extends Bindings {
  final String tagText;
  ZhenxieArticleBlueprintDetailsBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<ZhenxieArticleBlueprintDetailsController>(
      () => ZhenxieArticleBlueprintDetailsController(tagText: tagText),
      tag: tagText,
    );
  }
}
