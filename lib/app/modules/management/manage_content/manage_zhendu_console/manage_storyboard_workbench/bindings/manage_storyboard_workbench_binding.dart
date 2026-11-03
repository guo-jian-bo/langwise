import 'package:get/get.dart';

import '../controllers/manage_storyboard_workbench_controller.dart';

class ManageStoryboardWorkbenchBinding extends Bindings {
  final String tag;
  ManageStoryboardWorkbenchBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageStoryboardWorkbenchController>(
      () => ManageStoryboardWorkbenchController(tag: tag),
      tag: tag,
    );
  }
}
