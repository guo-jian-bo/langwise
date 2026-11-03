import 'package:get/get.dart';

import '../controllers/assessment_history_time_machine_controller.dart';

class AssessmentHistoryTimeMachineBinding extends Bindings {
  final String tagText;
  AssessmentHistoryTimeMachineBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<AssessmentHistoryTimeMachineController>(
      () => AssessmentHistoryTimeMachineController(tagText: tagText),
      tag: tagText,
    );
  }
}
