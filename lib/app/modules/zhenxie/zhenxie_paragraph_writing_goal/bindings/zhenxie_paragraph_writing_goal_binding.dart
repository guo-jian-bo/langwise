import 'package:get/get.dart';

import '../controllers/zhenxie_paragraph_writing_goal_controller.dart';

class ZhenxieParagraphWritingGoalBinding extends Bindings {
  final String tagText;
  ZhenxieParagraphWritingGoalBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<ZhenxieParagraphWritingGoalController>(
      () => ZhenxieParagraphWritingGoalController(tagText: tagText),
      tag: tagText,
    );
  }
}
