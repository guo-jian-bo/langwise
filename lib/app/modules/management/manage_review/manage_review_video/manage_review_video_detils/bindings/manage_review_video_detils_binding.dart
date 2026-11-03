import 'package:get/get.dart';

import '../controllers/manage_review_video_detils_controller.dart';

class ManageReviewVideoDetilsBinding extends Bindings {
  final String tag;
  ManageReviewVideoDetilsBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageReviewVideoDetilsController>(
      () => ManageReviewVideoDetilsController(tag: tag),
      tag: tag,
    );
  }
}
