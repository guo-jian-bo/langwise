import 'package:get/get.dart';

import '../controllers/elements_word_analysis_cards_controller.dart';

class ElementsWordAnalysisCardsBinding extends Bindings {
  final String tagText;

  ElementsWordAnalysisCardsBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<ElementsWordAnalysisCardsController>(
      () => ElementsWordAnalysisCardsController(tagText: tagText),
      tag: tagText,
    );
  }
}
