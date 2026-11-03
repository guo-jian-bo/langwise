import 'package:get/get.dart';

import '../controllers/manage_unit_writing_task_list_controller.dart';

class ManageUnitWritingTaskListBinding extends Bindings {
  final String tagText;
  ManageUnitWritingTaskListBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<ManageUnitWritingTaskListController>(
      () => ManageUnitWritingTaskListController(tagText: tagText),
      tag: tagText,
    );
  }
}
