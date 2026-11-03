import 'package:get/get.dart';

import '../controllers/manage_quiz_classify_challenge_controller.dart';

class ManageQuizClassifyChallengeBinding extends Bindings {
  final String tag;
  ManageQuizClassifyChallengeBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageQuizClassifyChallengeController>(
      () => ManageQuizClassifyChallengeController(tag: tag),
      tag: tag,
    );
  }
}
