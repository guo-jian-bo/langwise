import 'package:get/get.dart';

import 'controller.dart';

class SubListenDetailsBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SubListenDetailsController>(() => SubListenDetailsController());
  }
}
