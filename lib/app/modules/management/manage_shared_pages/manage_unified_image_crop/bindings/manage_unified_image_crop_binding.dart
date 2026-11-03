import 'package:get/get.dart';

import '../controllers/manage_unified_image_crop_controller.dart';

class ManageUnifiedImageCropBinding extends Bindings {
  final String tag;
  ManageUnifiedImageCropBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageUnifiedImageCropController>(
      () => ManageUnifiedImageCropController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
