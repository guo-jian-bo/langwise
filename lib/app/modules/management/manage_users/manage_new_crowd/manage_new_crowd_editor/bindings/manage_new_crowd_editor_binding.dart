import 'package:get/get.dart';

import '../controllers/manage_new_crowd_editor_controller.dart';

class ManageNewCrowdEditorBinding extends Bindings {
  final String tag;
  ManageNewCrowdEditorBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageNewCrowdEditorController>(
      () => ManageNewCrowdEditorController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
