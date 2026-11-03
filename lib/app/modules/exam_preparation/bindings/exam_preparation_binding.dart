import 'package:get/get.dart';

import '../controllers/exam_preparation_controller.dart';

class ExamPreparationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExamPreparationController>(
      () => ExamPreparationController(),
    );
  }
}
