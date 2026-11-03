import 'package:get/get.dart';

import '../controllers/my_coupons_controller.dart';

class MyCouponsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyCouponsController>(
      () => MyCouponsController(),
    );
  }
}
