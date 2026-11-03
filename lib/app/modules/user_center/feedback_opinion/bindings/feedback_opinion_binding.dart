import 'package:get/get.dart';

import '../controllers/feedback_opinion_controller.dart';

class FeedbackOpinionBinding extends Bindings {
  final String tagText;
  FeedbackOpinionBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<FeedbackOpinionController>(
      () => FeedbackOpinionController(tagText: tagText),
      tag: tagText,
    );
  }
}
