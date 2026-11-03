import 'package:get/get.dart';

import '../controllers/feedback_opinion_controller.dart';

class FeedbackOpinionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FeedbackOpinionController>(
      () => FeedbackOpinionController(),
    );
  }
}
