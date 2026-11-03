import 'package:get/get.dart';

import '../controllers/manage_review_video_history_controller.dart';

class ManageReviewVideoHistoryBinding extends Bindings {
  final String tag;
  ManageReviewVideoHistoryBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageReviewVideoHistoryController>(
      () => ManageReviewVideoHistoryController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
