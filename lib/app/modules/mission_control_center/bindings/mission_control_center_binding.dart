import 'package:get/get.dart';

import '../controllers/mission_control_center_controller.dart';

class MissionControlCenterBinding extends Bindings {
  final String tagText;
  MissionControlCenterBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<MissionControlCenterController>(
      () => MissionControlCenterController(tagText: tagText),
      tag: tagText,
      fenix: true,
    );
  }
}
