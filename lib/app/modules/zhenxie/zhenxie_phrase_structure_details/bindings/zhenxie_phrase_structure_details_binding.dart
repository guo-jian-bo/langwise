import 'package:get/get.dart';

import '../controllers/zhenxie_phrase_structure_details_controller.dart';

class ZhenxiePhraseStructureDetailsBinding extends Bindings {
  final String tagText;
  ZhenxiePhraseStructureDetailsBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<ZhenxiePhraseStructureDetailsController>(
      () => ZhenxiePhraseStructureDetailsController(tagText: tagText),
      tag: tagText,
      fenix: true,
    );
  }
}
