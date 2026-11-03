import 'package:get/get.dart';

import '../controllers/limit_discoun_detail_controller.dart';

class LimitDiscounDetailBinding extends Bindings {
  final String tagText;
  LimitDiscounDetailBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<LimitDiscounDetailController>(
      () => LimitDiscounDetailController(tagText: tagText),
      tag: tagText,
    );
  }
}
