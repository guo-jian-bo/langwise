import 'package:get/get.dart';

import '../controllers/manage_exercise_controller.dart';

class ManageExerciseBinding implements Bindings {
  final String tag;
  ManageExerciseBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageExerciseController>(
      () => ManageExerciseController(tag: tag),
      tag: tag,
    );
  }
}
