import 'package:get/get.dart';

import '../controllers/select_learning_module_controller.dart';

class SelectLearningModuleBinding extends Bindings {
  final String tagText;
  SelectLearningModuleBinding({required this.tagText});

  @override
  void dependencies() {
    Get.lazyPut<SelectLearningModuleController>(
      () => SelectLearningModuleController(tagText: tagText),
      tag: tagText,
    );
  }
}
