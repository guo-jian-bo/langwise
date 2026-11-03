import 'package:get/get.dart';

import '../controllers/manage_edit_quiz_scenario_selection_b_controller.dart';

class ManageEditQuizScenarioSelectionBBinding extends Bindings {
  final String tag;
  ManageEditQuizScenarioSelectionBBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageEditQuizScenarioSelectionBController>(
      () => ManageEditQuizScenarioSelectionBController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
