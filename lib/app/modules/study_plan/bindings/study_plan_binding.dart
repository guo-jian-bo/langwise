import 'package:get/get.dart';

import '../controllers/study_plan_controller.dart';

class StudyPlanBinding extends Bindings {
  final String tagText;
  StudyPlanBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<StudyPlanController>(
      () => StudyPlanController(tagText: tagText),
      tag: tagText,
    );
  }
}
