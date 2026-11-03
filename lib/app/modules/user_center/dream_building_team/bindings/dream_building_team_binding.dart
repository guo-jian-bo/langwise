import 'package:get/get.dart';

import '../controllers/dream_building_team_controller.dart';

class DreamBuildingTeamBinding extends Bindings {
  final String tagText;
  DreamBuildingTeamBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<DreamBuildingTeamController>(
      () => DreamBuildingTeamController(tagText: tagText),
      tag: tagText,
      fenix: true,
    );
  }
}
