import 'package:get/get.dart';

import '../controllers/manage_students_controller.dart';

class ManageStudentsBinding extends Bindings {
  final String tagText;
  ManageStudentsBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<ManageStudentsController>(
      () => ManageStudentsController(tagText: tagText),
      tag: tagText,
      fenix: true,
    );
  }
}
