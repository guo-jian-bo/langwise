import 'package:get/get.dart';

import '../controllers/web_page_controller.dart';

class WebPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WebPageController>(
      () => WebPageController(),
    );
  }
}
