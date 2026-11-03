import 'package:get/get.dart';

import '../controllers/manage_create_exercises_controller.dart';

class ManageCreateExercisesBinding extends Bindings {
  final String tag;
  ManageCreateExercisesBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageCreateExercisesController>(
      () => ManageCreateExercisesController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
