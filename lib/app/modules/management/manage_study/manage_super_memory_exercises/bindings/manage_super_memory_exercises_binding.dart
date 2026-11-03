import 'package:get/get.dart';

import '../controllers/manage_super_memory_exercises_controller.dart';

class ManageSuperMemoryExercisesBinding implements Bindings {
  final String tag;
  ManageSuperMemoryExercisesBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageSuperMemoryExercisesController>(
      () => ManageSuperMemoryExercisesController(tag: tag),
      tag: tag,
    );
  }
}
