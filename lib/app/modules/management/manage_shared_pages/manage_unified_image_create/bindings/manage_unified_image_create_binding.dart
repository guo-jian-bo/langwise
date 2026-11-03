import 'package:get/get.dart';

import '../controllers/manage_unified_image_create_controller.dart';

class ManageUnifiedImageCreateBinding extends Bindings {
  final String tag;
  ManageUnifiedImageCreateBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageUnifiedImageCreateController>(
      () => ManageUnifiedImageCreateController(tag: tag),
      tag: tag,
    );
  }
}
