import 'package:get/get.dart';

import '../controllers/zhendu_show_detail_controller.dart';

class ZhenduShowDetailBinding extends Bindings {
  final String tagText;
  ZhenduShowDetailBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<ZhenduShowDetailController>(
      () => ZhenduShowDetailController(tagText: tagText),
      tag: tagText,
    );
  }
}
