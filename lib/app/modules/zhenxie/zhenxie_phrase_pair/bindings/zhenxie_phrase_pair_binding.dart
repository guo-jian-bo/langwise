import 'package:get/get.dart';

import '../controllers/zhenxie_phrase_pair_controller.dart';

class ZhenxiePhrasePairBinding extends Bindings {
  final String tagText;
  ZhenxiePhrasePairBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<ZhenxiePhrasePairController>(
      () => ZhenxiePhrasePairController(tagText: tagText),
      tag: tagText,
    );
  }
}
