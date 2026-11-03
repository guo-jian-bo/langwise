import 'package:get/get.dart';

import '../controllers/zhenxie_grammar_panorama_controller.dart';

class ZhenxieGrammarPanoramaBinding extends Bindings {
  final String tagText;
  ZhenxieGrammarPanoramaBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<ZhenxieGrammarPanoramaController>(
      () => ZhenxieGrammarPanoramaController(tagText: tagText),
      tag: tagText,
    );
  }
}
