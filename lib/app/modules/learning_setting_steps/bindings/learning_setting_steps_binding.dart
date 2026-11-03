import 'package:get/get.dart';

import '../controllers/learning_setting_steps_controller.dart';

class LearningSettingStepsBinding extends Bindings {
  final String tagText;
  LearningSettingStepsBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<LearningSettingStepsController>(
      () => LearningSettingStepsController(tagText: tagText),
      tag: tagText,
    );
  }
}
