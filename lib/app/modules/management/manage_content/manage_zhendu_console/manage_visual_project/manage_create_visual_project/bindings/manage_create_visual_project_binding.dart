import 'package:get/get.dart';

import '../controllers/manage_create_visual_project_controller.dart';

class ManageCreateVisualProjectBinding extends Bindings {
  final String tag;
  ManageCreateVisualProjectBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageCreateVisualProjectController>(
      () => ManageCreateVisualProjectController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
