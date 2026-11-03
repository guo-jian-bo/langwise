import 'package:get/get.dart';

import 'controller.dart';

class ImageModerationDetailBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ImageModerationDetailController>(() => ImageModerationDetailController());
  }
}
