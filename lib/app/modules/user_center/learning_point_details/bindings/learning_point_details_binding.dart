import 'package:get/get.dart';

import '../controllers/learning_point_details_controller.dart';

class LearningPointDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LearningPointDetailsController>(
      () => LearningPointDetailsController(),
    );
  }
}
