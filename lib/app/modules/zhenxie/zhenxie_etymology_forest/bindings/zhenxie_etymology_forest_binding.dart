import 'package:get/get.dart';

import '../controllers/zhenxie_etymology_forest_controller.dart';

class ZhenxieEtymologyForestBinding extends Bindings {
  final String tagText;
  ZhenxieEtymologyForestBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<ZhenxieEtymologyForestController>(
      () => ZhenxieEtymologyForestController(tagText: tagText),
      tag: tagText,
    );
  }
}
