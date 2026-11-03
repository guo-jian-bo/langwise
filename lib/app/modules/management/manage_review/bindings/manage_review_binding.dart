import 'package:get/get.dart';

import '../controllers/manage_review_controller.dart';

class ManageReviewBinding extends Bindings {
  final String tag;
  ManageReviewBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageReviewController>(
      () => ManageReviewController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
