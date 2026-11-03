import 'package:get/get.dart';

import '../controllers/zhenxie_phrase_contrast_details_controller.dart';

class ZhenxiePhraseContrastDetailsBinding extends Bindings {
  final String tagText;
  ZhenxiePhraseContrastDetailsBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<ZhenxiePhraseContrastDetailsController>(
      () => ZhenxiePhraseContrastDetailsController(tagText: tagText),
      tag: tagText,
      fenix: true,
    );
  }
}
