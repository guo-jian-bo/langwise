import 'package:get/get.dart';

import '../controllers/plan_exercise_setting_controller.dart';

class PlanExerciseSettingBinding extends Bindings {
  final String tagText;
  PlanExerciseSettingBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<PlanExerciseSettingController>(
      () => PlanExerciseSettingController(tagText: tagText),
      tag: tagText,
      fenix: true,
    );
  }
}
