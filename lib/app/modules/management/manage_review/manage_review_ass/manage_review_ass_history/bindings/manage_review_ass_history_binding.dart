import 'package:get/get.dart';

import '../controllers/manage_review_ass_history_controller.dart';

class ManageReviewAssHistoryBinding extends Bindings {
  final String tag;
  ManageReviewAssHistoryBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageReviewAssHistoryController>(
      () => ManageReviewAssHistoryController(tag: tag),
      tag: tag,
    );
  }
}
