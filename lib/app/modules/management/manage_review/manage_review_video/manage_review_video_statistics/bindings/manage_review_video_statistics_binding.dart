import 'package:get/get.dart';

import '../controllers/manage_review_video_statistics_controller.dart';

class ManageReviewVideoStatisticsBinding extends Bindings {
  final String tag;
  ManageReviewVideoStatisticsBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageReviewVideoStatisticsController>(
      () => ManageReviewVideoStatisticsController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
