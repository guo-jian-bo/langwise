import 'package:get/get.dart';

import '../controllers/select_learning_module_controller.dart';

class SelectLearningModuleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SelectLearningModuleController>(
      () => SelectLearningModuleController(),
    );
  }
}
