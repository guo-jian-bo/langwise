import 'package:get/get.dart';

import '../controllers/zhenxie_phrase_match_controller.dart';

class ZhenxiePhraseMatchBinding extends Bindings {
  final String tagText;
  ZhenxiePhraseMatchBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<ZhenxiePhraseMatchController>(
      () => ZhenxiePhraseMatchController(tagText: tagText),
      tag: tagText,
    );
  }
}
