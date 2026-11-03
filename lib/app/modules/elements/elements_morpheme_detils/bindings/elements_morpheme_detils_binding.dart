import 'package:get/get.dart';

import '../controllers/elements_morpheme_detils_controller.dart';

class ElementsMorphemeDetilsBinding extends Bindings {
  final String tagText;

  ElementsMorphemeDetilsBinding({required this.tagText});

  @override
  void dependencies() async{
    Get.lazyPut<ElementsMorphemeDetilsController>(
      () => ElementsMorphemeDetilsController(),
      tag: tagText,
      fenix: true,
    );
  }
}
