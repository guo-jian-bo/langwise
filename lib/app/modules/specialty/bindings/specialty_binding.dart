import 'package:get/get.dart';

import '../controllers/specialty_controller.dart';

class SpecialtyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SpecialtyController>(
      () => SpecialtyController(),
      fenix: true, 
    );
  }
}
