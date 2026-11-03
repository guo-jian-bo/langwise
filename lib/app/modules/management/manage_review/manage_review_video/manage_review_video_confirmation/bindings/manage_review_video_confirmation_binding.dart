import 'package:get/get.dart';

import '../controllers/manage_review_video_confirmation_controller.dart';

class ManageReviewVideoConfirmationBinding extends Bindings {
  final String tag;
  ManageReviewVideoConfirmationBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageReviewVideoConfirmationController>(
      () => ManageReviewVideoConfirmationController(tag: tag),
      tag: tag,
    );
  }
}
