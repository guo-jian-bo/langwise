import 'package:get/get.dart';

import '../controllers/user_evaluation_level_controller.dart';

class UserEvaluationLevelBinding extends Bindings {
  final String tagText;
  UserEvaluationLevelBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<UserEvaluationLevelController>(
      () => UserEvaluationLevelController(tagText: tagText),
      tag: tagText,
      fenix: true,
    );
  }
}
