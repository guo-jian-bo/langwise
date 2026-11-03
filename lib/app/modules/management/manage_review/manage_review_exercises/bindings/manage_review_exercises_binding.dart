import 'package:get/get.dart';

import '../../../controllers/manage_admin_auth_controller.dart';
import '../controllers/manage_review_exercises_controller.dart';

class ManageReviewExercisesBinding extends Bindings {
  final String tag;
  ManageReviewExercisesBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageReviewExercisesController>(
      () => ManageReviewExercisesController(tag: tag),
      tag: tag,
      fenix: true,
    );
    Get.lazyPut<ManageAuthController>(
      () => ManageAuthController(),
    );
  }
}
