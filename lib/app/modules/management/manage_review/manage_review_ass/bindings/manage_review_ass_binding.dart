import 'package:get/get.dart';

import '../controllers/manage_review_ass_controller.dart';

class ManageReviewAssBinding extends Bindings {
  final String tag;
  ManageReviewAssBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageReviewAssController>(
      () => ManageReviewAssController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
