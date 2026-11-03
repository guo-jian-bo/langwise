import 'package:get/get.dart';

import '../controllers/zhenxie_composition_instances_controller.dart';

class ZhenxieCompositionInstancesBinding extends Bindings {
  final String tagText;

  ZhenxieCompositionInstancesBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<ZhenxieCompositionInstancesController>(
      () => ZhenxieCompositionInstancesController(tagText: tagText),
      tag: tagText,
    );
  }
}
