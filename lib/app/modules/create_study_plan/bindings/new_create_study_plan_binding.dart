import 'package:get/get.dart';

import '../controllers/new_create_study_plan_controller.dart';

class NewCreateStudyPlanBinding extends Bindings {
  final String tagText;
  NewCreateStudyPlanBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<NewCreateStudyPlanController>(
      () => NewCreateStudyPlanController(tagText: tagText),
      tag: tagText,
      fenix: true,
    );
  }
}
