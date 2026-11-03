import 'package:get/get.dart';

import '../controllers/manage_zhendu_generate_task_controller.dart';

class ManageZhenduGenerateTaskBinding extends Bindings {
  final String tag;
  ManageZhenduGenerateTaskBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageZhenduGenerateTaskController>(
      () => ManageZhenduGenerateTaskController(tag: tag),
      tag: tag,
    );
  }
}
