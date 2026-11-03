import 'package:get/get.dart';

import 'controller.dart';

class UnitBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UnitController>(() => UnitController());
  }
}
