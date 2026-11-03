import 'package:get/get.dart';

import '../controllers/elements_lexical_detail_controller.dart';

class ElementsLexicalDetailBinding extends Bindings {
  final String tagText;

  ElementsLexicalDetailBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<ElementsLexicalDetailController>(
      () => ElementsLexicalDetailController(tagText: tagText),
      tag: tagText,
    );
  }
}
