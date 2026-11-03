import 'package:get/get.dart';

import '../controllers/zhendu_perform_controller.dart';
import '../controllers/zhendu_perform_player_controller.dart';

class ZhenduPerformBinding extends Bindings {
  final String tagText;
  ZhenduPerformBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<ZhenduPerformController>(
      () => ZhenduPerformController(tagText: tagText),
      tag: tagText,
    );
    Get.lazyPut<ZhenduPerformPlayerController>(
      () => ZhenduPerformPlayerController(tagText: tagText),
      tag: tagText,
    );
  }
}
