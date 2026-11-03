import 'package:get/get.dart';

import '../controllers/manage_check_image_controller.dart';

class ManageCheckImageBinding extends Bindings {
  final String tag;
  ManageCheckImageBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageCheckImageController>(
      () => ManageCheckImageController(tag: tag),
      tag: tag,
    );
  }
}
