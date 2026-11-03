import 'package:get/get.dart';

import 'controller.dart';

class SubListenBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SubListenController>(
      () => SubListenController(),
      fenix: true, 
    );
  }
}
