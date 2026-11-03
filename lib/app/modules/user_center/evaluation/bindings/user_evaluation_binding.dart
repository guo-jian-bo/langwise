import 'package:get/get.dart';

import '../controllers/user_evaluation_controller.dart';

class UserEvaluationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserEvaluationController>(() => UserEvaluationController());
  }
}
