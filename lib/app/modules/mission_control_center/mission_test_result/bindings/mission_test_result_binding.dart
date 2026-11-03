import 'package:get/get.dart';

import '../controllers/mission_test_result_controller.dart';

class MissionTestResultBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MissionTestResultController>(
      () => MissionTestResultController(),
    );
  }
}
