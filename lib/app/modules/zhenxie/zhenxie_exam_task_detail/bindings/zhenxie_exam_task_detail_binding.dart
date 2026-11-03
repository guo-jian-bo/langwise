import 'package:get/get.dart';

import '../controllers/zhenxie_exam_task_detail_controller.dart';

class ZhenxieExamTaskDetailBinding extends Bindings {
  final String tagText;

  ZhenxieExamTaskDetailBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<ZhenxieExamTaskDetailController>(
      () => ZhenxieExamTaskDetailController(tagText: tagText),
      tag: tagText,
    );
  }
}
