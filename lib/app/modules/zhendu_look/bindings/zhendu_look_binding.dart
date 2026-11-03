import 'package:get/get.dart';

import '../controllers/zhendu_look_controller.dart';
import '../controllers/zhendu_look_player_controller.dart';

class ZhenduLookBinding extends Bindings {
  final String tagText;
  ZhenduLookBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<ZhenduLookController>(
      () => ZhenduLookController(tagText: tagText),
      tag: tagText,
      fenix: true,
    );
    Get.lazyPut<ZhenduLookPlayerController>(
      () => ZhenduLookPlayerController(tagText: tagText),
      tag: tagText,
      fenix: true,
    );
  }
}
