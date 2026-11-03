import 'package:get/get.dart';

import '../controllers/elements_phrase_sentence_cards_controller.dart';

class ElementsPhraseSentenceCardsBinding extends Bindings {
  final String tagText;

  ElementsPhraseSentenceCardsBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<ElementsPhraseSentenceCardsController>(
      () => ElementsPhraseSentenceCardsController(tagText: tagText),
      tag: tagText,
    );
  }
}
