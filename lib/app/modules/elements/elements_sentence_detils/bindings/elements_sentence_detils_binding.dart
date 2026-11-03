import 'package:get/get.dart';

import '../controllers/elements_sentence_detils_controller.dart';

class ElementsSentenceDetilsBinding extends Bindings {
  final String tagText;
  ElementsSentenceDetilsBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<ElementsSentenceDetilsController>(
      () => ElementsSentenceDetilsController(tagText: tagText),
      tag: tagText,
      fenix: true,
    );
  }
}
