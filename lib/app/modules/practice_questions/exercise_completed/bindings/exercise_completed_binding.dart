import 'package:get/get.dart';

import '../controllers/exercise_completed_controller.dart';

class ExerciseCompletedBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExerciseCompletedController>(
      () => ExerciseCompletedController(),
    );
  }
}
