import 'package:get/get.dart';

import '../controllers/zhenxie_grammar_panorama_details_controller.dart';

class ZhenxieGrammarPanoramaDetailsBinding extends Bindings {
  final String tagText;
  ZhenxieGrammarPanoramaDetailsBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<ZhenxieGrammarPanoramaDetailsController>(
      () => ZhenxieGrammarPanoramaDetailsController(tagText: tagText),
      tag: tagText,
    );
  }
}
