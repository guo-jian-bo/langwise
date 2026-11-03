import 'package:get/get.dart';

import '../controllers/manage_unit_writing_task_exemplar_controller.dart';

class ManageUnitWritingTaskExemplarBinding extends Bindings {
  final String tagText;
  ManageUnitWritingTaskExemplarBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut(
      () => ManageUnitWritingTaskExemplarController(tagText: tagText),
      tag: tagText,
    );
  }
}
