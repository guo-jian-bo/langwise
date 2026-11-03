import 'package:get/get.dart';

import '../controllers/manage_select_exercises_controller.dart';

class ManageSelectExercisesBinding extends Bindings {
  final String tag;
  ManageSelectExercisesBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageSelectExercisesController>(
      () => ManageSelectExercisesController(tag: tag),
      tag: tag,
    );
  }
}
