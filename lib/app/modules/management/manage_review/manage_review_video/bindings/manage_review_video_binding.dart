import 'package:get/get.dart';

import '../controllers/manage_review_video_controller.dart';

class ManageReviewVideoBinding extends Bindings {
  final String tag;
  ManageReviewVideoBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageReviewVideoController>(
      () => ManageReviewVideoController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
