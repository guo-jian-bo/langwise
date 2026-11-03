import 'package:get/get.dart';

import '../controllers/mission_test_result_controller.dart';

class MissionTestResultBinding extends Bindings {
  final String tagText;
  MissionTestResultBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<MissionTestResultController>(
      () => MissionTestResultController(tagText: tagText),
      tag: tagText,
    );
  }
}
