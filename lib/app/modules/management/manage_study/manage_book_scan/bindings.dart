import 'package:get/get.dart';

import 'controller.dart';

class ManageBookScanBinding extends Bindings {
  final String tag;
  ManageBookScanBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageBookScanController>(
      () => ManageBookScanController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
