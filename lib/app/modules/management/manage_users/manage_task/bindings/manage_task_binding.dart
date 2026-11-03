import 'package:get/get.dart';

import '../controllers/manage_task_controller.dart';

class ManageTaskBinding extends Bindings {
  final String tag;
  ManageTaskBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageTaskController>(
      () => ManageTaskController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
