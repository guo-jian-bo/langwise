import 'package:get/get.dart';

import '../controllers/zhenxie_enter_sentence_controller.dart';

class ZhenxieEnterSentenceBinding extends Bindings {
  final String tagText;
  ZhenxieEnterSentenceBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<ZhenxieEnterSentenceController>(
      () => ZhenxieEnterSentenceController(tagText: tagText),
      tag: tagText,
    );
  }
}
