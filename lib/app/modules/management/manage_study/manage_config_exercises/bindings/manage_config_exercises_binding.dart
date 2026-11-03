import 'package:get/get.dart';

import '../controllers/manage_config_exercises_controller.dart';

class ManageConfigExercisesBinding extends Bindings {
  final String tag;
  ManageConfigExercisesBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageConfigExercisesController>(
      () => ManageConfigExercisesController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
