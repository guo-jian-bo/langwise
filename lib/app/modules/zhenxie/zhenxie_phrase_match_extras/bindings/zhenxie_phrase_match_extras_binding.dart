import 'package:get/get.dart';

import '../controllers/zhenxie_phrase_match_extras_controller.dart';

class ZhenxiePhraseMatchExtrasBinding extends Bindings {
  final String tagText;
  ZhenxiePhraseMatchExtrasBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<ZhenxiePhraseMatchExtrasController>(
      () => ZhenxiePhraseMatchExtrasController(tagText: tagText),
      tag: tagText,
      fenix: true,
    );
  }
}
