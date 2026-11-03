import 'package:get/get.dart';

import '../controllers/zhenxie_composition_stage_edit_controller.dart';

class ZhenxieCompositionStageEditBinding extends Bindings {
  final String tagText;

  ZhenxieCompositionStageEditBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<ZhenxieCompositionStageEditController>(
      () => ZhenxieCompositionStageEditController(tagText: tagText),
      tag: tagText,
    );
  }
}
