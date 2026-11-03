import 'package:get/get.dart';

import '../controllers/zhenxie_phrase_pair_details_controller.dart';

class ZhenxiePhrasePairDetailsBinding extends Bindings {
  final String tagText;
  ZhenxiePhrasePairDetailsBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<ZhenxiePhrasePairDetailsController>(
      () => ZhenxiePhrasePairDetailsController(tagText: tagText),
      tag: tagText,
      fenix: true,
    );
  }
}
