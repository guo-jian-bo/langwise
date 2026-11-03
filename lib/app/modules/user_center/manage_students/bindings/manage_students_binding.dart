import 'package:get/get.dart';

import '../controllers/manage_students_controller.dart';

class ManageStudentsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ManageStudentsController>(
      () => ManageStudentsController(),
    );
  }
}
