import 'package:get/get.dart';

import 'controller.dart';

/// 审核人管理页面绑定
class ImageModerationAdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ImageModerationAdminController>(
      () => ImageModerationAdminController(),
    );
  }
}
