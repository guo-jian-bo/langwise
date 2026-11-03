import 'package:get/get.dart';

import '../controllers/zhenxie_article_blueprint_controller.dart';

class ZhenxieArticleBlueprintBinding extends Bindings {
  final String tagText;
  ZhenxieArticleBlueprintBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<ZhenxieArticleBlueprintController>(
      () => ZhenxieArticleBlueprintController(tagText: tagText),
      tag: tagText,
    );
  }
}
