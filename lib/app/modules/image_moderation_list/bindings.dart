import 'package:get/get.dart';
import 'controller.dart';

class ImageModerationListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ImageModerationListController>(() => ImageModerationListController());
  }
}
