import 'package:get/get.dart';

import '../controllers/user_evaluation_controller.dart';

class UserEvaluationBinding extends Bindings {
  final String tagText;
  UserEvaluationBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<UserEvaluationController>(
      () => UserEvaluationController(tagText: tagText),
      tag: tagText,
      fenix: true,
    );
  }
}
