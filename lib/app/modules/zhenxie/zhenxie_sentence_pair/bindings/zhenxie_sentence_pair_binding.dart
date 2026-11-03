import 'package:get/get.dart';

import '../controllers/zhenxie_sentence_pair_controller.dart';

class ZhenxieSentencePairBinding extends Bindings {
  final String tagText;
  ZhenxieSentencePairBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<ZhenxieSentencePairController>(
      () => ZhenxieSentencePairController(tagText: tagText),
      tag: tagText,
    );
  }
}
