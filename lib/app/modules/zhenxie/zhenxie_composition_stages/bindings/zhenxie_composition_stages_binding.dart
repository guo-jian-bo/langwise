import 'package:get/get.dart';

import '../controllers/zhenxie_composition_stages_controller.dart';

class ZhenxieCompositionStagesBinding extends Bindings {
  final String tagText;
  ZhenxieCompositionStagesBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<ZhenxieCompositionStagesController>(
      () => ZhenxieCompositionStagesController(tagText: tagText),
      tag: tagText,
    );
  }
}
