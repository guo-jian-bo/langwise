import 'package:get/get.dart';

import 'controller.dart';

class ImageModerationAdminDetailBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ImageModerationAdminDetailController>(() => ImageModerationAdminDetailController());
  }
}
