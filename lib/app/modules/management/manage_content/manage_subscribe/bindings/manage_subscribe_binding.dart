import 'package:get/get.dart';

import '../controllers/manage_subscribe_controller.dart';

class ManageSubscribeBinding extends Bindings {
  final String tag;
  ManageSubscribeBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageSubscribeController>(
      () => ManageSubscribeController(tag: tag),
      tag: tag,
      fenix: true,
    );
  }
}
