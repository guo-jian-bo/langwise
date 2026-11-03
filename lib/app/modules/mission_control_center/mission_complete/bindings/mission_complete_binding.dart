import 'package:get/get.dart';

import '../controllers/mission_complete_controller.dart';

class MissionCompleteBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MissionCompleteController>(
      () => MissionCompleteController(),
    );
  }
}
