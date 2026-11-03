import 'package:get/get.dart';

import '../controllers/plan_details_controller.dart';

class PlanDetailsBinding extends Bindings {
  final String tagText;
  PlanDetailsBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<PlanDetailsController>(
      () => PlanDetailsController(tagText: tagText),
      tag: tagText,
    );
  }
}
