import 'package:get/get.dart';

import '../controllers/manage_create_quiz_classify_challenge_controller.dart';

class ManageCreateQuizClassifyChallengeBinding extends Bindings {
  final String tag;
  ManageCreateQuizClassifyChallengeBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageCreateQuizClassifyChallengeController>(
      () => ManageCreateQuizClassifyChallengeController(tag: tag),
      tag: tag,
    );
  }
}
