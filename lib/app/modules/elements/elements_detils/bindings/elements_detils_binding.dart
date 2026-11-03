import 'package:get/get.dart';

import '../controllers/elements_detils_controller.dart';

class ElementsDetilsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ElementsDetilsController>(
      () => ElementsDetilsController(), 
    );
  }
}
