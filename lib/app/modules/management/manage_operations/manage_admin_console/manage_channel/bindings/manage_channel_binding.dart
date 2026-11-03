import 'package:get/get.dart';

import '../controllers/manage_channel_controller.dart';

class ManageChannelBinding extends Bindings {
  final String tag;
  ManageChannelBinding({required this.tag});

  @override
  void dependencies() {
    Get.lazyPut<ManageChannelController>(
      () => ManageChannelController(tag: tag),
      tag: tag,
    );
  }
}
