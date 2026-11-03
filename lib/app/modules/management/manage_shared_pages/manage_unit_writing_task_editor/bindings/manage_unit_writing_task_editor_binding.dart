import 'package:get/get.dart';

import '../controllers/manage_unit_writing_task_editor_controller.dart';

class ManageUnitWritingTaskEditorBinding extends Bindings {
  final String tagText;
  ManageUnitWritingTaskEditorBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<ManageUnitWritingTaskEditorController>(
      () => ManageUnitWritingTaskEditorController(tagText: tagText),
      tag: tagText,
    );
  }
}
