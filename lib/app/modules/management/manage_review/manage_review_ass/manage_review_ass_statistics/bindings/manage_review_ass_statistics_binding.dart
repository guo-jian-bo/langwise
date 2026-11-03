import 'package:get/get.dart';

import '../controllers/manage_review_ass_statistics_controller.dart';

class ManageReviewAssStatisticsBinding extends Bindings {
  final String tag;
  ManageReviewAssStatisticsBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageReviewAssStatisticsController>(
      () => ManageReviewAssStatisticsController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
