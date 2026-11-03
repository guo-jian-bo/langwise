import 'package:get/get.dart';

import '../controllers/exam_preparation_controller.dart';

class ExamPreparationBinding extends Bindings {
  final String tagText;
  ExamPreparationBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<ExamPreparationController>(
      () => ExamPreparationController(tagText: tagText),
      tag: tagText,
    );
  }
}
