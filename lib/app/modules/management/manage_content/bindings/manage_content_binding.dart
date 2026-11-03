import 'package:get/get.dart';

import '../controllers/manage_content_controller.dart';

class ManageContentBinding extends Bindings {
  final String tag;
  ManageContentBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageContentController>(
      () => ManageContentController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
