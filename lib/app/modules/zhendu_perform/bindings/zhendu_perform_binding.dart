import 'package:get/get.dart';

import '../controllers/zhendu_perform_controller.dart';
import '../controllers/zhendu_perform_player_controller.dart';

class ZhenduPerformBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ZhenduPerformController>(
      () => ZhenduPerformController(),
    );
    Get.lazyPut<ZhenduPerformPlayerController>(
      () => ZhenduPerformPlayerController(),
    );
  }
}
