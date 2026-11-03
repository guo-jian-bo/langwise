import 'package:get/get.dart';

import '../controllers/zhenxie_composition_writing_controller.dart';

class ZhenxieCompositionWritingBinding extends Bindings {
  final String tagText;

  ZhenxieCompositionWritingBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<ZhenxieCompositionWritingController>(
      () => ZhenxieCompositionWritingController(tagText: tagText),
      tag: tagText,
    );
  }
}
