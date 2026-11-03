import 'package:get/get.dart';

import '../controllers/zhenxie_sentence_pair_fork_details_controller.dart';

class ZhenxieSentencePairForkDetailsBinding extends Bindings {
  final String tagText;
  ZhenxieSentencePairForkDetailsBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<ZhenxieSentencePairForkDetailsController>(
      () => ZhenxieSentencePairForkDetailsController(tagText: tagText),
      tag: tagText,
      fenix: true,
    );
  }
}
