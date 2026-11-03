import 'package:get/get.dart';

import '../controllers/zhenxie_sentence_pattern_compare_details_controller.dart';

class ZhenxieSentencePatternCompareDetailsBinding extends Bindings {
  final String tagText;
  ZhenxieSentencePatternCompareDetailsBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<ZhenxieSentencePatternCompareDetailsController>(
      () => ZhenxieSentencePatternCompareDetailsController(tagText: tagText),
      tag: tagText,
      fenix: true,
    );
  }
}
