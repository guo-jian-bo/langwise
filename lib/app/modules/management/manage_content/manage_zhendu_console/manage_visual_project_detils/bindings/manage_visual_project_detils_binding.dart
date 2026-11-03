import 'package:get/get.dart';

import '../controllers/manage_visual_project_detils_controller.dart';

class ManageVisualProjectDetilsBinding extends Bindings {
  final String tag;
  ManageVisualProjectDetilsBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageVisualProjectDetilsController>(
      () => ManageVisualProjectDetilsController(tag: tag),
      tag: tag,
    );
  }
}
