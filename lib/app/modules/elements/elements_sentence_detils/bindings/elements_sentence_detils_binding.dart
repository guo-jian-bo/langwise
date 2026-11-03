import 'package:get/get.dart';

import '../controllers/elements_sentence_detils_v2_controller.dart';

class ElementsSentenceDetilsBinding extends Bindings {
  final String tagText;
  ElementsSentenceDetilsBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<ElementsSentenceDetilsV2Controller>(
      () => ElementsSentenceDetilsV2Controller(tagText: tagText),
      tag: tagText,
      fenix: true,
    );
  }
}
