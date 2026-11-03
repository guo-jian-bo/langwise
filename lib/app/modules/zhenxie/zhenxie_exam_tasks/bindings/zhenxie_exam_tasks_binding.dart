import 'package:get/get.dart';

import '../controllers/zhenxie_exam_tasks_controller.dart';

class ZhenxieExamTaskListBinding extends Bindings {
  final String tagText;

  ZhenxieExamTaskListBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<ZhenxieExamTaskListController>(
      () => ZhenxieExamTaskListController(tagText: tagText),
      tag: tagText,
    );
  }
}
