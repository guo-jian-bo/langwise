import 'package:get/get.dart';

import '../controllers/manage_unit_writing_stage_pick_controller.dart';

class ManageUnitWritingStagePickBinding extends Bindings {
  final String tagText;
  ManageUnitWritingStagePickBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut(
      () => ManageUnitWritingStagePickController(tagText: tagText),
      tag: tagText,
    );
  }
}
