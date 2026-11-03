import 'package:get/get.dart';

import '../controllers/zhenxie_controller.dart';

class ZhenxieBinding extends Bindings {
  final String tagText;
  ZhenxieBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<ZhenxieController>(
      () => ZhenxieController(tagText: tagText),
      tag: tagText,
    );
  }
}
