import 'package:get/get.dart';

import '../controllers/recharge_naibi_controller.dart';

class RechargeNaibiBinding extends Bindings {
  final String tagText;
  RechargeNaibiBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<RechargeNaibiController>(
      () => RechargeNaibiController(tagText: tagText),
      tag: tagText,
      fenix: true,
    );
  }
}
