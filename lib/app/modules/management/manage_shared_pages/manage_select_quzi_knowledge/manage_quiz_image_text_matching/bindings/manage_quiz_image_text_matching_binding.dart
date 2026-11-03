import 'package:get/get.dart';

import '../controllers/manage_quiz_image_text_matching_controller.dart';

class ManageQuizImageTextMatchingBinding extends Bindings {
  final String tag;
  ManageQuizImageTextMatchingBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageQuizImageTextMatchingController>(
      () => ManageQuizImageTextMatchingController(tag: tag),
      tag: tag,
    );
  }
}
