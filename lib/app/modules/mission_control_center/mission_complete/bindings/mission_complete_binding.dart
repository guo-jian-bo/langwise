import 'package:get/get.dart';

import '../controllers/mission_complete_controller.dart';

class MissionCompleteBinding extends Bindings {
  final String tagText;
  MissionCompleteBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<MissionCompleteController>(
      () => MissionCompleteController(tagText: tagText),
      tag: tagText,
      fenix: true,
    );
  }
}
