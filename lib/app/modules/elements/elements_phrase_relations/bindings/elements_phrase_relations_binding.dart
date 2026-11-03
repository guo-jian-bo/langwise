import 'package:get/get.dart';

import '../controllers/elements_phrase_relations_controller.dart';

class ElementsPhraseRelationsBinding extends Bindings {
  final String tagText;

  ElementsPhraseRelationsBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<ElementsPhraseRelationsController>(
      () => ElementsPhraseRelationsController(tagText: tagText),
      tag: tagText,
    );
  }
}
