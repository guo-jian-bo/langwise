import 'package:get/get.dart';

import '../controllers/zhendu_player_controller.dart';

class ZhenduPlayerBinding extends Bindings {
  final int scriptId;
  final String initialMode;

  ZhenduPlayerBinding({
    required this.scriptId,
    required this.initialMode,
  });

  @override
  void dependencies() {
    Get.put<ZhenduPlayerController>(
      ZhenduPlayerController(
        scriptId: scriptId,
        initialMode: initialMode,
      ),
    );
  }
}

