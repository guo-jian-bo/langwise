import 'package:get/get.dart';

import '../controllers/learning_point_details_controller.dart';

class LearningPointDetailsBinding extends Bindings {
  final String tagText;
  LearningPointDetailsBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<LearningPointDetailsController>(
      () => LearningPointDetailsController(tagText: tagText),
      tag: tagText,
      fenix: true,
    );
  }
}
