import 'package:get/get.dart';

import '../controllers/manage_review_exercises_history_controller.dart';

class ManageReviewExercisesHistoryBinding extends Bindings {
  final String tag;
  ManageReviewExercisesHistoryBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageReviewExercisesHistoryController>(
      () => ManageReviewExercisesHistoryController(tag: tag),
      tag: tag,
    );
  }
}
