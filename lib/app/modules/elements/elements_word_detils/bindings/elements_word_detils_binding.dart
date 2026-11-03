import 'package:get/get.dart';

import '../controllers/elements_word_detils_controller.dart';

class ElementsWordDetilsBinding extends Bindings {
  final String tagText;
  ElementsWordDetilsBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<ElementsWordDetilsController>(
      () => ElementsWordDetilsController(tagText: tagText),
      tag: tagText,
      fenix: true,
    );
  }
}
