import 'package:get/get.dart';

import '../controllers/zhendu_look_controller.dart';
import '../controllers/zhendu_look_player_controller.dart';

class ZhenduLookBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ZhenduLookController>(
      () => ZhenduLookController(),
    );
    Get.lazyPut<ZhenduLookPlayerController>(
      () => ZhenduLookPlayerController(),
    );


  }
}
