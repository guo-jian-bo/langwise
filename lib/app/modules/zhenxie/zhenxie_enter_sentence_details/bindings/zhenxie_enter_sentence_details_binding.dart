import 'package:get/get.dart';

import '../controllers/zhenxie_enter_sentence_details_controller.dart';

class ZhenxieEnterSentenceDetailsBinding extends Bindings {
  final String tagText;
  ZhenxieEnterSentenceDetailsBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<ZhenxieEnterSentenceDetailsController>(
      () => ZhenxieEnterSentenceDetailsController(tagText: tagText),
      tag: tagText,
      fenix: true,
    );
  }
}
