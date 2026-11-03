import 'package:get/get.dart';

import '../controllers/manage_edit_quiz_classify_challenge_controller.dart';

class ManageEditQuizClassifyChallengeBinding extends Bindings {
  final String tag;
  ManageEditQuizClassifyChallengeBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageEditQuizClassifyChallengeController>(
      () => ManageEditQuizClassifyChallengeController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
