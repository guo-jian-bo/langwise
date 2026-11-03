import 'package:get/get.dart';

import '../controllers/elements_word_detils_controller.dart';

class ElementsWordDetilsBinding extends Bindings {
  final String tagText;
  ElementsWordDetilsBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<ElementsWordDetilsController>(
      () => ElementsWordDetilsController(),
      tag: tagText, // 用单词ID作为tag
      fenix: true,
    );
  }
}
