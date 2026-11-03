import 'package:get/get.dart';

import '../controllers/zhenxie_paragraph_example_controller.dart';

class ZhenxieParagraphExampleBinding extends Bindings {
  final String tagText;
  ZhenxieParagraphExampleBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<ZhenxieParagraphExampleController>(
      () => ZhenxieParagraphExampleController(tagText: tagText),
      tag: tagText,
    );
  }
}
