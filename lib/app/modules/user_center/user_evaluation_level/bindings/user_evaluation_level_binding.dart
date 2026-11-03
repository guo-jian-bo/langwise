import 'package:get/get.dart';

import '../controllers/user_evaluation_level_controller.dart';

class UserEvaluationLevelBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserEvaluationLevelController>(
      () => UserEvaluationLevelController(),
    );
  }
}
