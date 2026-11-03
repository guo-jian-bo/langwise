import 'package:get/get.dart';

import '../controllers/zhenxie_sentence_pair_details_controller.dart';

class ZhenxieSentencePairDetailsBinding extends Bindings {
  final String tagText;
  ZhenxieSentencePairDetailsBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<ZhenxieSentencePairDetailsController>(
      () => ZhenxieSentencePairDetailsController(tagText: tagText),
      tag: tagText,
    );
  }
}
