import 'package:get/get.dart';

import '../../controllers/mission_control_center_controller.dart';

class MissionControlCenterDailyTaskController extends GetxController {
  final String tagText;
  MissionControlCenterDailyTaskController({required this.tagText});

  String get shellTag => tagText;

  MissionControlCenterController get shellController =>
      Get.find<MissionControlCenterController>(tag: shellTag);
}
