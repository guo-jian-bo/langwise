import 'package:get/get.dart';

import '../controllers/zhenxie_lexis_controller.dart';

class ZhenxieLexisBinding extends Bindings {
  final String tagText;
  ZhenxieLexisBinding({required this.tagText});

  @override
  void dependencies() {
    Get.put<ZhenxieLexisController>(
      ZhenxieLexisController(tagText: tagText),
      tag: tagText,
    );
  }
}
