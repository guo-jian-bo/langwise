import 'package:get/get.dart';

import '../controllers/recharge_point_controller.dart';

class RechargePointBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RechargePointController>(
      () => RechargePointController(),
    );
  }
}
