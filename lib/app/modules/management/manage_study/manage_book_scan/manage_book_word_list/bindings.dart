import 'package:get/get.dart';

import 'controller.dart';

class ManageBookWordListBinding extends Bindings {
  final String tag;
  ManageBookWordListBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageBookWordListController>(
      () => ManageBookWordListController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
