import 'package:get/get.dart';

import '../controllers/dream_building_team_controller.dart';

class DreamBuildingTeamBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DreamBuildingTeamController>(
      () => DreamBuildingTeamController(),
    );
  }
}
