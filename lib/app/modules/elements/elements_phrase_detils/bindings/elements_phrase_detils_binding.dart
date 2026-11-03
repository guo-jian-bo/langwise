import 'package:get/get.dart';

import '../controllers/elements_phrase_detils_controller.dart';

class ElementsPhraseDetilsBinding extends Bindings {
  final String tagText;

  ElementsPhraseDetilsBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<ElementsPhraseDetilsController>(
      () => ElementsPhraseDetilsController(),
      tag: tagText,
      fenix: true,
    );
  }
}
