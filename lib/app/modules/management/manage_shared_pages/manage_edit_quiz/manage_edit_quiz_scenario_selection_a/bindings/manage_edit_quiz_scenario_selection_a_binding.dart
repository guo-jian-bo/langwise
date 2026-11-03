import 'package:get/get.dart';

import '../controllers/manage_edit_quiz_scenario_selection_a_controller.dart';

class ManageEditQuizScenarioSelectionABinding extends Bindings {
  final String tag;
  ManageEditQuizScenarioSelectionABinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageEditQuizScenarioSelectionAController>(
      () => ManageEditQuizScenarioSelectionAController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
