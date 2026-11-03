import 'package:get/get.dart';

import '../controllers/approved_images_confirm_controller.dart';

class ApprovedImagesConfirmBinding extends Bindings {
  final String tag;
  ApprovedImagesConfirmBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ApprovedImagesConfirmController>(
      () => ApprovedImagesConfirmController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
