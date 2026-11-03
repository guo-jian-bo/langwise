import 'package:get/get.dart';

import '../controllers/recharge_naibi_controller.dart';

class RechargeNaibiBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RechargeNaibiController>(
      () => RechargeNaibiController(),
    );
  }
}
