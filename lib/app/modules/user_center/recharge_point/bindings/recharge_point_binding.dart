import 'package:get/get.dart';

import '../controllers/recharge_point_controller.dart';

class RechargePointBinding extends Bindings {
  final String tagText;
  RechargePointBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<RechargePointController>(
      () => RechargePointController(tagText: tagText),
      tag: tagText,
    );
  }
}
