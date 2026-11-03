import 'package:get/get.dart';

import '../controllers/manage_visual_project_controller.dart';

class ManageVisualProjectBinding extends Bindings {
  final String tag;
  ManageVisualProjectBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageVisualProjectController>(
      () => ManageVisualProjectController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
