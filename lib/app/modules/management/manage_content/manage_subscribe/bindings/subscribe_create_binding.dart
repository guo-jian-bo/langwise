import 'package:get/get.dart';

import '../controllers/subscribe_create_controller.dart';

class SubscribeCreateBinding extends Bindings {
  final String tag;
  SubscribeCreateBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<SubscribeCreateController>(
      () => SubscribeCreateController(tag: tag),
      tag: tag,
    );
  }
}
