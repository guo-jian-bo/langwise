import 'package:get/get.dart';

import '../controllers/zhendu_practice_controller.dart';

class ZhenduPracticeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ZhenduPracticeController>(
      () => ZhenduPracticeController(),
    );
  }
}
