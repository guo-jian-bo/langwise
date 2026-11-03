import 'package:get/get.dart';

import '../controllers/zhenxie_exam_controller.dart';

class ZhenxieExamBinding extends Bindings {
  final String tagText;
  ZhenxieExamBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<ZhenxieExamController>(
      () => ZhenxieExamController(tagText: tagText),
      tag: tagText,
    );
  }
}
