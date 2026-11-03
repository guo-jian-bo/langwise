import 'package:get/get.dart';

import '../controllers/manage_review_ass_translate_controller.dart';

class ManageReviewAssTranslateBinding extends Bindings {
  final String tag;
  ManageReviewAssTranslateBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageReviewAssTranslateController>(
      () => ManageReviewAssTranslateController(tag: tag),
      tag: tag,
    );
  }
}
