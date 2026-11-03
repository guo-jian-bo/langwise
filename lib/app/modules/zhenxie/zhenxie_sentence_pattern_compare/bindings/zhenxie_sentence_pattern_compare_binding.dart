import 'package:get/get.dart';

import '../controllers/zhenxie_sentence_pattern_compare_controller.dart';

class ZhenxieSentencePatternCompareBinding extends Bindings {
  final String tagText;
  ZhenxieSentencePatternCompareBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<ZhenxieSentencePatternCompareController>(
      () => ZhenxieSentencePatternCompareController(tagText: tagText),
      tag: tagText,
      fenix: true,
    );
  }
}
