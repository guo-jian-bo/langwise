import 'package:get/get.dart';

import '../controllers/zhendu_practice_controller.dart';

class ZhenduPracticeBinding extends Bindings {
  final String tagText;
  ZhenduPracticeBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<ZhenduPracticeController>(
      () => ZhenduPracticeController(tagText: tagText),
      tag: tagText,
      fenix: true,
    );
  }
}
