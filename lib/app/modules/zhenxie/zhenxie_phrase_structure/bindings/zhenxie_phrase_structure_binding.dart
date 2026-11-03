import 'package:get/get.dart';

import '../controllers/zhenxie_phrase_structure_controller.dart';

class ZhenxiePhraseStructureBinding extends Bindings {
  final String tagText;
  ZhenxiePhraseStructureBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<ZhenxiePhraseStructureController>(
      () => ZhenxiePhraseStructureController(tagText: tagText),
      tag: tagText,
    );
  }
}
