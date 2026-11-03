import 'package:get/get.dart';

import '../controllers/manage_review_ass_detils_controller.dart';

class ManageReviewAssDetilsBinding extends Bindings {
  final String tag;
  ManageReviewAssDetilsBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageReviewAssDetilsController>(
      () => ManageReviewAssDetilsController(tag: tag),
      tag: tag,
    );
  }
}
