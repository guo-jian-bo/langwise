import 'package:get/get.dart';

import '../controllers/plan_valid_assessment_controller.dart';

class PlanValidAssessmentBinding extends Bindings {
  final String tagText;
  PlanValidAssessmentBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<PlanValidAssessmentController>(
      () => PlanValidAssessmentController(tagText: tagText),
      tag: tagText,
    );
  }
}
