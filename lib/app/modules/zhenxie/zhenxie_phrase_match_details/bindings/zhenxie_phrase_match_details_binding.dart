import 'package:get/get.dart';

import '../controllers/zhenxie_phrase_match_details_controller.dart';

class ZhenxiePhraseMatchDetailsBinding extends Bindings {
  final String tagText;
  ZhenxiePhraseMatchDetailsBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<ZhenxiePhraseMatchDetailsController>(
      () => ZhenxiePhraseMatchDetailsController(tagText: tagText),
      tag: tagText,
    );
  }
}
