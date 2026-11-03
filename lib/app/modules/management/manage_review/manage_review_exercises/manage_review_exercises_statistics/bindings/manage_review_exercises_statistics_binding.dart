import 'package:get/get.dart';

import '../controllers/manage_review_exercises_statistics_controller.dart';

class ManageReviewExercisesStatisticsBinding extends Bindings {
  final String tag;
  ManageReviewExercisesStatisticsBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageReviewExercisesStatisticsController>(
      () => ManageReviewExercisesStatisticsController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
