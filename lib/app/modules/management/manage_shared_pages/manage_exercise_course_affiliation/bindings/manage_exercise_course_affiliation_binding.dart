import 'package:get/get.dart';

import '../controllers/manage_exercise_course_affiliation_controller.dart';

class ManageExerciseCourseAffiliationBinding extends Bindings {
  final String tag;
  ManageExerciseCourseAffiliationBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageExerciseCourseAffiliationController>(
      () => ManageExerciseCourseAffiliationController(tag: tag),
      tag: tag,
    );
  }
}
