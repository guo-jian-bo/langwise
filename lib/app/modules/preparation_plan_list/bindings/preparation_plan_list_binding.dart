import 'package:get/get.dart';

import '../controllers/preparation_plan_list_controller.dart';

class PreparationPlanListBinding extends Bindings {
  final String tagText;
  PreparationPlanListBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<PreparationPlanListController>(
      () => PreparationPlanListController(tagText: tagText),
      tag: tagText,
    );
  }
}
