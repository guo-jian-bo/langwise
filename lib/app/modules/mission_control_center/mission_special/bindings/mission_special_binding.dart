import 'package:get/get.dart';

import '../controllers/mission_special_controller.dart';

class MissionSpecialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MissionSpecialController>(
      () => MissionSpecialController(),
    );
  }
}
