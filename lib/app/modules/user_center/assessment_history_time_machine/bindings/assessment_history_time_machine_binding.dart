import 'package:get/get.dart';

import '../controllers/assessment_history_time_machine_controller.dart';

class AssessmentHistoryTimeMachineBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AssessmentHistoryTimeMachineController>(() => AssessmentHistoryTimeMachineController());
  }
}
