import 'package:get/get.dart';

import '../controllers/mission_special_controller.dart';

class MissionSpecialBinding extends Bindings {
  final String tagText;
  MissionSpecialBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<MissionSpecialController>(
      () => MissionSpecialController(tagText: tagText),
      tag: tagText,
      fenix: true,
    );
  }
}
