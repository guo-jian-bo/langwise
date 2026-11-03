import 'package:get/get.dart';

import '../controllers/mission_content_select_controller.dart';

class MissionContentSelectBinding extends Bindings {
  final String tagText;
  MissionContentSelectBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<MissionContentSelectController>(
      () => MissionContentSelectController(tagText: tagText),
      tag: tagText,
    );
  }
}
