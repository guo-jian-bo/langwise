import 'package:get/get.dart';

import '../controllers/zhenxie_phrase_contrast_controller.dart';

class ZhenxiePhraseContrastBinding extends Bindings {
  final String tagText;
  ZhenxiePhraseContrastBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<ZhenxiePhraseContrastController>(
      () => ZhenxiePhraseContrastController(tagText: tagText),
      tag: tagText,
      fenix: true,
    );
  }
}
