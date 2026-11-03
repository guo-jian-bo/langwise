import 'package:get/get.dart';

import 'home/controllers/zhendu_home_controller.dart';

class ZhenduBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ZhenduHomeController>(() => ZhenduHomeController(), fenix: true);
  }
}

