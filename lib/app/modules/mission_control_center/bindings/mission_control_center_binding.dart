import 'package:get/get.dart';

import '../controllers/mission_control_center_controller.dart';

class MissionControlCenterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MissionControlCenterController>(
      () => MissionControlCenterController(),
    );
  }
}
