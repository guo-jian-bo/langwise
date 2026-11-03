import 'package:get/get.dart';

import '../controllers/zhenxie_task_details_controller.dart';

class ZhenxieTaskDetailsBinding extends Bindings {
  final String tagText;
  ZhenxieTaskDetailsBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<ZhenxieTaskDetailsController>(
      () => ZhenxieTaskDetailsController(tagText: tagText),
      tag: tagText,
    );
  }
}
